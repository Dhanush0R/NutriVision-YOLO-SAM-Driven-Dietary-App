from fastapi import FastAPI, File, UploadFile, Form, Body
from fastapi import HTTPException
from diet_calculator.model2 import *
from diet_calculator.recommend import *
from diet_calculator.calculation import *
from pydantic import BaseModel
from typing import List, Optional
import numpy as np
import cv2
import base64
import torch
from segment_anything import SamPredictor, sam_model_registry
from ultralytics import YOLO
import pandas as pd
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.preprocessing import StandardScaler
import io
import json
from diet_calculator.model import *
import matplotlib.pyplot as plt



# FastAPI app initialization
app = FastAPI()

# Define InputData and BoundingBox models
class BoundingBox(BaseModel):
    x1: int
    y1: int
    x2: int
    y2: int

class InputData(BaseModel):
    bounding_boxes: List[BoundingBox]
    diseases: List[str]


# # FastAPI Diet Calculation Endpoint
# @app.post("/calculate_recommended_intake/")
# async def calculate_recommended_intake(user_data: UserData):
#     weight = user_data.weight
#     height = user_data.height
#     age = user_data.age
#     gender = user_data.gender
#     activity_level = user_data.exercise
#     selected_diseases = user_data.selected_diseases

#     # Calculate TDEE
#     TDEE = calculate_tdee(weight, height, age, gender, activity_level)

#     # Load disease configuration
#     disease_config = load_disease_config(file_path="C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diseases.json")

#     # Calculate adjusted macronutrients
#     protein, fat, carbs = calculate_adjusted_macronutrients(TDEE, selected_diseases, disease_config)

#     return {
#         "Calories": TDEE,
#         "Protein": protein,
#         "Fats": fat,
#         "Carbs": carbs
#     }


class UserData(BaseModel):
    age: int
    height: float
    weight: float
    gender: str
    exercise: str
    selected_diseases: dict[str, str]
    goal:str

@app.post("/calculate_recommended_intake/")
async def calculate_recommended_intake(user_data: UserData):
    
    try:
        # Extract user data
        weight = user_data.weight
        height = user_data.height
        age = user_data.age
        gender = user_data.gender
        activity_level = user_data.exercise
        selected_diseases = user_data.selected_diseases
        goal=user_data.goal
        print("inside backend")

        # Calculate TDEE
        TDEE = calculate_tdee(weight, height, age, gender, activity_level,goal)

        # Load disease configuration
        disease_config_path = "C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/diseases2.json"
        disease_config = load_disease_config(file_path=disease_config_path)

        # Calculate adjusted macronutrients
        protein, fat, carbs = calculate_adjusted_macronutrients(TDEE, selected_diseases, disease_config)

        # Response
        response = {
            "Calories": TDEE,
            "Protein": protein,
            "Fats": fat,
            "Carbs": carbs,
        }

        # Add a note if no diseases are selected
        if not selected_diseases:
            response["Note"] = "No diseases selected. Default macronutrient distribution applied."

        return response

    except FileNotFoundError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail="An unexpected error occurred.")




@app.post("/analyze_meal_image_bounding/")
async def analyze_meal_image(file: UploadFile = File(...), input_data: str = Form(...)):
    image_data = await file.read()
    # Parse the JSON string to a dictionary
    try:
        input_data_dict = json.loads(input_data)
        print(input_data_dict)
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=400, detail=f"Error decoding input data: {e}")
    
    # # Now input_data_dict can be used as a normal dictionary
    bounding_box = input_data_dict.get('bounding_box', [])
    
    # bounding_boxes=[]

    # if None not in (x1, y1, x2, y2):
    #     bounding_boxes.append(np.array([x1, y1, x2, y2]))
    # else:
    #     raise ValueError("Bounding box coordinates are missing or invalid.")

    diseases = input_data_dict.get("diseases", [])

    # Initialize the ImageProcessor with model paths
    processor = ImageProcessor(
        yolo_model_path='C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/best.pt',
        sam_checkpoint='C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/sam_vit_h_4b8939.pth'
    )

    # Load image and process
   
    processor.load_image(image_data)

    # if bounding_boxes:
    #     processor.bounding_boxes = [
    #         np.array([bbox['x1'], bbox['y1'], bbox['x2'], bbox['y2']]) for bbox in bounding_boxes
    #     ]
    # else:
    # processor.draw_bounding_boxes()
    for box in bounding_box:

        x1, y1 = box.get('x1'), box.get('y1')
        x2, y2 = box.get('x2'), box.get('y2')
        processor.bounding_boxes.append(np.array([int(x1), int(y1), int(x2), int(y2)]))
    print(processor.bounding_boxes)

    labeled_image,class_names = processor.label_image()
    if not class_names:
        return {"message": "No food items in the meal image"}
    print("classes names",class_names)
    classCount: Dict[str, int] = processor.class_cnt(class_names)

    masks = processor.segment_image(labeled_image)
    masked_img=processor.segment_objects_return_image(masks=masks,labeled_image=labeled_image,classes=class_names)
    # # masked_image = processor.encode_mask_to_base64(masks, labeled_image)
    # masked_image =processor.display_segmented_image(labeled_image, masks)
    
    # cv2.imshow(masked_image)
    rgb_image = cv2.cvtColor(masked_img, cv2.COLOR_BGR2RGB)

# Encode the RGB image to Base64
    _, buffer = cv2.imencode('.jpg', rgb_image, [cv2.IMWRITE_JPEG_QUALITY, 90])
    masked_image_base64 = base64.b64encode(buffer).decode('utf-8')
    
    servingSize: Dict[str, float] ={}
    for i in class_names:
        print(i)

    meals = []
    for label in set(class_names):
       
        
        result = recommend_food(label, diseases or [])
                
        # Handle the response
        if result["error"]:
            # Error case: Handle gracefully
            print(result["message"])  # Display the error message to the user
        else:
            recommendations = result["recommendations"]
            servingSize[label] = result["serving_size"]

            similar_foods = [
                {
                    "name": row["Food Name"],
                    "calories": f"{row['Calories (kcal)']}Kcal",
                    "carbs": f"{row['Carbs (g)']}g",
                    "protein": f"{row['Protein (g)']}g",
                    "fat": f"{row['Total Fat (g)']}g",
                
                }
                for _, row in recommendations.iterrows()
            ]

            meals.append({
                "meal": {
                    "name": label,
                    "calories": f"{recommendations.iloc[0]['Calories (kcal)']}Kcal",
                    "carbs": f"{recommendations.iloc[0]['Carbs (g)']}g",
                    "protein": f"{recommendations.iloc[0]['Protein (g)']}g",
                    "fat": f"{recommendations.iloc[0]['Total Fat (g)']}g"
                },
                "similarFoods": similar_foods
            })

    total_calories = sum(float(meal["meal"]["calories"][:-4]) for meal in meals)
    total_carbs = sum(float(meal["meal"]["carbs"][:-1]) for meal in meals)
    total_protein = sum(float(meal["meal"]["protein"][:-1]) for meal in meals)
    total_fat = sum(float(meal["meal"]["fat"][:-1]) for meal in meals)

    food_summary = {
        "calories": f"{total_calories:.1f}Kcal",
        "carbs": f"{total_carbs:.1f}g",
        "protein": f"{total_protein:.1f}g",
        "fat": f"{total_fat:.1f}g"
    }


    return {
        "mealAnalysis":{
        "foodSummary": food_summary,
        "meals": meals,
        "maskedImage": masked_image_base64
        },
        "foodCount":classCount,
        "servingSize":servingSize
    
    }




@app.post("/analyze_meal_image/")
async def analyze_meal_image(file: UploadFile = File(...), input_data: str = Form(...)):
    image_data = await file.read()
    # Parse the JSON string to a dictionary
    try:
        input_data_dict = json.loads(input_data)
        print(input_data_dict)
    except json.JSONDecodeError as e:
        raise HTTPException(status_code=400, detail=f"Error decoding input data: {e}")
    
    
    diseases = input_data_dict.get("diseases", [])
    return analyzeMeal(img_data=image_data,diseases=diseases)

