import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class SettingsPage extends StatefulWidget {
 @override
 _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
 String username = 'Username'; 

 @override
 void initState() {
   super.initState();
   _loadUsername();
 }

 Future<void> _loadUsername() async {
   final user = FirebaseAuth.instance.currentUser;
   if (user != null && user.email != null) {
     setState(() {
       username = user.email!.split('@')[0];
     });
   }
 }

 Future<void> _handleLogout() async {
   try {
     await FirebaseAuth.instance.signOut();
     Navigator.of(context).pushAndRemoveUntil(
       MaterialPageRoute(builder: (context) => LoginPage()),
       (Route<dynamic> route) => false,
     );
   } catch (e) {
     ScaffoldMessenger.of(context).showSnackBar(
       SnackBar(content: Text('Failed to logout. Please try again.')),
     );
   }
 }

 @override
 Widget build(BuildContext context) {
   return Scaffold(
     appBar: AppBar(
       title: Text('Profile'),
       backgroundColor: Colors.blue,
       elevation: 0,
     ),
     body: Center(
       child: Column(
         children: [
           SizedBox(height: 40),
           Container(
             width: 100,
             height: 100,
             decoration: BoxDecoration(
               shape: BoxShape.circle,
               border: Border.all(
                 color: Colors.black,
                 width: 2,
               ),
             ),
             child: Icon(
               Icons.person_outline,
               size: 60,
             ),
           ),
           SizedBox(height: 20),
           Text(
             'Hello $username',
             style: TextStyle(
               fontSize: 20,
               fontWeight: FontWeight.bold,
             ),
           ),
           Spacer(),
           Padding(
             padding: const EdgeInsets.all(20.0),
             child: SizedBox(
               width: double.infinity,
               height: 45,
               child: ElevatedButton(
                 onPressed: _handleLogout,
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.blue,
                 ),
                 child: Text('Logout'),
               ),
             ),
           ),
         ],
       ),
     ),
   );
 }
}