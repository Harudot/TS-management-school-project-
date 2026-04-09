import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Хэрэглэгчийн мэдээлэл хадгалах model
class AppUser {
  final String name;
  final String email;
  final String password;
  final bool isAdmin;

  const AppUser({
    required this.name,
    required this.email,
    required this.password,
    this.isAdmin = false,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'password': password,
    'isAdmin': isAdmin,
  };

  factory AppUser.fromJson(Map<String, dynamic> j) => AppUser(
    name: j['name'],
    email: j['email'],
    password: j['password'],
    isAdmin: j['isAdmin'] ?? false,
  );
}

/// Нэвтрэх / бүртгэх үйлчилгээ
///
/// Admin account статикаар тодорхойлогдсон:
///   email:    admin@oxalis.edu
///   password: Admin@1234
class AuthService {
  static const _usersKey = 'oxalis_users';
  static const _loggedInKey = 'oxalis_logged_in_email';

  // ── Static admin ──────────────────────────────
  static const AppUser _adminUser = AppUser(
    name: 'Admin',
    email: 'admin@oxalis.edu',
    password: 'Admin@1234',
    isAdmin: true,
  );

  // ── Бүх хэрэглэгч унших ──────────────────────
  static Future<List<AppUser>> _loadUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_usersKey) ?? [];
    return raw.map((s) => AppUser.fromJson(jsonDecode(s))).toList();
  }

  // ── Хэрэглэгч хадгалах ───────────────────────
  static Future<void> _saveUsers(List<AppUser> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _usersKey,
      users.map((u) => jsonEncode(u.toJson())).toList(),
    );
  }

  // ── Бүртгэл үүсгэх ───────────────────────────
  /// null → амжилттай, String → алдааны мессеж
  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) return 'Нэрээ оруулна уу';
    if (!email.contains('@')) return 'И-мэйл буруу байна';
    if (password.length < 6) return 'Нууц үг хамгийн багадаа 6 тэмдэгт';
    if (password != confirmPassword) return 'Нууц үг таарахгүй байна';

    if (email.trim().toLowerCase() == _adminUser.email.toLowerCase()) {
      return 'Энэ и-мэйл аль хэдийн бүртгэлтэй байна';
    }

    final users = await _loadUsers();
    final exists = users.any(
      (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
    );
    if (exists) return 'Энэ и-мэйл аль хэдийн бүртгэлтэй байна';

    users.add(
      AppUser(
        name: name.trim(),
        email: email.trim().toLowerCase(),
        password: password,
      ),
    );
    await _saveUsers(users);
    return null;
  }

  // ── Нэвтрэх ──────────────────────────────────
  /// AppUser → амжилттай, null → буруу мэдээлэл
  static Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final e = email.trim().toLowerCase();
    final p = password.trim();

    if (e == _adminUser.email.toLowerCase() && p == _adminUser.password) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loggedInKey, e);
      return _adminUser;
    }

    final users = await _loadUsers();
    final user = users
        .where((u) => u.email == e && u.password == p)
        .firstOrNull;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_loggedInKey, e);
    }
    return user;
  }

  // ── Гарах ────────────────────────────────────
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loggedInKey);
  }

  // ── Одоогийн нэвтэрсэн хэрэглэгч ────────────
  static Future<AppUser?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_loggedInKey);
    if (email == null) return null;
    if (email == _adminUser.email.toLowerCase()) return _adminUser;
    final users = await _loadUsers();
    return users.where((u) => u.email == email).firstOrNull;
  }
}
