import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Manages Firebase Authentication state.
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth;
  User? _user;

  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance {
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;
  bool get isSignedIn => _user != null;
  bool get isAnonymous => _user?.isAnonymous ?? true;
  String? get userId => _user?.uid;
  String? get displayName => _user?.displayName;
  String? get email => _user?.email;

  /// Sign in anonymously — allows usage without an account.
  Future<void> signInAnonymously() async {
    if (_user != null) return;
    await _auth.signInAnonymously();
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize();
    final googleUser = await googleSignIn.authenticate();

    final googleAuth = googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    await _linkOrSignIn(credential);
  }

  // ── Apple Sign-In ─────────────────────────────────────────────────────────

  Future<void> signInWithApple() async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    await _linkOrSignIn(oauthCredential);

    // Apple only sends the name on first sign-in — persist it.
    if (appleCredential.givenName != null && _user != null) {
      final name =
          '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
              .trim();
      if (name.isNotEmpty &&
          (_user!.displayName == null || _user!.displayName!.isEmpty)) {
        await _user!.updateDisplayName(name);
        await _user!.reload();
        _user = _auth.currentUser;
        notifyListeners();
      }
    }
  }

  // ── Email / Password ──────────────────────────────────────────────────────

  Future<String?> signInWithEmail(String email, String password) async {
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      await _linkOrSignIn(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign-in failed';
    }
  }

  Future<String?> registerWithEmail(String email, String password) async {
    try {
      if (_user != null && _user!.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        try {
          await _user!.linkWithCredential(credential);
          _user = _auth.currentUser;
          notifyListeners();
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use' ||
              e.code == 'credential-already-in-use') {
            // Account exists — sign in instead.
            await _auth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
          } else {
            rethrow;
          }
        }
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Registration failed';
    }
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Password reset failed';
    }
  }

  // ── Sign out ──────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _auth.signOut();
    await signInAnonymously();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Link the credential to the current anonymous account, or sign in
  /// directly if linking fails (e.g. credential already used elsewhere).
  Future<void> _linkOrSignIn(AuthCredential credential) async {
    if (_user != null && _user!.isAnonymous) {
      try {
        await _user!.linkWithCredential(credential);
        _user = _auth.currentUser;
        notifyListeners();
        return;
      } on FirebaseAuthException catch (e) {
        if (e.code != 'credential-already-in-use' &&
            e.code != 'email-already-in-use') {
          rethrow;
        }
        // Credential belongs to an existing account — sign in there instead.
      }
    }
    await _auth.signInWithCredential(credential);
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
