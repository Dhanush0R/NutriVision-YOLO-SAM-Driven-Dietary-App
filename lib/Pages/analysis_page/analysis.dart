import 'package:f_logs/f_logs.dart';
import 'package:flutter/material.dart';
import 'package:nutrivision/Pages/MainPage/HomePage/meal_card.dart';
import 'package:nutrivision/Models/meal_analysis_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Provider/consumed_meal_provider.dart';
import 'dart:convert';

// Parsing dummy data to MealAnalysis
final MealAnalysis parsedMealAnalysis =
    MealAnalysis.fromJson(dummyMealAnalysis);

class AnalysisPage extends ConsumerStatefulWidget {
  final MealAnalysis analysis;
  final Map<String, int> foodCount;
  final Map<String, double> sirvingSize;
  const AnalysisPage(
      {super.key,
      required this.analysis,
      required this.foodCount,
      required this.sirvingSize});

  @override
  ConsumerState<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends ConsumerState<AnalysisPage> {
  late Map<String, int> foodCount;

  Nutrition selectedNutrition =
      Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0);
  List<MainMeal> consumedFoodItem = [];
  late MealAnalysis analysis;
  String _time = "Breakfast";
  @override
  void initState() {
    super.initState();
    analysis = widget.analysis;
    foodCount = widget.foodCount;
  }

  void saveConsumedMeal() {
    for (int i = 0; i < consumedFoodItem.length; i++) {
      FLog.info(text: "$_time  ${consumedFoodItem[i].meal.name}");
    }
    consumedFoodItem = (consumedFoodItem.toSet()).toList();
    ref.read(consumedMealProvider.notifier).addConsumedMeal(
        _time,
        MealAnalysis(
            foodSummary: selectedNutrition,
            meals: consumedFoodItem,
            analyzedimg: analysis.analyzedimg));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("Meal for $_time Saved"),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        backgroundColor: Colors.green,
        onPressed: saveConsumedMeal,
        label: const Text(
          "Save",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            MealImageWidget(analysis: analysis),
            FoodSummaryWidget(
                foodCount: foodCount,
                servingSize: widget.sirvingSize,
                analysis: analysis,
                onValuesChanged: (selectedNutri, consumedMeal, time) {
                  selectedNutrition = selectedNutri;
                  consumedFoodItem = consumedMeal;
                  _time = time;
                  FLog.info(text: "$_time");
                })
          ],
        ),
      ),
    );
  }
}

class FoodSummaryWidget extends StatefulWidget {
  final MealAnalysis analysis;
  final Map<String, int> foodCount;
  final Map<String, double> servingSize;

  final Function(Nutrition selectedNutrition, List<MainMeal> consumedFoodItem,
      String time) onValuesChanged;

  const FoodSummaryWidget(
      {super.key,
      required this.analysis,
      required this.onValuesChanged,
      required this.foodCount,
      required this.servingSize});

  @override
  State<FoodSummaryWidget> createState() => _FoodSummaryWidgetState();
}

class _FoodSummaryWidgetState extends State<FoodSummaryWidget> {
  Nutrition selectedNutrition =
      Nutrition(calories: 0, protein: 0, carbs: 0, fats: 0);
  List<MainMeal> consumedFoodItem = [];
  late MealAnalysis analysis;
  String _time = "Breakfast";
  late Map<String, double> servingSize;

  @override
  void initState() {
    super.initState();
    analysis = widget.analysis;
    servingSize = widget.servingSize;
  }

  void _updateValues() {
    // Notify parent widget of the updated values
    widget.onValuesChanged(selectedNutrition, consumedFoodItem, _time);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Food Summary",
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Nutrient Badges Row
          MealSummaryBadges(
            nutrition:
                consumedFoodItem.isEmpty || selectedNutrition.calories == 0
                    ? analysis.foodSummary
                    : selectedNutrition,
          ),
          const SizedBox(height: 20),
          // Dropdown Menu for Meal Time
          Container(
            width: double.maxFinite,
            height: 35,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.grey[300],
                value: _time,
                isDense: true,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                items: ["Breakfast", "Lunch", "Snacks", "Dinner"]
                    .map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _time = newValue!;
                    _updateValues();
                  });
                },
              ),
            ),
          ),
          const Divider(
            height: 30,
            thickness: 1,
          ),
          // Dynamically generate MealCard widgets based on the meals list
          ...analysis.meals.map<Widget>((mainMeal) {
            FLog.info(text: "${servingSize[mainMeal.meal.name]! / 400.0}");
            return MealCard(
              key: ValueKey(mainMeal.meal.name),
              showAdjustment: true,
              itemCount: widget.foodCount[mainMeal.meal.name],
              servingSize: servingSize[mainMeal.meal.name],

              showCheckBox: true,
              showSimilear: true,
              meal: mainMeal.meal,

              similarFoods: mainMeal.similarFoods,
              // Pass the meal data to the MealCard widget
              onToggleValues: (meal) {
                consumedFoodItem.forEach((action) {
                  FLog.info(text: "in Consumed food items ${action.meal.name}");
                });
                MainMeal selectedmeal =
                    consumedFoodItem.singleWhere((mainmeal) {
                  return mainmeal.meal.name == meal.name ? true : false;
                });
                int mealindex = consumedFoodItem.indexWhere((mainmeal) {
                  return mainmeal.meal.name == meal.name ? true : false;
                });
                consumedFoodItem[mealindex] = MainMeal(
                    meal: meal, similarFoods: selectedmeal.similarFoods);
                selectedNutrition.subValues(Nutrition(
                    calories: selectedmeal.meal.calories,
                    protein: selectedmeal.meal.protein,
                    carbs: selectedmeal.meal.carbs,
                    fats: selectedmeal.meal.fat));
                selectedNutrition.addValues(Nutrition(
                    calories: meal.calories,
                    protein: meal.protein,
                    carbs: meal.carbs,
                    fats: meal.fat));
                setState(() {});
              },

              ontoggleCheckBox: (MainMeal selectedMeal, isSelected) {
                Meal newval = selectedMeal.meal;
                if (isSelected) {
                  FLog.info(text: " checked ${selectedMeal.meal.name}");

                  consumedFoodItem.add(selectedMeal);
                  FLog.info(text: "${consumedFoodItem.length}");
                  selectedNutrition.addValues(Nutrition(
                      calories: newval.calories,
                      protein: newval.protein,
                      carbs: newval.carbs,
                      fats: newval.fat));
                } else {
                  FLog.info(text: "unchecked ${selectedMeal.meal.name}");

                  consumedFoodItem.removeWhere((mainmeal) {
                    return mainmeal.meal.name == selectedMeal.meal.name
                        ? true
                        : false;
                  });
                  FLog.info(text: "${consumedFoodItem.length}");
                  selectedNutrition.subValues(Nutrition(
                      calories: newval.calories,
                      protein: newval.protein,
                      carbs: newval.carbs,
                      fats: newval.fat));
                }
                consumedFoodItem.forEach((action) {
                  FLog.info(text: " inconsumed fooditem ${action.meal.name}");
                });

                _updateValues();
                setState(() {});
              },
            );
          }),
        ],
      ),
    );
  }
}

class MealImageWidget extends StatelessWidget {
  final MealAnalysis analysis;
  const MealImageWidget({super.key, required this.analysis});

  @override
  Widget build(BuildContext context) {
    return analysis.analyzedimg.isNotEmpty
        ? Image.memory(
            const Base64Decoder().convert(analysis.analyzedimg),
            width: double.maxFinite,
            height: 300,
            fit: BoxFit.contain,
          )
        : Image.asset(
            'assets/images/food2.jpg', // Fallback image
            fit: BoxFit.fitHeight,
          );
  }
}

class MealSummaryBadges extends StatelessWidget {
  final Nutrition nutrition;

  const MealSummaryBadges({
    super.key,
    required this.nutrition,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        NutrientBadge(
          label: "Calories",
          value: "${nutrition.calories} Kcal",
          color: Colors.green,
        ),
        NutrientBadge(
          label: "Carbs",
          value: "${nutrition.carbs} g",
          color: Colors.pink,
        ),
        NutrientBadge(
          label: "Protein",
          value: "${nutrition.protein} g",
          color: Colors.orange,
        ),
        NutrientBadge(
          label: "Fat",
          value: "${nutrition.fats} g",
          color: Colors.blue,
        ),
      ],
    );
  }
}

class NutrientBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const NutrientBadge({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 60,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            width: 80,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
