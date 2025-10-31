import 'package:collectors_app/core/app_strings.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<User?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user?.updateDisplayName(name);
      await cred.user?.reload();

      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '445062815461-375ajgj4ha280ab91okmcqe5o94gn8bf.apps.googleusercontent.com',
      );
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user?.displayName == null ||
          userCredential.user!.displayName!.isEmpty) {
        await userCredential.user?.updateDisplayName(googleUser.displayName);
        await userCredential.user?.reload();
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw AppStrings.googleLoginFailed;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Помилка надсилання листа: $e';
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  User? get currentUser => _auth.currentUser;

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Пароль занадто слабкий';
      case 'email-already-in-use':
        return 'Цей email вже використовується';
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return 'Невірний email або пароль';
      case 'account-exists-with-different-credential':
        return 'Даний email вже використовується';
      case 'invalid-email':
        return 'Невірний формат email';
      default:
        if (e.message!.contains('dev.flutter')) {
          return 'Будь ласка, заповніть всі поля коректно';
        }
        return e.message ?? 'Помилка авторизації';
    }
  }
}
