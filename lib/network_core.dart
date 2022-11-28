import 'package:azure_application_insights/azure_application_insights.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class Dioo {

  static Dio _dio = Dio(BaseOptions(connectTimeout: 0, receiveTimeout: 0));

  static post<T>(
    String path, {
    data,
    Map<String, Object>? queryParameters,
    Map<String, Object>? propertiesToLog,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
    TelemetryClient? telemetryClient,
  }) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();

    try {
      var response = await _dio.post(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);

      _sendTelemetry(response, null, "POST", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      return response;
    } on DioError catch (error) {
      _sendErrorTelemetry(error, 0, "POST", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      throw Future.error(error);
    }
  }

  static _sendTelemetry<T>(Response response, dynamic contentLength, String method, DateTime timestamp, String path,
      Map<String, Object>? queryParameters, Map<String, Object>? propertiesToLog, Stopwatch stopwatch, TelemetryClient? telemetryClient) {
    stopwatch.stop();
    if(telemetryClient == null) {
      return;
    }
    var additionalProperties = <String, Object>{
      'method': method,
      // 'headers': request.headers.entries.map((e) => '${e.key}=${e.value}').join(','),
      if (contentLength != null) 'contentLength': contentLength,
      if (kDebugMode) 'debugMode': 'true'
    };

    if (queryParameters != null) {
      additionalProperties.addAll(queryParameters);
    }
    if (propertiesToLog != null) {
      additionalProperties.addAll(propertiesToLog);
    }

    telemetryClient.trackRequest(
      id: const Uuid().v1(),
      url: path,
      duration: stopwatch.elapsed,
      responseCode: response.statusCode.toString(),
      success: response.statusCode! >= 200 && response.statusCode! < 300,
      additionalProperties: additionalProperties,
      timestamp: timestamp,
    );
    return response;
  }

  static _sendErrorTelemetry(DioError error, contentLength, String method, DateTime timestamp, String path,
      Map<String, Object>? queryParameters, Map<String, Object>? propertiesToLog, Stopwatch stopwatch,
      TelemetryClient? telemetryClient) {
    stopwatch.stop();
    if(telemetryClient == null) {
      return;
    }
    var response = error.response;
    var additionalProperties = <String, Object>{
      'method': method,
      if (response?.statusMessage != null) 'errorMessage': error.message,
      // 'headers': request.headers.entries.map((e) => '${e.key}=${e.value}').join(','),
      if (contentLength != null) 'contentLength': contentLength,
      if (kDebugMode) 'debugMode': 'true'
    };

    if (queryParameters != null) {
      additionalProperties.addAll(queryParameters);
    }
    if (propertiesToLog != null) {
      additionalProperties.addAll(propertiesToLog);
    }

    telemetryClient.trackRequest(
      id: const Uuid().v1(),
      url: path,
      duration: stopwatch.elapsed,
      responseCode: (response?.statusCode?.toString() ?? ""),
      success: false,
      additionalProperties: additionalProperties,
      timestamp: timestamp,
    );
    throw error;
  }

  static void _sendGeneralErrorTelemetry(Exception error, DateTime timestamp, Stopwatch stopwatch, telemetryClient) {
    stopwatch.stop();

    var additionalProperties = <String, Object>{if (kDebugMode) 'debugMode': 'true'};

    telemetryClient.trackError(
      severity: Severity.error,
      error: error,
      additionalProperties: additionalProperties,
      timestamp: timestamp,
    );
  }

  static put<T>(String path,
      {data,
        Map<String, Object>? queryParameters,
        Map<String, Object>? propertiesToLog,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress,
        bool trackTelemetry = true,
        TelemetryClient? telemetryClient,
      }) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();

    // TODO
    // final contentLength = data.map((x) => x.value.length).reduce((a,b) => a + b);

    try {
      var response = await _dio.put(path,
          data: data,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onSendProgress: onSendProgress,
          onReceiveProgress: onReceiveProgress);

      if (trackTelemetry)
        _sendTelemetry(response, null, "PUT", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      return response;
    } on DioError catch (error) {
      _sendErrorTelemetry(error, 0, "PUT", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      throw Future.error(error);
    }
  }

  static get<T>(
      String path, {
        Map<String, Object>? queryParameters,
        Map<String, Object>? propertiesToLog,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
        TelemetryClient? telemetryClient,
      }) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();

    try {
      var response = await _dio.get(path,
          queryParameters: queryParameters,
          options: options,
          cancelToken: cancelToken,
          onReceiveProgress: onReceiveProgress);

      _sendTelemetry(response, null, "GET", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      return response;
    } on DioError catch (error) {
      _sendErrorTelemetry(error, 0, "GET", timestamp, path, queryParameters, propertiesToLog, stopwatch, telemetryClient);
      throw Future.error(error);
    }
  }

  static Future<Response<T>> getSearchResults<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Map<String, Object>? propertiesToLog,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onReceiveProgress,
        TelemetryClient? telemetryClient,
      }) async {
    final stopwatch = Stopwatch()..start();
    final timestamp = DateTime.now().toUtc();

    Response<T> response = await _dio.get(path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress);

    _sendSearchRequestTelemetry(response, 0, "GET", timestamp, path, propertiesToLog, stopwatch, telemetryClient);
    return response;
  }

  static void _sendSearchRequestTelemetry<T>(Response response, dynamic contentLength, String method,
      DateTime timestamp, String path, Map<String, Object>? propertiesToLog, Stopwatch stopwatch, TelemetryClient? telemetryClient) {
    _sendTelemetry(response, 0, "GET", timestamp, path, null, propertiesToLog, stopwatch, telemetryClient);
  }
}
