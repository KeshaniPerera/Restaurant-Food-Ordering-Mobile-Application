import 'package:dominos/screens/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'cart_page.dart';
import 'item_description.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _checkUserLoggedIn();
  }

  Future<void> _checkUserLoggedIn() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.email != null) {
      setState(() {
        _itemListFuture = _fetchItems();
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final email = userProvider.email;
      final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('favorites')
          .where('email', isEqualTo: email)
          .get();

      List<String> favoriteItemIds = querySnapshot.docs.map((doc) => doc['itemId'].toString()).toList();

      if (favoriteItemIds.isEmpty) {
        return []; // Return an empty list indicating no favorite items found
      }

      final QuerySnapshot<Map<String, dynamic>> itemQuerySnapshot = await FirebaseFirestore.instance
          .collection('items')
          .where(FieldPath.documentId, whereIn: favoriteItemIds)
          .get();

      final itemList = itemQuerySnapshot.docs.map((doc) {
        return {
          'itemId': doc.id,
          'itemName': doc['itemName'] ?? 'No Name',
          'itemDescription': doc['itemDescription'] ?? 'No Description',
          'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(),
          'imageUrl': doc['imageUrl'] ?? '',
          'categoryName': doc['categoryName'] ?? 'No Category',
        };
      }).toList();

      print('Fetched favorite items: $itemList');

      return itemList;
    } catch (e) {
      throw Exception('Failed to fetch favorite items: $e');
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(height: 10.0),
          Container(
            height: 45.0,
            width: 300.0,
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
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.email == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: primaryColor,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text(
            'My Favorites',
            style: whiteheading,
          ),
        ),
        body: Center(
          child: Text(
            'Login to set favorites',
            style: TextStyle(fontSize: 18.0),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'My Favorites',
          style: whiteheading,
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _itemListFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<Map<String, dynamic>> itemList = snapshot.data ?? [];
            if (itemList.isEmpty) {
              return Center(child: Text("No favorites found."));
            } else {
              final filteredItemList = itemList.where((item) =>
                  item['itemName'].toLowerCase().contains(_searchText.toLowerCase())).toList();
              return Column(
                children: [
                  _buildSearchBar(),
                  Expanded(
                    child: _buildHorizontalCards(filteredItemList),
                  ),
                ],
              );
            }
          }
        },
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

  Widget _buildHorizontalCards(List<Map<String, dynamic>> itemList) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          (itemList.length / 2).ceil(),
              (rowIndex) {
            final startIndex = rowIndex * 2;
            final endIndex = startIndex + 2;
            final rowItems = itemList
                .sublist(startIndex, endIndex.clamp(0, itemList.length))
                .map((item) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: _buildCard(
                    context,
                    item['itemId'],
                    item['itemName'],
                    item['itemDescription'],
                    item['itemPrice'],
                    item['imageUrl'],
                    item['categoryName'],
                  ),
                ),
              );
            }).toList();

            if (rowItems.length == 1) {
              return Row(
                children: [
                  rowItems[0],
                  SizedBox(width: 160.0 + 4.0),
                ],
              );
            } else {
              return Row(children: rowItems);
            }
          },
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String itemId, String itemName, String itemDescription,
      double itemPrice, String imageUrl, String categoryName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DescriptionPage(
              itemId: int.parse(itemId),
              itemName: itemName,
              itemDescription: itemDescription,
              itemPrice: itemPrice,
              imageUrl: imageUrl,
              categoryName: categoryName,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: SizedBox(
          width: 160.0,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.white30.withOpacity(0.9),
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Card(
              color: Colors.yellow[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Text(
                      '$itemName',
                      style: itemname,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: 95.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.0,
                            vertical: 3.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Rs $itemPrice',
                                style: itemprice,
                              ),
                              SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.add_circle,
                                color: Colors.orange,
                                size: 18.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
