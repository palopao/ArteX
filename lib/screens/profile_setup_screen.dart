import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../models/user_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../services/profile_image_service.dart';
import '../services/media_decode_service.dart';
import 'main_screen.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageService = ProfileImageService();
  String? _profilePicBase64;
  bool _isSaving = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context).chooseFromGallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context).takePicture),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    try {
      final value = await _imageService.pickAndCompress(source);
      if (mounted && value != null) setState(() => _profilePicBase64 = value);
    } on FormatException catch (error) {
      if (mounted) setState(() => _error = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = AppLocalizations.of(context).imageLoadFailed);
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final authUser = FirebaseAuth.instance.currentUser;
    final language = ref.read(selectedLanguageProvider) ?? 'English';
    if (authUser == null) {
      setState(() => _error = AppLocalizations.of(context).pleaseLogInAgain);
      return;
    }
    setState(() {
      _isSaving = true;
      _error = null;
    });
    try {
      await ref
          .read(firestoreServiceProvider)
          .createUser(
            UserModel(
              id: authUser.uid,
              email: authUser.email ?? '',
              username: _usernameController.text.trim(),
              profilePicBase64: _profilePicBase64 == null
                  ? null
                  : base64.normalize(_profilePicBase64!),
              description: _descriptionController.text.trim(),
              language: language,
            ),
          );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = AppLocalizations.of(context).profileSaveFailed,
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final username = _usernameController.text.trim();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileSetup)),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: FutureBuilder(
                future: decodeBase64InIsolate(_profilePicBase64 ?? ''),
                builder: (context, snapshot) => GestureDetector(
                  onTap: _selectImage,
                  child: CircleAvatar(
                    radius: 52,
                    backgroundImage: snapshot.data == null
                        ? null
                        : MemoryImage(snapshot.data!),
                    child: snapshot.data == null
                        ? Text(
                            username.isEmpty ? '?' : username[0].toUpperCase(),
                            style: const TextStyle(fontSize: 36),
                          )
                        : null,
                  ),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: _selectImage,
              icon: const Icon(Icons.add_a_photo),
              label: Text(l10n.addProfilePictureOptional),
            ),
            TextFormField(
              controller: _usernameController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: l10n.username),
              validator: (value) => value == null || value.trim().isEmpty
                  ? l10n.usernameRequired
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLength: 160,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.shortDescriptionOptional,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: TextStyle(color: Colors.red.shade700)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : Text(l10n.finish),
            ),
          ],
        ),
      ),
    );
  }
}
