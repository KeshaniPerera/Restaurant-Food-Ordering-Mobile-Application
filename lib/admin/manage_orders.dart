import 'package:flutter/material.dart';
import 'order_list.dart'; // Import the "order_list" page
import '../theme.dart'; // Import the theme

class ManageOrders extends StatefulWidget {
  const ManageOrders({Key? key}) : super(key: key);

  @override
  State<ManageOrders> createState() => _ManageOrdersState();
}

class _ManageOrdersState extends State<ManageOrders> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Orders',
          style: whiteheading, // Use the whiteheading style
        ),
        backgroundColor: primaryColor, // Set the background color of the app bar
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCard(
              icon: Icons.pending_actions,
              title: "Pending Orders",
              onTap: () => _navigateToOrderList(context, 'Pending'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.check_circle,
              title: "Accepted Orders",
              onTap: () => _navigateToOrderList(context, 'Accepted'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.done_all,
              title: "Completed Orders",
              onTap: () => _navigateToOrderList(context, 'Completed'),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.cancel,
              title: "Cancelled Orders",
              onTap: () => _navigateToOrderList(context, 'Cancelled'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToOrderList(BuildContext context, String orderStatus) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => OrderList(orderStatus: orderStatus)),
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
              Icon(icon, color: primaryColor),
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
