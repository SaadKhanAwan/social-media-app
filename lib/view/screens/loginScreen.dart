import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/view/screens/home_screen.dart';
import 'package:social_media_app/Controller/services/authentication.dart';
import 'package:social_media_app/Controller/services/firebase_api.dart';
import 'package:social_media_app/view/widgets/progress.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    super.initState();
  }

  final authentication = Authentication();
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo, Colors.purple],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "FlutterShare",
              style: TextStyle(
                  fontFamily: "Signatra", fontSize: 80, color: Colors.white),
            ),
            SizedBox(
              height: 70,
              width: 250,
              child: GestureDetector(
                onTap: () {
                  handleServices();
                },
                child: isloading == false
                    ? Image.asset(
                        "assets/images/google_signin_button.png",
                        fit: BoxFit.fill,
                      )
                    : circulaprogress(Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  handleServices() async {
    try {
      setState(() {
        isloading = true;
      });
      await authentication.signInWithGoogle().then((value) async {
        if (FirebaseAuth.instance.currentUser != null) {
          if ((await APi.userExist())) {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
            APi.getSelfInfo();
          } else {
            APi.createUSer().then((value) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            });
          }
        }
        setState(() {
          isloading = false;
        });
      });
    } catch (e) {
      setState(() {
        isloading = false;
      });
    }
  }
}
