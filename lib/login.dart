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
          MaterialPageRoute(builder: (context) => UserFoodListScreen()),  // Replace with your actual home screen widget
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
      body: SingleChildScrollView( // Makes the content scrollable
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center( // Centers the Column
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(), // Adds a border to the TextField
                  ),
                ),
                SizedBox(height: 8), // Adds space between the fields
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(), // Adds a border to the TextField
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 24), // More space before the button
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10), // Space above the error message
                    child: Text(_errorMessage, style: TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 36), // Makes the button wider and taller
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
