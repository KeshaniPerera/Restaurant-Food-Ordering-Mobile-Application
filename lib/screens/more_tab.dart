import 'package:dominos/screens/signup.dart';
import 'package:dominos/screens/user_orders_list.dart';
import 'package:dominos/screens/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'about_us_page.dart';
import 'home.dart';
import 'user_provider.dart';
import 'cart.dart';

class MoreScreen extends StatefulWidget {
  const MoreScreen({Key? key}) : super(key: key);

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context); // Get the existing instance of Cart

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    if (userProvider.username != null && userProvider.email != null) {
                      // If username and email are set, display Sign Out ListTile
                      return ListTile(
                        leading: Icon(Icons.logout, color: Colors.deepOrange),
                        title: Text(
                          'Sign Out',
                          style: tiletext,
                        ),
                        onTap: () {
                          userProvider.clearUser(); // Clear user data
                          cart.clearCart(); // Clear cart
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomePage(),
                            ),
                          );
                        },
                      );
                    } else {
                      // If username and email are not set, display Sign In TextTile
                      return ListTile(
                        leading: Icon(Icons.login, color: Colors.deepOrange),
                        title: Text(
                          'Sign Up',
                          style: tiletext,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationPage(),
                            ),
                          );
                          // Navigate to sign in page
                        },
                      );
                    }
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.person_2_outlined, color: Colors.deepOrange),
                  title: Text(
                    'My Profile',
                    style: tiletext,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserProfile()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.bookmark_border, color: Colors.deepOrange),
                  title: Text(
                    'My Orders',
                    style: tiletext,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UserOrders()),
                    );
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.notification_add_sharp, color: Colors.deepOrange),
                  title: Text(
                    'Notifications',
                    style: tiletext,
                  ),
                  onTap: () {},
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.account_balance_outlined, color: Colors.deepOrange),
                  title: Text(
                    'About Us',
                    style: tiletext,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AboutUs()),
                    );
                  },
                ),
                Divider(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

