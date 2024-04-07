import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/pages/home_page.dart';
import 'package:instagram_clone_firebase/pages/sign_in_page.dart';
import 'package:instagram_clone_firebase/pages/sign_up_page.dart';
import 'package:instagram_clone_firebase/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
