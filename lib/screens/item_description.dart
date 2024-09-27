import 'package:dominos/screens/signup.dart';
import 'package:dominos/screens/user_provider.dart';
import 'package:dominos/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import '../services/firestore.dart';
import 'cart.dart';
import 'cart_page.dart';
import 'item_model.dart';

class DescriptionPage extends StatefulWidget {
  final String itemName;
  final double itemPrice;
  final String itemDescription;
  final String imageUrl;
  final String categoryName;
  final int itemId;

  const DescriptionPage({
    Key? key,
    required this.itemName,
    required this.itemPrice,
    required this.itemDescription,
    required this.imageUrl,
    required this.categoryName,
    required this.itemId, // Add itemId to the constructor


  }) : super(key: key);

  @override
  State<DescriptionPage> createState() => _ItemDescriptionPageState();
}

class _ItemDescriptionPageState extends State<DescriptionPage> {
  bool isFavorite = false;
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    checkIfFavorite();
  }

  Future<void> checkIfFavorite() async {
    // Get the currently logged-in user's email
    String email = Provider.of<UserProvider>(context, listen: false).email ?? '';

    // Check if the current item is in the user's favorites
    bool isItemFavorite = await _fireStoreService.isFavorite(email, widget.itemId);

    setState(() {
      isFavorite = isItemFavorite;
    });
  }
  bool isEmailAndUsernameSet() {
    String? email = Provider.of<UserProvider>(context, listen: false).email;
    String? username = Provider.of<UserProvider>(context, listen: false).username;
    return email != null && email.isNotEmpty && username != null && username.isNotEmpty;
  }

  final superheading = TextStyle(
      fontFamily: 'Boring-Sans-A-Bold',
      fontSize: 21.0,
      color: Colors.black,
      fontWeight: FontWeight.w800);
  final heading = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 23.0,
      color: Colors.black,
      fontWeight: FontWeight.w600);
  final redheading = TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 21.0,
      color: Color(0xffec4f4a),
      fontWeight: FontWeight.w600);
  final description = TextStyle(
      fontSize: 16.0,
    color:Colors.black87,
      fontWeight: FontWeight.w600);

  final itemname = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  final itemprice = TextStyle(
      fontFamily: 'Boring-Sans-A-Bold',
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.red);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        title: Text(
          widget.categoryName,
          style: categoryname,
        ),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: AssetImage('assets/image background.png'),
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.itemName,
                    style: superheading,
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : null,
                      size: 30,
                    ),
                    onPressed: () async {
                      // Get the currently logged in user's email
                      String email = Provider.of<UserProvider>(context, listen: false).email ?? '';

                      setState(() {
                        isFavorite = !isFavorite;
                      });

                      if (isFavorite && (isEmailAndUsernameSet())) {
                        await _fireStoreService.addFavorite(email, widget.itemId);
                      } else if (!isFavorite && (isEmailAndUsernameSet())){
                        await _fireStoreService.deleteFavorite(email, widget.itemId);
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.itemDescription,
                style: description,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Price:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    'Rs ${widget.itemPrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 35.0,),
              Center(
                child: Container(
                  width: 155.0,
                  height: 50.0,
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: TextButton(
                    onPressed: () {
                      String? username = Provider.of<UserProvider>(context, listen: false).username;

                      if (username != null && username.isNotEmpty) {
                        Item item = Item(
                          name: widget.itemName,
                          price: widget.itemPrice,
                          imageUrl: widget.imageUrl,
                          quantity: 1,
                          subtotal: widget.itemPrice,
                        );
                        Provider.of<Cart>(context, listen: false).addItem(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Item Added to cart'),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationPage()),
                        );
                        showTopSnackBar(
                          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          Overlay.of(context),
                          CustomSnackBar.success(
                            message: "Please login to place your order",
                            backgroundColor: Colors.lightGreenAccent,
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Add to Cart',
                      style: subtitle,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CartPage()),
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(
          Icons.shopping_cart,
          color: Colors.white,
        ),
      ),
    );
  }
}