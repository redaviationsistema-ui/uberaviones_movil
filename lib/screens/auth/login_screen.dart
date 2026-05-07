import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await context.read<AuthProvider>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  DemoBranchUser? _matchedDemoUser(String value) {
    final email = value.trim().toLowerCase();
    for (final user in AuthProvider.demoBranchUsers) {
      if (user.email == email) {
        return user;
      }
    }
    return null;
  }

  void _fillDemoUser(DemoBranchUser user) {
    _emailController.text = user.email;
    _passwordController.text = user.passwordHint;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final demoUser = _matchedDemoUser(_emailController.text);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF06111D), Color(0xFF0E2238), Color(0xFF17324A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 28,
                        offset: Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE8C27A), Color(0xFFF6D899)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.flight_takeoff_rounded,
                              size: 28,
                              color: Color(0xFF10253A),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'SkyLuxe AeroQuote',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF10253A),
                          ),
                        ),
                        const Text(
                          'Activar demo por perfil',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF10253A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...AuthProvider.demoBranchUsers.map(
                          (user) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _DemoUserCard(
                              user: user,
                              onTap: () => _fillDemoUser(user),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.alternate_email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo.';
                            }
                            if (!_emailRegex.hasMatch(value.trim())) {
                              return 'Ingresa un correo valido.';
                            }
                            return null;
                          },
                        ),
                        if (demoUser != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8EA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFFE8C27A),
                              ),
                            ),
                            child: Text(
                              'Rama detectada: ${demoUser.branch} | Perfil: ${demoUser.label}',
                              style: const TextStyle(
                                color: Color(0xFF6C4C12),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Contrasena',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu contrasena.';
                            }
                            if (value.length < 6) {
                              return 'La contrasena debe tener al menos 6 caracteres.';
                            }
                            return null;
                          },
                        ),
                        if (auth.errorMessage != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF1F0),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFFFCCC7),
                              ),
                            ),
                            child: Text(
                              auth.errorMessage!,
                              style: const TextStyle(
                                color: Color(0xFF8D1F1A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: auth.isLoading ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFE8C27A),
                              foregroundColor: const Color(0xFF1A1A1A),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child:
                                auth.isLoading
                                    ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : const Text(
                                      'Entrar / activar demo',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Center(
                          child: Text(
                            'Despues de la demo se requiere un plan activo para cotizar, reservar o publicar flota.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF6B7786),
                              height: 1.35,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}



class _DemoUserCard extends StatelessWidget {
  final DemoBranchUser user;
  final VoidCallback onTap;

  const _DemoUserCard({required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final icon = switch (user.role) {
      AppUserRole.client => Icons.person_rounded,
      AppUserRole.operator => Icons.support_agent_rounded,
      AppUserRole.admin => Icons.admin_panel_settings_rounded,
      AppUserRole.unknown => Icons.auto_awesome_rounded,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE3E9EF)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3D8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(child: Icon(icon, color: const Color(0xFF10253A))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.branch} | ${user.label}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10253A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: const TextStyle(color: Color(0xFF5A6C7D)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Contrasena demo: ${user.passwordHint}',
                    style: const TextStyle(
                      color: Color(0xFF8B6B2E),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_west, color: Color(0xFF10253A)),
          ],
        ),
      ),
    );
  }
}
