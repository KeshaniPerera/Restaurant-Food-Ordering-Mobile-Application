import 'package:dominos/admin/view_users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/user_provider.dart';
import '../screens/signup.dart';
import '../theme.dart';
import 'manage_items.dart';
import 'manage_orders.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize userProvider inside the build method
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? '';
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Admin Home",
          style: whiteheading,
        ),
        centerTitle: true,
        backgroundColor: primaryColor, // Set the background color of the app bar
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
      ),
      // backgroundColor: Colors. red[100], // Set the background color of the scaffold
      body: Padding(
        padding: const EdgeInsets.all(26.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Text(
              " Hi, ${username ?? ''}", // Replace "User" with the actual username
              style: redheading,
            ),
            const SizedBox(height: 40),
            ElevatedCard(
              icon: Icons.list,
              title: "Manage Orders",
              onTap: () => _navigateTo(context, ManageOrders()),
            ),
            const SizedBox(height: 30),
            ElevatedCard(
              icon: Icons.add_card_sharp,
              title: "Manage Items",
              onTap: () => _navigateTo(context, ManageItems()),
            ),

            const SizedBox(height: 30),
            ElevatedCard(
              icon: Icons.people,
              title: "View Users",
              onTap: () => _navigateTo(context, ViewUsers()),
            ),
            SizedBox(
                height:30.0
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 50.0,
                height: 40.0,// Make button width full
                decoration: BoxDecoration(
                  color: secondaryColor, // Set background color
                  borderRadius: BorderRadius.circular(10.0), // Set circular corners
                ),
                child: TextButton(
                  onPressed: () {
                    Provider.of<UserProvider>(context, listen: false).clearUser();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                  child: Text(
                    'Log Out',
                    style:subtitle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ElevatedCard({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon,
                color: primaryColor,),
              const SizedBox(width: 16),
              Text(
                title,
                style: blacksubtext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
