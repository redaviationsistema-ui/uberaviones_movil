import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/constants.dart';
import '../services/session_store.dart';

enum AppUserRole { client, operator, crew, admin, unknown }

class DemoBranchUser {
  final String branch;
  final String label;
  final String email;
  final String passwordHint;
  final AppUserRole role;

  const DemoBranchUser({
    required this.branch,
    required this.label,
    required this.email,
    required this.passwordHint,
    required this.role,
  });
}

class AuthSessionUser {
  final String email;
  final String? name;
  final Map<String, dynamic> raw;

  const AuthSessionUser({required this.email, required this.raw, this.name});
}

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _restoreSession();
  }

  String? _token;
  AuthSessionUser? _user;
  DemoBranchUser? _demoUser;

  bool isLoading = false;
  String? errorMessage;
  AppUserRole role = AppUserRole.unknown;

  static const List<DemoBranchUser> demoBranchUsers = [];

  String? get session => _token;
  AuthSessionUser? get user => _user;
  DemoBranchUser? get demoUser => _demoUser;
  bool get isDemoSession => _demoUser != null;
  bool get isAuthenticated => _user != null || _demoUser != null;

  Future<void> _restoreSession() async {
    isLoading = true;
    notifyListeners();

    try {
      _token = SessionStore.instance.token;
      if (_token == null || _token!.isEmpty) {
        _token = null;
        role = AppUserRole.unknown;
        return;
      }

      await loadUserRole();
    } catch (_) {
      await _clearStoredAuth();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final normalizedEmail = email.trim().toLowerCase();
      final demoMatch = demoBranchUsers.where(
        (user) =>
            user.email.toLowerCase() == normalizedEmail &&
            user.passwordHint == password,
      );

      if (demoMatch.isNotEmpty) {
        _demoUser = demoMatch.first;
        _user = null;
        _token = null;
        SessionStore.instance.clear();
        role = _demoUser!.role;
        errorMessage = null;
        return;
      }

      _demoUser = null;

      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/login'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email.trim(),
          'password': password,
          'role': _apiRoleFromAppRole(roleFromEmail(normalizedEmail)),
        }),
      );

      final payload = _decodePayload(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildApiError(payload, response.statusCode);
      }

      await _applyAuth(payload);

      if (_user == null && _token != null) {
        await loadUserRole();
      }
    } catch (error) {
      errorMessage =
          error is _ApiException
              ? error.message
              : 'No fue posible iniciar sesion.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    final token = _token;
    await _clearStoredAuth();
    notifyListeners();

    if (token != null && token.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('${AppConstants.apiBaseUrl}/auth/logout'),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({}),
        );
      } catch (_) {
        // El cierre local ya se completo; no bloqueamos la salida por logout remoto.
      }
    }
  }

  Future<void> loadUserRole() async {
    final token = _token;
    if (token == null || token.isEmpty) {
      role = AppUserRole.unknown;
      _user = null;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/auth/me'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final payload = _decodePayload(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _buildApiError(payload, response.statusCode);
      }

      await _applyAuth(payload, keepExistingToken: true);
    } catch (_) {
      await _clearStoredAuth();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _applyAuth(
    Map<String, dynamic> payload, {
    bool keepExistingToken = false,
  }) async {
    final resolved = _resolveAuthPayload(payload);
    final resolvedToken = resolved['token'] as String?;
    final userPayload = resolved['user'] as Map<String, dynamic>?;
    final accessPayload = resolved['access'] as Map<String, dynamic>?;
    final loginContextPayload =
        resolved['login_context'] as Map<String, dynamic>?;

    _token = keepExistingToken ? (_token ?? resolvedToken) : resolvedToken;
    if (_token != null && _token!.isNotEmpty) {
      SessionStore.instance.setToken(_token!);
    }

    if (userPayload != null && userPayload.isNotEmpty) {
      final email =
          (userPayload['email'] ?? userPayload['username'] ?? '').toString();
      if (email.trim().isNotEmpty) {
        _user = AuthSessionUser(
          email: email,
          name:
              (userPayload['company_name'] ?? userPayload['name'])?.toString(),
          raw: userPayload,
        );
      }
    }

    role = _resolveRoleFromPayload(
      userPayload: userPayload,
      accessPayload: accessPayload,
      loginContextPayload: loginContextPayload,
    );
  }

  Future<void> _clearStoredAuth() async {
    _token = null;
    _user = null;
    _demoUser = null;
    role = AppUserRole.unknown;
    errorMessage = null;
    SessionStore.instance.clear();
  }

  Map<String, dynamic> _decodePayload(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return <String, dynamic>{};
  }

  _ApiException _buildApiError(Map<String, dynamic> payload, int statusCode) {
    final message = _extractApiErrorMessage(payload, statusCode);
    return _ApiException(message);
  }

  String _extractApiErrorMessage(Map<String, dynamic> payload, int statusCode) {
    final message = payload['message'];
    if (message is String &&
        message.trim().isNotEmpty &&
        message != 'Error $statusCode') {
      return message;
    }

    final errors = payload['errors'];
    if (errors is Map<String, dynamic>) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final first = value.first;
          if (first is String && first.trim().isNotEmpty) {
            return first;
          }
        }
      }
    }

    return 'Error $statusCode';
  }

  Map<String, dynamic> _resolveAuthPayload(Map<String, dynamic> payload) {
    final data =
        payload['data'] is Map<String, dynamic>
            ? payload['data'] as Map<String, dynamic>
            : <String, dynamic>{};
    final user =
        payload['user'] ??
        data['user'] ??
        data['account'] ??
        <String, dynamic>{};

    return {
      'token':
          payload['token'] ??
          payload['access_token'] ??
          payload['plainTextToken'] ??
          data['token'] ??
          data['access_token'] ??
          data['plainTextToken'] ??
          _token,
      'user': user is Map<String, dynamic> ? user : <String, dynamic>{},
      'access':
          payload['access'] is Map<String, dynamic>
              ? payload['access'] as Map<String, dynamic>
              : data['access'] is Map<String, dynamic>
              ? data['access'] as Map<String, dynamic>
              : null,
      'login_context':
          payload['login_context'] is Map<String, dynamic>
              ? payload['login_context'] as Map<String, dynamic>
              : data['login_context'] is Map<String, dynamic>
              ? data['login_context'] as Map<String, dynamic>
              : data['loginContext'] is Map<String, dynamic>
              ? data['loginContext'] as Map<String, dynamic>
              : null,
    };
  }

  AppUserRole _resolveRoleFromPayload({
    required Map<String, dynamic>? userPayload,
    required Map<String, dynamic>? accessPayload,
    required Map<String, dynamic>? loginContextPayload,
  }) {
    final explicitRoles = <dynamic>[
      ...((loginContextPayload?['roles'] as List?) ?? const []),
      ...((accessPayload?['roles'] as List?) ?? const []),
      ...((userPayload?['roles'] as List?) ?? const []),
      loginContextPayload?['effective_role'],
      accessPayload?['effective_role'],
      userPayload?['operational_role'],
      userPayload?['role'],
    ];

    for (final roleValue in explicitRoles) {
      if (roleValue is Map<String, dynamic>) {
        final nested =
            roleValue['code'] ?? roleValue['key'] ?? roleValue['name'];
        final mapped = _roleFromDynamic(nested);
        if (mapped != AppUserRole.unknown) return mapped;
      } else {
        final mapped = _roleFromDynamic(roleValue);
        if (mapped != AppUserRole.unknown) return mapped;
      }
    }

    return roleFromEmail(userPayload?['email']?.toString());
  }

  static AppUserRole roleFromEmail(String? email) {
    final normalized = email?.toLowerCase().trim() ?? '';
    if (normalized.isEmpty) return AppUserRole.unknown;

    final demoMatch = demoBranchUsers.where((user) => user.email == normalized);
    if (demoMatch.isNotEmpty) {
      return demoMatch.first.role;
    }

    if (normalized.contains('admin')) return AppUserRole.admin;
    if (normalized.contains('ops') ||
        normalized.contains('operator') ||
        normalized.contains('operador') ||
        normalized.contains('provider')) {
      return AppUserRole.operator;
    }
    if (normalized.contains('crew') ||
        normalized.contains('sobrecargo') ||
        normalized.contains('cabina')) {
      return AppUserRole.crew;
    }

    return AppUserRole.client;
  }

  AppUserRole _roleFromDynamic(dynamic raw) {
    final value = raw?.toString().toLowerCase().trim();

    switch (value) {
      case 'admin':
      case 'administrator':
        return AppUserRole.admin;
      case 'operator':
      case 'operador':
      case 'provider':
      case 'proveedor':
        return AppUserRole.operator;
      case 'crew':
      case 'sobrecargo':
      case 'cabina':
      case 'tripulacion':
        return AppUserRole.crew;
      case 'client':
      case 'cliente':
      case 'customer':
      case 'user':
        return AppUserRole.client;
      default:
        return AppUserRole.unknown;
    }
  }

  String _apiRoleFromAppRole(AppUserRole role) {
    switch (role) {
      case AppUserRole.client:
        return 'client';
      case AppUserRole.operator:
        return 'provider';
      case AppUserRole.crew:
        return 'sobrecargo';
      case AppUserRole.admin:
        return 'admin';
      case AppUserRole.unknown:
        return 'client';
    }
  }
}

class _ApiException implements Exception {
  const _ApiException(this.message);

  final String message;
}
