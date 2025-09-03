import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // For Firestore Database
import 'package:intl_phone_field/intl_phone_field.dart'; // Import the new package
import 'package:intl_phone_field/phone_number.dart'; // Import PhoneNumber for type safety

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  // Controllers to get text from the input fields
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _phoneNumber; // To store the full international phone number

  bool _isLoading = false; // To show a loading indicator during registration

  @override
  void dispose() {
    // Clean up the controllers when the widget is removed from the widget tree
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Function to handle user registration
  Future<void> _createAccount() async {
    // Set loading state to true to show indicator and disable button
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Register user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Get the newly created user's ID
      String? uid = userCredential.user?.uid;

      // 2. Save user data to Firestore (if registration was successful)
      if (uid != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'uid': uid,
          'email': _emailController.text.trim(),
          'phoneNumber': _phoneNumber, // Save phone number if collected
          'createdAt': Timestamp.now(), // Timestamp of account creation
          // You can add more fields here like 'name', 'profileImageUrl', etc.
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created and data saved!')),
        );

        // TODO: Navigate to the next screen (e.g., Home screen or profile setup)
        // Example: Navigator.pushReplacementNamed(context, '/home');
        // For now, we'll just pop the screen to go back to the splash/welcome screen
        Navigator.pop(context);
      } else {
        // This case should ideally not happen if createUserWithEmailAndPassword succeeds
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User ID not found after registration.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication specific errors
      String errorMessage;
      if (e.code == 'weak-password') {
        errorMessage = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'The account already exists for that email.';
      } else {
        errorMessage = 'Firebase Auth Error: ${e.message}';
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      // Handle any other unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
        ),
      );
    } finally {
      // Always set loading state to false after the operation completes or fails
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Default white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Title
              const Text(
                'Create\nAccount',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 30),

              // Profile Picture Upload Area (currently just an icon)
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0C0C0C),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: Color(0xFF000000),
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Email Input Field
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Email',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Password Input Field
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  suffixIcon: const Icon(Icons.visibility_off),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Phone Number Input Field (Optional)
              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: 'Your number',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  counterText: "",
                ),
                initialCountryCode: 'PK',
                onChanged: (phone) {
                  _phoneNumber = phone.completeNumber;
                },
                dropdownIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.black54,
                ),
                dropdownIconPosition: IconPosition.trailing,
                showDropdownIcon: true,
                flagsButtonPadding: const EdgeInsets.only(left: 8),
                disableLengthCheck: false,
              ),

              const SizedBox(height: 30),

              // Done Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _createAccount, // Disable button if loading
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF000000),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                  _isLoading // Show a loading indicator if _isLoading is true
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Cancel Link
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}