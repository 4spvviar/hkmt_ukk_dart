import 'package:flutter/material.dart';
import 'package:hkmt_ukk_dart/log.dart';
import 'package:hkmt_ukk_dart/store_form.dart';
import 'package:hkmt_ukk_dart/store_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashPage(),
      routes: {
      "/store": (context) => const StorePage(),
      "/store-form": (context) => const StoreFormPage(),
    }
    );
  }
}
