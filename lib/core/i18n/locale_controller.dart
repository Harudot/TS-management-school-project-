import 'dart:ui' show Locale;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User-selected app locale. `null` means follow the system locale.
class LocaleController extends StateNotifier<Locale?> {
  LocaleController() : super(null) {
    _load();
  }

  static const _key = 'app_locale';

  static const supported = <Locale>[
    Locale('en'),
    Locale('mn'),
  ];

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key);
    if (code == 'en' || code == 'mn') {
      state = Locale(code!);
    }
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, locale.languageCode);
    }
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale?>(
        (ref) => LocaleController());
