import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'services/error_logging_service.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';

Future<void> main() async {
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      FlutterError.onError = (details) {
        if (kIsWeb) {
          FlutterError.presentError(details);
        } else {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        unawaited(
          ErrorLoggingService.record(error, stack, fatal: true),
        );
        return true;
      };
      runApp(const ProviderScope(child: MyApp()));
    },
    (error, stack) {
      unawaited(
        ErrorLoggingService.record(error, stack, fatal: true),
      );
    },
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp(
      title: 'Artex',
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) {
        ErrorWidget.builder = (_) => const ArtexErrorScreen();
        return child ?? const ArtexErrorScreen();
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
