import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

// Model class for Disease
class Disease {
  final String name;
  final double protein;
  final double carbs;
  final double fat;

  Disease({
    required this.name,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
}

class DietCalculator {
  final double weight;
  final double height;
  final int age;
  final String gender;
  final String exerciseLevel;
  final bool isNonVeg;
  final List<String> selectedDiseases; // Disease names
  late Map<String, Disease> diseaseMap; // Stores diseases from CSV

  // Constructor
  DietCalculator({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.exerciseLevel,
    required this.isNonVeg,
    required this.selectedDiseases,
  });

  // PAL values for each exercise level
  final Map<String, double> exerciseLevels = {
    "Little or no exercise": 1.2,
    "Exercise 1-3 times/week": 1.375,
    "Exercise or Intense Exercise 3-4 times/week": 1.55,
    "Exercise 4-5 times/week": 1.725,
    "Intense Exercise 6-7 times/week": 1.9,
    "Intense Exercise daily": 2.1,
  };

  // Load disease data from CSV
  Future<void> loadDiseaseData() async {
    final csvData =
        await rootBundle.loadString('assets/diseases/diseases_csv.csv');
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

    // Create a map from the CSV data
    diseaseMap = {
      for (var row in rows.skip(1)) // Skip header row
        row[0]: Disease(
          name: row[0],
          protein: row[1],
          carbs: row[2],
          fat: row[3],
        ),
    };
  }

  double calculateBmr() {
    if (gender == 'Male') {
      return 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      return 10 * weight + 6.25 * height - 5 * age - 161;
    }
  }

  double calculateCalories(double bmr) {
    double pal = exerciseLevels[exerciseLevel] ??
        1.2; // Default to 1.2 if no valid exercise level
    return bmr * pal;
  }

  Map<String, double> getNutrition() {
    double protein = 100;
    double carbs = 250;
    double fat = 100;

    for (var diseaseName in selectedDiseases) {
      Disease? disease = diseaseMap[diseaseName];
      if (disease != null) {
        if (disease.protein < protein) {
          protein = disease.protein;
        }
        if (disease.carbs < carbs) {
          carbs = disease.carbs;
        }
        if (disease.fat < fat) {
          fat = disease.fat;
        }
      }
    }

    return {'protein': protein, 'carbs': carbs, 'fat': fat};
  }

  Map<String, Map<String, double>> calculateAndStore() {
    // Step 1: Calculate BMR
    double bmr = calculateBmr();

    // Step 2: Calculate Calories based on activity level
    double calories = calculateCalories(bmr);

    // Step 3: Get the required nutrition based on diseases
    Map<String, double> nutrition = getNutrition();

    // Step 4: Apply the multiplier
    double multiplier = calories / 2200;
    double protein = nutrition['protein']! * multiplier;
    double carbs = nutrition['carbs']! * multiplier;
    double fat = nutrition['fat']! * multiplier;

    // Step 5: Meal-wise distribution of nutrition
    Map<String, Map<String, double>> mealPlan = {
      'breakfast': {
        'protein': 0.37 * protein,
        'carbs': 0.37 * carbs,
        'fat': 0.3 * fat,
        'calories': 0.3 * fat * 8 + 0.37 * carbs * 4 + 0.37 * protein * 4,
      },
      'lunch': {
        'protein': 0.3 * protein,
        'carbs': 0.35 * carbs,
        'fat': 0.35 * fat,
        'calories': 0.35 * fat * 8 + 0.35 * carbs * 4 + 0.3 * protein * 4,
      },
      'snacks': {
        'protein': 0.05 * protein,
        'carbs': 0.1 * carbs,
        'fat': 0.1 * fat,
        'calories': 0.1 * fat * 8 + 0.1 * carbs * 4 + 0.05 * protein * 4,
      },
      'dinner': {
        'protein': 0.28 * protein,
        'carbs': 0.25 * carbs,
        'fat': 0.25 * fat,
        'calories': 0.25 * fat * 8 + 0.25 * carbs * 4 + 0.28 * protein * 4,
      },
    };

    return mealPlan;
  }
}



void main() async {
  List<String> selectedDiseases = ['Diabetes', 'Hypertension'];

  // Create an instance of the DietCalculator with user inputs
  DietCalculator calculator = DietCalculator(
    weight: 75.0, // User's weight in kg
    height: 180.0, // User's height in cm
    age: 25, // User's age
    gender: 'Male', // User's gender
    exerciseLevel: "Exercise 1-3 times/week", // User's exercise level
    isNonVeg: true, // Whether the user is non-vegetarian or vegetarian
    selectedDiseases: selectedDiseases, // List of selected diseases
  );

  // Load disease data from CSV
  await calculator.loadDiseaseData();

  // Calculate and print the meal plan
  Map<String, Map<String, double>> mealPlan = calculator.calculateAndStore();
  print(mealPlan);
}
