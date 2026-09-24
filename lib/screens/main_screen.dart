import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';

import '../widgets/home_tab.dart';
import '../widgets/explore_tab.dart';
import 'auth_gate.dart';
import 'my_area_tab.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 1;
  bool _loggingOut = false;

  Future<void> _logout() async {
    if (_loggingOut) return;
    setState(() => _loggingOut = true);
    try {
      await FirebaseAuth.instance.signOut();
      ref.invalidate(firestoreServiceProvider);
      ref.invalidate(selectedLanguageProvider);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AuthGate()),
        (_) => false,
      );
    } finally {
      if (mounted) setState(() => _loggingOut = false);
    }
  }

  List<NavigationDestination> _destinations(AppLocalizations l10n) => [
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: l10n.myArea,
    ),
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: l10n.home,
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: l10n.explore,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titleForIndex(_selectedIndex, l10n)),
        actions: [
          IconButton(
            tooltip: l10n.logout,
            onPressed: _loggingOut ? null : _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          MyAreaTab(),
          HomeTab(),
          ExploreTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        destinations: _destinations(l10n),
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  String _titleForIndex(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.myArea;
      case 2:
        return l10n.explore;
      default:
        return l10n.appTitle;
    }
  }
}
