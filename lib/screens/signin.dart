import 'dart:convert';
import 'package:dominos/screens/user_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:crypto/crypto.dart';
import 'package:dominos/admin/admin_home.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import 'home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Key for the form

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an email address';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password';
    }
    return null;
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // Query the "users" collection for the user with the provided email
        final DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

        // Check if the user exists and the password matches
        if (userDoc.exists) {
          final String storedHashedPassword =
          (userDoc.data() as Map<String, dynamic>)['password'];

          final String username = (userDoc.data() as Map<String, dynamic>)['username'];

          // Hash the entered password
          final String hashedPassword = sha256.convert(utf8.encode(password)).toString();
          if (storedHashedPassword == hashedPassword) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
            );

            Provider.of<UserProvider>(context, listen: false).setUser(username, email);
            return; // Exit the method after successful login
          }
        } else if (email == "hungrybunny@gmail.com" && password == "admin123") {
          // Authentication successful, navigate to admin home page
          Provider.of<UserProvider>(context, listen: false).setUser("Admin", email);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHome()),
          );
          return; // Exit the method after successful login
        } else {
          // User not found or password mismatch, show error message
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Login Failed'),
                content: Text('Invalid email or password'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } catch (e) {
        // Handle login errors
        print('Error logging in: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // This will add the back arrow button

      ),
      body: Padding(
        padding: EdgeInsets.all(26.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('SIGN IN',
                style: capitalblackheading,
              ),
              SizedBox(height: 36.0),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Focused underline color
                  ),
                ),
                validator: _validateEmail,
              ),
              SizedBox(height: 8.0),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password',
                  labelStyle: TextStyle(fontWeight: FontWeight.w600,color:Color(0xff3b3b2e)),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Underline color
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.black45), // Focused underline color
                  ),
                ),
                obscureText: true,
                validator: _validatePassword,
              ),
              SizedBox(height: 66.0),
              GestureDetector(
                onTap: _login,
                child: Container(
                  decoration: BoxDecoration(
                    color: secondaryColor, // Yellow color for the rectangle
                    borderRadius: BorderRadius.circular(8.0), // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.0), // Add vertical padding
                  alignment: Alignment.center, // Center the child
                  child: Text(
                    'Login',
                    style: blacksubtext,

                  ),
                ),
              ),
              SizedBox(height: 60.0),

              Image.asset(
                "assets/logo flavicon.png",
                height: 150,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
