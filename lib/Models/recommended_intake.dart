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

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: json['Calories'] ?? 0.0,
      protein: json['Protein'] ?? 0.0,
      carbs: json['Carbs'] ?? 0.0,
      fats: json['Fats'] ?? 0.0,
    );
  }

  
}
