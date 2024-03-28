import 'package:flutter/material.dart';
import 'api.dart';  // Ensure this points to your API file
import 'models.dart';  // Ensure this points to your models file
import 'login.dart';

void main() {
  runApp(CalorieTrackerApp());
}

class CalorieTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Calorie Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class UserFoodListScreen extends StatefulWidget {
  @override
  _UserFoodListScreenState createState() => _UserFoodListScreenState();
}

class _UserFoodListScreenState extends State<UserFoodListScreen> {
  late Future<List<UserFood>> futureUserFoods;
  List<Food> _allFoods = [];
  List<UserFood> _userFoods = [];
  int _todaysCalories = 0;

  void _loadData() async {
    _allFoods = await fetchFoods();  // Get all foods
    _userFoods = await fetchUserFoods();  // Get user-specific food consumption records

    // Now match food names to user food records based on IDs
    setState(() {
      _userFoods.forEach((userFood) {
        // Find the matching food based on foodId
        final matchingFood = _allFoods.firstWhere(
              (food) => food.id == userFood.foodId,
          orElse: () => Food(id: 0, name: 'Unknown', caloriesPerUnit: 0),  // Handle 'unknown' case
        );
        userFood.foodName = matchingFood.name; // Assign the food name from the matched food
      });
    });
  }

  void showAddFoodModal(BuildContext context, List<Food> allFoods) async {
    final TextEditingController _amountController = TextEditingController();
    Food? selectedFood;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New User Food'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Autocomplete<Food>(
                  displayStringForOption: (Food option) => option.name,
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text == '') {
                      return const Iterable<Food>.empty();
                    }
                    return allFoods.where((Food food) {
                      return food.name.toLowerCase().contains(textEditingValue.text.toLowerCase());
                    });
                  },
                  onSelected: (Food selection) {
                    selectedFood = selection;
                  },
                  fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                      ) {
                    return TextField(
                      controller: fieldTextEditingController,
                      focusNode: fieldFocusNode,
                      decoration: InputDecoration(
                        hintText: "Search Foods", // Add your hint text here
                        border: OutlineInputBorder(),
                      ),
                    );
                  },
                ),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(hintText: "Enter amount"),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add'),
              onPressed: () async {
                if (selectedFood != null && _amountController.text.isNotEmpty) {
                  double? amount = double.tryParse(_amountController.text);
                  if (amount != null) {
                    UserFood? newUserFood = await createUserFood(selectedFood!.id, amount);
                    if (newUserFood != null) {
                      Navigator.of(context).pop(); // Close the dialog
                      // Assuming _userFoods is your list of user foods displayed in the UI
                      newUserFood.foodName = selectedFood!.name; // Assign the food name to the newUserFood
                      setState(() {
                        _userFoods.add(newUserFood); // Add the new user food to the list
                      });
                      _updateTodaysCalories(); // Update today's calorie count
                    } else {
                      // Handle errors, e.g., show a message
                    }
                  }
                }
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateTodaysCalories() async {
    try {
      final calories = await fetchCaloriesForToday();
      setState(() {
        _todaysCalories = calories;
      });
    } catch (e) {
      print("Error fetching today's calories: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    futureUserFoods = fetchUserFoods();  // API call to get user foods
    _loadData();  // Load all necessary data on init
    _updateTodaysCalories(); // Fetch today's calories on screen initialization
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, // Use min to wrap content
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // This will space out the children evenly
          children: [
            Text('My Consumed Foods', style: TextStyle(fontSize: 18)), // Adjust the style as needed
            Text(
              'Today\'s Calories: $_todaysCalories',
              style: TextStyle(
                fontSize: 14, // Adjust the size as needed
                color: Colors.black.withOpacity(0.7), // Slightly faded white for the subtitle
              ),
            ),
          ],
        ),
        centerTitle: false, // Align the title to the start
      ),
      body: FutureBuilder<List<UserFood>>(
        future: futureUserFoods,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            return ListView.builder(
              itemCount: _userFoods.length,
              itemBuilder: (context, index) {
                final userFood = _userFoods[index];
                return ListTile(
                  title: Text(userFood.foodName ?? 'Unknown Food'),
                  subtitle: Text('${userFood.amount} units consumed on ${userFood.consumedDateTime}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () async {
                          final newAmount = userFood.amount - 1;
                          if (newAmount >= 0) { // Allow setting amount to 0 since the backend handles deletion
                            final success = await updateUserFoodAmount(userFood.foodId, userFood.id, newAmount);
                            if (success) {
                              setState(() {
                                if (newAmount == 0) {
                                  _userFoods.removeAt(index);  // Remove from list if amount is 0
                                } else {
                                  userFood.amount = newAmount;  // Update amount if more than 0
                                }
                              });
                              _updateTodaysCalories(); // Update today's calorie count
                            }
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () async {
                          final newAmount = userFood.amount + 1;
                          final success = await updateUserFoodAmount(userFood.foodId, userFood.id, newAmount);
                          if (success) {
                            setState(() {
                              userFood.amount = newAmount;  // Update the local amount if API call was successful
                            });
                            _updateTodaysCalories(); // Update today's calorie count
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            )
            ;
          } else {
            // By default, show a loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          List<Food> allFoods = await fetchAllFoods(); // Fetch all the food items
          showAddFoodModal(context, allFoods); // Show the modal for adding a new user food
        },
        child: Icon(Icons.add),
        tooltip: 'Add New Food',
      ),
    );
  }
}
