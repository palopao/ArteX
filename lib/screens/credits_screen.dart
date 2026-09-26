import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  static const _repoUrl = 'https://github.com/palopao/ArteX';
  static const _creatorName = 'José Torres';

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.credits)),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: screenSize.height * 0.5,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              l10n.creditsCreatedBy,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              _creatorName,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              leading: Icon(Icons.code, color: colorScheme.primary),
              title: Text(l10n.creditsRepository),
              subtitle: Text(
                _repoUrl,
                style: TextStyle(color: colorScheme.primary),
              ),
              trailing: const Icon(Icons.open_in_new),
              onTap: () => _launchUrl(context, _repoUrl),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              l10n.creditsOpenSource,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).couldNotOpenLink)),
      );
    }
  }
}
