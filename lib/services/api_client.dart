import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';
import 'session_store.dart';

class ApiClient {
  Future<List<Map<String, dynamic>>> getList(
    List<String> candidatePaths, {
    bool auth = false,
    Map<String, String>? queryParameters,
  }) async {
    final payload = await _requestAny(
      'GET',
      candidatePaths,
      auth: auth,
      queryParameters: queryParameters,
    );

    final list = _extractList(payload);
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> getMap(
    List<String> candidatePaths, {
    bool auth = false,
    Map<String, String>? queryParameters,
  }) async {
    final payload = await _requestAny(
      'GET',
      candidatePaths,
      auth: auth,
      queryParameters: queryParameters,
    );

    return _extractMap(payload);
  }

  Future<Map<String, dynamic>> postMap(
    List<String> candidatePaths,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final payload = await _requestAny(
      'POST',
      candidatePaths,
      auth: auth,
      body: body,
    );

    return _extractMap(payload);
  }

  Future<List<Map<String, dynamic>>> postList(
    List<String> candidatePaths,
    Map<String, dynamic> body, {
    bool auth = false,
  }) async {
    final payload = await _requestAny(
      'POST',
      candidatePaths,
      auth: auth,
      body: body,
    );

    final list = _extractList(payload);
    return list.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<dynamic> _requestAny(
    String method,
    List<String> candidatePaths, {
    bool auth = false,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
  }) async {
    ApiException? lastError;

    for (final candidatePath in candidatePaths) {
      final normalizedPath = _normalizePath(candidatePath);
      final uri = Uri.parse(
        '${AppConstants.apiBaseUrl}$normalizedPath',
      ).replace(queryParameters: queryParameters);

      try {
        final response = await _send(method, uri, auth: auth, body: body);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return _decodePayload(response.body);
        }

        final payload = _decodePayload(response.body);
        final error = ApiException(
          _extractMessage(payload, response.statusCode),
          statusCode: response.statusCode,
          path: normalizedPath,
        );

        if (response.statusCode == 404) {
          lastError = error;
          continue;
        }

        throw error;
      } catch (error) {
        if (error is ApiException && error.statusCode == 404) {
          lastError = error;
          continue;
        }

        rethrow;
      }
    }

    throw lastError ??
        const ApiException(
          'No fue posible localizar un endpoint compatible en la API.',
        );
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    required bool auth,
    Map<String, dynamic>? body,
  }) async {
    final headers = await _headers(auth: auth);

    switch (method) {
      case 'GET':
        return http.get(uri, headers: headers);
      case 'POST':
        return http.post(
          uri,
          headers: headers,
          body: jsonEncode(body ?? <String, dynamic>{}),
        );
      default:
        throw ApiException('Metodo HTTP no soportado: $method');
    }
  }

  Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (!auth) return headers;

    final token = SessionStore.instance.token;
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  dynamic _decodePayload(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic> || decoded is List) return decoded;
    return <String, dynamic>{'value': decoded};
  }

  List<dynamic> _extractList(dynamic payload) {
    if (payload is List) return payload;

    if (payload is Map<String, dynamic>) {
      final candidates = [
        payload['data'],
        payload['items'],
        payload['results'],
        payload['rows'],
        payload['airports'],
        payload['plans'],
        payload['memberships'],
        payload['trips'],
        payload['reservations'],
        payload['flight_requests'],
        payload['matches'],
        payload['matched_options'],
        payload['options'],
        payload['flight_request'] is Map<String, dynamic>
            ? (payload['flight_request'] as Map<String, dynamic>)['matched_options']
            : null,
      ];

      for (final candidate in candidates) {
        if (candidate is List) return candidate;
      }
    }

    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final nested = payload['data'];
      if (nested is Map<String, dynamic>) return nested;
      return payload;
    }

    throw const ApiException('La API regreso una respuesta invalida.');
  }

  String _extractMessage(dynamic payload, int statusCode) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final error = payload['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }
    }

    return 'Error $statusCode';
  }

  String _normalizePath(String path) {
    final trimmed = path.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.startsWith('/') ? trimmed : '/$trimmed';
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode, this.path});

  final String message;
  final int? statusCode;
  final String? path;

  @override
  String toString() => message;
}
