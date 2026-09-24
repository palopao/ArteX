import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';

import '../services/firestore_service.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class SelectedLanguageNotifier extends Notifier<String?> {
  @override
  String? build() {
    switch (PlatformDispatcher.instance.locale.languageCode) {
      case 'pt':
        return 'Portuguese';
      case 'es':
        return 'Spanish';
      case 'en':
      default:
        return 'English';
    }
  }

  void select(String language) => state = language;
}

final selectedLanguageProvider =
    NotifierProvider<SelectedLanguageNotifier, String?>(
  SelectedLanguageNotifier.new,
);

final localeProvider = Provider<Locale>((ref) {
  final language = ref.watch(selectedLanguageProvider);
  switch (language) {
    case 'Portuguese':
      return const Locale('pt');
    case 'Spanish':
      return const Locale('es');
    default:
      return const Locale('en');
  }
});
