import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../services/firestore.dart';
import '../theme.dart';

class DeleteItem extends StatefulWidget {
  const DeleteItem({Key? key}) : super(key: key);

  @override
  State<DeleteItem> createState() => _DeleteItemState();
}

class _DeleteItemState extends State<DeleteItem> {

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://hungry-bunny-6ef57.appspot.com',
  );
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final FireStoreService _fireStoreService = FireStoreService();

  @override
  void initState() {
    super.initState();
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('items').get();

      return querySnapshot.docs.map((doc) {
        return {
          'itemId': doc['itemId'],
          'itemName': doc['itemName'],
          'imageUrl':doc['imageUrl']
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Future<void> _deleteItem(int itemId, String imageUrl) async {
    try {
      await _fireStoreService.deleteItem(itemId,imageUrl);

      showToast(
        'Item Deleted Successfully!',
        context: context,
        textStyle: itemname,
        backgroundColor: Colors.yellow,
        textPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
        borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(10.0, 20.0),
          bottom: Radius.elliptical(10.0, 20.0),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.ltr,
        position: StyledToastPosition(
          align: Alignment.bottomCenter,
          offset: 20.0,
        ),
      );
      setState(() {
        _itemListFuture = _fetchItems();
      });
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to delete item",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Delete Item",
          style: whiteheading,
        ),
        backgroundColor: Color(0xff05af0d),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _itemListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final itemList = snapshot.data!;
              return ListView.builder(
                itemCount: itemList.length,
                itemBuilder: (context, index) {
                  final item = itemList[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: ListTile(
                      title: Row(
                        children: [
                          Text(
                            '${item['itemId']}',
                            style: tiletext,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '${item['itemName']}',
                            style: tiletext,
                          ),
                        ],
                      ),
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Confirm Deletion'),
                            content: Text('Are you sure you want to delete this item?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  _deleteItem(item['itemId'], item['imageUrl']);
                                  Navigator.of(context).pop();

                                },
                                child: Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      trailing: Icon(Icons.delete,
                        color: primaryColor, // Use primaryColor for icon color
                      ),

                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
