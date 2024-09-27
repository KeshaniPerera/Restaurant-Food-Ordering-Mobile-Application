import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:switcher_button/switcher_button.dart';

import '../services/firestore.dart';
import '../theme.dart';

class UpdateItem extends StatefulWidget {
  const UpdateItem({Key? key}) : super(key: key);

  @override
  State<UpdateItem> createState() => _UpdateItemState();
}

class _UpdateItemState extends State<UpdateItem> {
  late Future<List<Map<String, dynamic>>> _itemListFuture;
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  String _searchText = '';

  late Stream<QuerySnapshot> _itemsStream;
  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }


  String _imageFile = ''; // Variable to hold the selected image file
  Uint8List? selectedImageInBytes;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://hungry-bunny-6ef57.appspot.com',
  );

  final FireStoreService _fireStoreService = FireStoreService();

  String _selectedMeal = 'Main Course'; // Default selection
  bool _isBestSelling = false;

  @override
  void initState() {
    super.initState();
    // Initialize Firestore service and items stream
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
    // Initialize the future to fetch item data
    _itemListFuture = _fetchItems();
  }

  Future<void> pickImage() async {
    try {
      // Pick image using file_picker package
      FilePickerResult? fileResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      // If user picks an image, save selected image to variable
      if (fileResult != null) {
        setState(() {
          _imageFile = fileResult.files.first.name!;
          selectedImageInBytes = fileResult.files.first.bytes;
        });
      }
    } catch (e) {
      // If an error occurred, show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<String> uploadImage(Uint8List selectedImageInBytes) async {
    try {
      // This is reference where image uploaded in firebase storage bucket
      Reference ref = _storage.ref().child('images/$_imageFile');

      // Metadata to save image extension
      final metadata = SettableMetadata(contentType: 'image/jpeg');

      // UploadTask to finally upload image
      UploadTask uploadTask = ref.putData(selectedImageInBytes, metadata);

      // After successfully upload show SnackBar
      await uploadTask.whenComplete(() => print("Image Uploaded"));
      return await ref.getDownloadURL();
    } catch (e) {
      // If an error occurred while uploading, show SnackBar with error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      return '';
    }
  }

  void updateSelectedItem() async {
    showDialog(
      context: context,
      builder: (context) {
        double uploadProgress = 0.0;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemIdController,
                    enabled: false,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Item ID',
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedMeal,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMeal = newValue!;
                      });
                    },
                    items: <String>[
                      'Main Course',
                      'Burgers',
                      'Pizza',
                      'Appetizers',
                      'Desserts',
                      'Beverages'
                    ].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  TextField(
                    controller: itemNameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                    ),
                  ),
                  TextField(
                    controller: itemDescriptionController,
                    decoration: InputDecoration(
                      labelText: 'Item Description',
                    ),
                  ),
                  TextField(
                    controller: itemPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Item Price',
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.image_rounded),
                    title: Text('Upload Image'),
                    onTap: () async {
                      // Pick image using file_picker package
                      pickImage();
                    },
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Best Selling',
                        style: TextStyle(fontSize: 16.0),
                      ),
                      SizedBox(width: 10),
                      SwitcherButton(
                        value: _isBestSelling,
                        onChange: (value) {
                          setState(() {
                            _isBestSelling = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: uploadProgress, // Pass the current progress value
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    final String enteredItemId = itemIdController.text.trim();
                    final String enteredItemName = itemNameController.text.trim();
                    final String enteredItemDescription = itemDescriptionController.text.trim();
                    final String enteredItemPrice = itemPriceController.text.trim();
                    // Validate that no field is empty
                    if (enteredItemId.isEmpty ||
                        enteredItemName.isEmpty ||
                        enteredItemDescription.isEmpty ||
                        enteredItemPrice.isEmpty) {
                      _showSnackBar('All fields are required');
                      return;
                    }

                    // Validate item price format
                    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(enteredItemPrice)) {
                      _showSnackBar('Invalid item price!');
                      return;
                    }

                    // Validate item price format
                    if (!RegExp(r'^\d+(\.\d+)?$').hasMatch(enteredItemId)) {
                      _showSnackBar('Invalid Item ID!');
                      return;
                    }

                    // Validate image is selected
                    if (selectedImageInBytes == null) {
                      _showSnackBar('Please select an image!');
                      return;
                    }

                    // Update progress value before uploading image
                    setState(() {
                      uploadProgress = 0.5; // Arbitrary value to represent progress
                    });

                    final String imageUrl = await uploadImage(selectedImageInBytes!);

                    // Update progress value after image upload completes
                    setState(() {
                      uploadProgress = 1.0; // Full progress
                    });

                    // Add item data to Firestore using FireStoreService
                    await _fireStoreService.updateItem(
                      int.parse(enteredItemId),
                      _selectedMeal,
                      itemNameController.text,
                      itemDescriptionController.text,
                      double.parse(itemPriceController.text),
                      imageUrl,
                      _isBestSelling,
                    );

                    showToast(
                      'Item Updated Successfully',
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

                    // Clear text controllers
                    itemIdController.clear();
                    itemNameController.clear();
                    itemDescriptionController.clear();
                    itemPriceController.clear();

                    // Close the dialog
                    Navigator.pop(context);
                  },
                  child: Text("Update Item"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchItems() async {
    // Fetch item data from Firestore
    final QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
        .collection('items')
        .get();

    // Extract item IDs and names
    return querySnapshot.docs.map((doc) {
      return {
        'itemId': doc['itemId'],
        'itemName': doc['itemName'],
      };
    }).toList();
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
        title: Text(
          'Update Item',
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
                    // Display a loading indicator while waiting for data
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    // Display an error message if fetching data fails
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    // Display the list of items
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
                            onTap: () async {
                              // Fetch the item details from Firestore
                              QuerySnapshot<Map<String, dynamic>> itemSnapshot = await FirebaseFirestore.instance
                                  .collection('items')
                                  .where('itemId', isEqualTo: item['itemId'])
                                  .limit(1)
                                  .get();

                              if (itemSnapshot.docs.isNotEmpty) {
                                // Extract item data from the snapshot
                                Map<String, dynamic> itemData = itemSnapshot.docs.first.data();

                                // Set the retrieved data to the form fields
                                setState(() {
                                  itemIdController.text = itemData['itemId'].toString();
                                  _selectedMeal = itemData['categoryName'];
                                  itemNameController.text = itemData['itemName'];
                                  itemDescriptionController.text = itemData['itemDescription'];
                                  itemPriceController.text = itemData['itemPrice'].toString();

                                  // You may need to handle imageUrl retrieval based on your implementation
                                });

                                // Show the update dialog after setting the form fields
                                updateSelectedItem();
                              } else {
                                // Show an error message if item details are not found
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Item details not found')),
                                );
                              }
                            },
                            trailing: Icon(Icons.update_rounded,
                                color: primaryColor),
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
