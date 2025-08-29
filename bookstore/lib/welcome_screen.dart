import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get screen height for responsive positioning
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack( // Use a single Stack for the entire screen
        children: [
          Column( // This Column holds the image and text/buttons
            children: [
              // Top Section: Background Image
              Expanded(
                flex: 1, // Takes roughly half the screen height
                child: Container(
                  color: Colors.white, // Ensure white background for contrast
                  child: Image.asset(
                    'assets/images/welcome.png', // Your background image
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              // Bottom Section: Text and Buttons
              Expanded(
                flex: 1, // Takes roughly half the screen height
                child: Container(
                  color: Colors.white, // Background color for the text/button area
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end, // Align contents to the bottom
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Read more and stress less with our online book shopping app.Shop from anywhere you are and discover titles that you love. Happy reading!',
                          style: TextStyle(
                            color: Colors.grey[600], // Lighter grey for text on black background
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 50),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              // Handle Get Started button press
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black, // White button on black background
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(
                                color: Colors.white, // Black text on white button
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextButton(
                          onPressed: () {
                            // Handle Register button press
                          },
                          child: Text(
                            'Register',
                            style: TextStyle(
                              color: Colors.black, // White text for register
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Logo - Positioned centrally over both sections
          Positioned(
            top: screenHeight / 2 - (190 / 2), // Center vertically
            left: 0,
            right: 0,
            child: Center(
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
                    width: 150, // Smaller image size relative to container
                    height: 150,
                    // *** Using Image.asset for local assets ***
                    child: Image.asset(
                      'assets/images/logo.png', // Is this path absolutely correct?
                      // ...
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}