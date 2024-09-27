import 'package:dominos/screens/signup.dart';
import 'package:dominos/theme.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeScreen extends StatelessWidget {
  final controller = PageController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: controller,
                children: [
                  Tab1(),
                  Tab2(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: SmoothPageIndicator(
                controller: controller,
                count: 2,
                effect: CustomizableEffect(
                  activeDotDecoration: DotDecoration(
                    width: 25,
                    height: 25,
                    color: Colors.yellow,
                    rotationAngle: 180,
                    verticalOffset: -10,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(5.0),
                      bottomLeft: Radius.circular(5.0),
                      bottomRight: Radius.circular(10.0),
                    ),
                  ),
                  dotDecoration: DotDecoration(
                    width: 11,
                    height: 11,
                    color: Color(0xffec4f4a),
                    borderRadius: BorderRadius.circular(16),
                    verticalOffset: 0,
                  ),
                  spacing: 6.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Tab1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/splash screen 1.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

class Tab2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/splash screen 2.png'),
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          bottom: 40,
          right: 20,
          left: 20, // Center the TextButton horizontally
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () {
                // Navigate to another page here
                // For example:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RegistrationPage()),
                );
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.red, // Background color
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text(
                'LETS GET STARTED',
                style: capitalheading,
              ),
            ),
          ),
        ),
      ],
    );
  }
}


