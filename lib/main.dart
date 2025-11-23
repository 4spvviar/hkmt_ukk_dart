import 'package:flutter/material.dart';
import 'package:toko_ku/log.dart';
import 'package:toko_ku/store_form.dart';
import 'package:toko_ku/store_page.dart';

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
