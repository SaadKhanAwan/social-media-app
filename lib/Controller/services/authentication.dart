import 'dart:io';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Authentication {
  static final auth = FirebaseAuth.instance;
  Future signInWithGoogle() async {
    try {
      await InternetAddress.lookup("google.com");
      // Trigger Google Sign-In flow
      final googleUser = await GoogleSignIn().signIn();
      // Obtain authentication details from the request
      final googleAuth = await googleUser?.authentication;
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Sign in to Firebase with the credential
      return await auth.signInWithCredential(credential);
    } catch (e) {
      log('Error signing in with Google: $e');
      log('check your connection');
    }
  }

  Future signOutWithGoogle() async {
    await auth.signOut();
    await GoogleSignIn().signOut();
  }
}
