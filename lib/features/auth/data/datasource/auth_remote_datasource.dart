import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthRemoteDatasource {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Đăng ký bằng Email & Password
  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Cập nhật thông tin user
    await credential.user!.updateProfile(displayName: displayName);

    // Lưu thông tin user vào Firestore
    await _firestore.collection('users').doc(credential.user!.uid).set({
      'uid': credential.user!.uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': '',
      'isOnline': true,
      'createAt': FieldValue.serverTimestamp(),
      'lastSeen': FieldValue.serverTimestamp(),
    });

    return credential;
  }

  // Đăng nhập bằng Email & Password
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Đăng nhập bằng Google
  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // User đã huỷ đăng nhập
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Đăng nhập Google đã bị huỷ.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  // Đăng nhập bằng Apple
  Future<UserCredential> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final oAuthCredential = OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );

    return await _auth.signInWithCredential(oAuthCredential);
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
