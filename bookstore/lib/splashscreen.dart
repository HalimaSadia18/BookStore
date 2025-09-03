import 'package:bookstore/welcome_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(
      const Duration(seconds: 3),
        (){
        Navigator.pushReplacement(
            context, 
            MaterialPageRoute(builder: (context) => const WelcomeScreen())
        );
        }
    );
  }
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Background color similar to bg-gray-100
      body: Center(
        // Centers the entire content
        child: Container(
          width: 200, // Default width
          height: 200, // Default height
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 7,
                offset: const Offset(0, 3), // Shadow effect
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 200, // Smaller image size relative to container
              height: 200,
              // *** Using Image.asset for local assets ***
              child: Image.asset(
                'assets/images/logo1.png', // Is this path absolutely correct?
                // ...
              ),
            ),
          ),
        ),
      ),
    );
  }
}
