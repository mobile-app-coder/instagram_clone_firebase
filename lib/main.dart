import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/pages/home_page.dart';
import 'package:instagram_clone_firebase/pages/sign_in_page.dart';
import 'package:instagram_clone_firebase/pages/sign_up_page.dart';
import 'package:instagram_clone_firebase/pages/splash_page.dart';
import 'package:instagram_clone_firebase/services/notife_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDO7TzW8YExowKNl7Vfvd4nrmdyNOy2p3o",
        // paste your api key here
        appId: "1:1059403096267:android:349a550803ae43b50dfb4e",
        //paste your app id here
        messagingSenderId: "1059403096267",
        //paste your messagingSenderId here
        projectId: "instagram-af6ed",
        //
        storageBucket:
            "instagram-af6ed.appspot.com" // paste your project id here
        ),
  );
  await NotifyService().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashPage(),
      routes: {
        HomePage.id: (context) => HomePage(),
        SplashPage.id: (context) => SplashPage(),
        SignInPage.id: (context) => SignInPage(),
        SignUpPage.id: (context) => SignUpPage()
      },
    );
  }
}
