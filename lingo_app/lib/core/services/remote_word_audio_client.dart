import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../utils/text_normalizer.dart';

/// A typed outcome for a static word-audio request.
enum RemoteWordAudioFailure {
  notConfigured,
  invalidUrl,
  notFound,
  timeout,
  invalidAudio,
  unavailable,
}

/// Error deliberately kept separate from provider/API errors so word playback
/// can give a useful, translated message without exposing network internals.
class RemoteWordAudioException implements Exception {
  final RemoteWordAudioFailure failure;
  final int? statusCode;

  const RemoteWordAudioException(this.failure, {this.statusCode});

  String get source => switch (failure) {
    RemoteWordAudioFailure.notConfigured => 'remote_not_configured',
    RemoteWordAudioFailure.invalidUrl => 'remote_invalid_url',
    RemoteWordAudioFailure.notFound => 'remote_not_found',
    RemoteWordAudioFailure.timeout => 'remote_timeout',
    RemoteWordAudioFailure.invalidAudio => 'remote_invalid_audio',
    RemoteWordAudioFailure.unavailable => 'remote_unavailable',
  };

  @override
  String toString() => switch (failure) {
    RemoteWordAudioFailure.notConfigured =>
      'Remote word-audio server is not configured',
    RemoteWordAudioFailure.invalidUrl =>
      'Remote word-audio server URL is invalid',
    RemoteWordAudioFailure.notFound => 'Remote word-audio file was not found',
    RemoteWordAudioFailure.timeout => 'Remote word-audio request timed out',
    RemoteWordAudioFailure.invalidAudio =>
      'Remote word-audio response is not a WAV file',
    RemoteWordAudioFailure.unavailable =>
      'Remote word-audio server is unavailable',
  };
}

class RemoteWordAudioResponse {
  final int statusCode;
  final Uint8List bytes;
  final String? contentType;

  const RemoteWordAudioResponse({
    required this.statusCode,
    required this.bytes,
    this.contentType,
  });
}

typedef RemoteWordAudioRequest =
    Future<RemoteWordAudioResponse> Function(Uri url);

/// A lightweight remote request used by the release screen to inspect whether
/// a published WAV can be reached. The default request asks only for the WAV
/// header with an HTTP range request, so checking a list does not download all
/// of its audio bytes when the static server supports ranges.
typedef RemoteWordAudioProbeRequest =
    Future<RemoteWordAudioResponse> Function(Uri url);

/// Fetches pre-generated Qwen word WAV files from the application's static
/// audio server. It never persists received bytes to disk.
class RemoteWordAudioClient {
  /// Bump this when a synthesis parameter that affects audible output changes.
  /// The new key prevents clients from accepting stale server audio.
  static const String audioKeyProfileVersion = 'qwen-word-wav-48k-british-v2';
  static const String wavMimeType = 'audio/wav';

  final String baseUrl;
  final RemoteWordAudioRequest _request;
  final RemoteWordAudioProbeRequest _probeRequest;

  factory RemoteWordAudioClient({
    required String baseUrl,
    Dio? dio,
    RemoteWordAudioRequest? request,
    RemoteWordAudioProbeRequest? probeRequest,
  }) {
    final normalizedBaseUrl = normalizeBaseUrl(baseUrl);
    final effectiveDio =
        dio ??
        Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 20),
          ),
        );
    return RemoteWordAudioClient._(
      baseUrl: normalizedBaseUrl,
      request: request ?? ((url) => _requestWithDio(effectiveDio, url)),
      probeRequest: probeRequest ?? ((url) => _probeWithDio(effectiveDio, url)),
    );
  }

  const RemoteWordAudioClient._({
    required this.baseUrl,
    required RemoteWordAudioRequest request,
    required RemoteWordAudioProbeRequest probeRequest,
  }) : _request = request,
       _probeRequest = probeRequest;

  /// Strips only a trailing slash. The configured path is intentional: during
  /// development it is normally `http://<Lighthouse-IP>/audio`.
  static String normalizeBaseUrl(String rawBaseUrl) {
    var normalized = rawBaseUrl.trim();
    if (normalized.isEmpty) {
      throw const RemoteWordAudioException(
        RemoteWordAudioFailure.notConfigured,
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
      throw const RemoteWordAudioException(RemoteWordAudioFailure.invalidUrl);
    }
    return uri.toString();
  }

  /// Normalisation is shared by local staging and remote playback, so
  /// `Extension` and `extension` always resolve to the same server file.
  static String normalizeWord(String text) =>
      TextNormalizer.normalizeQuotes(text).trim().toLowerCase();

  static String normalizeLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    if (!RegExp(r'^[a-z]{2,8}(?:-[a-z0-9]+)*$').hasMatch(normalized)) {
      throw const RemoteWordAudioException(RemoteWordAudioFailure.invalidUrl);
    }
    return normalized;
  }

  static String audioKeyFor(String text, {String language = 'en'}) {
    final normalizedWord = normalizeWord(text);
    final normalizedLanguage = normalizeLanguage(language);
    if (normalizedWord.isEmpty) {
      throw const RemoteWordAudioException(RemoteWordAudioFailure.invalidAudio);
    }
    return sha256
        .convert(
          utf8.encode(
            '$audioKeyProfileVersion\n$normalizedLanguage\n$normalizedWord',
          ),
        )
        .toString();
  }

  static String audioFileNameFor(String text, {String language = 'en'}) =>
      '${audioKeyFor(text, language: language)}.wav';

  Uri buildAudioUri(String text, {String language = 'en'}) {
    final normalizedLanguage = normalizeLanguage(language);
    final fileName = audioFileNameFor(text, language: normalizedLanguage);
    return Uri.parse('$baseUrl/v1/$normalizedLanguage/$fileName');
  }

  /// Returns `null` only when the exact static endpoint is reachable and
  /// begins with a WAV header. A non-null value gives the same typed reason
  /// that [fetch] would report, without retaining the response bytes.
  Future<RemoteWordAudioFailure?> probe(
    String text, {
    String language = 'en',
  }) async {
    final uri = buildAudioUri(text, language: language);
    try {
      final response = await _probeRequest(uri);
      if (response.statusCode == 404) {
        return RemoteWordAudioFailure.notFound;
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return RemoteWordAudioFailure.unavailable;
      }
      if (!isWav(response.bytes)) {
        return RemoteWordAudioFailure.invalidAudio;
      }
      return null;
    } on TimeoutException {
      return RemoteWordAudioFailure.timeout;
    } on DioException catch (error) {
      return _failureForDio(error);
    } catch (_) {
      return RemoteWordAudioFailure.unavailable;
    }
  }

  Future<Uint8List> fetch(String text, {String language = 'en'}) async {
    final uri = buildAudioUri(text, language: language);
    try {
      final response = await _request(uri);
      if (response.statusCode == 404) {
        throw const RemoteWordAudioException(RemoteWordAudioFailure.notFound);
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw RemoteWordAudioException(
          RemoteWordAudioFailure.unavailable,
          statusCode: response.statusCode,
        );
      }
      if (!isWav(response.bytes)) {
        throw const RemoteWordAudioException(
          RemoteWordAudioFailure.invalidAudio,
        );
      }
      return response.bytes;
    } on RemoteWordAudioException {
      rethrow;
    } on TimeoutException {
      throw const RemoteWordAudioException(RemoteWordAudioFailure.timeout);
    } on DioException catch (error) {
      throw RemoteWordAudioException(_failureForDio(error));
    } catch (_) {
      throw const RemoteWordAudioException(RemoteWordAudioFailure.unavailable);
    }
  }

  static bool isWav(Uint8List bytes) {
    return bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x41 &&
        bytes[10] == 0x56 &&
        bytes[11] == 0x45;
  }

  static Future<RemoteWordAudioResponse> _requestWithDio(
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
    return RemoteWordAudioResponse(
      statusCode: response.statusCode ?? 0,
      bytes: Uint8List.fromList(response.data ?? const []),
      contentType: response.headers.value('content-type'),
    );
  }

  static Future<RemoteWordAudioResponse> _probeWithDio(Dio dio, Uri url) async {
    final response = await dio.get<List<int>>(
      url.toString(),
      options: Options(
        responseType: ResponseType.bytes,
        headers: const {'Range': 'bytes=0-11'},
        validateStatus: (_) => true,
      ),
    );
    return RemoteWordAudioResponse(
      statusCode: response.statusCode ?? 0,
      bytes: Uint8List.fromList(response.data ?? const []),
      contentType: response.headers.value('content-type'),
    );
  }

  static RemoteWordAudioFailure _failureForDio(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => RemoteWordAudioFailure.timeout,
      _ => RemoteWordAudioFailure.unavailable,
    };
  }
}
