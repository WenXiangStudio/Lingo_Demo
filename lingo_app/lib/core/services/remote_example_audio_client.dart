import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../utils/text_normalizer.dart';

/// A typed outcome for a static Qwen3 example-audio request.
///
/// This intentionally does not share the word-audio error type: example
/// sentences have a separate cache profile and a separate server directory.
enum RemoteExampleAudioFailure {
  notConfigured,
  invalidUrl,
  notFound,
  timeout,
  invalidAudio,
  unavailable,
}

class RemoteExampleAudioException implements Exception {
  final RemoteExampleAudioFailure failure;
  final int? statusCode;

  const RemoteExampleAudioException(this.failure, {this.statusCode});

  String get source => switch (failure) {
    RemoteExampleAudioFailure.notConfigured => 'remote_example_not_configured',
    RemoteExampleAudioFailure.invalidUrl => 'remote_example_invalid_url',
    RemoteExampleAudioFailure.notFound => 'remote_example_not_found',
    RemoteExampleAudioFailure.timeout => 'remote_example_timeout',
    RemoteExampleAudioFailure.invalidAudio => 'remote_example_invalid_audio',
    RemoteExampleAudioFailure.unavailable => 'remote_example_unavailable',
  };

  @override
  String toString() => switch (failure) {
    RemoteExampleAudioFailure.notConfigured =>
      'Remote example-audio server is not configured',
    RemoteExampleAudioFailure.invalidUrl =>
      'Remote example-audio server URL is invalid',
    RemoteExampleAudioFailure.notFound =>
      'Remote example-audio file was not found',
    RemoteExampleAudioFailure.timeout =>
      'Remote example-audio request timed out',
    RemoteExampleAudioFailure.invalidAudio =>
      'Remote example-audio response is not a WAV file',
    RemoteExampleAudioFailure.unavailable =>
      'Remote example-audio server is unavailable',
  };
}

class RemoteExampleAudioResponse {
  final int statusCode;
  final Uint8List bytes;
  final String? contentType;

  const RemoteExampleAudioResponse({
    required this.statusCode,
    required this.bytes,
    this.contentType,
  });
}

typedef RemoteExampleAudioRequest =
    Future<RemoteExampleAudioResponse> Function(Uri url);

typedef RemoteExampleAudioProbeRequest =
    Future<RemoteExampleAudioResponse> Function(Uri url);

/// Immutable identity for one independently produced example-audio profile.
///
/// The profile version is part of every SHA-256 key and [fileNamePrefix] is
/// part of every server file name. That combination makes Qwen3 and Tencent
/// examples coexist in the same static `/examples/` directory without either
/// producer replacing the other's approved recordings.
class RemoteExampleAudioProfile {
  final String audioKeyProfileVersion;
  final List<String> compatibleAudioKeyProfileVersions;
  final String fileNamePrefix;

  /// Older immutable profiles that may already contain an approved recording
  /// for the same sentence.  This is intentionally separate from
  /// [compatibleAudioKeyProfileVersions], whose versions all use this
  /// profile's filename prefix.
  final List<RemoteExampleAudioProfile> fallbackProfiles;
  final bool preferFallbackProfiles;

  const RemoteExampleAudioProfile({
    required this.audioKeyProfileVersion,
    required this.compatibleAudioKeyProfileVersions,
    required this.fileNamePrefix,
    this.fallbackProfiles = const [],
    this.preferFallbackProfiles = false,
  });

  static const qwen3 = RemoteExampleAudioProfile(
    audioKeyProfileVersion:
        'qwen3-tts-flash-katerina-british-instruction-example-v2',
    compatibleAudioKeyProfileVersions: [
      'qwen3-tts-flash-katerina-british-instruction-example-v2',
      'qwen3-tts-flash-katerina-example-v1',
    ],
    fileNamePrefix: 'qwen3-example-',
  );

  static const tencentWeWinny = RemoteExampleAudioProfile(
    audioKeyProfileVersion:
        'tencent-text-to-voice-wewinny-501009-en-wav-24k-example-v1',
    compatibleAudioKeyProfileVersions: [
      'tencent-text-to-voice-wewinny-501009-en-wav-24k-example-v1',
    ],
    fileNamePrefix: 'tencent-wewinny-example-',
  );

  /// WeJack is the 101050 English premium voice.  Its 16 kHz files are a new
  /// immutable identity, while already-approved WeWinny files remain valid
  /// read-only fallbacks for the same sentence.  Keeping the fallback first
  /// avoids an extra 404 for the large existing WeWinny batch; newly generated
  /// files still always use the current WeJack identity.
  static const tencentWeJack = RemoteExampleAudioProfile(
    audioKeyProfileVersion:
        'tencent-text-to-voice-wejack-101050-en-wav-16k-example-v1',
    compatibleAudioKeyProfileVersions: [
      'tencent-text-to-voice-wejack-101050-en-wav-16k-example-v1',
    ],
    fileNamePrefix: 'tencent-wejack-example-',
    fallbackProfiles: [tencentWeWinny],
    preferFallbackProfiles: true,
  );

  Iterable<RemoteExampleAudioProfile> get readProfiles sync* {
    if (preferFallbackProfiles) {
      yield* fallbackProfiles;
      yield this;
    } else {
      yield this;
      yield* fallbackProfiles;
    }
  }

  String audioKeyFor(
    String text, {
    String language = 'en',
    String? profileVersion,
  }) {
    final normalizedText = RemoteExampleAudioClient.normalizeText(text);
    final normalizedLanguage = RemoteExampleAudioClient.normalizeLanguage(
      language,
    );
    if (normalizedText.isEmpty) {
      throw const RemoteExampleAudioException(
        RemoteExampleAudioFailure.invalidAudio,
      );
    }
    return sha256
        .convert(
          utf8.encode(
            '${profileVersion ?? audioKeyProfileVersion}\n'
            '$normalizedLanguage\n'
            '$normalizedText',
          ),
        )
        .toString();
  }

  String audioFileNameFor(
    String text, {
    String language = 'en',
    String? profileVersion,
  }) =>
      '$fileNamePrefix${audioKeyFor(text, language: language, profileVersion: profileVersion)}.wav';

  List<String> audioFileNamesFor(String text, {String language = 'en'}) => [
    for (final profile in readProfiles)
      for (final profileVersion in profile.compatibleAudioKeyProfileVersions)
        profile.audioFileNameFor(
          text,
          language: language,
          profileVersion: profileVersion,
        ),
  ];
}

/// Resolves static WAV files synthesized by an immutable example-sentence
/// profile. Qwen3 Flash / Katerina remains the default for backward
/// compatibility; Tencent WeWinny is selected explicitly by its release and
/// playback paths.
///
/// File keys include the exact normalized sentence, language and profile. A
/// sentence edit therefore creates a new immutable server object instead of
/// overwriting an already reviewed recording.
class RemoteExampleAudioClient {
  static const String audioKeyProfileVersion =
      'qwen3-tts-flash-katerina-british-instruction-example-v2';

  /// The profile used by the first Qwen3 example release (2026-08-05).
  ///
  /// The profile version is part of the immutable SHA-256 key, so changing
  /// [audioKeyProfileVersion] must not make an existing local cache silently
  /// disappear.  Keep the old version as a read-only compatibility candidate
  /// while all newly synthesized files continue to use the current profile.
  static const String legacyAudioKeyProfileVersion =
      'qwen3-tts-flash-katerina-example-v1';
  static const List<String> compatibleAudioKeyProfileVersions = <String>[
    audioKeyProfileVersion,
    legacyAudioKeyProfileVersion,
  ];
  static const String fileNamePrefix = 'qwen3-example-';
  static const String wavMimeType = 'audio/wav';
  static const RemoteExampleAudioProfile qwen3Profile =
      RemoteExampleAudioProfile.qwen3;
  static const RemoteExampleAudioProfile tencentWeWinnyProfile =
      RemoteExampleAudioProfile.tencentWeWinny;
  static const RemoteExampleAudioProfile tencentWeJackProfile =
      RemoteExampleAudioProfile.tencentWeJack;

  final String baseUrl;
  final RemoteExampleAudioProfile profile;
  final RemoteExampleAudioRequest _request;
  final RemoteExampleAudioProbeRequest _probeRequest;

  factory RemoteExampleAudioClient({
    required String baseUrl,
    RemoteExampleAudioProfile profile = RemoteExampleAudioProfile.qwen3,
    Dio? dio,
    RemoteExampleAudioRequest? request,
    RemoteExampleAudioProbeRequest? probeRequest,
  }) {
    final normalizedBaseUrl = normalizeBaseUrl(baseUrl);
    final effectiveDio =
        dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );
    return RemoteExampleAudioClient._(
      baseUrl: normalizedBaseUrl,
      profile: profile,
      request: request ?? ((url) => _requestWithDio(effectiveDio, url)),
      probeRequest: probeRequest ?? ((url) => _probeWithDio(effectiveDio, url)),
    );
  }

  factory RemoteExampleAudioClient.tencentWeWinny({
    required String baseUrl,
    Dio? dio,
    RemoteExampleAudioRequest? request,
    RemoteExampleAudioProbeRequest? probeRequest,
  }) => RemoteExampleAudioClient(
    baseUrl: baseUrl,
    profile: RemoteExampleAudioProfile.tencentWeWinny,
    dio: dio,
    request: request,
    probeRequest: probeRequest,
  );

  factory RemoteExampleAudioClient.tencentWeJack({
    required String baseUrl,
    Dio? dio,
    RemoteExampleAudioRequest? request,
    RemoteExampleAudioProbeRequest? probeRequest,
  }) => RemoteExampleAudioClient(
    baseUrl: baseUrl,
    profile: RemoteExampleAudioProfile.tencentWeJack,
    dio: dio,
    request: request,
    probeRequest: probeRequest,
  );

  const RemoteExampleAudioClient._({
    required this.baseUrl,
    required this.profile,
    required RemoteExampleAudioRequest request,
    required RemoteExampleAudioProbeRequest probeRequest,
  }) : _request = request,
       _probeRequest = probeRequest;

  /// The configured path is intentional: in development it is normally
  /// `http://<Lighthouse-IP>/audio`.
  static String normalizeBaseUrl(String rawBaseUrl) {
    var normalized = rawBaseUrl.trim();
    if (normalized.isEmpty) {
      throw const RemoteExampleAudioException(
        RemoteExampleAudioFailure.notConfigured,
      );
    }
    while (normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw const RemoteExampleAudioException(
        RemoteExampleAudioFailure.invalidUrl,
      );
    }
    return uri.toString();
  }

  /// Preserve sentence case and punctuation because they can change Qwen3's
  /// prosody. Quotes and whitespace are normalized so CSV/import formatting
  /// differences do not produce duplicate recordings.
  static String normalizeText(String text) => TextNormalizer.normalizeQuotes(
    text,
  ).trim().replaceAll(RegExp(r'\s+'), ' ');

  static String normalizeLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]+)*$').hasMatch(normalized)) {
      throw const RemoteExampleAudioException(
        RemoteExampleAudioFailure.invalidUrl,
      );
    }
    return normalized;
  }

  static String audioKeyFor(
    String text, {
    String language = 'en',
    String? profileVersion,
  }) {
    return audioKeyForProfile(
      text,
      language: language,
      profileVersion: profileVersion ?? audioKeyProfileVersion,
    );
  }

  static String audioKeyForProfile(
    String text, {
    String language = 'en',
    required String profileVersion,
  }) => qwen3Profile.audioKeyFor(
    text,
    language: language,
    profileVersion: profileVersion,
  );

  static String audioFileNameFor(
    String text, {
    String language = 'en',
    String? profileVersion,
  }) => qwen3Profile.audioFileNameFor(
    text,
    language: language,
    profileVersion: profileVersion,
  );

  /// Returns the current key first, followed by immutable keys from profiles
  /// that were shipped previously and are still safe to reuse locally.
  static List<String> audioFileNamesFor(
    String text, {
    String language = 'en',
  }) => qwen3Profile.audioFileNamesFor(text, language: language);

  Uri buildAudioUri(String text, {String language = 'en'}) {
    return buildAudioUriForProfile(
      text,
      language: language,
      profileVersion: profile.audioKeyProfileVersion,
    );
  }

  Uri buildAudioUriForProfile(
    String text, {
    String language = 'en',
    required String profileVersion,
  }) {
    final normalizedLanguage = normalizeLanguage(language);
    final fileName = profile.audioFileNameFor(
      text,
      language: normalizedLanguage,
      profileVersion: profileVersion,
    );
    return Uri.parse('$baseUrl/v1/$normalizedLanguage/examples/$fileName');
  }

  Future<RemoteExampleAudioFailure?> probe(
    String text, {
    String language = 'en',
  }) async {
    RemoteExampleAudioFailure? uncertainFailure;
    for (final candidate in profile.readProfiles) {
      for (final profileVersion
          in candidate.compatibleAudioKeyProfileVersions) {
        final uri = _buildAudioUriForCandidate(
          text,
          language: language,
          candidate: candidate,
          profileVersion: profileVersion,
        );
        try {
          final response = await _probeRequest(uri);
          if (response.statusCode == 404) continue;
          if (response.statusCode < 200 || response.statusCode >= 300) {
            uncertainFailure ??= RemoteExampleAudioFailure.unavailable;
            continue;
          }
          if (!isWav(response.bytes)) {
            uncertainFailure ??= RemoteExampleAudioFailure.invalidAudio;
            continue;
          }
          return null;
        } on TimeoutException {
          uncertainFailure ??= RemoteExampleAudioFailure.timeout;
        } on DioException catch (error) {
          uncertainFailure ??= _failureForDio(error);
        } catch (_) {
          uncertainFailure ??= RemoteExampleAudioFailure.unavailable;
        }
      }
    }
    return uncertainFailure ?? RemoteExampleAudioFailure.notFound;
  }

  Future<Uint8List> fetch(String text, {String language = 'en'}) async {
    RemoteExampleAudioFailure? uncertainFailure;
    int? uncertainStatusCode;
    for (final candidate in profile.readProfiles) {
      for (final profileVersion
          in candidate.compatibleAudioKeyProfileVersions) {
        final uri = _buildAudioUriForCandidate(
          text,
          language: language,
          candidate: candidate,
          profileVersion: profileVersion,
        );
        try {
          final response = await _request(uri);
          if (response.statusCode == 404) continue;
          if (response.statusCode < 200 || response.statusCode >= 300) {
            uncertainFailure ??= RemoteExampleAudioFailure.unavailable;
            uncertainStatusCode ??= response.statusCode;
            continue;
          }
          if (!isWav(response.bytes)) {
            uncertainFailure ??= RemoteExampleAudioFailure.invalidAudio;
            continue;
          }
          return response.bytes;
        } on TimeoutException {
          uncertainFailure ??= RemoteExampleAudioFailure.timeout;
        } on DioException catch (error) {
          uncertainFailure ??= _failureForDio(error);
        } catch (_) {
          uncertainFailure ??= RemoteExampleAudioFailure.unavailable;
        }
      }
    }
    throw RemoteExampleAudioException(
      uncertainFailure ?? RemoteExampleAudioFailure.notFound,
      statusCode: uncertainStatusCode,
    );
  }

  Uri _buildAudioUriForCandidate(
    String text, {
    required String language,
    required RemoteExampleAudioProfile candidate,
    required String profileVersion,
  }) {
    final normalizedLanguage = normalizeLanguage(language);
    final fileName = candidate.audioFileNameFor(
      text,
      language: normalizedLanguage,
      profileVersion: profileVersion,
    );
    return Uri.parse('$baseUrl/v1/$normalizedLanguage/examples/$fileName');
  }

  static bool isWav(Uint8List bytes) =>
      bytes.length >= 12 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x41 &&
      bytes[10] == 0x56 &&
      bytes[11] == 0x45;

  static Future<RemoteExampleAudioResponse> _requestWithDio(
    Dio dio,
    Uri url,
  ) async {
    final response = await dio.get<List<int>>(
      url.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (_) => true,
      ),
    );
    return RemoteExampleAudioResponse(
      statusCode: response.statusCode ?? 0,
      bytes: Uint8List.fromList(response.data ?? const []),
      contentType: response.headers.value('content-type'),
    );
  }

  static Future<RemoteExampleAudioResponse> _probeWithDio(
    Dio dio,
    Uri url,
  ) async {
    final response = await dio.get<List<int>>(
      url.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        headers: const {'Range': 'bytes=0-11'},
        validateStatus: (_) => true,
      ),
    );
    return RemoteExampleAudioResponse(
      statusCode: response.statusCode ?? 0,
      bytes: Uint8List.fromList(response.data ?? const []),
      contentType: response.headers.value('content-type'),
    );
  }

  static RemoteExampleAudioFailure _failureForDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => RemoteExampleAudioFailure.timeout,
      _ => RemoteExampleAudioFailure.unavailable,
    };
  }
}
