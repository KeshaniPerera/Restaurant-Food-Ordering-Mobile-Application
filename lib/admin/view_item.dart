import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firestore.dart';
import '../theme.dart';
import 'item_description.dart';

class ViewItem extends StatefulWidget {
  const ViewItem({Key? key}) : super(key: key);

  @override
  State<ViewItem> createState() => _ViewItemState();
}

class _ViewItemState extends State<ViewItem> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final FireStoreService _fireStoreService = FireStoreService();
  String _searchText = '';

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
          'imageUrl': doc['imageUrl'],

        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 45.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchText = value;
              });
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Search items...',
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.0), // Adjust the size as needed
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Items',
          style: whiteheading,
        ),
        backgroundColor: Color(0xff05af0d),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            SizedBox(height: 10.0,),
            _buildSearchBar(),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _itemListFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final itemList = snapshot.data!;
                    final filteredItems = _searchText.isEmpty
                        ? itemList
                        : itemList.where((item) {
                      final itemId = item['itemId'].toString().toLowerCase();
                      final itemName = item['itemName'].toString().toLowerCase();
                      final searchLower = _searchText.toLowerCase();

                      return itemId.contains(searchLower) ||
                          itemName.contains(searchLower);
                    }).toList();
                    return ListView.builder(
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          child: ListTile(
                            title: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item['itemId']}',
                                  style: tiletext,
                                ),
                                SizedBox(width: 25),
                                Text(
                                  '${item['itemName']}',
                                  style: tiletext,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigate to ItemDescription page and pass itemId
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ItemDescription(
                                    itemId: item['itemId'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
