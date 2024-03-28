import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

const String baseUrl = 'https://divyeshdeficit.pythonanywhere.com/'; // Change this to your actual URL

Future<List<Food>> fetchFoods() async {
  final response = await http.get(
    Uri.parse('$baseUrl/foods/'),
    headers: {
      'Content-Type': 'application/json',
      // Include token if needed
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> foodsJson = json.decode(response.body);
    return foodsJson.map((json) => Food.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load foods');
  }
}

Future<List<UserFood>> fetchUserFoods() async {
  // Retrieve the token from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('$baseUrl/userfoods/'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',  // Use the token here
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> userFoodsJson = json.decode(response.body);
    return userFoodsJson.map((json) => UserFood.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load user foods');
  }
}

Future<String> obtainAuthToken(String username, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api-token-auth/'),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'username': username,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['token']; // Assuming the response contains a 'token' field
  } else {
    // Handle errors, throw exception, or return an empty string if no token obtained
    throw Exception('Failed to obtain token');
  }
}

Future<bool> updateUserFoodAmount(int foodId, int userFoodId, double newAmount) async {
  // Retrieve the token from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final response = await http.put(
    Uri.parse('$baseUrl/userfoods/$userFoodId/'), // Adjust the URL as necessary
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',  // Use the token here
    },
    body: jsonEncode({
      'food': foodId,
      'amount': newAmount,
    }),
  );
  return response.statusCode == 200 || response.statusCode == 204;
}

Future<UserFood?> createUserFood(int foodId, double amount) async {
  // Retrieve the token from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');

  final response = await http.post(
    Uri.parse('$baseUrl/userfoods/'), // Use your actual endpoint URL
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',  // Use the token here
    },
    body: jsonEncode({
      'food': foodId,
      'amount': amount,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    // Assuming your API returns the created user food object
    return UserFood.fromJson(json.decode(response.body));
  } else {
    // Handle errors or return null to indicate failure
    return null;
  }
}

Future<List<Food>> fetchAllFoods() async {
  final response = await http.get(
    Uri.parse('$baseUrl/foods/'), // Use your actual endpoint URL
    headers: {
      'Content-Type': 'application/json',
      // Add authorization headers if required
    },
  );

  if (response.statusCode == 200) {
    List foodsJson = json.decode(response.body);
    return foodsJson.map((foodJson) => Food.fromJson(foodJson)).toList();
  } else {
    throw Exception('Failed to load foods');
  }
}

String getTodaysDate() {
  final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd'); // Use 'yyyy' for the full year
  final String formatted = formatter.format(now);
  return formatted;
}


// Inside api.dart
Future<int> fetchCaloriesForToday() async {
  // Retrieve the token from shared preferences
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? token = prefs.getString('auth_token');
  final String todaysDate = getTodaysDate();

  final response = await http.get(
    Uri.parse('$baseUrl/calories/$todaysDate/'), // Use the correct URL and format the date to YYYY-MM-DD
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Token $token',  // Use the token here
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['total_calories'];
  } else if (response.statusCode == 404) { // Assuming 404 is used for "not found"
    return 0; // No records found for today, so return 0 calories
  } else {
    throw Exception('Failed to load today\'s calorie count');
  }

}
