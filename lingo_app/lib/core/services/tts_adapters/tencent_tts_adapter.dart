import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../tts_provider.dart';

enum TencentWeWinnyAudioValidationFailure {
  invalidWav,
  unexpectedFormat,
  tooShort,
  silent,
}

/// A fixed 24 kHz WeWinny WAV must be valid before a batch release can use
/// it. Keeping this distinct from the Qwen3 validator means the two reviewed
/// production profiles cannot accidentally share cache or package rules.
class TencentWeWinnyAudioValidationException implements Exception {
  final TencentWeWinnyAudioValidationFailure failure;

  const TencentWeWinnyAudioValidationException(this.failure);

  @override
  String toString() => 'tencent_wewinny_audio_${failure.name}';
}

/// A Tencent Cloud error with metadata that is safe to persist in the local
/// TTS usage history. It deliberately never stores request headers, the
/// secret key, or a request signature.
class TencentTtsException implements Exception {
  final String code;
  final String message;
  final String? requestId;
  final int? statusCode;
  final bool isRetryable;

  const TencentTtsException({
    required this.code,
    required this.message,
    this.requestId,
    this.statusCode,
    required this.isRetryable,
  });

  @override
  String toString() {
    final status = statusCode == null ? '' : ' HTTP $statusCode';
    final request = requestId == null || requestId!.isEmpty
        ? ''
        : ' (request $requestId)';
    return 'Tencent TTS$status $code: $message$request';
  }
}

/// An inspectable TC3 signing result used by the offline adapter tests.
///
/// [authorization] contains the SecretId but never the SecretKey. Callers
/// must still avoid putting it in user-visible diagnostics.
class TencentTc3Authorization {
  final String authorization;
  final String canonicalRequest;
  final String stringToSign;
  final String credentialScope;
  final String signedHeaders;

  const TencentTc3Authorization({
    required this.authorization,
    required this.canonicalRequest,
    required this.stringToSign,
    required this.credentialScope,
    required this.signedHeaders,
  });
}

/// Direct HTTPS implementation of Tencent Cloud TTS's TC3-HMAC-SHA256 API.
///
/// This is intentionally not a general settings-screen TTS provider. The
/// WeWinny production release path gets credentials only from the process
/// environment, so SecretId and SecretKey never enter app settings, release
/// reports, cache records, or generated source files.
class TencentTtsAdapter implements MeteredTtsProvider {
  static const String weWinnyProviderId = 'tencent_wewinny';
  static const String weJackProviderId = 'tencent_wejack';
  static const String service = 'tts';
  static const String action = 'TextToVoice';
  static const String apiVersion = '2019-08-23';
  static const String defaultRegion = 'ap-guangzhou';
  static const String defaultEndpoint = 'https://tts.tencentcloudapi.com/';
  static const String secretIdEnvironmentKey = 'TENCENTCLOUD_SECRET_ID';
  static const String secretKeyEnvironmentKey = 'TENCENTCLOUD_SECRET_KEY';

  static const int weWinnyVoiceType = 501009;
  static const int weJackVoiceType = 101050;
  static const int weWinnyModelType = 1;
  static const int englishPrimaryLanguage = 2;
  static const int weWinnySampleRate = 24000;
  static const int weJackSampleRate = 16000;
  static const String weWinnyCodec = 'wav';
  static const String audioMimeType = 'audio/wav';
  static const String cacheFileExtension = 'wav';
  static const Duration minimumExampleAudioDuration = Duration(
    milliseconds: 250,
  );
  static const int _minimumAudiblePcmSample = 64;
  static const String _contentType = 'application/json; charset=utf-8';

  static final Random _random = Random.secure();
  static int _sessionSequence = 0;

  final String _secretId;
  final String _secretKey;
  final Uri _endpoint;
  final String _region;
  final int _voiceType;
  final int _sampleRate;
  final Dio _dio;
  final DateTime Function() _clock;
  final String Function() _sessionIdFactory;

  TencentTtsAdapter({
    required String secretId,
    required String secretKey,
    String endpoint = defaultEndpoint,
    String region = defaultRegion,
    int voiceType = weWinnyVoiceType,
    int sampleRate = weWinnySampleRate,
    Dio? dio,
    DateTime Function()? clock,
    String Function()? sessionIdFactory,
  }) : _secretId = secretId.trim(),
       _secretKey = secretKey.trim(),
       _endpoint = _parseEndpoint(endpoint),
       _region = region.trim(),
       _voiceType = voiceType,
       _sampleRate = sampleRate,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               connectTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 180),
             ),
           ),
       _clock = clock ?? DateTime.now,
       _sessionIdFactory = sessionIdFactory ?? _newSessionId {
    if (_secretId.isEmpty || _secretKey.isEmpty) {
      throw const TencentTtsException(
        code: 'CredentialsNotConfigured',
        message:
            'Set TENCENTCLOUD_SECRET_ID and TENCENTCLOUD_SECRET_KEY before using Tencent TTS.',
        isRetryable: false,
      );
    }
    if (_region.isEmpty) {
      throw const TencentTtsException(
        code: 'InvalidRegion',
        message: 'Tencent TTS region is required.',
        isRetryable: false,
      );
    }
  }

  factory TencentTtsAdapter.fromEnvironment({
    Map<String, String>? environment,
    String endpoint = defaultEndpoint,
    String region = defaultRegion,
    int voiceType = weWinnyVoiceType,
    int sampleRate = weWinnySampleRate,
    Dio? dio,
    DateTime Function()? clock,
    String Function()? sessionIdFactory,
  }) {
    final values = environment ?? Platform.environment;
    return TencentTtsAdapter(
      secretId: values[secretIdEnvironmentKey] ?? '',
      secretKey: values[secretKeyEnvironmentKey] ?? '',
      endpoint: endpoint,
      region: region,
      voiceType: voiceType,
      sampleRate: sampleRate,
      dio: dio,
      clock: clock,
      sessionIdFactory: sessionIdFactory,
    );
  }

  static bool hasEnvironmentCredentials([Map<String, String>? environment]) {
    final values = environment ?? Platform.environment;
    return (values[secretIdEnvironmentKey] ?? '').trim().isNotEmpty &&
        (values[secretKeyEnvironmentKey] ?? '').trim().isNotEmpty;
  }

  static Map<String, bool> environmentCredentialPresence([
    Map<String, String>? environment,
  ]) {
    final values = environment ?? Platform.environment;
    return {
      secretIdEnvironmentKey: (values[secretIdEnvironmentKey] ?? '')
          .trim()
          .isNotEmpty,
      secretKeyEnvironmentKey: (values[secretKeyEnvironmentKey] ?? '')
          .trim()
          .isNotEmpty,
    };
  }

  @override
  String get providerName => _voiceType == weJackVoiceType
      ? 'Tencent Cloud TTS (WeJack)'
      : 'Tencent Cloud TTS (WeWinny)';

  /// Builds the immutable WeWinny request profile. The selected large-model
  /// voice only supports this production path, not a user-editable voice form.
  static Map<String, dynamic> buildPayload({
    required String text,
    required String sessionId,
    int voiceType = weWinnyVoiceType,
    int sampleRate = weWinnySampleRate,
  }) {
    return {
      'Text': text,
      'SessionId': sessionId,
      'ModelType': weWinnyModelType,
      'VoiceType': voiceType,
      'PrimaryLanguage': englishPrimaryLanguage,
      'SampleRate': sampleRate,
      'Codec': weWinnyCodec,
      'Volume': 0,
      'Speed': 0,
    };
  }

  /// Produces the TC3 signature over exactly [payload], which must be sent
  /// unchanged in the subsequent HTTP request.
  static TencentTc3Authorization buildTc3Authorization({
    required String secretId,
    required String secretKey,
    required Uri endpoint,
    required int timestampSeconds,
    required String payload,
    String requestAction = action,
  }) {
    final date = _utcDateForTimestamp(timestampSeconds);
    final host = _hostForEndpoint(endpoint).toLowerCase();
    final canonicalHeaderValues = <String, String>{
      'content-type': _contentType,
      'host': host,
      'x-tc-action': requestAction.trim().toLowerCase(),
    };
    final headerNames = canonicalHeaderValues.keys.toList()..sort();
    final canonicalHeaders = StringBuffer();
    for (final name in headerNames) {
      canonicalHeaders.write(
        '$name:${_canonicalHeaderValue(canonicalHeaderValues[name]!)}\n',
      );
    }
    final signedHeaders = headerNames.join(';');
    final canonicalUri = endpoint.path.isEmpty ? '/' : endpoint.path;
    final canonicalRequest = [
      'POST',
      canonicalUri,
      endpoint.query,
      canonicalHeaders.toString(),
      signedHeaders,
      sha256.convert(utf8.encode(payload)).toString(),
    ].join('\n');
    final credentialScope = '$date/$service/tc3_request';
    final stringToSign = [
      'TC3-HMAC-SHA256',
      timestampSeconds.toString(),
      credentialScope,
      sha256.convert(utf8.encode(canonicalRequest)).toString(),
    ].join('\n');
    final secretDate = _hmacSha256(utf8.encode('TC3${secretKey.trim()}'), date);
    final secretService = _hmacSha256(secretDate, service);
    final secretSigning = _hmacSha256(secretService, 'tc3_request');
    final signature = Hmac(
      sha256,
      secretSigning,
    ).convert(utf8.encode(stringToSign)).toString();
    final authorization =
        'TC3-HMAC-SHA256 Credential=${secretId.trim()}/$credentialScope, '
        'SignedHeaders=$signedHeaders, Signature=$signature';
    return TencentTc3Authorization(
      authorization: authorization,
      canonicalRequest: canonicalRequest,
      stringToSign: stringToSign,
      credentialScope: credentialScope,
      signedHeaders: signedHeaders,
    );
  }

  @override
  Future<Uint8List> synthesize(String text, {String language = 'en'}) async {
    return (await synthesizeWithMetadata(text, language: language)).audioBytes;
  }

  @override
  Future<TtsSynthesisResult> synthesizeWithMetadata(
    String text, {
    String language = 'en',
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) {
      throw const TencentTtsException(
        code: 'InvalidText',
        message: 'Tencent TTS text is empty.',
        isRetryable: false,
      );
    }
    if (!_isEnglishLanguage(language)) {
      throw const TencentTtsException(
        code: 'InvalidLanguage',
        message:
            'The WeWinny release profile is limited to English example sentences.',
        isRetryable: false,
      );
    }

    final sessionId = _sessionIdFactory().trim();
    if (sessionId.isEmpty || sessionId.length > 128) {
      throw const TencentTtsException(
        code: 'InvalidSessionId',
        message: 'Tencent TTS SessionId must contain 1 to 128 characters.',
        isRetryable: false,
      );
    }
    final timestampSeconds = _clock().toUtc().millisecondsSinceEpoch ~/ 1000;
    final payload = jsonEncode(
      buildPayload(
        text: normalizedText,
        sessionId: sessionId,
        voiceType: _voiceType,
        sampleRate: _sampleRate,
      ),
    );
    final signature = buildTc3Authorization(
      secretId: _secretId,
      secretKey: _secretKey,
      endpoint: _endpoint,
      timestampSeconds: timestampSeconds,
      payload: payload,
    );
    final stopwatch = Stopwatch()..start();

    try {
      final response = await _dio.postUri<dynamic>(
        _endpoint,
        data: payload,
        options: Options(
          contentType: _contentType,
          responseType: ResponseType.json,
          validateStatus: (_) => true,
          headers: {
            'Authorization': signature.authorization,
            'Content-Type': _contentType,
            'Host': _hostForEndpoint(_endpoint),
            'X-TC-Action': action,
            'X-TC-Version': apiVersion,
            'X-TC-Timestamp': timestampSeconds.toString(),
            'X-TC-Region': _region,
          },
        ),
      );
      stopwatch.stop();
      final body = _responseMap(response.data);
      final responseBody = _responseMap(body?['Response']);
      final requestId = responseBody?['RequestId']?.toString();
      final apiError = _responseMap(responseBody?['Error']);
      if (apiError != null) {
        throw _apiException(
          apiError,
          requestId: requestId,
          statusCode: response.statusCode,
        );
      }
      final statusCode = response.statusCode;
      if (statusCode == null || statusCode < 200 || statusCode >= 300) {
        throw TencentTtsException(
          code: 'HttpStatus',
          message: 'Tencent TTS returned HTTP ${statusCode ?? 'unknown'}.',
          requestId: requestId,
          statusCode: statusCode,
          isRetryable: _isRetryableHttpStatus(statusCode),
        );
      }
      final audioValue = responseBody?['Audio'];
      if (audioValue is! String || audioValue.trim().isEmpty) {
        throw TencentTtsException(
          code: 'InvalidResponse',
          message: 'Tencent TTS response did not contain Base64 WAV audio.',
          requestId: requestId,
          statusCode: statusCode,
          isRetryable: false,
        );
      }
      final audioBytes = _decodeAudio(audioValue, requestId: requestId);
      final validationFailure = audioValidationFailure(
        audioBytes,
        expectedSampleRate: _sampleRate,
      );
      if (validationFailure != null) {
        throw TencentWeWinnyAudioValidationException(validationFailure);
      }
      return TtsSynthesisResult(
        audioBytes: audioBytes,
        requestId: requestId,
        durationMs: stopwatch.elapsedMilliseconds,
      );
    } on TencentTtsException {
      stopwatch.stop();
      rethrow;
    } on TencentWeWinnyAudioValidationException {
      stopwatch.stop();
      rethrow;
    } on DioException catch (error) {
      stopwatch.stop();
      throw _dioException(error);
    } on FormatException {
      stopwatch.stop();
      throw const TencentTtsException(
        code: 'InvalidResponse',
        message: 'Tencent TTS response was not valid JSON.',
        isRetryable: false,
      );
    }
  }

  /// Validates the PCM WAV profile returned by the selected Tencent voice.
  static TencentWeWinnyAudioValidationFailure? weWinnyAudioValidationFailure(
    Uint8List audioBytes,
  ) =>
      audioValidationFailure(audioBytes, expectedSampleRate: weWinnySampleRate);

  static TencentWeWinnyAudioValidationFailure? audioValidationFailure(
    Uint8List audioBytes, {
    required int expectedSampleRate,
  }) {
    if (audioBytes.length < 12 ||
        audioBytes[0] != 0x52 ||
        audioBytes[1] != 0x49 ||
        audioBytes[2] != 0x46 ||
        audioBytes[3] != 0x46 ||
        audioBytes[8] != 0x57 ||
        audioBytes[9] != 0x41 ||
        audioBytes[10] != 0x56 ||
        audioBytes[11] != 0x45) {
      return TencentWeWinnyAudioValidationFailure.invalidWav;
    }

    final data = ByteData.sublistView(audioBytes);
    var offset = 12;
    int? audioFormat;
    int? channels;
    int? sampleRate;
    int? byteRate;
    int? blockAlign;
    int? bitsPerSample;
    int? audioDataOffset;
    int? audioDataLength;

    while (offset + 8 <= audioBytes.length) {
      final chunkSize = data.getUint32(offset + 4, Endian.little);
      final chunkDataOffset = offset + 8;
      final availableChunkBytes = audioBytes.length - chunkDataOffset;
      final isFmt =
          audioBytes[offset] == 0x66 &&
          audioBytes[offset + 1] == 0x6d &&
          audioBytes[offset + 2] == 0x74 &&
          audioBytes[offset + 3] == 0x20;
      final isData =
          audioBytes[offset] == 0x64 &&
          audioBytes[offset + 1] == 0x61 &&
          audioBytes[offset + 2] == 0x74 &&
          audioBytes[offset + 3] == 0x61;

      if (isFmt) {
        if (chunkSize > availableChunkBytes || chunkSize < 16) {
          return TencentWeWinnyAudioValidationFailure.invalidWav;
        }
        audioFormat = data.getUint16(chunkDataOffset, Endian.little);
        channels = data.getUint16(chunkDataOffset + 2, Endian.little);
        sampleRate = data.getUint32(chunkDataOffset + 4, Endian.little);
        byteRate = data.getUint32(chunkDataOffset + 8, Endian.little);
        blockAlign = data.getUint16(chunkDataOffset + 12, Endian.little);
        bitsPerSample = data.getUint16(chunkDataOffset + 14, Endian.little);
      } else if (isData) {
        audioDataOffset = chunkDataOffset;
        audioDataLength = chunkSize > availableChunkBytes
            ? availableChunkBytes
            : chunkSize;
        break;
      } else if (chunkSize > availableChunkBytes) {
        return TencentWeWinnyAudioValidationFailure.invalidWav;
      }

      offset = chunkDataOffset + chunkSize + (chunkSize.isOdd ? 1 : 0);
    }

    if (audioFormat == null ||
        channels == null ||
        sampleRate == null ||
        byteRate == null ||
        blockAlign == null ||
        bitsPerSample == null ||
        audioDataOffset == null ||
        audioDataLength == null) {
      return TencentWeWinnyAudioValidationFailure.invalidWav;
    }

    const expectedAudioFormat = 1;
    const expectedChannels = 1;
    const expectedBitsPerSample = 16;
    const expectedBlockAlign = expectedChannels * expectedBitsPerSample ~/ 8;
    final expectedByteRate = expectedSampleRate * expectedBlockAlign;
    if (audioFormat != expectedAudioFormat ||
        channels != expectedChannels ||
        sampleRate != expectedSampleRate ||
        bitsPerSample != expectedBitsPerSample ||
        blockAlign != expectedBlockAlign ||
        byteRate != expectedByteRate ||
        audioDataLength % expectedBlockAlign != 0) {
      return TencentWeWinnyAudioValidationFailure.unexpectedFormat;
    }

    final minimumBytes =
        expectedByteRate * minimumExampleAudioDuration.inMilliseconds ~/ 1000;
    if (audioDataLength < minimumBytes) {
      return TencentWeWinnyAudioValidationFailure.tooShort;
    }

    final audioDataEnd = audioDataOffset + audioDataLength;
    for (
      var sampleOffset = audioDataOffset;
      sampleOffset + 1 < audioDataEnd;
      sampleOffset += 2
    ) {
      final sample = data.getInt16(sampleOffset, Endian.little);
      if (sample.abs() >= _minimumAudiblePcmSample) return null;
    }
    return TencentWeWinnyAudioValidationFailure.silent;
  }

  static Uri _parseEndpoint(String rawEndpoint) {
    final uri = Uri.tryParse(rawEndpoint.trim());
    if (uri == null ||
        (uri.scheme != 'https' && uri.scheme != 'http') ||
        uri.host.isEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        uri.userInfo.isNotEmpty) {
      throw const TencentTtsException(
        code: 'InvalidEndpoint',
        message:
            'Tencent TTS endpoint must be an absolute HTTP(S) URL without a query.',
        isRetryable: false,
      );
    }
    return uri;
  }

  static String _newSessionId() {
    _sessionSequence = (_sessionSequence + 1) & 0x7fffffff;
    final randomPart = _random.nextInt(0x7fffffff).toRadixString(16);
    return 'lingo-${DateTime.now().microsecondsSinceEpoch}-$_sessionSequence-$randomPart';
  }

  static bool _isEnglishLanguage(String language) {
    final normalized = language.trim().toLowerCase();
    return normalized == 'en' || normalized == 'en-us' || normalized == 'en-gb';
  }

  static String _utcDateForTimestamp(int timestampSeconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      timestampSeconds * 1000,
      isUtc: true,
    );
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  static String _hostForEndpoint(Uri endpoint) {
    final defaultPort =
        (endpoint.scheme == 'https' && endpoint.port == 443) ||
        (endpoint.scheme == 'http' && endpoint.port == 80);
    return defaultPort ? endpoint.host : '${endpoint.host}:${endpoint.port}';
  }

  static String _canonicalHeaderValue(String value) =>
      value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

  static List<int> _hmacSha256(List<int> key, String value) =>
      Hmac(sha256, key).convert(utf8.encode(value)).bytes;

  static Map<String, dynamic>? _responseMap(Object? value) {
    if (value is! Map) return null;
    return {
      for (final entry in value.entries) entry.key.toString(): entry.value,
    };
  }

  static Uint8List _decodeAudio(String rawAudio, {String? requestId}) {
    try {
      return Uint8List.fromList(base64Decode(rawAudio.trim()));
    } on FormatException {
      throw TencentTtsException(
        code: 'InvalidResponse',
        message: 'Tencent TTS Audio is not valid Base64.',
        requestId: requestId,
        isRetryable: false,
      );
    }
  }

  static TencentTtsException _apiException(
    Map<String, dynamic> error, {
    String? requestId,
    int? statusCode,
  }) {
    final code = error['Code']?.toString().trim();
    final message = error['Message']?.toString().trim();
    final effectiveCode = code == null || code.isEmpty ? 'ApiError' : code;
    return TencentTtsException(
      code: effectiveCode,
      message: message == null || message.isEmpty
          ? 'Tencent TTS rejected the request.'
          : message,
      requestId: requestId,
      statusCode: statusCode,
      isRetryable: _isRetryableApiCode(effectiveCode),
    );
  }

  static TencentTtsException _dioException(DioException error) {
    final statusCode = error.response?.statusCode;
    final body = _responseMap(error.response?.data);
    final response = _responseMap(body?['Response']);
    final apiError = _responseMap(response?['Error']);
    if (apiError != null) {
      return _apiException(
        apiError,
        requestId: response?['RequestId']?.toString(),
        statusCode: statusCode,
      );
    }
    final retryable = switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError => true,
      _ => _isRetryableHttpStatus(statusCode),
    };
    return TencentTtsException(
      code: 'NetworkError',
      message: error.message ?? 'Tencent TTS network request failed.',
      statusCode: statusCode,
      isRetryable: retryable,
    );
  }

  static bool _isRetryableHttpStatus(int? statusCode) =>
      statusCode == 408 ||
      statusCode == 429 ||
      (statusCode != null && statusCode >= 500);

  static bool _isRetryableApiCode(String code) {
    final normalized = code.toLowerCase();
    if (normalized.startsWith('authfailure') ||
        normalized.startsWith('invalidparameter') ||
        normalized.startsWith('missingparameter') ||
        normalized.startsWith('unsupportedoperation') ||
        normalized.startsWith('resourcenotfound') ||
        normalized.contains('quota') ||
        normalized.contains('insufficient')) {
      return false;
    }
    return normalized.startsWith('internalerror') ||
        normalized.startsWith('requestlimitexceeded') ||
        normalized.startsWith('serviceunavailable') ||
        normalized.startsWith('requesttimeout');
  }
}
