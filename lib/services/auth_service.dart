import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/services/prefs_service.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;

  static bool isLoggedIn() {
    final User? firebaseUser = _auth.currentUser;
    return firebaseUser != null;
  }

  static String currentUserid() {
    final User? firebaseUser = _auth.currentUser;
    return firebaseUser!.uid;
  }

  static Future<User?> signInUser(
      BuildContext context, String email, String password) async {
    try {
      _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = _auth.currentUser;
      return user;
    } catch (e) {
      return null;
    }
  }

  static Future<User?> signUpUser(
      BuildContext context, String name, String email, String password) async {
    try {
      var authResult = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = authResult.user;
      print(user.toString());
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static void signOutUser(BuildContext context) async {
    _auth.signOut();
    await Prefs.removeUserId();
  }
}
