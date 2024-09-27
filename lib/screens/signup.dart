import 'dart:convert';
import 'package:dominos/screens/signin.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import '../services/firestore.dart';
import '../theme.dart';
import 'home.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for the form

  final FireStoreService _fireStoreService = FireStoreService();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a username';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a phone number';
    }

    final RegExp phoneRegex = RegExp(r'^\+?\(?\d{10,16}\)?$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }

    return null;
  }


  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an address';
    }


    return null;
  }



  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String username = _usernameController.text.trim();
      final String phoneNumber = _phoneNumberController.text.trim();
      final String address = _addressController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();





      // Hash the password using SHA-256 algorithm
      final hashedPassword = sha256.convert(utf8.encode(password)).toString();

      try {
        // Check if the email already exists in the database
        final existingUser = await FirebaseFirestore.instance.collection('users').doc(email).get();
        if (existingUser.exists) {
          // Email is already registered, show error message to the user
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Error'),
              content: Text('Email is already registered. Please use a different email.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        // Email is unique, proceed with user registration
        await _fireStoreService.addUser(
          email,
          username,
          phoneNumber,
          address,
          hashedPassword,

        );

        // Clear all input fields after successful registration
        _emailController.clear();
        _usernameController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _phoneNumberController.clear();



        showTopSnackBar(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust padding
          Overlay.of(context),
          CustomSnackBar.success(
            message:
            "Sign Up Successfull!",
            backgroundColor: Colors.yellow,
            textStyle: TextStyle(color: Colors.black,
            fontWeight: FontWeight.bold),
          ),
        );
        // Registration successful, navigate to login page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } catch (e) {
        // Handle registration errors
        print('Error registering user: $e');
      }
    }
  }

  void _login() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: EdgeInsets.all(26.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 18.0),
              Text('SIGN UP',
                style: capitalblackheading,
              ),
              SizedBox(
                height: 15.0,
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87), // Focused underline color
                  ),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87), // Focused underline color
                  ),                ),
                validator: _validateUsername,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87), // Focused underline color
                  ),                ),
                validator: _validateAddress,
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Focused underline color
                  ),                ),
                validator: _validatePhoneNumber,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Focused underline color
                  ),                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black87), // Focused underline color
                  ),
                ),
                obscureText: true,
                validator: _validateConfirmPassword,
              ),
              SizedBox(height: 30.0),
              SizedBox(
                width: double.infinity, // Match the width of the parent
                child: GestureDetector(
                  onTap: _register, // Call the _register function when tapped
                  child: Container(
                    decoration: BoxDecoration(
                      color: secondaryColor, // Yellow color for the rectangle
                      borderRadius: BorderRadius.circular(8.0), // Rounded corners
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.0), // Add vertical padding
                    alignment: Alignment.center, // Center the child
                    child: Text(
                      'Register',
                      style: blacksubtext,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10.0),
              TextButton(
                onPressed: _login,
                child: Text.rich(
                  TextSpan(
                    text: 'Already have an account? ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 15.0),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                  );
                },
                child: Text('Skip for Now',
                  style: TextStyle(
                      color:primaryColor,
                      fontWeight: FontWeight.w700
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