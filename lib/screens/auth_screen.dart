import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import 'main_screen.dart';
import 'profile_setup_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final auth = FirebaseAuth.instance;
      final credential = _isLogin
          ? await auth.signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            )
          : await auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
      if (!mounted || credential.user == null) return;
      if (_isLogin) {
        final exists = await ref
            .read(firestoreServiceProvider)
            .userExists(credential.user!.uid);
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => exists
                ? const MainScreen()
                : const ProfileSetupScreen(),
          ),
          (_) => false,
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => const ProfileSetupScreen(),
          ),
        );
      }
    } on FirebaseAuthException catch (error) {
      setState(() => _error = _authError(error.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _authError(String code) {
    final l10n = AppLocalizations.of(context);
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return l10n.invalidCredentials;
      case 'email-already-in-use':
        return l10n.accountAlreadyExists;
      case 'weak-password':
        return l10n.passwordMin;
      case 'invalid-email':
        return l10n.invalidEmail;
      default:
        return l10n.authenticationFailed;
    }
  }

  Future<void> _forgotPassword() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = l10n.emailRequired);
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) setState(() => _error = l10n.resetEmailSent);
    } on FirebaseAuthException catch (error) {
      if (mounted) setState(() => _error = _authError(error.code));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final selectedLanguage = ref.watch(selectedLanguageProvider) ?? 'English';
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? l10n.logIn : l10n.createAccount),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              tooltip: l10n.chooseLanguage,
              onSelected: (language) => ref
                  .read(selectedLanguageProvider.notifier)
                  .select(language),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'Portuguese',
                  child: Text('🇵🇹 PT'),
                ),
                PopupMenuItem(
                  value: 'Spanish',
                  child: Text('🇪🇸 ES'),
                ),
                PopupMenuItem(
                  value: 'English',
                  child: Text('🇬🇧 EN'),
                ),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(_languageLabel(selectedLanguage)),
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: screenSize.height * 0.5,
              fit: BoxFit.contain,
            ),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: l10n.email),
              validator: (value) =>
                  value == null || !value.contains('@') ? l10n.emailRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: l10n.password),
              validator: (value) => value == null || value.length < 6
                  ? l10n.passwordMin
                  : null,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : Text(_isLogin ? l10n.logIn : l10n.signUp),
            ),
            if (_isLogin)
              TextButton(
                onPressed: _isLoading ? null : _forgotPassword,
                child: Text(l10n.forgotPassword),
              ),
            TextButton(
              onPressed: _isLoading
                  ? null
                  : () => setState(() {
                        _isLogin = !_isLogin;
                        _error = null;
                      }),
              child: Text(
                _isLogin
                    ? l10n.needAccount
                    : l10n.alreadyHaveAccount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _languageLabel(String language) {
    switch (language) {
      case 'Portuguese':
        return '🇵🇹 PT';
      case 'Spanish':
        return '🇪🇸 ES';
      default:
        return '🇬🇧 EN';
    }
  }
}
