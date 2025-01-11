import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:nutrivision/Provider/diet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nutrivision/Provider/consumed_nutrition_provider.dart';
import 'package:f_logs/f_logs.dart';

class DashboardUI extends ConsumerStatefulWidget {
  const DashboardUI({super.key});

  @override
  ConsumerState<DashboardUI> createState() => _DashboardUIState();
}

class _DashboardUIState extends ConsumerState<DashboardUI> {
  @override
  Widget build(BuildContext context) {
    FLog.info(text: "Building dashboard ui");
    final nutrictionValues = ref.read(dietProvider); // Static values, read once
    final consumedNutri =
        ref.watch(consumedNutriProvider); // Dynamic values, react to changes

    return SizedBox(
      height: 300,
      child: Card(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Progress Indicator for Calories
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text("${consumedNutri.calories.toInt()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    const Text('consumed',
                        style: TextStyle(fontSize: 14, color: Colors.black)),
                  ],
                ),
                const SizedBox(width: 20),
                CircularPercentIndicator(
                  startAngle: 180,
                  radius: 70.0,
                  lineWidth: 18.0,
                  percent: (consumedNutri.calories / nutrictionValues.calories)
                      .clamp(
                          0.0, 1.0), // Ensure the value stays between 0 and 1
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${nutrictionValues.calories.toInt()}",
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const Text("kcal",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          )),
                    ],
                  ),
                  progressColor:
                      (consumedNutri.calories > nutrictionValues.calories)
                          ? Colors.red // Warning color if exceeded
                          : Colors.green, // Normal color
                  backgroundColor: Colors.grey[300]!,
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    Text(
                        '${(nutrictionValues.calories - consumedNutri.calories).toInt()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        )),
                    const Text('remaining',
                        style: TextStyle(fontSize: 14, color: Colors.black)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNutrientBar(
                    context,
                    'Protein',
                    consumedNutri.protein.toInt(),
                    nutrictionValues.protein.toInt(),
                    Colors.pink),
                _buildNutrientBar(context, 'Fats', consumedNutri.fats.toInt(),
                    nutrictionValues.fats.toInt(), Colors.orange),
                _buildNutrientBar(context, 'Carbs', consumedNutri.carbs.toInt(),
                    nutrictionValues.carbs.toInt(), Colors.blue),
              ],
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildNutrientBar(BuildContext context, String nutrient, int consumed,
    int total, Color color) {
  // Determine if consumption exceeds the total
  bool isExceeded = consumed > total;
  Color progressColor = isExceeded ? Colors.red : color;

  // Show a SnackBar when the nutrient limit is exceeded
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (isExceeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$nutrient intake exceeded!'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  });

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(nutrient,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          )),
      SizedBox(
        width: 100,
        child: LinearProgressIndicator(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          value: (consumed / total).clamp(0.0, 1.0), // Prevent overflow
          minHeight: 10,
          backgroundColor: Colors.grey[300],
          color: progressColor, // Dynamic color based on condition
        ),
      ),
      Text(
        '$consumed / $total g',
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}
