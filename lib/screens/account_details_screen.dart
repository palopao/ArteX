import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../services/profile_image_service.dart';

class AccountDetailsScreen extends ConsumerStatefulWidget {
  const AccountDetailsScreen({super.key});

  @override
  ConsumerState<AccountDetailsScreen> createState() => _AccountDetailsScreenState();
}

class _AccountDetailsScreenState extends ConsumerState<AccountDetailsScreen> {
  final _username = TextEditingController();
  final _description = TextEditingController();
  final _imageService = ProfileImageService();
  String _language = 'English';
  String? _profilePic;
  Uint8List? _localProfilePreview;
  String _originalUsername = '';
  String _originalDescription = '';
  String _originalLanguage = 'English';
  String? _originalProfilePic;
  bool _loaded = false;
  bool _saving = false;
  String? _error;

  bool get _isDirty =>
      _username.text.trim() != _originalUsername ||
      _description.text != _originalDescription ||
      _language != _originalLanguage ||
      _profilePic != _originalProfilePic;

  @override
  void initState() {
    super.initState();
    _username.addListener(_onFormChanged);
    _description.addListener(_onFormChanged);
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _username.removeListener(_onFormChanged);
    _description.removeListener(_onFormChanged);
    _username.dispose();
    _description.dispose();
    super.dispose();
  }

  void _load(UserModel user) {
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _username.text = user.username;
      _description.text = user.description;
      setState(() {
        _language = user.language;
        _profilePic = user.profilePicBase64;
        _originalUsername = user.username;
        _originalDescription = user.description;
        _originalLanguage = user.language;
        _originalProfilePic = user.profilePicBase64;
      });
      if (user.profilePicBase64 != null) {
        try {
          _localProfilePreview = Uint8List.fromList(
            base64Decode(base64.normalize(user.profilePicBase64!)),
          );
        } on FormatException {
          _localProfilePreview = null;
        }
      }
      ref.read(selectedLanguageProvider.notifier).select(_language);
    });
  }

  Future<void> _pickPicture() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Wrap(children: [
        ListTile(title: Text(AppLocalizations.of(context).gallery), onTap: () => Navigator.pop(context, ImageSource.gallery)),
        ListTile(title: Text(AppLocalizations.of(context).camera), onTap: () => Navigator.pop(context, ImageSource.camera)),
      ]),
    );
    if (source == null) return;
    try {
      final value = await _imageService.pickAndCompress(source);
      if (mounted && value != null) {
        final previewBytes = Uint8List.fromList(base64Decode(value));
        setState(() {
          _profilePic = value;
          _localProfilePreview = previewBytes;
        });
      }
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    }
  }

  Future<void> _save(UserModel user) async {
    final l10n = AppLocalizations.of(context);
    if (_username.text.trim().isEmpty) {
      setState(() => _error = l10n.usernameRequired);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(firestoreServiceProvider).updateUser(
            user.copyWith(
              username: _username.text.trim(),
              description: _description.text.trim(),
              language: _language,
              profilePicBase64: _profilePic == null ? null : base64.normalize(_profilePic!),
            ),
          );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _error = l10n.saveChanges);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final id = FirebaseAuth.instance.currentUser?.uid;
    if (id == null) return Scaffold(body: Center(child: Text(l10n.pleaseLogInAgain)));
    return FutureBuilder<UserModel?>(
      future: ref.read(firestoreServiceProvider).getUser(id),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        _load(user);
        return Scaffold(
          appBar: AppBar(title: Text(l10n.accountDetails)),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: _localProfilePreview == null
                      ? null
                      : MemoryImage(_localProfilePreview!),
                  child: _localProfilePreview != null
                      ? null
                      : Text(
                          _username.text.isEmpty
                              ? '?'
                              : _username.text[0].toUpperCase(),
                        ),
                ),
              ),
              TextButton.icon(onPressed: _pickPicture, icon: const Icon(Icons.add_a_photo), label: Text(l10n.changeProfilePicture)),
              TextField(controller: _username, decoration: InputDecoration(labelText: l10n.username)),
              const SizedBox(height: 12),
              TextField(controller: _description, maxLines: 3, decoration: InputDecoration(labelText: l10n.description)),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _language,
                items: [
                  DropdownMenuItem(value: 'Portuguese', child: Text(l10n.portuguese)),
                  DropdownMenuItem(value: 'English', child: Text(l10n.english)),
                  DropdownMenuItem(value: 'Spanish', child: Text(l10n.spanish)),
                ],
                onChanged: (value) {
                  final next = value ?? _language;
                  setState(() => _language = next);
                  ref.read(selectedLanguageProvider.notifier).select(next);
                },
                decoration: InputDecoration(labelText: l10n.language),
              ),
              if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!)),
              const SizedBox(height: 20),
              if (_isDirty)
                FilledButton(
                  onPressed: _saving ? null : () => _save(user),
                  child: Text(l10n.saveChanges),
                ),
            ],
          ),
        );
      },
    );
  }
}
