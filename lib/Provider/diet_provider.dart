import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Models/recommended_intake.dart';

// final dietProvider=Provider((ref){  return Nutrition(
//     calories: 2189.025,
//     protein: 59.70068181818182,
//     carbs: 246.2653125,
//     fats: 72.63582954545454,
//   );});

class DietNotifier extends StateNotifier<Nutrition> {
  DietNotifier() : super(Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0));

  void toggleDietValues(Nutrition newValue) {
    state = newValue;
  }
}

final dietProvider = StateNotifierProvider<DietNotifier,Nutrition>((ref) {
  return DietNotifier();
});
