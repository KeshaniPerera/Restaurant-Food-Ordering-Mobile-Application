import 'package:dominos/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../admin/order_details.dart'; // Import the OrderDetails page
import '../theme.dart'; // Import the theme

class UserOrders extends StatefulWidget {
  const UserOrders({Key? key}) : super(key: key);

  @override
  State<UserOrders> createState() => _UserOrdersState();
}

class _UserOrdersState extends State<UserOrders> {
  late String _email; // Variable to store email from the provider

  @override
  void initState() {
    super.initState();
    _getEmailFromProvider(); // Initialize the email from the provider
  }

  // Function to get email from the provider
  void _getEmailFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _email = userProvider.email ?? '';
  }

  Future<List<Map<String, dynamic>>> _fetchUserOrders() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .where('email', isEqualTo: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'orderId': doc['orderId'],
          'orderStatus': doc['orderStatus'] ?? 'No Status',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username != null && userProvider.email != null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
        title: Text(
          'My Orders',
          style: whiteheading,
        ),
      ),
      body: isLoggedIn
          ? FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            List<Map<String, dynamic>> orders = snapshot.data!;
            orders.sort((a, b) {
              // Define the order of statuses
              Map<String, int> statusOrder = {
                'Pending': 0,
                'Accepted': 1,
                'Completed': 2,
                'Cancelled': 3,
              };
              return statusOrder[a['orderStatus']]! - statusOrder[b['orderStatus']]!;
            });
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Padding(
                  padding: const EdgeInsets.only(left:20.0,right:20.0,top:30.0),
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Text(
                        'Order ID: ${order['orderId']}',
                        style: tiletext,
                      ),
                      subtitle: Text(
                        'Order Status: ${order['orderStatus']}',
                        style: tiletext,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetails(orderId: order['orderId']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      )
          : Center(
        child: Text(
          'Login for order details',
          style: tiletext,
        ),
      ),
    );
  }
}
