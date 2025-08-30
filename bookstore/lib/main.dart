import 'package:bookstore/home_screen.dart';
import 'package:bookstore/splashscreen.dart';
import 'package:bookstore/OrderSuccessScreen.dart';
import 'package:bookstore/CartScreen.dart'; // Import the CartScreen
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(cartItems: []), // Passing an empty list to fix the error
    );
  }
}
