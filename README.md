# NutriVision: YOLO-SAM-Driven Dietary App for Personalized Food Recommendation and Meal Tracking

## Overview

NutriVision is an innovative Android application designed to enhance dietary management. It allows users to capture meal images, analyze their nutritional value, and receive personalized food recommendations. By leveraging advanced models like YOLO and SAM, the app provides accurate segmentation and identification of food items. Using user health data such as age, sex, BMI, and specific health conditions, NutriVision calculates tailored nutritional intake. The app also features a dashboard for users to monitor their daily calorie and macronutrient intake, helping them achieve their dietary goals.

![IMG-20250112-WA0019](https://github.com/user-attachments/assets/fe7df05c-c839-4ece-9d00-e62c3ca836d7)   ![IMG-20250112-WA0005](https://github.com/user-attachments/assets/92afb8ac-5e12-4678-8779-e46572bd6f23)  ![IMG-20250112-WA0006](https://github.com/user-attachments/assets/cca8e38b-7640-4cf2-8505-cd880ee3d660)

- For more application snapshots, refer to the [images](https://github.com/Dhanush0R/NutriVision-YOLO-SAM-Driven-Dietary-App/edit/master/images) folder.


---
![IMG-20250112-WA0025](https://github.com/user-attachments/assets/9ffb2701-6c04-47e4-a756-bffa7b81c5d9)   ![IMG-20250112-WA0023](https://github.com/user-attachments/assets/881c4432-94a0-4e4a-a810-c62cebbc3495)   ![IMG-20250112-WA0026](https://github.com/user-attachments/assets/241a77b0-80f1-4031-a653-7d6608236463)

## Features

1. **Food Detection and Segmentation**  
   - Detects and segments food items in meal images using YOLO and SAM models.

2. **Nutritional Intake Calculation**  
   - Calculates personalized daily nutritional recommendations based on user health data.

3. **Personalized Food Recommendations**  
   - Recommends similar food items based on nutritional properties and user preferences.

4. **Dashboard for Tracking**  
   - Tracks daily calorie and macronutrient intake to help users manage their diet effectively.

---

## architecture

![image](https://github.com/user-attachments/assets/516fc27b-690b-4d44-a08b-2b08bf1befa8)

---

## How to Run

### Prerequisites

Ensure the following are installed on your system:
- Python 3.8 or higher
- FastAPI
- Required Python libraries: `torch`, `pydantic`, `opencv-python`, `pandas`, `matplotlib`, `scikit-learn`
#### Notes:
 - **Python Version:** Ensure you are using Python 3.8 or later for compatibility with the listed packages and the SAM and YOLO models.
 - **PyTorch Version:** Refer to the Segment Anything installation guide for compatible PyTorch versions to avoid any issues with the SAM model setup.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/NutriVision.git
   cd NutriVision
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up the models as described below.

4. Run the FastAPI server:
   ```bash
   uvicorn main:app --reload
   ```

   The server will be accessible at `http://127.0.0.1:8000`.

### Frontend Setup

- Follow the [Flutter documentation](https://flutter.dev/docs) to set up the NutriVision mobile application.
- Use the provided API endpoints for backend communication.

---

## Model Setup

### SAM (Segment Anything Model)

The Segment Anything Model (SAM) by Meta AI is used for food segmentation in the application.  

Follow these steps to set up SAM:  
1. Clone the SAM repository:
   ```bash
   git clone https://github.com/facebookresearch/segment-anything.git
   cd segment-anything
   ```

2. Install the required dependencies:
   ```bash
   pip install -e .
   ```

3. Download the SAM model weights:
   - Refer to the official SAM repository for available model weights: [SAM Installation Guide](https://github.com/facebookresearch/segment-anything?tab=readme-ov-file#installation).

---

### YOLOv11 (You Only Look Once)

YOLOv11 is used for food detection and bounding box generation in the application.  

#### Option 1: Use Pre-Trained Model
1. Download the pre-trained YOLO model weights (`best.pt`):
   - Place the `best.pt` file in the `models/` directory.

#### Option 2: Train on Custom Data
1. Clone the YOLOv11 repository:
   ```bash
   git clone https://github.com/ultralytics/ultralytics.git
   cd ultralytics
   ```

2. Follow the instructions in the YOLOv11 documentation for data preparation and training: [YOLOv11 Setup and Training Guide](https://github.com/ultralytics/ultralytics).  

3. Once training is complete, place the trained weights file (e.g., `best.pt`) in the `models/` directory.

---

## API Endpoints

### 1. `/calculate_recommended_intake/` (POST)  
   **Purpose**: Calculate daily nutritional requirements.  
   **Input**: User details (age, sex, weight, height, activity level, health conditions).  
   **Output**: Recommended calories, protein, carbs, and fat intake.

### 2. `/segment_everything/` (POST)  
   **Purpose**: Segment all food items in an uploaded image.  
   **Input**: Meal image.  
   **Output**: Masked image with segmented food items and their nutritional analysis.

### 3. `/segment_selected/` (POST)  
   **Purpose**: Segment specific user-selected food items in an image.  
   **Input**: Bounding box coordinates for selected regions.  
   **Output**: Masked image with segmented food items.

### 4. `/recommend/` (POST)  
   **Purpose**: Provide personalized food recommendations.  
   **Input**: Nutritional analysis and user preferences.  
   **Output**: List of similar food items and meals.

---

## Future Enhancements

- Support for additional cuisines and dietary restrictions (e.g., vegetarian, vegan, gluten-free).
- Integration with wearable devices for activity and health data tracking.
- Advanced meal planning and recipe suggestions.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---
