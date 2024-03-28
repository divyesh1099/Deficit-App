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

// Exercise Models
class Exercise {
  final int id;
  final String name;
  final String unit; // Keep units as a string if they are not used for calculations
  final double caloriesBurntPerUnit;

  Exercise({
    required this.id,
    required this.name,
    required this.unit,
    required this.caloriesBurntPerUnit
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
      caloriesBurntPerUnit: double.parse(json['calories_burnt_per_unit']),
    );
  }
}


class UserExercise {
  final int id;
  final int userId;
  final int exerciseId;
  double duration; // Use a double since the API gives a string that represents a decimal
  final DateTime performedDateTime;
  String? exerciseName;

  UserExercise({
    required this.id,
    required this.userId,
    required this.exerciseId,
    required this.duration,
    required this.performedDateTime,
    this.exerciseName
  });

  factory UserExercise.fromJson(Map<String, dynamic> json) {
    return UserExercise(
      id: json['id'] as int,
      userId: json['user'] as int,
      exerciseId: json['exercise'] as int,
      duration: double.parse(json['duration']),
      performedDateTime: DateTime.parse(json['performed_datetime']),
    );
  }
}
