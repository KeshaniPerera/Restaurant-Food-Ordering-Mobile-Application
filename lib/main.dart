import 'package:dominos/splash_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/cart.dart';
import 'package:flutter_sendinblue/flutter_sendinblue.dart';
import 'screens/user_provider.dart'; // Import the UserProvider class
import 'package:animated_splash_screen/animated_splash_screen.dart';

// Asynchronous function to initialize Firebase and start the app
Future<void> main() async {
  // Ensure that Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Check if the app is running on the web platform
  if (kIsWeb) {
    // Initialize Firebase with specified options for web platform
    await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyBHRw40cFXUNW2SIcfsn5bLWZP0NyNGR_k",
          appId:"1:152546575560:web:810b4a2bd91416cbb651fd",
          messagingSenderId: "152546575560",
          projectId: "hungry-bunny-6ef57"
      ),
    );
  } else {
    // Initialize Firebase for non-web platforms
    await Firebase.initializeApp();
  }
  Sendinblue.initialize(
    configuration: SendinblueConfiguration(
      apiKey:
      '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',
    ),
  );

  // Start the Flutter app by running MyApp
  runApp(const MyApp());
}

// MyApp class, which represents the root of the application
class MyApp extends StatelessWidget {
  // Constructor for MyApp class
  const MyApp({Key? key});

  // Build method to define the UI structure of the application
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
      ],
      // Return MaterialApp widget which defines the basic structure of the app
      child: MaterialApp(
        title: 'Hungry Bunny',
        debugShowCheckedModeBanner: false,
        home: AnimatedSplashScreen(
          splash: Image.asset(
            'assets/logo.png',
            height: 200,
            scale: 3.5,
          ),
          nextScreen: WelcomeScreen(),
          splashTransition: SplashTransition.scaleTransition,
          duration: 3,
        ),

      ),
    );
  }
}
