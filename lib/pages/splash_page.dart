import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/pages/home_page.dart';
import 'package:instagram_clone_firebase/pages/sign_in_page.dart';
import 'package:instagram_clone_firebase/services/notife_service.dart';

import '../services/auth_service.dart';
import '../services/log_service.dart';
import '../services/prefs_service.dart';

class SplashPage extends StatefulWidget {
  static const String id = "splash_page";

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  _initNotification() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      LogService.i('User granted permission');
    } else {
      LogService.e('User declined or has not accepted permission');
    }

    _firebaseMessaging.getToken().then((value) async {
      String fcmToken = value.toString();
      Prefs.saveFCM(fcmToken);
      String token = await Prefs.loadFCM();
      LogService.i("FCM Token: $token");
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      String title = message.notification!.title.toString();
      String body = message.notification!.body.toString();
      LogService.i(title);
      LogService.i(body);
      LogService.i(message.data.toString());

      NotifyService().showLocalNotification(title, body);
    });
  }

  _callNextPage() {
    if (AuthService.isLoggedIn()) {
      Navigator.pushReplacementNamed(context, HomePage.id);
    } else {
      Navigator.pushReplacementNamed(context, SignInPage.id);
    }
  }

  _timer() {
    Timer(const Duration(seconds: 3), () {
      _callNextPage();
    });
  }

  @override
  void initState() {
    super.initState();
    _timer();
    _initNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Color.fromRGBO(193, 53, 132, 1),
              Color.fromRGBO(131, 58, 180, 1),
            ])),
        child: const Column(
          children: [
            Expanded(
                child: Center(
                    child: Text(
              "Instagram",
              style: TextStyle(
                  color: Colors.white, fontSize: 45, fontFamily: "Billabong"),
            ))),
            Text(
              "All rights reserved",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }
}
