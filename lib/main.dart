import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/Controller/services/fcm_services.dart';
import 'package:social_media_app/firebase_options.dart';
import 'package:social_media_app/view/screens/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FCMService.initializeFCM();
  FCMService.configure();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            centerTitle: true,
            backgroundColor: Colors.teal,
            iconTheme: IconThemeData(color: Colors.white, size: 35),
            titleTextStyle: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
      ),
      home: const SplashScreen(),
    );
  }
}
