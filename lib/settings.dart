import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart'; 

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _handleSignOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Clear stored user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Add any other sign out logic here, for example:
      // await firebaseAuth.signOut();
      // await googleSignIn.signOut();

      // Pop loading dialog
      Navigator.of(context).pop();

      // Navigate to login page and clear navigation stack
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Pop loading dialog
      Navigator.of(context).pop();
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign out. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: Text('Enable Notifications'),
              subtitle: Text(_notificationsEnabled ? 'Enabled' : 'Disabled'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            Divider(height: 32),
            TextButton(
              onPressed: _handleSignOut,
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}