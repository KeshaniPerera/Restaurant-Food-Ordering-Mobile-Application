import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dominos/screens/user_provider.dart';
import '../theme.dart';
import 'cart_page.dart';
import 'favorites.dart';
import 'item_description.dart';
import 'menu_tab.dart';
import '../services/firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final FireStoreService _fireStoreService = FireStoreService();


  @override
  void initState() {
    super.initState();
    // Remove the initialization of userProvider from initState
    _itemListFuture = _fetchItems();
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('items').where('isBestSelling', isEqualTo: true).get(); // Filter items where 'isBestSelling' is true

      return querySnapshot.docs.map((doc) {
        return {
          'itemId':doc['itemId']??'No Id',
          'itemName': doc['itemName'] ?? 'No Name',
          'itemDescription': doc['itemDescription'] ?? 'No Description',
          'itemPrice': (doc['itemPrice'] ?? 0.0).toDouble(), // Convert to double
          'imageUrl': doc['imageUrl'] ?? '',
          'categoryName': doc['categoryName'] ?? '',

        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch items: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize userProvider inside the build method
    final userProvider = Provider.of<UserProvider>(context);
    final username = userProvider.username ?? 'have a nice day!';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(

          children: [
            Container(
               height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage('assets/home_bg2.png'),
                  fit: BoxFit.fitWidth,
                  opacity: 0.5
                ),
              ), // Set your desired background color here
              child: Padding(
                padding: const EdgeInsets.all(26.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Hi, ${username ?? ''}",
                        style: redheading,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to favorite page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => FavoritesScreen()),
                            );
                          },
                          child: Icon(Icons.favorite_outlined, color: Colors.orange),
                        ),
                        SizedBox(width: 10),
                        GestureDetector(
                          onTap: () {
                            // Navigate to cart page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => CartPage()),
                            );
                          },
                          child: Icon(Icons.shopping_cart_rounded, color: primaryColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only( left:26.0,right:26.0,bottom:26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 500,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: AssetImage('assets/banner1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                      "Hungry for?",
                      style: heading
                  ),
                  SizedBox(height: 10),
                  _buildImageList(context),
                  SizedBox(height: 10),
                  Text(
                      "Best Selling",
                      style: heading
                  ),
                  SizedBox(height: 10),
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: _itemListFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        final itemList = snapshot.data!;
                        return _buildHorizontalCards(itemList);
                      }
                    },
                  ),
                  SizedBox(height: 20.0),
                  Text(
                      "Deals and Promotions",
                      style: heading
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: 400,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/deal1.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Container(
                    width: 400,
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: AssetImage('assets/deal2.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildImageItem(context, 'assets/category image 1.png', 'Main Course', 1),
          _buildImageItem(context, 'assets/category image 2.png', 'Burgers', 2),
          _buildImageItem(context, 'assets/category image 3.png', 'Pizza', 3),
          _buildImageItem(context, 'assets/category image 4.png', 'Appetizers', 4),
          _buildImageItem(context, 'assets/category image 5.png', 'Desserts', 5),
          _buildImageItem(context, 'assets/category image 6.png', 'Beverages', 6),
        ],
      ),
    );
  }
  Widget _buildImageItem(BuildContext context, String imagePath, String labelText, int tabIndex) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MenuScreen(initialTabIndex: tabIndex)),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Text(
              labelText,
              style: subtitle,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // Implement your navigation logic here
    // For example, if you're using a TabBar, you can use the following:
    DefaultTabController.of(context)?.animateTo(index);
  }


  Widget _buildHorizontalCards(List<Map<String, dynamic>> itemList) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: itemList.length,
        itemBuilder: (context, index) {
          final item = itemList[index];
          return _buildCard(
            item['itemId'],
            item['imageUrl'],
            item['itemName'],
            item['itemPrice'],
            item['itemDescription'],
            item['categoryName'],

          );
        },
      ),
    );
  }

  Widget _buildCard(int itemId, String imagePath, String itemName, double itemPrice,String itemDescription, String categoryName) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DescriptionPage(
              itemId:itemId,
              itemName: itemName,
              itemDescription: itemDescription,
              itemPrice: itemPrice,
              imageUrl: imagePath,
              categoryName: categoryName,
            ),
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          width: 160,
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
                        imagePath,
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
                        width: 115.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        padding: EdgeInsets.only(left: 6.0,right:6.0,top:3.0,bottom:3.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\ Rs $itemPrice',
                              style: itemprice,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Icon(
                              Icons.add_circle,
                              color: Colors.orange,
                              size: 22.0,
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
    );
  }
}
