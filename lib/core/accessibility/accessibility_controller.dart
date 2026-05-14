import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilitySettings {
  const AccessibilitySettings({
    this.textScale = 1.0,
    this.highContrast = false,
    this.reduceMotion = false,
    this.boldText = false,
    this.largeTouchTargets = false,
    this.screenReaderHints = true,
  });

  final double textScale;
  final bool highContrast;
  final bool reduceMotion;
  final bool boldText;
  final bool largeTouchTargets;
  final bool screenReaderHints;

  AccessibilitySettings copyWith({
    double? textScale,
    bool? highContrast,
    bool? reduceMotion,
    bool? boldText,
    bool? largeTouchTargets,
    bool? screenReaderHints,
  }) =>
      AccessibilitySettings(
        textScale: textScale ?? this.textScale,
        highContrast: highContrast ?? this.highContrast,
        reduceMotion: reduceMotion ?? this.reduceMotion,
        boldText: boldText ?? this.boldText,
        largeTouchTargets: largeTouchTargets ?? this.largeTouchTargets,
        screenReaderHints: screenReaderHints ?? this.screenReaderHints,
      );
}

class AccessibilityController extends StateNotifier<AccessibilitySettings> {
  AccessibilityController() : super(const AccessibilitySettings()) {
    _load();
  }

  static const _kScale = 'a11y_text_scale';
  static const _kContrast = 'a11y_high_contrast';
  static const _kMotion = 'a11y_reduce_motion';
  static const _kBold = 'a11y_bold_text';
  static const _kTouch = 'a11y_large_targets';
  static const _kScreenReader = 'a11y_screen_reader_hints';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = AccessibilitySettings(
      textScale: prefs.getDouble(_kScale) ?? 1.0,
      highContrast: prefs.getBool(_kContrast) ?? false,
      reduceMotion: prefs.getBool(_kMotion) ?? false,
      boldText: prefs.getBool(_kBold) ?? false,
      largeTouchTargets: prefs.getBool(_kTouch) ?? false,
      screenReaderHints: prefs.getBool(_kScreenReader) ?? true,
    );
  }

  Future<void> setTextScale(double v) async {
    state = state.copyWith(textScale: v);
    (await SharedPreferences.getInstance()).setDouble(_kScale, v);
  }

  Future<void> setHighContrast(bool v) async {
    state = state.copyWith(highContrast: v);
    (await SharedPreferences.getInstance()).setBool(_kContrast, v);
  }

  Future<void> setReduceMotion(bool v) async {
    state = state.copyWith(reduceMotion: v);
    (await SharedPreferences.getInstance()).setBool(_kMotion, v);
  }

  Future<void> setBoldText(bool v) async {
    state = state.copyWith(boldText: v);
    (await SharedPreferences.getInstance()).setBool(_kBold, v);
  }

  Future<void> setLargeTouchTargets(bool v) async {
    state = state.copyWith(largeTouchTargets: v);
    (await SharedPreferences.getInstance()).setBool(_kTouch, v);
  }

  Future<void> setScreenReaderHints(bool v) async {
    state = state.copyWith(screenReaderHints: v);
    (await SharedPreferences.getInstance()).setBool(_kScreenReader, v);
  }

  Future<void> resetAll() async {
    state = const AccessibilitySettings();
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_kScale),
      prefs.remove(_kContrast),
      prefs.remove(_kMotion),
      prefs.remove(_kBold),
      prefs.remove(_kTouch),
      prefs.remove(_kScreenReader),
    ]);
  }
}

final accessibilityControllerProvider =
    StateNotifierProvider<AccessibilityController, AccessibilitySettings>(
        (ref) => AccessibilityController());
