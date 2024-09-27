import 'package:dominos/screens/user_orders_list.dart';
import 'package:dominos/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dominos/screens/user_provider.dart';
import 'cart.dart';
import '../services/firestore.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

class CartPage extends StatefulWidget {
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final fireStoreService = FireStoreService();

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Calculate total price
    double totalPrice = cart.items.values.fold(
      0,
          (previousValue, item) => previousValue + (item.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text('My Cart',
              style: whiteheading,
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(26.0),
        child: cart.items.isEmpty
            ? Center(
          child: Image.asset(
            'assets/empty cart.png',
            fit: BoxFit.contain,

          ),
        )
        :Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cart.items.length,
                itemBuilder: (context, index) {
                  var item = cart.items.values.toList()[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: 20.0),
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.yellow[100],
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(
                        color: Color(0xfff7b2b2), // Set the color of the stroke
                        width: 1.0, // Adjust the width of the stroke
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.network(
                          item.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: itemname,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Rs. ${item.price}',
                                style: itemprice,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // Increase quantity
                                cart.increaseQuantity(item.name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 15, // Adjust icon size
                                ),
                              ),
                            ),
                            SizedBox(height: 8.0,),
                            Text(
                              'Qty: ${item.quantity}',
                              style: itemname,
                            ),
                            SizedBox(height: 8.0,),
                            GestureDetector(
                              onTap: () {
                                // Decrease quantity
                                cart.decreaseQuantity(item.name);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  color: Colors.white,
                                  size: 15, // Adjust icon size
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 8.0,),
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            // Remove item
                            cart.removeItem(item.name);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 10.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                'Total: Rs. $totalPrice',
                style:heading,
              ),
            ),
            SizedBox(height: 20),
            Container(
              width: 155.0,
              height: 50.0,
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: TextButton(
                onPressed: () async {
                  String email = userProvider.email ?? '';
                  String username = userProvider.username ?? '';
                  // Fetch user document from Firestore
                  DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(email)
                      .get();
                  String phoneNumber = userSnapshot['phoneNumber'] ?? '';
                  String address = userSnapshot['address'] ?? '';
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Confirm Order'),
                        content: Text('Are you sure to confirm Order?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              // Dismiss dialog
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              fireStoreService.addPendingOrder(cart.items, totalPrice, username, email, phoneNumber, address);

                              Navigator.of(context).pop();
                              showTopSnackBar(
                                padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Adjust padding
                                Overlay.of(context),
                                CustomSnackBar.success(
                                  message:
                                  "Order Placed! Please check order status for accept confirmation",
                                  backgroundColor: Colors.yellow,
                                  textStyle: TextStyle(color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              );
                              cart.clearCart();
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => UserOrders()),
                              );

                            },
                            child: Text('Ok'),
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(secondaryColor), // Set the background color
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                ),
                child: Text('Confirm Order',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
