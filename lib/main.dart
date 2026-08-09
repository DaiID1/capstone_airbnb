// import 'package:capstone_airbnb/model/category.dart';
import 'package:capstone_airbnb/view/login_screen.dart';
import 'package:capstone_airbnb/view/main_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:capstone_airbnb/provider/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await saveCategoryItems();
  runApp(
    ChangeNotifierProvider(
      create: (_) {
        final provider = LanguageProvider();
        provider.loadLanguage();
        return provider;
      },
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const AppMainScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
