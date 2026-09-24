import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import 'auth_screen.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  static const languages = <String, String>{
    'Portuguese': 'Português',
    'English': 'English',
    'Spanish': 'Español',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedLanguageProvider);
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.welcomeToArtex)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.chooseLanguage,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            RadioGroup<String>(
              groupValue: selected,
              onChanged: (value) {
                if (value != null) {
                  ref.read(selectedLanguageProvider.notifier).select(value);
                }
              },
              child: Column(
                children: languages.entries
                    .map(
                      (language) => RadioListTile<String>(
                        value: language.key,
                        title: Text(language.value),
                      ),
                    )
                    .toList(),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: selected == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const AuthScreen(),
                        ),
                      ),
              child: Text(l10n.continueLabel),
            ),
          ],
        ),
      ),
    );
  }
}
