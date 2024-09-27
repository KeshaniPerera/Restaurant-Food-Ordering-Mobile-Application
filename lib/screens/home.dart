import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:dominos/screens/home_tab.dart';
import 'package:flutter/material.dart';

import 'menu_tab.dart';
import 'more_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Widget> screens = [
    HomeScreen(),
    MenuScreen(initialTabIndex: 0,),
    MoreScreen(),
  ];
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Color(0xffec4f4a),

        items: [
          Icon(Icons.home, size: 30, color: Colors.white,),
          Icon(Icons.fastfood_rounded, size: 30, color: Colors.white,),
          Icon(Icons.more_horiz, size: 30, color: Colors.white,),
        ],
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

      ),

    );
  }
}
