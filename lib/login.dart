import 'package:flutter/material.dart';
import 'api.dart'; // Ensure this points to your API service
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // Assuming this is the file where your main home screen is located

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';

  Future<void> _login() async {
    try {
      final token = await obtainAuthToken(
        _usernameController.text,
        _passwordController.text,
      );
      if (token.isNotEmpty) {
        // Save the token in shared preferences
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        // Navigate to the main home screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => UserFoodListScreen()),  // Replace MainHomeScreen with your actual home screen widget
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to login: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            if (_errorMessage.isNotEmpty) Text(_errorMessage, style: TextStyle(color: Colors.red)),
            ElevatedButton(onPressed: _login, child: Text('Login')),
          ],
        ),
      ),
    );
  }
}