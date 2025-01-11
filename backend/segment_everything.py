import os

import cv2
import matplotlib.pyplot as plt
import numpy as np
import torch
from segment_anything import SamPredictor, sam_model_registry
from ultralytics import YOLO


class ObjectDetectionAndSegmentation:
    def __init__(self, yolo_model_path, sam_checkpoint_path, device='cuda'):
        self.device = device
        self.model = YOLO(yolo_model_path)
        self.sam = sam_model_registry["default"](checkpoint=sam_checkpoint_path).to(device=self.device)
        self.predictor = SamPredictor(self.sam)
        self.class_colors = {}

    def load_image(self, img_path):
        image = cv2.imread(img_path)
        return image

    def detect_objects(self, image, conf_threshold=0.0):
        results = self.model(image)
        bboxes, classes = [], []

        for result in results:
            for box in result.boxes:
                x1, y1, x2, y2 = map(int, box.xyxy[0].tolist())
                conf = box.conf[0].item()
                cls = int(box.cls[0])

                if conf >= conf_threshold:
                    label = self.model.names[cls]
                    classes.append(label)
                    bboxes.append([x1, y1, x2, y2])

        return np.array(bboxes), classes

    def draw_label(self, image, bboxes, classes):
        for i, (x1, y1, x2, y2) in enumerate(bboxes):
            label = classes[i]
            color = (0, 0, 0)

            center_x, center_y = (x1 + x2) // 2, (y1 + y2) // 2 - 3
            cv2.circle(image, (center_x, center_y), 3, color, -1)

            (text_width, text_height), _ = cv2.getTextSize(label, cv2.FONT_HERSHEY_SIMPLEX, 0.5, 2)
            text_x, text_y = center_x - text_width // 2, center_y + text_height // 2

            cv2.putText(image, label, (text_x, text_y), cv2.FONT_HERSHEY_SIMPLEX, 1.0, color, 2)

        return image


    def show_mask(self, mask, ax, class_name):
        h, w = mask.shape[-2:]
        if class_name not in self.class_colors:
            color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)
            self.class_colors[class_name] = color
        else:
            color = self.class_colors[class_name]

        mask_image = mask.reshape(h, w, 1) * color.reshape(1, 1, -1)
        ax.imshow(mask_image)

    # def segment_objects(self, image, bboxes, classes,img_path):
    #     self.predictor.set_image(image)
    #     input_boxes = torch.tensor(bboxes, device=self.device)
    #     transformed_boxes = self.predictor.transform.apply_boxes_torch(input_boxes, image.shape[:2])
    #     masks, _, _ = self.predictor.predict_torch(
    #         point_coords=None,
    #         point_labels=None,
    #         boxes=transformed_boxes,
    #         multimask_output=False,
    #     )
    #     save_dir = 'C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/saved_images'
    #     output_image_path = os.path.join(save_dir, os.path.basename(img_path))
    #     plt.figure(figsize=(7, 7))
    #     plt.imshow(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))
    #     for i, mask in enumerate(masks):
    #         self.show_mask(mask.cpu().numpy(), plt.gca(), classes[i])
    #     plt.axis('off')
    #     plt.savefig(output_image_path,bbox_inches='tight', pad_inches=0)
    #     # plt.show()
    #     plt.close()



    



    def segment_objects(self, image, bboxes, classes):
        # A dictionary to store class colors
        self.class_colors = getattr(self, "class_colors", {})

        # Predictor processing
        self.predictor.set_image(image)
        input_boxes = torch.tensor(bboxes, device=self.device)
        transformed_boxes = self.predictor.transform.apply_boxes_torch(input_boxes, image.shape[:2])
        masks, _, _ = self.predictor.predict_torch(
            point_coords=None,
            point_labels=None,
            boxes=transformed_boxes,
            multimask_output=False,
        )

        # Create an overlay for masks
        overlay = image.copy()
        overlay = overlay.astype(np.float32) / 255.0  # Normalize image to [0, 1] for blending

        for i, mask in enumerate(masks):
            mask_np = mask.cpu().numpy().squeeze()  # Ensure mask is in (H, W) format
            class_name = classes[i]

            # Generate or retrieve the color for the class
            if class_name not in self.class_colors:
                color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)  # RGBA with alpha=0.6
                self.class_colors[class_name] = color
            else:
                color = self.class_colors[class_name]

            # Apply the mask with transparency
            h, w = mask_np.shape[-2:]
            mask_image = mask_np.reshape(h, w, 1) * color[:3].reshape(1, 1, -1)  # Apply RGB color only
            mask_alpha = mask_np * color[3]  # Use the alpha channel for blending

            # Blend the mask with the overlay
            for c in range(3):  # Iterate over R, G, B channels
                overlay[:, :, c] = overlay[:, :, c] * (1 - mask_alpha) + mask_image[:, :, c] * mask_alpha

        # Convert the overlay back to uint8
        result_image = (overlay * 255).astype(np.uint8)
        return result_image





# Main function to execute the code
def main():
    # Initialize paths
    yolo_model_path = 'C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/best.pt'
    sam_checkpoint_path = 'C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/sam_vit_h_4b8939.pth'
   
    img_path = 'C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/test2.jpg'
    

    # Initialize the object detection and segmentation class
    app = ObjectDetectionAndSegmentation(yolo_model_path, sam_checkpoint_path)

    # Load and process the image
    image = app.load_image(img_path)
    bboxes, classes = app.detect_objects(image)
    annotated_image = app.draw_label(image, bboxes, classes)

    # Perform segmentation and display results
    app.segment_objects(annotated_image, bboxes, classes)


if __name__ == "__main__":
    main()
