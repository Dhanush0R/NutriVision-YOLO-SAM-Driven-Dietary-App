import 'package:flutter/material.dart';
import 'package:nutrivision/Models/meal_analysis_model.dart';

class MealCard extends StatefulWidget {
  final bool showCheckBox;
  final Function(Meal)? onToggleValues;
  final Meal meal;
  final List<Meal>? similarFoods;
  final Function? ontoggleCheckBox;
  final bool showSimilear;
  final bool showAdjustment;
  final int? itemCount;
  final double? servingSize;

  const MealCard({
    super.key,
    required this.meal,
    required this.showSimilear,
    required this.showCheckBox,
    this.ontoggleCheckBox,
    this.similarFoods,
    required this.showAdjustment,
    this.itemCount,
    this.servingSize,
    this.onToggleValues,
  });

  @override
  State<MealCard> createState() => _MealCardState();
}

class _MealCardState extends State<MealCard> {
  bool _isSelected = false;
  bool _isExpanded = false;
  late double servingSize;
  late int count;
  double maxvalue = 600; // Ensure max value is appropriate

  @override
  void initState() {
    super.initState();
    servingSize = widget.servingSize ?? 100;
    count = widget.itemCount ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("Building MealCard for meal: ${widget.meal.name}");
    double scalFactor = servingSize / 100.0; // Calculate once

    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 6,
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.asset(
                      "assets/images/food1.png",
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.meal.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            NutrientInfo(
                                Colors.green,
                                (widget.meal.calories * scalFactor * count)
                                    .round()
                                    .toString()),
                            NutrientInfo(
                                Colors.pink,
                                (widget.meal.protein * scalFactor * count)
                                    .round()
                                    .toString()),
                            NutrientInfo(
                                Colors.orange,
                                (widget.meal.carbs * scalFactor * count)
                                    .round()
                                    .toString()),
                            NutrientInfo(
                                Colors.blue,
                                (widget.meal.fat * scalFactor * count)
                                    .round()
                                    .toString()),
                          ],
                        ),
                      ],
                    ),
                  ),
                  widget.showCheckBox
                      ? Checkbox(
                          value: _isSelected,
                          onChanged: (value) {
                            setState(() {
                              _isSelected = value ?? false;
                              if (widget.ontoggleCheckBox != null) {
                                widget.ontoggleCheckBox!(
                                  MainMeal(
                                    meal: Meal(
                                      name: widget.meal.name,
                                      calories: widget.meal.calories *
                                          scalFactor *
                                          count,
                                      protein: widget.meal.protein *
                                          scalFactor *
                                          count,
                                      carbs: widget.meal.carbs *
                                          scalFactor *
                                          count,
                                      fat: widget.meal.fat * scalFactor * count,
                                    ),
                                    similarFoods: widget.similarFoods ?? [],
                                  ),
                                  _isSelected,
                                );
                              }
                            });
                          },
                        )
                      : const SizedBox()
                ],
              ),
              const SizedBox(height: 10),
              widget.showAdjustment
                  ? Row(
                      children: [
                        Column(
                          children: [
                            Text(
                                "Average Serving Size: ${servingSize.round()}g"),
                            SizedBox(
                              width: 250,
                              child: Slider(
                                label: "${servingSize.round()}g",
                                value: servingSize,
                                min: 0,
                                max: maxvalue,
                                onChanged: (value) {
                                  servingSize = value;
                                  setState(() {});
                                  if (widget.onToggleValues != null) {
                                    widget.onToggleValues!(
                                      Meal(
                                        name: widget.meal.name,
                                        calories: widget.meal.calories *
                                            (servingSize / 100.0) *
                                            count,
                                        protein: widget.meal.protein *
                                            (servingSize / 100.0) *
                                            count,
                                        carbs: widget.meal.carbs *
                                            (servingSize / 100.0) *
                                            count,
                                        fat: widget.meal.fat *
                                            (servingSize / 100.0) *
                                            count,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        CounterWidget(
                          initialCount: count,
                          onToggleCount: (value) {
                            setState(() {
                              count = value;
                              if (_isSelected &&
                                  widget.onToggleValues != null) {
                                widget.onToggleValues!(
                                  Meal(
                                    name: widget.meal.name,
                                    calories: widget.meal.calories *
                                        scalFactor *
                                        count,
                                    protein: widget.meal.protein *
                                        scalFactor *
                                        count,
                                    carbs:
                                        widget.meal.carbs * scalFactor * count,
                                    fat: widget.meal.fat * scalFactor * count,
                                  ),
                                );
                              }
                            });
                          },
                        ),
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 10),
              widget.showSimilear && _isExpanded
                  ? ExpandTail(
                      similarFood: widget.similarFoods
                              ?.where((food) => food != widget.meal)
                              .toList() ??
                          [],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}

// Other classes remain unchanged

class ExpandTail extends StatelessWidget {
  final List<Meal> similarFood; // List of Meal objects for similar foods

  const ExpandTail({super.key, required this.similarFood});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Divider(
            color: Colors.green,
            thickness: 3,
          ),
          const Text(
            "Similar Foods",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          // Display the list of similar foods dynamically
          ...similarFood.map<Widget>((food) {
            return Column(
              children: [
                MealCard(
                  key: ValueKey(food.name), // Add a unique key
                  meal: food,
                  showSimilear: false,
                  showCheckBox: false,
                  showAdjustment: false,
                ),
                const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class NutrientInfo extends StatelessWidget {
  final String _value;
  final Color valueColor;

  const NutrientInfo(
    this.valueColor,
    this._value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: valueColor,
          ),
        ),
        const SizedBox(width: 3),
        Text(_value),
      ],
    );
  }
}

class CounterWidget extends StatefulWidget {
  final Function(int) onToggleCount;
  final int initialCount;
  const CounterWidget(
      {super.key, required this.initialCount, required this.onToggleCount});

  @override
  _CounterWidgetState createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;
  @override
  void initState() {
    super.initState();
    _counter = widget.initialCount;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 1.5),
          borderRadius: BorderRadius.circular(10), // Smaller border radius
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.remove,
                  color: Colors.red, size: 16), // Smaller icon
              onPressed: () {
                setState(() {
                  if (_counter > 0) _counter--;
                  widget.onToggleCount(_counter);
                });
              },
              padding: EdgeInsets.zero, // Remove extra padding
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            ),
            Text(
              '$_counter',
              style: const TextStyle(
                fontSize: 14, // Smaller text size
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add, color: Colors.red, size: 16),
              onPressed: () {
                setState(() {
                  _counter++;
                  widget.onToggleCount(_counter);
                });
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
            ),
          ],
        ),
      ),
    );
  }
}
