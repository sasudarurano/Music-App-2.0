import 'package:flutter/material.dart';
import 'package:music_app/screens/login_page.dart'; 
import 'package:flutter_native_splash/flutter_native_splash.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Future.delayed(const Duration(seconds: 4));
  FlutterNativeSplash.remove();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music App', 
      theme: ThemeData(
        // primarySwatch: Colors.blue, 
      ),
      home: const LoginPage(), 
    );
  }
}