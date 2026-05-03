import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:ts_management/data/models/app_user.dart';
import 'package:ts_management/data/repositories/repositories.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((_) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>(
    (ref) => ref.watch(firebaseAuthProvider).authStateChanges());

final isAdminProvider = StreamProvider<bool>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  await for (final user in auth.idTokenChanges()) {
    if (user == null) {
      yield false;
    } else {
      final token = await user.getIdTokenResult();
      yield token.claims?['role'] == 'admin';
    }
  }
});

final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  final repo = ref.watch(usersRepositoryProvider);
  final user = auth.currentUser;
  if (user == null) {
    yield null;
    return;
  }
  yield* repo.watch(user.uid);
});

class AuthService {
  AuthService(this._auth, this._users);
  final FirebaseAuth _auth;
  final UsersRepository _users;

  Future<void> signInEmail(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  Future<void> signUpEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(name);
    await _users.upsert(AppUser(uid: user.uid, name: name, email: email));
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email);

  Future<void> signInWithGoogle() async {
    final google = await GoogleSignIn().signIn();
    if (google == null) return;
    final auth = await google.authentication;
    final cred = GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    final result = await _auth.signInWithCredential(cred);
    final user = result.user!;
    final existing = await _users.get(user.uid);
    if (existing == null) {
      await _users.upsert(AppUser(
        uid: user.uid,
        name: user.displayName ?? '',
        email: user.email ?? '',
        photoUrl: user.photoURL,
      ));
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut().catchError((_) => null);
    await _auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) =>
    AuthService(ref.watch(firebaseAuthProvider), ref.watch(usersRepositoryProvider)));
