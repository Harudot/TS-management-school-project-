import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrivacySettings {
  const PrivacySettings({
    this.shareLocation = false,
    this.shareUsageAnalytics = true,
    this.crashReports = true,
    this.showInDirectory = true,
    this.allowSearchByName = true,
    this.personalizedContent = true,
  });

  final bool shareLocation;
  final bool shareUsageAnalytics;
  final bool crashReports;
  final bool showInDirectory;
  final bool allowSearchByName;
  final bool personalizedContent;

  PrivacySettings copyWith({
    bool? shareLocation,
    bool? shareUsageAnalytics,
    bool? crashReports,
    bool? showInDirectory,
    bool? allowSearchByName,
    bool? personalizedContent,
  }) =>
      PrivacySettings(
        shareLocation: shareLocation ?? this.shareLocation,
        shareUsageAnalytics: shareUsageAnalytics ?? this.shareUsageAnalytics,
        crashReports: crashReports ?? this.crashReports,
        showInDirectory: showInDirectory ?? this.showInDirectory,
        allowSearchByName: allowSearchByName ?? this.allowSearchByName,
        personalizedContent: personalizedContent ?? this.personalizedContent,
      );
}

class PrivacyController extends StateNotifier<PrivacySettings> {
  PrivacyController() : super(const PrivacySettings()) {
    _load();
  }

  static const _kLoc = 'priv_share_location';
  static const _kAnalytics = 'priv_analytics';
  static const _kCrash = 'priv_crash';
  static const _kDir = 'priv_directory';
  static const _kSearch = 'priv_search';
  static const _kPersonalized = 'priv_personalized';

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    state = PrivacySettings(
      shareLocation: p.getBool(_kLoc) ?? false,
      shareUsageAnalytics: p.getBool(_kAnalytics) ?? true,
      crashReports: p.getBool(_kCrash) ?? true,
      showInDirectory: p.getBool(_kDir) ?? true,
      allowSearchByName: p.getBool(_kSearch) ?? true,
      personalizedContent: p.getBool(_kPersonalized) ?? true,
    );
  }

  Future<void> setShareLocation(bool v) async {
    state = state.copyWith(shareLocation: v);
    (await SharedPreferences.getInstance()).setBool(_kLoc, v);
  }

  Future<void> setShareUsageAnalytics(bool v) async {
    state = state.copyWith(shareUsageAnalytics: v);
    (await SharedPreferences.getInstance()).setBool(_kAnalytics, v);
  }

  Future<void> setCrashReports(bool v) async {
    state = state.copyWith(crashReports: v);
    (await SharedPreferences.getInstance()).setBool(_kCrash, v);
  }

  Future<void> setShowInDirectory(bool v) async {
    state = state.copyWith(showInDirectory: v);
    (await SharedPreferences.getInstance()).setBool(_kDir, v);
  }

  Future<void> setAllowSearchByName(bool v) async {
    state = state.copyWith(allowSearchByName: v);
    (await SharedPreferences.getInstance()).setBool(_kSearch, v);
  }

  Future<void> setPersonalizedContent(bool v) async {
    state = state.copyWith(personalizedContent: v);
    (await SharedPreferences.getInstance()).setBool(_kPersonalized, v);
  }

  /// Wipe non-essential cached prefs (keeps auth state and theme).
  Future<void> clearCachedPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final keep = {'theme_mode', 'app_locale'};
    final keys = prefs.getKeys().where((k) => !keep.contains(k)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
    state = const PrivacySettings();
  }
}

final privacyControllerProvider =
    StateNotifierProvider<PrivacyController, PrivacySettings>(
        (ref) => PrivacyController());
