import 'package:flutter/material.dart';
import 'package:nutrivision/Models/meal_analysis_model.dart';
import 'package:nutrivision/Pages/MainPage/HomePage/dashboard_ui.dart';
import 'package:nutrivision/Pages/MainPage/HomePage/meal_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:f_logs/f_logs.dart';
import 'package:nutrivision/Provider/consumed_meal_provider.dart';
import 'package:nutrivision/Provider/consumed_nutrition_provider.dart';

final List<String> _meals = ["Breakfast", "Lunch", "Snacks", "Dinner"];

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  Set<String> _selected = {"Breakfast"};
  Nutrition totalNutrition =
      Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0);

  @override
  Widget build(BuildContext context) {
    // Watch the consumedMealProvider to trigger rebuilds when its state changes
    final consumedMeal = ref.watch(consumedMealProvider);

    // Listen for changes in consumedMealProvider and update totalNutrition
    ref.listen<Map<String, MealAnalysis>>(consumedMealProvider,
        (previous, next) {
      // Recalculate total nutrition whenever consumedMealProvider changes
      FLog.info(text: "changes detected in consumedmealprovider");
      totalNutrition = Nutrition(
          calories: 0,
          protein: 0,
          carbs: 0,
          fats: 0); // Reset before recalculating

      next.forEach((key, value) {
        totalNutrition.addValues(value.foodSummary);
        FLog.info(
          text:
              'Recalculating Total Nutrition: $key: ${value.meals.map((m) => m.meal.name).toList()}',
        );
      });

      // Update consumedNutriProvider with the new total nutrition
      ref
          .read(consumedNutriProvider.notifier)
          .toggleConsumedValues(totalNutrition);
    });

    return Padding(
      padding: const EdgeInsets.only(top: 10.0, left: 10, right: 10),
      child: Column(
        children: [
          DashboardUI(),
          const SizedBox(height: 20),

          // Segmented Button for meal selection
          SegmentedButton(
            showSelectedIcon: false,
            style: const ButtonStyle(),
            segments: _meals.map((value) {
              return ButtonSegment(value: value, label: Text(value));
            }).toList(),
            selected: _selected,
            onSelectionChanged: (selectedTime) {
              setState(() {
                _selected = selectedTime;
              });
            },
          ),
          const SizedBox(height: 10),

          // Display MealCard based on selected meal
          Expanded(
            child: ListView(
              children: _selected.map((selectedMeal) {
                // Fetch the corresponding meal analysis
                FLog.info(text: "Building Mealcard for $selectedMeal");
                MealAnalysis? mealAnalysis = consumedMeal[selectedMeal];

                if (mealAnalysis != null) {
                  mealAnalysis.meals.forEach((meall) {
                    FLog.info(text: "mealanalysis values ${meall.meal.name}");
                  });
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...mealAnalysis.meals.map((mainMeal) {
                          FLog.info(
                              text:
                                  "Creating MealCard of ${mainMeal.meal.name}");
                          return MealCard(
                            meal: mainMeal.meal,
                            showSimilear: true,
                            showCheckBox: false,
                            similarFoods: mainMeal.similarFoods,
                            showAdjustment: false,
                          );
                        }),
                      ],
                    ),
                  );
                } else {
                  return Center(
                    child: Text('No data available for $selectedMeal'),
                  );
                }
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
