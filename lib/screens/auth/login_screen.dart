import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  static final RegExp _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );
  bool _obscurePassword = true;
  int _currentStep = 1;
  bool _animateIn = false;
  bool _trustPulse = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _animateIn = true;
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _hasIdentifier => _emailController.text.trim().isNotEmpty;

  Future<void> _submit() async {
    if (!_passwordFormKey.currentState!.validate()) return;
    _triggerTrustPulse();

    await context.read<AuthProvider>().signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _continueToPassword() {
    if (!_identifierFormKey.currentState!.validate()) return;
    setState(() {
      _currentStep = 2;
    });
    _triggerTrustPulse();
  }

  void _backToIdentifier() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _triggerTrustPulse() {
    if (!mounted) return;
    setState(() {
      _trustPulse = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted) return;
      setState(() {
        _trustPulse = false;
      });
    });
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
    setState(() {
      _currentStep = 2;
    });
  }

  String? _validateIdentifier(String? value) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return 'Ingresa tu correo.';
    }
    if (!_emailRegex.hasMatch(normalized)) {
      return 'Ingresa un correo valido.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final demoUser = _matchedDemoUser(_emailController.text);
    final hasDemoUsers = AuthProvider.demoBranchUsers.isNotEmpty;
    final mediaQuery = MediaQuery.of(context);
    final isCompact = mediaQuery.size.width < 380;
    final horizontalPadding = isCompact ? 18.0 : 24.0;
    final titleSize = isCompact ? 24.0 : 28.0;
    final logoSize = isCompact ? 78.0 : 90.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFFFFF), Color(0xFFF6F4EF), Color(0xFFFFFFFF)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                20,
                horizontalPadding,
                20 + mediaQuery.viewInsets.bottom * 0.08,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 560),
                        curve: Curves.easeOut,
                        opacity: _animateIn ? 1 : 0,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 560),
                          curve: Curves.easeOutCubic,
                          scale: _animateIn ? 1 : 0.96,
                          child: Column(
                            children: [
                              Container(
                                width: logoSize,
                                height: logoSize,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0xFFE7E0D3),
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x22000000),
                                      blurRadius: 22,
                                      offset: Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Sky Group',
                                style: TextStyle(
                                  color: Color(0xFF111111),
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 620),
                      curve: Curves.easeOutCubic,
                      tween: Tween(begin: _animateIn ? 20 : 20, end: _animateIn ? 0 : 20),
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(0, value),
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 620),
                            curve: Curves.easeOut,
                            opacity: _animateIn ? 1 : 0,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isCompact ? 18 : 22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE7E0D3)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x11000000),
                              blurRadius: 30,
                              offset: Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PORTAL CLIENTE',
                              style: TextStyle(
                                color: Color(0xFF8C6A1F),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _StepIndicator(currentStep: _currentStep),
                            const SizedBox(height: 14),
                            Text(
                              _currentStep == 1
                                  ? 'Acceso privado'
                                  : 'Tu acceso exclusivo',
                              style: TextStyle(
                                color: const Color(0xFF111111),
                                fontSize: titleSize,
                                fontWeight: FontWeight.w800,
                                height: 1.05,
                                letterSpacing: -1.1,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _currentStep == 1
                                  ? 'Ingresa tu correo.'
                                  : 'Verifica tu acceso.',
                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 14,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 18),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 260),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, animation) {
                                final beginOffset =
                                    child.key == const ValueKey('password-step')
                                        ? const Offset(0.10, 0)
                                        : const Offset(-0.10, 0);
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: beginOffset,
                                      end: Offset.zero,
                                    ).animate(animation),
                                    child: child,
                                  ),
                                );
                              },
                              child:
                                  _currentStep == 1
                                      ? Form(
                                        key: _identifierFormKey,
                                        child: Column(
                                          key: const ValueKey('identifier-step'),
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Padding(
                                              padding: EdgeInsets.only(left: 2, bottom: 8),
                                              child: Text(
                                                'Correo electronico',
                                                style: TextStyle(
                                                  color: Color(0xFF555555),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _emailController,
                                              keyboardType: TextInputType.emailAddress,
                                              textInputAction: TextInputAction.done,
                                              onChanged: (_) => setState(() {}),
                                              decoration: _fieldDecoration(
                                                'nombre@empresa.com',
                                              ),
                                              validator: _validateIdentifier,
                                              onFieldSubmitted: (_) => _continueToPassword(),
                                            ),
                                            if (demoUser != null) ...[
                                              const SizedBox(height: 12),
                                              _IdentityChip(
                                                label: 'Cuenta demo',
                                                value:
                                                    '${demoUser.branch} | ${demoUser.label}',
                                                muted: demoUser.email,
                                              ),
                                            ],
                                            const SizedBox(height: 14),
                                            _PremiumPrimaryButton(
                                              onPressed:
                                                  _hasIdentifier
                                                      ? _continueToPassword
                                                      : null,
                                              enabled: _hasIdentifier,
                                              label: 'Continuar ->',
                                            ),
                                            const SizedBox(height: 12),
                                            _TrustRow(isPulsing: _trustPulse),
                                            if (auth.errorMessage != null) ...[
                                              const SizedBox(height: 14),
                                              _ErrorText(message: auth.errorMessage!),
                                            ],
                                          ],
                                        ),
                                      )
                                      : Form(
                                        key: _passwordFormKey,
                                        child: Column(
                                          key: const ValueKey('password-step'),
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _IdentityChip(
                                              label: 'Cuenta',
                                              value: _emailController.text.trim(),
                                            ),
                                            const SizedBox(height: 12),
                                            const Padding(
                                              padding: EdgeInsets.only(left: 2, bottom: 8),
                                              child: Text(
                                                'Contrasena',
                                                style: TextStyle(
                                                  color: Color(0xFF555555),
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            TextFormField(
                                              controller: _passwordController,
                                              obscureText: _obscurePassword,
                                              textInputAction: TextInputAction.done,
                                              decoration: _fieldDecoration(
                                                'Ingresa tu contrasena',
                                                suffixIcon: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _obscurePassword =
                                                          !_obscurePassword;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    _obscurePassword
                                                        ? Icons.visibility_outlined
                                                        : Icons.visibility_off_outlined,
                                                    color: const Color(0xFF555555),
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
                                              onFieldSubmitted:
                                                  (_) => auth.isLoading ? null : _submit(),
                                            ),
                                            const SizedBox(height: 14),
                                            _PremiumPrimaryButton(
                                              onPressed: auth.isLoading ? null : _submit,
                                              enabled: !auth.isLoading,
                                              label: 'Continuar ->',
                                              child:
                                                  auth.isLoading
                                                      ? const _PremiumLoadingLabel()
                                                      : null,
                                            ),
                                            const SizedBox(height: 10),
                                            SizedBox(
                                              width: double.infinity,
                                              child: OutlinedButton(
                                                onPressed: _backToIdentifier,
                                                style: OutlinedButton.styleFrom(
                                                  foregroundColor: Colors.black,
                                                  side: const BorderSide(
                                                    color: Color(0xFFD8D8D8),
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(12),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 15,
                                                      ),
                                                ),
                                                child: const Text(
                                                  'Cambiar correo',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            _TrustRow(isPulsing: _trustPulse || auth.isLoading),
                                            if (auth.errorMessage != null) ...[
                                              const SizedBox(height: 14),
                                              _ErrorText(message: auth.errorMessage!),
                                            ],
                                          ],
                                        ),
                                      ),
                            ),
                            if (_currentStep == 1 && hasDemoUsers) ...[
                              const SizedBox(height: 18),
                              const _DividerLabel(label: 'accesos demo'),
                              const SizedBox(height: 14),
                              ...AuthProvider.demoBranchUsers.map(
                                (user) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _DemoUserCard(
                                    user: user,
                                    onTap: () => _fillDemoUser(user),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'No tienes cuenta? ',
                          style: TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 13,
                          ),
                          children: [
                            TextSpan(
                              text: 'Solicita acceso premium',
                              style: TextStyle(
                                color: Color(0xFF111111),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Membresias, vuelos y acceso exclusivo.',
                        style: TextStyle(
                          color: Color(0xFF555555),
                          fontSize: 12,
                          height: 1.35,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hintText, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFFCFCFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 1.8),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.black, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBE9658), width: 2),
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({required this.isPulsing});

  final bool isPulsing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 320),
          tween: Tween(begin: 1, end: isPulsing ? 1.08 : 1),
          builder: (context, value, child) {
            return Transform.scale(scale: value, child: child);
          },
          child: const Icon(
            Icons.lock_rounded,
            size: 16,
            color: Color(0xFF8C6A1F),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Acceso seguro y verificado',
          style: TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _PremiumPrimaryButton extends StatelessWidget {
  const _PremiumPrimaryButton({
    required this.onPressed,
    required this.enabled,
    required this.label,
    this.child,
  });

  final VoidCallback? onPressed;
  final bool enabled;
  final String label;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient:
                enabled
                    ? const LinearGradient(
                      colors: [Color(0xFF121212), Color(0xFF2C2116)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    )
                    : null,
            color: enabled ? null : const Color(0xFFD8D8D8),
            boxShadow:
                enabled
                    ? const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ]
                    : null,
          ),
          child: Center(
            child:
                child ??
                Text(
                  label,
                  style: TextStyle(
                    color: enabled ? Colors.white : const Color(0xFF777777),
                    fontWeight: FontWeight.w800,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}

class _PremiumLoadingLabel extends StatefulWidget {
  const _PremiumLoadingLabel();

  @override
  State<_PremiumLoadingLabel> createState() => _PremiumLoadingLabelState();
}

class _PremiumLoadingLabelState extends State<_PremiumLoadingLabel> {
  Timer? _timer;
  int _dots = 1;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 380), (_) {
      if (!mounted) return;
      setState(() {
        _dots = _dots == 3 ? 1 : _dots + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Verificando acceso',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(
          width: 20,
          child: Text(
            '.' * _dots,
            style: const TextStyle(
              color: Color(0xFFE7C98D),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityChip extends StatelessWidget {
  const _IdentityChip({
    required this.label,
    required this.value,
    this.muted,
  });

  final String label;
  final String value;
  final String? muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF111111),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (muted != null) ...[
            const SizedBox(height: 2),
            Text(
              muted!,
              style: const TextStyle(
                color: Color(0xFF666666),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFD9D9D9))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF777777),
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFD9D9D9))),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepPill(
            label: '1. Cuenta',
            isActive: currentStep == 1,
            isComplete: currentStep > 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepPill(
            label: '2. Acceso',
            isActive: currentStep == 2,
            isComplete: false,
          ),
        ),
      ],
    );
  }
}

class _StepPill extends StatelessWidget {
  const _StepPill({
    required this.label,
    required this.isActive,
    required this.isComplete,
  });

  final String label;
  final bool isActive;
  final bool isComplete;

  @override
  Widget build(BuildContext context) {
    final background =
        isActive
            ? const Color(0xFF111111)
            : isComplete
            ? const Color(0xFFEDE7D8)
            : const Color(0xFFF2F2F2);
    final foreground =
        isActive ? Colors.white : const Color(0xFF555555);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(
        color: Color(0xFFC62828),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DemoUserCard extends StatelessWidget {
  const _DemoUserCard({required this.user, required this.onTap});

  final DemoBranchUser user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = switch (user.role) {
      AppUserRole.client => Icons.person_rounded,
      AppUserRole.operator => Icons.support_agent_rounded,
      AppUserRole.crew => Icons.badge_rounded,
      AppUserRole.admin => Icons.admin_panel_settings_rounded,
      AppUserRole.unknown => Icons.auto_awesome_rounded,
    };

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD8D8D8)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF111111)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user.branch} | ${user.label}',
                    style: const TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    user.email,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Contrasena demo: ${user.passwordHint}',
                    style: const TextStyle(
                      color: Color(0xFF8C6A1F),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.north_east_rounded, color: Color(0xFF111111)),
          ],
        ),
      ),
    );
  }
}
