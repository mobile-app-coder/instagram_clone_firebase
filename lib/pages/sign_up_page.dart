import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_firebase/pages/sign_in_page.dart';

import '../models/member_model.dart';
import '../services/auth_service.dart';
import '../services/db_service.dart';
import '../services/prefs_service.dart';
import '../services/util_service.dart';
import 'home_page.dart';

class SignUpPage extends StatefulWidget {
  static const String id = "sing_up_page";

  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  var isLoading = false;
  var emailController = TextEditingController();
  var fullnameController = TextEditingController();
  var passwordController = TextEditingController();
  var cpasswordController = TextEditingController();

  _doSignUp() async {
    String fullname = fullnameController.text.toString().trim();
    String email = emailController.text.toString().trim();
    String password = passwordController.text.toString().trim();
    String cpassword = cpasswordController.text.toString().trim();

    if (fullname.isEmpty || email.isEmpty || password.isEmpty) return;

    if (cpassword != password) {
      Utils.fireToast("Password and confirm password does not match");
      return;
    }

    setState(() {
      isLoading = true;
    });

    AuthService.signUpUser(context, fullname, email, password)
        .then((firebaseUser) => {
              _getFirebaseUser(firebaseUser, Member(fullname, email)),
            });
  }

  _getFirebaseUser(User? firebaseUser, Member member) async {
    setState(() {
      isLoading = false;
    });
    if (firebaseUser != null) {
      _saveMemberIdToLocal(firebaseUser);
      _saveMemberToCloud(member);

      _callHomePage();
    } else {
      Utils.fireToast("Check your information");
    }
  }

  _saveMemberIdToLocal(User firebaseUser) async {
    await Prefs.saveUserId(firebaseUser.uid);
  }

  _saveMemberToCloud(Member member) async {
    await DBService.storeMember(member);
  }

  _callHomePage() {
    Navigator.pushReplacementNamed(context, HomePage.id);
  }

  _callSignInPage() {
    Navigator.pushReplacementNamed(context, SignInPage.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            Color.fromRGBO(193, 53, 132, 1),
            Color.fromRGBO(131, 58, 180, 1),
          ])),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Instagram",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontFamily: "Billabong"),
                  ),
                  //#name
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 50,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7)),
                    child: TextField(
                      controller: fullnameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Username",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.white54)),
                    ),
                  ),

                  //#email
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 50,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7)),
                    child: TextField(
                      controller: emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Email",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.white54)),
                    ),
                  ),

                  //#password
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 50,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7)),
                    child: TextField(
                      obscureText: true,
                      controller: passwordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Password",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.white54)),
                    ),
                  ),

                  //#confirm password
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    height: 50,
                    padding: EdgeInsets.only(left: 10, right: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(7)),
                    child: TextField(
                      obscureText: true,
                      controller: cpasswordController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          hintText: "Confirm password",
                          border: InputBorder.none,
                          hintStyle:
                              TextStyle(fontSize: 17, color: Colors.white54)),
                    ),
                  ),
                  //#signin
                  GestureDetector(
                    onTap: () {
                      _doSignUp();
                    },
                    child: Container(
                        margin: EdgeInsets.only(top: 10),
                        height: 50,
                        padding: EdgeInsets.only(left: 10, right: 10),
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(7)),
                        child: const Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(color: Colors.white, fontSize: 17),
                          ),
                        )),
                  ),
                ],
              )),

              //footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Do have an account already?",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  GestureDetector(
                      onTap: () {
                        //_callSignUpPage();
                        _callSignInPage();
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ],
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    ));
  }
}
