import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// define the AuthService class
class AuthService with ChangeNotifier {
  // initialize the FirebaseAuth instance, GoogleSignIn instance, and FirebaseFirestore instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get the current user
  User? get currentUser => _auth.currentUser;
  // get a stream of user changes
  Stream<User?> get user => _auth.authStateChanges();

// sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _updateUserData(result.user);
      notifyListeners();
      return result;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // sign up with email and password
  Future<UserCredential?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await _updateUserData(result.user);
      notifyListeners();
      return result;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  // sign in with Google

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        // Obtain the auth details from google sign in
        final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

        // Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        // Sign in with credential
        UserCredential result = await _auth.signInWithCredential(credential);
        await _updateUserData(result.user);
        notifyListeners();
        return result;
      }
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  // key for the navigator 
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  // sign out
  Future<void> signOut(BuildContext context) async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    notifyListeners();
    // Navigate back to the login screen
    navigatorKey.currentState?.pushReplacementNamed('/auth');
  }

  Future<void> _updateUserData(User? user) async {
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSeen': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }
      await _updateUserData(user);
      notifyListeners();
    }
  }
}