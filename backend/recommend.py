# import pandas as pd
# from sklearn.metrics.pairwise import cosine_similarity
# from sklearn.preprocessing import StandardScaler

# # Load the dataset
# df = pd.read_csv('C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/merged_test.csv')

# # Extract nutritional data 
# nutrition_columns = [
#     'Carbs (g)', 'Total Fat (g)', 'Saturated Fat (g)', 'Protein (g)', 'Fiber (g)', 'Sugar (g)', 
#     'Potassium (mg)', 'Magnesium (mg)', 'Calcium (mg)', 'Iron (mg)', 'Vitamin C (mg)', 'Vitamin A (IU)', 
#     'Vitamin E (mg)', 'Vitamin K (mcg)', 'Calories (kcal)'
# ]
# disease_columns = [
#     'Coeliac disease', 'Hypothyroidism', 'Hyperthyroidism', 'Diabetes insipidus', 'Frozen Shoulder', 
#     'Trigger Finger', 'Haemochromatosis', 'Acute Pancreatitis', 'Chronic Pancreatitis', 'Nausea and vomiting',
#     'Migraine', 'Mononucleosis', 'Stomach aches', 'Conjunctivitis', 'Dry Mouth', 'Acne', 'Malnutrition', 
#     'Diabetes', 'Kidney Infection', 'Obstructive Sleep Apnoea', 'Thyroid', 'Scleroderma', 'Acromegaly',
#     'Pheochromocytoma', 'Lupus', 'Cushing Syndrome', 'Hypertension', 'Type 2 Diabetes', 'High blood pressure', 
#     'Heart Disease', 'Stroke', 'Sleep apnea', 'Metabolic syndrome', 'Fatty liver disease', 'Osteoarthritis', 
#     'Gallbladder diseases', 'Kidney Diseases', 'Measles', 'Mouth ulcer', 'Sore throat', 'Yellow fever'
# ]

# # Normalize 
# nutrition_data = df[nutrition_columns].values
# scaler = StandardScaler()
# nutrition_data_scaled = scaler.fit_transform(nutrition_data)

# # Function to get the food recommendations
# def recommend_food( input_food,  diseases):
#     # Find the index of the input food item
#     input_food = input_food.strip().capitalize()
#     print(input_food)
#     # Check if the input food exists in the DataFrame
#     food_indices = df[df['Food Name'] == input_food].index
#     if food_indices.empty:
#         raise ValueError(f"Food '{input_food}' not found in the dataset.")
    
#     # Get the index of the input food
    
#     input_food_idx = food_indices[0]
#     serving_size = df['Avg serving size(g)'] = pd.to_numeric(df['Avg serving size(g)'], errors='coerce')

    
#     # Calculate cosine similarity between the input food and all other food items
#     cosine_sim = cosine_similarity([nutrition_data_scaled[input_food_idx]], nutrition_data_scaled)
    
#     # Get the top 10 most similar food items (excluding the input food)
#     similar_indices = cosine_sim[0].argsort()[-11:-1][::-1]
#     recommended_foods = df.iloc[similar_indices]
    
#     # Filter the recommended foods based on diseases
#     filtered_recommendations = recommended_foods.copy()
    
#     # Only consider diseases that are valid in the DataFrame
#     valid_diseases = [disease for disease in diseases if disease in disease_columns]
    
#     # Filter based on valid diseases
#     for disease in valid_diseases:
#         filtered_recommendations = filtered_recommendations[filtered_recommendations[disease] == 'Yes']
    
#     # Return only the relevant nutritional columns
#     return filtered_recommendations[['Food Name'] + nutrition_columns],serving_size


import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler

# Load the dataset
df = pd.read_csv('C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/mergedData.csv')

# Extract nutritional data 
nutrition_columns = [
    'Carbs (g)', 'Total Fat (g)', 'Protein (g)', 'Sugar (g)', 'Calories (kcal)']
disease_columns = [
    'Coeliac disease', 'Hypothyroidism', 'Hyperthyroidism', 'Diabetes insipidus', 'Frozen Shoulder', 
    'Trigger Finger', 'Haemochromatosis', 'Acute Pancreatitis', 'Chronic Pancreatitis', 'Nausea and vomiting',
    'Migraine', 'Mononucleosis', 'Stomach aches', 'Conjunctivitis', 'Dry Mouth', 'Acne', 'Malnutrition', 
    'Diabetes', 'Kidney Infection', 'Obstructive Sleep Apnoea', 'Thyroid', 'Scleroderma', 'Acromegaly',
    'Pheochromocytoma', 'Lupus', 'Cushing Syndrome', 'Hypertension', 'Type 2 Diabetes', 'High blood pressure', 
    'Heart Disease', 'Stroke', 'Sleep apnea', 'Metabolic syndrome', 'Fatty liver disease', 'Osteoarthritis', 
    'Gallbladder diseases', 'Kidney Diseases', 'Measles', 'Mouth ulcer', 'Sore throat', 'Yellow fever'
]

# Handle missing values (NaN)
# Option 1: Drop rows with NaN values in nutrition columns
# df.dropna(subset=nutrition_columns, inplace=True)

# Option 2: Fill NaN values with the mean of the column (you can also use median or another strategy)
df[nutrition_columns] = df[nutrition_columns].fillna(df[nutrition_columns].mean())

# Normalize 
nutrition_data = df[nutrition_columns].values
scaler = StandardScaler()
nutrition_data_scaled = scaler.fit_transform(nutrition_data)

# Function to get the food recommendations
def recommend_food(input_food, diseases):
    # Find the index of the input food item
    input_food = input_food.strip().capitalize()
    print(input_food)
    # Check if the input food exists in the DataFrame
    food_indices = df[df['Food Name'] == input_food].index
    if food_indices.empty:
        # Gracefully handle the case where the food item is not found
        print(f"Food '{input_food}' not found in the dataset.")
        return {
            "error": True,
            "message": f"Food '{input_food}' not found in the dataset.",
            "recommendations": None,
            "serving_size": None,
        }
    
    # Get the index of the input food
    input_food_idx = food_indices[0]
    print(f"Input food index: {input_food_idx}")
    
    # Calculate cosine similarity between the input food and all other food items
    cosine_sim = cosine_similarity([nutrition_data_scaled[input_food_idx]], nutrition_data_scaled)

    serving_size = float(df.loc[df['Food Name'] == input_food, 'Avg serving size(g)'].values[0])

    print(serving_size)

    
    # Get the top 10 most similar food items (excluding the input food)
    similar_indices = cosine_sim[0].argsort()[-11:-1][::-1]
    recommended_foods = df.iloc[similar_indices]
    
    # Filter the recommended foods based on diseases
    filtered_recommendations = recommended_foods.copy()
    
    # Only consider diseases that are valid in the DataFrame
    valid_diseases = [disease for disease in diseases if disease in disease_columns]
    
    # Filter based on valid diseases
    for disease in valid_diseases:
        filtered_recommendations = filtered_recommendations[filtered_recommendations[disease] == 'Yes']
    
    # Return only the relevant nutritional columns
    
    return {
        "error": False,
        "message": "Success",
        "recommendations":filtered_recommendations[['Food Name'] + nutrition_columns],
        "serving_size": serving_size,
    }


# Test with an example food and disease
