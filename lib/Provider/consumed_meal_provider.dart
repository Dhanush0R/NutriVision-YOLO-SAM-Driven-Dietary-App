import 'package:nutrivision/Models/meal_analysis_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f_logs/f_logs.dart';

/// A provider to manage consumed meals by time (e.g., breakfast, lunch, dinner).
class ConsumedMealNotifier extends StateNotifier<Map<String, MealAnalysis>> {
  /// Initial state is an empty map
  ConsumedMealNotifier() : super({});

  /// Adds or updates consumed meals for a specific time (e.g., 'breakfast', 'lunch').
  /// The `newAnalysis` parameter is expected to contain `foodSummary` and `meals`.
  void addConsumedMeal(String time, MealAnalysis newAnalysis) {
    // Create a copy of the current state
    final updatedState = Map<String, MealAnalysis>.from(state);

    // Log the incoming meals for debugging
    FLog.info(
      text: 'Adding or updating analysis for $time: '
          '${newAnalysis.meals.map((m) => m.meal.name).toList()}',
    );

    // Ensure deep copy of the new analysis
    updatedState[time] = MealAnalysis(
      foodSummary: Nutrition(
        calories: newAnalysis.foodSummary.calories,
        protein: newAnalysis.foodSummary.protein,
        carbs: newAnalysis.foodSummary.carbs,
        fats: newAnalysis.foodSummary.fats,
      ),
      meals: newAnalysis.meals
          .map((mealItem) => MainMeal(
                meal: Meal(
                  name: mealItem.meal.name,
                  calories: mealItem.meal.calories,
                  carbs: mealItem.meal.carbs,
                  protein: mealItem.meal.protein,
                  fat: mealItem.meal.fat,
                ),
                
                similarFoods: mealItem.similarFoods
                    .map(
                      (similar) => Meal(
                        name: similar.name,
                        calories: similar.calories,
                        carbs: similar.carbs,
                        protein: similar.protein,
                        fat: similar.fat,
                      ),
                    )
                    .toList(),
              ))
          .toList(),
      analyzedimg: newAnalysis.analyzedimg,
    );

    // Update the state with the new data
    state = {...updatedState};

    // Log the updated state for debugging
    FLog.info(
      text: 'State after adding/updating $time: '
          '${updatedState.keys.map((key) => "$key => ${updatedState[key]?.meals.map((m) => m.meal.name).toList()}").join(", ")}',
    );
  }

  /// Removes a meal entry for a specific time (e.g., 'breakfast', 'lunch').
  void removeConsumedMeal(String time) {
    if (state.containsKey(time)) {
      final updatedState = Map<String, MealAnalysis>.from(state);
      updatedState.remove(time);
      state = updatedState;

      // Log the successful removal
      FLog.info(text: 'Removed meal entry for $time. Current state: $state');
    } else {
      // Log a warning if the time entry doesn't exist
      FLog.warning(
          text: 'Attempted to remove non-existent meal entry for $time.');
    }
  }

  /// Clears all consumed meals and resets the state to an empty map.
  void clearAllConsumedMeals() {
    state = {};
    FLog.info(text: 'Cleared all consumed meals. State reset to empty.');
  }
}

/// Provider to access the `ConsumedMealNotifier`.
final consumedMealProvider =
    StateNotifierProvider<ConsumedMealNotifier, Map<String, MealAnalysis>>(
  (ref) => ConsumedMealNotifier(),
);
