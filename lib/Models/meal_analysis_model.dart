// class Nutrition {
//   final double calories;
//   final double protein;
//   final double carbs;
//   final double fats;

//   Nutrition({
//     required this.calories,
//     required this.protein,
//     required this.carbs,
//     required this.fats,
//   });

//    factory Nutrition.fromJson(Map<String, dynamic> json) {
//     return Nutrition(
//       calories: json['Calories'] ?? 0.0,
//       protein: json['Protein'] ?? 0.0,
//       carbs: json['Carbs'] ?? 0.0,
//       fats: json['Fats'] ?? 0.0,
//     );
//   }
// }

// class Meal {
//   final String name;
//   final String calories;
//   final String carbs;
//   final String protein;
//   final String fat;

//   Meal({
//     required this.name,
//     required this.calories,
//     required this.carbs,
//     required this.protein,
//   required this.fat,
//   });
// }

// class MealAnalysis {
//   final Nutrition foodSummary;
//   final List<Meal> meals;
//   MealAnalysis({required this.foodSummary, required this.meals});
// }
import 'package:flutter/foundation.dart';

const Map<String, dynamic> dummyMealAnalysis = {
  "foodSummary": {
    "calories": "350Kcal",
    "carbs": "47g",
    "protein": "25g",
    "fat": "20g"
  },
  "meals": [
    {
      "meal": {
        "name": "Egg",
        "calories": "155Kcal",
        "carbs": "1.1g",
        "protein": "13g",
        "fat": "11g",
      },
      "similarFoods": [
        {
          "name": "Boiled Egg",
          "calories": "68Kcal",
          "carbs": "0.6g",
          "protein": "6g",
          "fat": "5g",
          "image": "boiled_egg.png"
        },
        {
          "name": "Scrambled Egg",
          "calories": "91Kcal",
          "carbs": "1.4g",
          "protein": "7g",
          "fat": "7g",
          "image": "scrambled_egg.png"
        }
      ]
    },
    {
      "meal": {
        "name": "Bread",
        "calories": "80Kcal",
        "carbs": "15g",
        "protein": "3g",
        "fat": "1g",
      },
      "similarFoods": [
        {
          "name": "Whole Wheat Bread",
          "calories": "70Kcal",
          "carbs": "12g",
          "protein": "4g",
          "fat": "1g",
        },
        {
          "name": "Multigrain Bread",
          "calories": "75Kcal",
          "carbs": "13g",
          "protein": "4g",
          "fat": "1.2g",
        }
      ]
    },
    {
      "meal": {
        "name": "Milk",
        "calories": "103Kcal",
        "carbs": "12g",
        "protein": "8g",
        "fat": "5g",
      },
      "similarFoods": [
        {
          "name": "Almond Milk",
          "calories": "39Kcal",
          "carbs": "1g",
          "protein": "1g",
          "fat": "3g",
        },
        {
          "name": "Soy Milk",
          "calories": "80Kcal",
          "carbs": "4g",
          "protein": "7g",
          "fat": "4g",
        }
      ]
    },
  ]
};

class Nutrition {
  double calories;
  double protein;
  double carbs;
  double fats;

  Nutrition({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  // CopyWith method for immutability
  Nutrition copyWith({
    double? calories,
    double? protein,
    double? carbs,
    double? fats,
  }) {
    return Nutrition(
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
    );
  }

  // Add values from another Nutrition object
  void addValues(Nutrition newValues) {
    calories += newValues.calories;
    protein += newValues.protein;
    carbs += newValues.carbs;
    fats += newValues.fats;

    // Ensure precision
    _roundValues();
  }

  // Subtract values from another Nutrition object
  void subValues(Nutrition newValues) {
    calories -= newValues.calories;
    protein -= newValues.protein;
    carbs -= newValues.carbs;
    fats -= newValues.fats;

    // Ensure precision
    _roundValues();
  }

  // Ensure values are rounded to 2 decimal places
  void _roundValues() {
    calories = double.parse(calories.toStringAsFixed(2));
    protein = double.parse(protein.toStringAsFixed(2));
    carbs = double.parse(carbs.toStringAsFixed(2));
    fats = double.parse(fats.toStringAsFixed(2));
  }

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    double parseValue(String? value) {
      return double.tryParse(
              value?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ??
          0.0;
    }

    return Nutrition(
      calories: parseValue(json['calories']),
      protein: parseValue(json['protein']),
      carbs: parseValue(json['carbs']),
      fats: parseValue(json['fat']),
    );
  }
}

class Meal {
  final String name;
  final double calories;
  final double carbs;
  final double protein;
  final double fat;

  Meal({
    required this.name,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    double parseValue(String? value) {
      return double.tryParse(
              value?.replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ??
          0.0;
    }

    return Meal(
      name: json['name'] ?? 'Unknown', // Default if name is missing
      calories: parseValue(json['calories']),
      carbs: parseValue(json['carbs']),
      protein: parseValue(json['protein']),
      fat: parseValue(json['fat']),
    );
  }
}
class MainMeal {
  final Meal meal;
  final List<Meal> similarFoods;

  MainMeal({required this.meal, required this.similarFoods, });

  factory MainMeal.fromJson(Map<String, dynamic> json) {
    return MainMeal(
      meal: Meal.fromJson(json['meal']),
      similarFoods: (json['similarFoods'] as List)
          .map((food) => Meal.fromJson(food))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MainMeal &&
        other.meal == meal &&
        listEquals(other.similarFoods, similarFoods);
  }

  @override
  int get hashCode => meal.hashCode ^ similarFoods.hashCode;

  @override
  String toString() {
    return 'MainMeal(meal: $meal, similarFoods: $similarFoods)';
  }
}

class MealAnalysis {
  final Nutrition foodSummary;
  final List<MainMeal> meals;
  final String analyzedimg;

  MealAnalysis({
    required this.foodSummary,
    required this.meals,
    required this.analyzedimg,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    return MealAnalysis(
      foodSummary: Nutrition.fromJson(json['foodSummary']),
      meals: (json['meals'] as List)
          .map((mealData) => MainMeal.fromJson(mealData))
          .toList(),
      analyzedimg: json['maskedImage'] ?? '',
    );
  }

  @override
  String toString() {
    return 'MealAnalysis(foodSummary: $foodSummary, meals: $meals, analyzedimg: $analyzedimg)';
  }
}

MealAnalysis parseDummyData(Map<String, dynamic> data) {
  return MealAnalysis.fromJson(data);
}
