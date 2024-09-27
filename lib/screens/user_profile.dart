import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dominos/screens/user_provider.dart';

import '../theme.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late String _email;

  @override
  void initState() {
    super.initState();
    _getEmailFromProvider();
  }

  void _getEmailFromProvider() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    _email = userProvider.email ?? '';
  }

  Future<List<Map<String, dynamic>>> _fetchUserDetails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: _email)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'username': doc['username'] ?? 'No Name',
          'email': doc['email'] ?? 'No Email',
          'phoneNumber': doc['phoneNumber'] ?? 'No Phone Number',
          'address': doc['address'] ?? 'No Address',
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'User Profile',
          style: whiteheading,
        ),
      ),
      body: _email.isNotEmpty
          ? FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final userDetails = snapshot.data!;
            return ListView.builder(
              itemCount: userDetails.length,
              itemBuilder: (context, index) {
                final user = userDetails[index];
                return Padding(
                  padding: const EdgeInsets.only(left:20.0,right:20.0,top:30.0),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 18),
                          Text('Username: ${user['username']}',
                          style:tiletext,),
                          SizedBox(height: 18),
                          Text('Email: ${user['email']}',
                            style:itemname,),
                          SizedBox(height: 18),
                          Text('Phone Number: ${user['phoneNumber']}',
                      style:itemname,),
                    SizedBox(height: 18),
                          Text('Address: ${user['address']}',
                      style:itemname,),
                          SizedBox(height: 18),

                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      )
          : Center(
        child: Text(
          'Login for profile details',
          style: subtitle,
        ),
      ),
    );
  }
}
