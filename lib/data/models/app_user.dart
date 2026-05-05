class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String role; // "user" | "admin"
  final String themePreference; // "light" | "dark" | "system"
  final String? fcmToken;
  final List<String> followedBuildings;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.role = 'user',
    this.themePreference = 'system',
    this.fcmToken,
    this.followedBuildings = const [],
  });

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: (m['name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        photoUrl: m['photoUrl'] as String?,
        role: (m['role'] ?? 'user') as String,
        themePreference: (m['themePreference'] ?? 'system') as String,
        fcmToken: m['fcmToken'] as String?,
        followedBuildings:
            ((m['followedBuildings'] ?? <dynamic>[]) as List).cast<String>(),
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'photoUrl': photoUrl,
        'role': role,
        'themePreference': themePreference,
        'fcmToken': fcmToken,
        'followedBuildings': followedBuildings,
      };
}
