import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/agribridge_repository.dart';
import '../screens/app_shell.dart';
import '../theme/app_theme.dart';

class AgriBridgeApp extends StatefulWidget {
  const AgriBridgeApp({super.key});
  @override
  State<AgriBridgeApp> createState() => _AgriBridgeAppState();
}

class _AgriBridgeAppState extends State<AgriBridgeApp> {
  String language = 'தமிழ்';
  bool languageChosen = false;
  String role = 'Farmer';
  int page = 1;
  bool _userInteracted = false;
  final Map<String, String> localValues = {};

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguage = prefs.getString('agri_language');
      final savedRole = prefs.getString('agri_role');
      final completed = prefs.getBool('agri_onboarding_complete') ?? false;
      if (!mounted || _userInteracted) return;
      setState(() {
        if (savedLanguage == 'தமிழ்' || savedLanguage == 'English') {
          language = savedLanguage!;
          languageChosen = true;
        }
        if (savedRole == 'Farmer' || savedRole == 'Retailer') role = savedRole!;
        page = completed ? (role == 'Farmer' ? 5 : 21) : 1;
      });
    } catch (_) {
      // The language picker remains usable if local storage is unavailable.
    }
  }

  Future<void> _saveLanguage(String value) async {
    _userInteracted = true;
    setState(() {
      language = value;
      languageChosen = true;
    });
    try {
      await (await SharedPreferences.getInstance()).setString(
        'agri_language',
        value,
      );
    } catch (_) {
      // Continue the current session even when preferences are unavailable.
    }
  }

  Future<void> _saveRole(String value) async {
    _userInteracted = true;
    setState(() {
      role = value;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('agri_role', value);
    } catch (_) {
      // Continue without blocking navigation.
    }
  }

  Future<void> _navigate(int value) async {
    _userInteracted = true;
    setState(() => page = value);
    if (value < 5) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('agri_onboarding_complete', true);
      if (value == 5 || value == 21) await prefs.setString('agri_role', role);
    } catch (_) {}
  }

  Future<void> _logout() async {
    setState(() {
      role = 'Farmer';
      page = 1;
      localValues.clear();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('agri_onboarding_complete');
      await prefs.remove('agri_role');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'AgriBridge',
    debugShowCheckedModeBanner: false,
    theme: buildAgriTheme(),
    home: AppShell(
      page: page,
      role: role,
      language: language,
      languageChosen: languageChosen,
      values: localValues,
      onPage: _navigate,
      onLanguage: _saveLanguage,
      onRole: _saveRole,
      onLogout: _logout,
      repository: const UnconfiguredAgriBridgeRepository(),
    ),
  );
}
