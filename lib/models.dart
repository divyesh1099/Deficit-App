class Food {
  final int id;
  final String name;
  final double caloriesPerUnit;

  Food({required this.id, required this.name, required this.caloriesPerUnit});

  @override
  String toString() {
    return name; // This will be used to display the food name in the suggestions.
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['id'] as int,
      name: json['name'] as String,
      caloriesPerUnit: (json['calories_per_unit'] is String)
          ? double.parse(json['calories_per_unit'])
          : (json['calories_per_unit'] as num).toDouble(),
    );
  }
}

class UserFood {
  final int id;
  double amount;  // Removed 'final' so this can be updated
  final int foodId;
  final DateTime consumedDateTime;
  String? foodName;  // Optional properties for additional details

  UserFood({
    required this.id,
    required this.foodId,
    required this.amount,
    required this.consumedDateTime,
    this.foodName,
  });

  factory UserFood.fromJson(Map<String, dynamic> json) {
    return UserFood(
      id: json['id'] as int,
      foodId: json['food'] as int,
      amount: double.parse(json['amount'].toString()),
      consumedDateTime: DateTime.parse(json['consumed_datetime']),
      foodName: json['foodName'], // Assuming you have this or you will add this
    );
  }
}


