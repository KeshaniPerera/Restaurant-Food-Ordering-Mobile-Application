import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:dominos/screens/item_model.dart';
import 'package:flutter_sendinblue/flutter_sendinblue.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FireStoreService {
  // Collection reference for 'notes' collection
  final CollectionReference notes = FirebaseFirestore.instance.collection('notes');
  final CollectionReference items = FirebaseFirestore.instance.collection('items');
  final CollectionReference users = FirebaseFirestore.instance.collection('users');
  final CollectionReference favorites = FirebaseFirestore.instance.collection('favorites');
  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://hungry-bunny-6ef57.appspot.com',
  );

  Future<void> sendTransactionalEmail(String recipientEmail, String subject, String body) async {

    String apiKey = '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';

    // Sendinblue API endpoint for sending transactional emails
    String apiUrl = 'https://api.sendinblue.com/v3/smtp/email';

    // Construct the request body
    Map<String, dynamic> requestBody = {
      'sender': {'email': 'keshani20001@gmail.com'},
      'to': [{'email': recipientEmail}],
      'subject': subject,
      'htmlContent': body,
    };

    // Make the HTTP POST request
    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'api-key': apiKey,
        },
        body: json.encode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 201) {
        print('Email sent successfully');
      } else {
        print('Failed to send email. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending email: $e');
    }
  }


  // Method to add a new note to Firestore
  Future<void> addUser(String email, String username, String phoneNumber, String address, String hashedPassword) {
    // Add a new document to the 'notes' collection with note content and timestamp
    return users.doc(email).set({
      'email': email,
      'username': username,
      'phoneNumber':phoneNumber,
      'address':address,
      'password': hashedPassword,
    });
  }

  // Method to add a new note to Firestore
  Future<void> addItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl, bool isBestSelling) {
    // Set the document ID to itemId while adding a new document
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).set({
      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription': itemDescription,
      'itemPrice': itemPrice,
      'imageUrl': ImageUrl,
      'isBestSelling': isBestSelling,
    });
  }


  Stream<QuerySnapshot> getItemsStream() {
    // Stream of snapshots from 'notes' collection ordered by timestamp in descending order
    final itemsStream = items.orderBy('itemId', descending: true).snapshots();
    return itemsStream;
  }

  Stream<QuerySnapshot> getUsersStream() {
    // Stream of snapshots from 'notes' collection ordered by timestamp in descending order
    final itemsStream = users.orderBy('email', descending: true).snapshots();
    return itemsStream;
  }


  // Method to update an existing note in Firestore
  Future<void> updateItem(int itemId, String categoryName, String itemName, String itemDescription, double itemPrice, String ImageUrl, bool isBestSelling) {
    // Update the document with specified docID in 'notes' collection with new note content, subtext, and updated timestamp
    return FirebaseFirestore.instance.collection('items').doc(itemId.toString()).update({

      'itemId': itemId,
      'categoryName': categoryName,
      'itemName': itemName,
      'itemDescription':itemDescription,
      'itemPrice':itemPrice,
      'imageUrl':ImageUrl,
      'isBestSelling': isBestSelling,

    });
  }

  Future<void> addPendingOrder(Map<String, Item> items, double totalPrice, String username, String email, String phoneNumber, String address) async {
    try {
      // Get the latest order ID from Firestore
      int latestOrderId = await _getLatestOrderId();

      // Generate the next order ID
      int orderId = latestOrderId + 1;

      // Create a reference to the pendingOrders collection
      CollectionReference orders = FirebaseFirestore.instance.collection('orders');

      // Set the orderId as the document ID
      DocumentReference orderRef = orders.doc(orderId.toString());

      // Store the order data in the document
      await orderRef.set({
        'orderId': orderId,
        'email': email,
        'username': username,
        'address': address,
        'phoneNumber': phoneNumber,
        'totalPrice': totalPrice,
        'orderStatus': "Pending",
        'items': items.map((key, item) => MapEntry(key, {
          'name': item.name,
          'quantity': item.quantity,
          'subtotal':item.subtotal,
        })),
        'timestamp': DateTime.now(),
      });

      print('Order added with ID: $orderId');
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<int> _getLatestOrderId() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').orderBy('orderId', descending: true).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['orderId'];
      } else {
        return 0; // If no orders found, start from 0
      }
    } catch (e) {
      print('Error getting latest order ID: $e');
      return 0; // Return 0 if error occurs
    }
  }


  Future<void> updateAcceptedOrder(int orderId) async {
    try {
      // Query to find the document with matching orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      // Check if a document with the specified orderId exists
      if (querySnapshot.docs.isNotEmpty) {

        // Get a reference to the document
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Accepted"
        await orderRef.update({
          'orderStatus': 'Accepted',
        }

        );

        String recipientEmail = querySnapshot.docs.first['email'];
        await sendTransactionalEmail(recipientEmail, 'Hungry Bunny ^_^ Order Accepted', 'Your order with ID $orderId has been Accepted.');
        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> updateCancelledOrder(int orderId) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Cancelled"
        await orderRef.update({
          'orderStatus': 'Cancelled',
        });
        String recipientEmail = querySnapshot.docs.first['email'];
        await sendTransactionalEmail(recipientEmail, 'Hungry Bunny #_# Order Cancelled', 'Sorry, your order with ID $orderId has been Cancelled.');

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  Future<void> updateCompletedOrder(int orderId) async {
    try {
      // Query to find the document with matching orderId
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('orders').where('orderId', isEqualTo: orderId).limit(1).get();

      // Check if a document with the specified orderId exists
      if (querySnapshot.docs.isNotEmpty) {
        // Get a reference to the document
        DocumentReference orderRef = querySnapshot.docs.first.reference;

        // Update the order status to "Cancelled"
        await orderRef.update({
          'orderStatus': 'Completed',
        });
        String recipientEmail = querySnapshot.docs.first['email'];
        await sendTransactionalEmail(recipientEmail, 'Order Completed', 'Your order with ID $orderId has been Completed.');

        print('Order status updated successfully for id: $orderId');
      } else {
        print('No document found with orderId: $orderId');
      }
    } catch (e) {
      print('Error updating order status: $e');
    }
  }


  Stream<QuerySnapshot> getBestSellingStream() {
    // Stream of snapshots from 'notes' collection where 'favorite' field is true
    final bestSellingStream = items.where('isBestSelling', isEqualTo: true).snapshots();
    return bestSellingStream;
  }



  Future<void> deleteItem(int itemId, String imageUrl) async {
    try {
      // Delete the document from Firestore collection
      await items.doc(itemId.toString()).delete();

      // Extract the image name from the URL
      String imageName = extractFilenameFromUrl(imageUrl);
      print('Image Name: $imageName'); // Print the extracted image name

      // Reference the image in Firebase Storage
      Reference imageRef = _storage.ref().child('images/$imageName');

      // Delete the image from Firebase Storage
      await imageRef.delete();
    } catch (error) {
      throw Exception('Failed to delete item: $error');
    }
  }

  Future<void> addFavorite(String email, int itemId) {
    // Set the document ID to a combination of email and itemId
    String documentId = '$email-$itemId';

    return FirebaseFirestore.instance.collection('favorites').doc(documentId).set({
      'email': email,
      'itemId': itemId,
    });
  }

  Future<void> deleteFavorite(String email, int itemId) async {
    try {
      // Delete the document where email=email and itemId=itemId
      await FirebaseFirestore.instance
          .collection('favorites')
          .where('email', isEqualTo: email)
          .where('itemId', isEqualTo: itemId)
          .get()
          .then((querySnapshot) {
        querySnapshot.docs.forEach((doc) async {
          await doc.reference.delete();
        });
      });
    } catch (e) {
    }
  }

  Future<bool> isFavorite(String email, int itemId) async {
    try {
      final FirebaseFirestore _firestore = FirebaseFirestore.instance;
      // Query the Firestore collection to check if the item is marked as favorite
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firestore
          .collection('favorites')
          .where('email', isEqualTo: email)
          .where('itemId', isEqualTo: itemId)
          .get();

      // Check if any documents are returned
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      // Handle errors if any
      print("Error checking favorite: $e");
      return false;
    }
  }


  String extractFilenameFromUrl(String imageUrl) {
    try {
      List<String> parts = imageUrl.split('/');
      String encodedFilename = parts.last;
      String decodedFilename = Uri.decodeComponent(encodedFilename);
      String filename = decodedFilename.split('/').last.split('?').first;
      return filename;
    } catch (e) {
      throw Exception('Failed to extract filename from URL: $e');
    }
  }



}
