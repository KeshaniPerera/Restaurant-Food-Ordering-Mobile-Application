import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';

class OrderDetails extends StatefulWidget {
  final int orderId;

  const OrderDetails({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetails> createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late Future<DocumentSnapshot<Map<String, dynamic>>> _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> _fetchOrderDetails() async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(widget.orderId.toString()) // Use orderId directly without casting
          .get();

      return orderSnapshot;
    } catch (e) {
      throw Exception('Failed to fetch order details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: whiteheading, // Use the whiteheading style
        ),
        backgroundColor: Color(0xff1872a4), // Set the background color of the app bar
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final orderData = snapshot.data!.data()!;
            // You can now use orderData to display order details
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 15),
                  Text(
                    'Order ID:   ${orderData['orderId']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Username:   ${orderData['username']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email:   ${orderData['email']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Address:   ${orderData['address']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone Number:   ${orderData['phoneNumber']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Order Status:   ${orderData['orderStatus']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Total Price: Rs.  ${orderData['totalPrice']}',
                    style: subtitle,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Items:',
                    style: subtitle,
                  ),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      height: 50, // Adjust the height as needed
                      child: ListView(
                        children: (orderData['items'] as Map<String, dynamic>)
                            .entries
                            .map(
                              (entry) => ListTile(
                            title: Text(
                              entry.value['name'],
                              style: subtitle,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quantity:   ${entry.value['quantity']}',
                                  style: subtitle,
                                ),
                                Text(
                                  'Subtotal: Rs.  ${entry.value['subtotal']}',
                                  style: subtitle,
                                ),
                              ],
                            ),
                          ),
                        )
                            .toList(),
                      ),


                    )

                  ),

                ],
              ),
            );
          }
        },
      ),
    );
  }
}
