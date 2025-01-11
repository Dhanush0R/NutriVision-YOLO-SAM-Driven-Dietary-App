import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Models/meal_analysis_model.dart';
import 'package:f_logs/f_logs.dart';


class ConsumedNotifier extends StateNotifier<Nutrition> {
  ConsumedNotifier()
      : super(Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0));

  void toggleConsumedValues(Nutrition newValue) {
    FLog.info(text:"Inside toggle Consumed nutrition");
    state = newValue;
        FLog.info(text:"Inside toggle Consumed nutrition State value : $state");

  }
}

final consumedNutriProvider = StateNotifierProvider<ConsumedNotifier, Nutrition>((ref) {
  return ConsumedNotifier();
});
