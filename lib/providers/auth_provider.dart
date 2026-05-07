import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AppUserRole { client, operator, admin, unknown }

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

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _session = _supabase.auth.currentSession;
    _user = _session?.user;
    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) async {
      _session = data.session;
      _user = data.session?.user;

      if (_user == null) {
        role = AppUserRole.unknown;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
        return;
      }

      await loadUserRole();
    });

    if (_user != null) {
      loadUserRole();
    }
  }

  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSubscription;

  Session? _session;
  User? _user;
  DemoBranchUser? _demoUser;

  bool isLoading = false;
  String? errorMessage;
  AppUserRole role = AppUserRole.unknown;

  static const List<DemoBranchUser> demoBranchUsers = [
    DemoBranchUser(
      branch: 'Comercial',
      label: 'Cliente SkyLuxe',
      email: 'cliente@skyluxe.com',
      passwordHint: 'DemoClient123',
      role: AppUserRole.client,
    ),
    DemoBranchUser(
      branch: 'Operaciones',
      label: 'Operador SkyLuxe',
      email: 'operador@skyluxe.com',
      passwordHint: 'DemoOperator123',
      role: AppUserRole.operator,
    ),
    DemoBranchUser(
      branch: 'Administracion',
      label: 'Admin SkyLuxe',
      email: 'admin@skyluxe.com',
      passwordHint: 'DemoAdmin123',
      role: AppUserRole.admin,
    ),
  ];

  Session? get session => _session;
  User? get user => _user;
  DemoBranchUser? get demoUser => _demoUser;
  bool get isDemoSession => _demoUser != null;
  bool get isAuthenticated => _user != null || _demoUser != null;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
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
        _session = null;
        _user = null;
        role = _demoUser!.role;
        errorMessage = null;
        return;
      }

      _demoUser = null;
      await _supabase.auth.signInWithPassword(email: email, password: password);
      await loadUserRole();
    } on AuthException catch (e) {
      errorMessage = e.message;
    } catch (_) {
      errorMessage = 'No fue posible iniciar sesion.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    if (_user != null) {
      await _supabase.auth.signOut();
    }
    _demoUser = null;
    _session = null;
    _user = null;
    role = AppUserRole.unknown;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadUserRole() async {
    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      role = AppUserRole.unknown;
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      role = await _resolveRole(currentUser);
    } catch (_) {
      role = AppUserRole.client;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<AppUserRole> _resolveRole(User user) async {
    final metadataRole = _roleFromDynamic(
      user.userMetadata?['role'] ?? user.appMetadata['role'],
    );
    if (metadataRole != AppUserRole.unknown) {
      return metadataRole;
    }

    final candidateTables = [
      {'table': 'users', 'column': 'role', 'keys': ['id', 'user_id']},
      {'table': 'profiles', 'column': 'role', 'keys': ['id', 'user_id']},
      {'table': 'user_roles', 'column': 'role', 'keys': ['id', 'user_id']},
      {'table': 'usuarios', 'column': 'role', 'keys': ['id', 'user_id']},
    ];

    for (final candidate in candidateTables) {
      for (final key in (candidate['keys']! as List<String>)) {
        try {
          final row =
              await _supabase
                  .from(candidate['table']! as String)
                  .select(candidate['column']! as String)
                  .eq(key, user.id)
                  .maybeSingle();

          if (row != null) {
            final mapped = _roleFromDynamic(
              row[candidate['column']! as String],
            );
            if (mapped != AppUserRole.unknown) {
              return mapped;
            }
          }
        } catch (_) {
          continue;
        }
      }
    }

    return roleFromEmail(user.email);
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
        normalized.contains('operador')) {
      return AppUserRole.operator;
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
      case 'client':
      case 'cliente':
      case 'customer':
      case 'user':
        return AppUserRole.client;
      default:
        return AppUserRole.unknown;
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
