import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme.dart';
import 'cart_page.dart';
import 'item_description.dart';

class MenuScreen extends StatefulWidget {
  final int initialTabIndex;

  const MenuScreen({Key? key, required this.initialTabIndex}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late Future<List<Map<String, dynamic>>> _itemListFuture;
  String _searchText = '';
  bool _sortAscending = true; // Default sort order

  final subtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this, initialIndex: widget.initialTabIndex);
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('items').get();

      final itemList = querySnapshot.docs.map((doc) {
        return {
          'itemId': doc.id, // Add itemId to the query result
          'itemName': doc['itemName'] ?? 'No Name',
          'itemDescription': doc['itemDescription'] ?? 'No Description',
          'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(), // Convert to double
          'imageUrl': doc['imageUrl'] ?? '',
          'categoryName': doc['categoryName'] ?? 'No Category',
        };
      }).toList();

      print('Fetched items: $itemList');

      // Sort the item list by item price
      itemList.sort((a, b) {
        if (_sortAscending) {
          return a['itemPrice'].compareTo(b['itemPrice']);
        } else {
          return b['itemPrice'].compareTo(a['itemPrice']);
        }
      });

      return itemList;
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
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
            width: 300.0, // Adjust the height as needed
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
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7, // Number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xffec4f4a),
          title: Row(
            children: [
              Text(
                "Let's Eat",
                style: whiteheading,
              ),
              SizedBox(width: 8),
              Image.asset(
                'assets/logo flavicon.png',
                width: 44,
                height: 44,
              ),
            ],
          ),
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          bottom: TabBar(
            isScrollable: true,
            // Allow horizontal scroll
            controller: _tabController,
            tabs: [
              Tab(
                child: Text(
                  'All',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Main Course',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Burgers',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Pizza',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Appetizers',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Desserts',
                  style: subtitle,
                ),
              ),
              Tab(
                child: Text(
                  'Beverages',
                  style: subtitle,
                ),
              ),
            ],
            labelColor: Colors.yellow[300], // Selected tab label color
            unselectedLabelColor: Colors.white, // Unselected tab label color
            indicatorColor: Colors.white, // Color of the line of tabs
          ),
          actions: [
            SizedBox(width: 8), // Add space between the sort button and the ascending sort button
            GestureDetector(
              onTap: () {
                setState(() {
                  _sortAscending = true;
                });
              },
              child: Image.asset(
                'assets/descending.png',
                width: 24,
                height: 24,
              ),
            ),
            SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                setState(() {
                  _sortAscending = false;
                });
              },
                child: Image.asset(
                  'assets/ascending.png',
                  width: 24,
                  height: 24,
                ),

            ),
            SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('All'),
                  _buildTabContent('Main Course'),
                  _buildTabContent('Burgers'),
                  _buildTabContent('Pizza'),
                  _buildTabContent('Appetizers'),
                  _buildTabContent('Desserts'),
                  _buildTabContent('Beverages'),
                ],
              ),
            ),
          ],
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
      ),
    );
  }

  Widget _buildTabContent(String tabLabel) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('items').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final itemList = snapshot.data!.docs.map((doc) {
            return {
              'itemId': doc.id, // Add itemId to the query result
              'itemName': doc['itemName'] ?? 'No Name',
              'itemDescription': doc['itemDescription'] ?? 'No Description',
              'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(), // Convert to double
              'imageUrl': doc['imageUrl'] ?? '',
              'categoryName': doc['categoryName'] ?? 'No Category',
            };
          }).toList();

          // Sort the item list by item price
          itemList.sort((a, b) {
            if (_sortAscending) {
              return a['itemPrice'].compareTo(b['itemPrice']);
            } else {
              return b['itemPrice'].compareTo(a['itemPrice']);
            }
          });

          List<Map<String, dynamic>> filteredItems = itemList.where((item) {
            if (tabLabel == 'All') {
              return item['itemName'].toLowerCase().contains(_searchText.toLowerCase());
            } else {
              return item['itemName'].toLowerCase().contains(_searchText.toLowerCase()) && item['categoryName'] == tabLabel;
            }
          }).toList();

          return _buildHorizontalCards(filteredItems);
        }
      },
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
                  SizedBox(width: 160.0 + 4.0), // Width of card + horizontal padding
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

  Widget _buildCard(BuildContext context, String itemId, String itemName, String itemDescription, double itemPrice,
      String imageUrl, String categoryName) {
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
                          fit: BoxFit.fitWidth,
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
                          padding: EdgeInsets.only(
                            left: 6.0,
                            right: 6.0,
                            top: 3.0,
                            bottom: 3.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '\ Rs $itemPrice',
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
