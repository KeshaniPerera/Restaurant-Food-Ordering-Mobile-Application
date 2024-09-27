import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../theme.dart';

class ItemDescription extends StatefulWidget {
  final int itemId;

  const ItemDescription({Key? key, required this.itemId}) : super(key: key);

  @override
  _ItemDescriptionState createState() => _ItemDescriptionState();
}

class _ItemDescriptionState extends State<ItemDescription> {
  late Future<Map<String, dynamic>> _itemDetailsFuture;

  @override
  void initState() {
    super.initState();

    _itemDetailsFuture = _fetchItemDetails(widget.itemId.toString());
  }

  Future<Map<String, dynamic>> _fetchItemDetails(String itemId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore
          .instance
          .collection('items')
          .where(FieldPath.documentId, isEqualTo: itemId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        // Handle null values and ensure correct data types
        return {
          'itemName': data['itemName'] ?? 'No Name',
          'itemDescription': data['itemDescription'] ?? 'No Description',
          'itemPrice': (data['itemPrice'] ?? 0.0).toDouble(), // Convert to double
          'imageUrl': data['imageUrl'] ?? '',
        };
      } else {
        throw Exception('Item not found with itemId: $itemId');
      }
    } catch (e) {
      throw Exception('Failed to fetch item details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Item Details',
          style: whiteheading, // Use the whiteheading style
        ),
        backgroundColor: Color(0xff1872a4), // Set the background color of the app bar
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _itemDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final itemDetails = snapshot.data!;
            return ItemDetailsSection(
              itemName: itemDetails['itemName'] ?? 'No Name',
              itemDescription: itemDetails['itemDescription'] ?? 'No Description',
              itemPrice: itemDetails['itemPrice'] ?? 0.0,
              itemImageUrl: itemDetails['imageUrl'] ?? '',
            );
          }
        },
      ),
    );
  }
}

class ItemDetailsSection extends StatelessWidget {
  final String itemName;
  final String itemDescription;
  final double itemPrice;
  final String itemImageUrl;

  const ItemDetailsSection({
    required this.itemName,
    required this.itemDescription,
    required this.itemPrice,
    required this.itemImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            itemName,
            style:superheading,
          ),
          SizedBox(height: 8),
          Text(
            itemDescription,
            style: normaltext,
          ),
          SizedBox(height: 8),
          Text(
            '\Rs. $itemPrice',
            style: itemprice,
          ),
          SizedBox(height: 16),
          // Use Image.network with errorBuilder to handle errors
          Image.network(
            itemImageUrl,
            height: 200,
            width: 200,
            fit: BoxFit.fitWidth,
            errorBuilder: (context, error, stackTrace) {
              // Print the imageUrl along with the error message
              print('Error loading image from $itemImageUrl: $error');
              return Icon(Icons.error); // Display placeholder icon on error
            },
          ),
          SizedBox(height: 16),
          // Add a text widget to display the image URL for debugging
          //Text(
            //'Image URL: $itemImageUrl',
           // style: TextStyle(
            //  fontSize: 14,
             // color: Colors.grey,
           // ),
         // ),
        ],
      ),
    );
  }
}
