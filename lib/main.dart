import 'package:asset_cache/asset_cache.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import './pages/home_page.dart';
import 'firebase_options.dart';

final ombImg = ImageAssetCache(basePath: 'assets/omb/');
Color mainColor = Color.fromARGB(255, 57, 136, 81);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner:
          false, //This is to avoid the banner 'debug' while testing the app
      home:
          WelcomePage(), //this opens the class WelcomePage found in the file home_page.dart
    );
  }
}
