import 'package:chat_portfolio/shared_prefs.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'chat_page.dart';
import 'firebase_options.dart';

import 'login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await _initializeFirebaseAuth();

  await SharedPrefs.setPrefsInstance();
  final sharedUid = SharedPrefs.fetchUid().toString();

  if (sharedUid == "" || sharedUid == null.toString()) {
    runApp(const LoginPage());
  } else {
    runApp(const ChatPage());
  }
}

Future<void> _initializeFirebaseAuth() async {
  await Firebase.initializeApp();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? user = _firebaseAuth.currentUser;
  if (user == null) {
    await _firebaseAuth.signInAnonymously();
  }
}
