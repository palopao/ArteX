import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firestore_service.dart';
import 'auth_gate.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _message;
  bool _working = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    await _run(() async {
      await FirebaseAuth.instance.currentUser?.verifyBeforeUpdateEmail(email);
      _message = 'A verification email was sent to the new address.';
    });
  }

  Future<void> _updatePassword() async {
    if (_passwordController.text.length < 6) {
      setState(() => _message = 'Password must contain at least 6 characters.');
      return;
    }
    await _run(() async {
      await FirebaseAuth.instance.currentUser
          ?.updatePassword(_passwordController.text);
      _message = 'Password updated.';
    });
  }

  Future<void> _run(Future<void> Function() operation) async {
    setState(() {
      _working = true;
      _message = null;
    });
    try {
      await operation();
    } on FirebaseAuthException catch (error) {
      _message = error.message ?? 'The account update failed.';
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text('This permanently deletes your account and profile.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    await _run(() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirestoreService().deleteUser(user.uid);
        await user.delete();
      }
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const AuthGate()),
          (_) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Definitions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'New email')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _working ? null : _updateEmail, child: const Text('Change email')),
          const SizedBox(height: 16),
          TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _working ? null : _updatePassword, child: const Text('Change password')),
          if (_message != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_message!)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _working ? null : () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            label: const Text('Log out'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _working ? null : _deleteAccount,
            child: const Text('Delete account', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
