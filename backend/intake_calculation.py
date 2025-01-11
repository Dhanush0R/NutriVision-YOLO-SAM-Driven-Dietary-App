import json
import os

# Helper Functions
def load_disease_config(file_path: str):
    """Load disease configuration from JSON file."""
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"Disease configuration file not found at: {file_path}")
    with open(file_path, "r") as file:
        return json.load(file)


def calculate_tdee(weight_kg, height_cm, age, gender, activity_level,goal="maintenance"):
    """Calculate Total Daily Energy Expenditure (TDEE)."""
    if gender.lower() == "male":
        bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age + 5
    elif gender.lower() == "female":
        bmr = 10 * weight_kg + 6.25 * height_cm - 5 * age - 161
    else:
        raise ValueError("Gender must be 'male' or 'female'.")

    activity_factors = {
        "sedentary": 1.2,
        "lightly active": 1.375,
        "moderately active": 1.55,
        "very active": 1.725,
        "extremely active": 1.9,
    }

    if activity_level not in activity_factors:
        raise ValueError("Invalid activity level.")

    activity_multiplier = activity_factors[activity_level]
    tdee = bmr * activity_multiplier
    
    # Adjust TDEE based on goal
    if goal.lower() == "weight loss":
        tdee *= 0.8  # 20% calorie deficit
    elif goal.lower() == "muscle gain":
        tdee *= 1.2  # 20% calorie surplus

    return tdee

def calculate_adjusted_macronutrients(TDEE, selected_diseases, disease_config):
    """Calculate adjusted macronutrients based on diseases."""
    class DiseaseAdjustment:
        def __init__(self, name, severity, config):
            self.name = name
            self.severity = severity
            self.config = config

        def get_adjustment(self):
            return self.config

    def calculate_macronutrients_with_diseases(TDEE, disease_adjustments):
        resolved_adjustments = {"protein_percent": 0, "fat_percent": 0, "carb_percent": 0}
        total_severity = 0

        for disease in disease_adjustments:
            adjustment = disease.get_adjustment()
            weight = disease.severity * disease.config.get("severity_weight", 1)
            total_severity += weight

            for key in ["protein_percent", "fat_percent", "carb_percent"]:
                resolved_adjustments[key] += adjustment[key] * weight

        if total_severity > 0:
            for key in resolved_adjustments.keys():
                resolved_adjustments[key] /= total_severity
        else:
            # Fallback to default macronutrient distribution (e.g., 20% protein, 30% fat, 50% carbs)
            resolved_adjustments = {"protein_percent": 20, "fat_percent": 30, "carb_percent": 50}

        total_percent = sum(resolved_adjustments.values())
        if total_percent > 0:
            for key in resolved_adjustments.keys():
                resolved_adjustments[key] = (resolved_adjustments[key] / total_percent) * 100
        else:
            raise ValueError("Total percentage after applying caps is zero. Check disease adjustments.")

        protein_grams = (resolved_adjustments["protein_percent"] / 100) * TDEE / 4
        fat_grams = (resolved_adjustments["fat_percent"] / 100) * TDEE / 9
        carbs_grams = (resolved_adjustments["carb_percent"] / 100) * TDEE / 4

        return protein_grams, fat_grams, carbs_grams

    # If no diseases are selected, return default proportions
    if not selected_diseases:
        return calculate_macronutrients_with_diseases(
            TDEE,
            []
        )

    disease_adjustments = []
   
    for disease, severity_level in selected_diseases.items():
    # Retrieve disease information from the configuration
        disease_info = next(
            (item for item in disease_config if item["disease_name"] == disease), None
        )
        if disease_info:
            # Use severity from user input instead of default priority
            severity = {
                "Mild": 1,
                "Moderate": 2,
                "Severe": 3
            }.get(severity_level, 1)  # Default to 'Mild' if not specified
            
            disease_adjustments.append(
                DiseaseAdjustment(
                    name=disease,
                    severity=severity,  # Severity based on user input
                    config=disease_info,
                )
        )


    return calculate_macronutrients_with_diseases(TDEE, disease_adjustments)
