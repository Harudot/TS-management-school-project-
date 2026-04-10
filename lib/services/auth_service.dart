class UserProfile {
  String name;
  String email;
  String phone;
  String bio;

  UserProfile({
    required this.name,
    required this.email,
    this.phone = '',
    this.bio = '',
  });
}

class AuthService {
  static UserProfile? currentUser;

  static Future<UserProfile?> login({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.isEmpty) return null;

    await Future.delayed(const Duration(milliseconds: 800));

    currentUser = UserProfile(
      name: 'John Doe',
      email: email.trim(),
      phone: '+976 9999-1234',
      bio: 'Computer Science student at Oxalis University.',
    );

    return currentUser;
  }

  static Future<String?> signUp({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (name.trim().isEmpty) return 'Name is required';
    if (email.trim().isEmpty) return 'Email is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    if (password != confirmPassword) return 'Passwords do not match';

    await Future.delayed(const Duration(milliseconds: 800));

    currentUser = UserProfile(name: name.trim(), email: email.trim());

    return null;
  }

  static Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String bio,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));

    currentUser ??= UserProfile(name: name, email: email);

    currentUser!.name = name;
    currentUser!.email = email;
    currentUser!.phone = phone;
    currentUser!.bio = bio;
  }

  static Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    currentUser = null;
  }
}
