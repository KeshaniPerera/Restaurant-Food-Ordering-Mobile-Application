import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dominos/admin/update_item.dart';
import 'package:dominos/admin/view_item.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firestore.dart';
import 'delete_item.dart';
import '../theme.dart'; // Import the theme

class ManageItems extends StatefulWidget {
  const ManageItems({Key? key}) : super(key: key);

  @override
  State<ManageItems> createState() => _ManageItemsState();
}

class _ManageItemsState extends State<ManageItems> {
  final TextEditingController itemIdController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController = TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  bool _isBestSelling = false;
  late Stream<QuerySnapshot> _itemsStream;

  String _imageFile = ''; // Variable to hold the selected image file
  Uint8List? selectedImageInBytes;

  final FirebaseStorage _storage = FirebaseStorage.instanceFor(
    bucket: 'gs://hungry-bunny-6ef57.appspot.com',
  );

  final FireStoreService _fireStoreService = FireStoreService();

  String _selectedMeal = 'Main Course'; // Default selection

  @override
  void initState() {
    super.initState();
    // Initialize Firestore service and items stream
    _itemsStream = FirebaseFirestore.instance.collection('items').snapshots();
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Image picked")));

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

      // After successfully upload, print a message
      await uploadTask.whenComplete(() => print("Image Uploaded"));

      // Return the download URL of the uploaded image
      return await ref.getDownloadURL();
    } catch (e) {
      // If an error occurred while uploading, print the error message
      print(e.toString());
    }
    return '';
  }

  String? _validateItemId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a unique ID';
    }
    return null;
  }

  void addItem() async {
    showDialog(
      context: context,
      builder: (context) {
        // Declare a variable to hold the progress value
        double uploadProgress = 0.0;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: itemIdController,
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
                    items: <String>['Main Course', 'Burgers', 'Pizza', 'Appetizers', 'Desserts', 'Beverages']
                        .map<DropdownMenuItem<String>>((String value) {
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
                    try {
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

                      // Continue with uploading details to Firestore
                      final QuerySnapshot<Map<String, dynamic>> existingItem =
                      await FirebaseFirestore.instance
                          .collection('items')
                          .where('itemId', isEqualTo: int.parse(enteredItemId))
                          .get();

                      if (existingItem.docs.isNotEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('Error'),
                            content: Text('An item with the same Item ID already exists.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      // Add item data to Firestore using FireStoreService
                      await _fireStoreService.addItem(
                        int.parse(enteredItemId),
                        _selectedMeal,
                        enteredItemName,
                        enteredItemDescription,
                        double.parse(enteredItemPrice),
                        imageUrl,
                        _isBestSelling,
                      );

                      showToast('Item added Successfully',
                        context: context,
                        textStyle: itemname,
                        backgroundColor: Colors.yellow,
                        textPadding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
                        borderRadius: BorderRadius.vertical(
                            top: Radius.elliptical(10.0, 20.0),
                            bottom: Radius.elliptical(10.0, 20.0)),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.ltr,
                        position: StyledToastPosition(
                          align: Alignment.bottomCenter, offset: 20.0,),

                      );

                      // Clear text controllers
                      itemIdController.clear();
                      itemNameController.clear();
                      itemDescriptionController.clear();
                      itemPriceController.clear();

                      // Close the dialog
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow),
                    foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                  ),
                  child: Text("Add Item"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Items',
          style: whiteheading, // Use the whiteheading style
        ),
        backgroundColor: primaryColor, // Set the background color of the app bar
        iconTheme: IconThemeData(color: Colors.white), // Set the color of the leading icon to white
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedCard(
              icon: Icons.list,
              title: "View Items",
              onTap: () => _navigateTo(context, ViewItem()),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.add,
              title: "Add Item",
              onTap: addItem,
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.update,
              title: "Update Item",
              onTap: () => _navigateTo(context, UpdateItem()),
            ),
            const SizedBox(height: 20),
            ElevatedCard(
              icon: Icons.delete,
              title: "Delete Item",
              onTap: () => _navigateTo(context, DeleteItem()),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ElevatedCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ElevatedCard({
    required this.icon,
    required this.title,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: primaryColor, // Use primaryColor for icon color
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: blacksubtext, // Use the blacksubtext style
              ),
            ],
          ),
        ),
      ),
    );
  }
}
