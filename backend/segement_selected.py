import cv2
import matplotlib.pyplot as plt
import numpy as np
import torch
from segment_anything import SamPredictor, sam_model_registry
from ultralytics import YOLO


class ImageProcessor:
    def __init__(self, yolo_model_path, sam_checkpoint, sam_model_type="default", device="cuda"):
        self.model = YOLO(yolo_model_path)
        self.sam = sam_model_registry[sam_model_type](checkpoint=sam_checkpoint)
        self.device = device
        self.sam.to(device=self.device)
        self.predictor = SamPredictor(self.sam)
        self.bounding_boxes = []
        self.img = None

    def load_image(self, img_path):
        self.img = cv2.imread(img_path)
        if self.img is None:
            raise FileNotFoundError(f"Image at {img_path} not found.")
        return self.img

    def draw_bounding_boxes(self):
        bbox_start, bbox_end, drawing = None, None, False

        def mouse_callback(event, x, y, flags, param):
            nonlocal bbox_start, bbox_end, drawing
            if event == cv2.EVENT_LBUTTONDOWN:
                bbox_start = (x, y)
                drawing = True
            elif event == cv2.EVENT_MOUSEMOVE and drawing:
                bbox_end = (x, y)
                img_copy = self.img.copy()
                cv2.rectangle(img_copy, bbox_start, bbox_end, (0, 255, 0), 2)
                cv2.imshow("Image", img_copy)
            elif event == cv2.EVENT_LBUTTONUP:
                bbox_end = (x, y)
                drawing = False
                cv2.rectangle(self.img, bbox_start, bbox_end, (0, 255, 0), 2)
                self.bounding_boxes.append(np.array([bbox_start[0], bbox_start[1], bbox_end[0], bbox_end[1]]))
                cv2.imshow("Image", self.img)

        cv2.imshow("Image", self.img)
        cv2.setMouseCallback("Image", mouse_callback)
        while True:
            if cv2.waitKey(1) & 0xFF == ord('q'):
                break
        cv2.destroyAllWindows()

    def calculate_iou_numpy(self, box1, box2):
        x_min_inter = np.maximum(box1[:, None, 0], box2[:, 0])
        y_min_inter = np.maximum(box1[:, None, 1], box2[:, 1])
        x_max_inter = np.minimum(box1[:, None, 2], box2[:, 2])
        y_max_inter = np.minimum(box1[:, None, 3], box2[:, 3])
        inter_width = np.maximum(0, x_max_inter - x_min_inter)
        inter_height = np.maximum(0, y_max_inter - y_min_inter)
        intersection_area = inter_width * inter_height
        box1_area = (box1[:, 2] - box1[:, 0]) * (box1[:, 3] - box1[:, 1])
        box2_area = (box2[:, 2] - box2[:, 0]) * (box2[:, 3] - box2[:, 1])
        union_area = box1_area[:, None] + box2_area - intersection_area
        return intersection_area / np.maximum(union_area, 1e-10)

    def label_image(self):
        results = self.model(self.img)
        pred_bboxes, pred_classes = [], []
        for result in results:
            for box in result.boxes:
                pred_bboxes.append(box.xyxy[0].cpu().numpy())
                pred_classes.append(int(box.cls[0].cpu().numpy()))
        pred_bboxes = np.array(pred_bboxes)

        max_overlap_indices = np.argmax(self.calculate_iou_numpy(np.array(self.bounding_boxes), pred_bboxes), axis=1)
        class_names = self.model.names
        labeled_image = self.img.copy()

        for i, bbox in enumerate(self.bounding_boxes):
            pred_idx = max_overlap_indices[i]
            class_label = f'{class_names[pred_classes[pred_idx]]}'
            x1, y1, x2, y2 = bbox
            center_x = (x1 + x2) // 2
            center_y = (y1 + y2) // 2
            (text_width, text_height), _ = cv2.getTextSize(class_label, cv2.FONT_HERSHEY_SIMPLEX, 0.9, 2)
            text_x = center_x - text_width // 2
            text_y = center_y + text_height // 2
            cv2.putText(labeled_image, class_label, (text_x, text_y), cv2.FONT_HERSHEY_SIMPLEX, 0.9, (255, 0, 0), 2)

        return labeled_image

    def segment_image(self, labeled_image):
        self.predictor.set_image(labeled_image)
        input_boxes = torch.tensor(self.bounding_boxes, device=self.device)
        transformed_boxes = self.predictor.transform.apply_boxes_torch(input_boxes, labeled_image.shape[:2])
        masks, _, _ = self.predictor.predict_torch(
            point_coords=None, point_labels=None, boxes=transformed_boxes, multimask_output=False
        )
        return masks
    
    def segment_objects_return_image(self, labeled_image, masks):
        # Convert the labeled image to RGB
        labeled_image = cv2.cvtColor(labeled_image, cv2.COLOR_BGR2RGB)

        # Create an overlay for applying the masks
        overlay = labeled_image.astype(np.float32) / 255.0  # Normalize image to [0, 1] for blending

        for mask in masks:
            # Get the mask as numpy array
            mask_np = mask.cpu().numpy().squeeze()  # Ensure mask is in (H, W) format

            # Random or predefined color for the mask
            color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0)  # Random color with transparency

            # Get image dimensions
            h, w = mask_np.shape[-2:]

            # Apply the mask color with transparency
            mask_image = mask_np.reshape(h, w, 1) * color[:3].reshape(1, 1, -1)  # Apply RGB color
            mask_alpha = mask_np * color[3]  # Alpha channel for transparency

            # Blend the mask with the image using the alpha value
            for c in range(3):  # Iterate over RGB channels
                overlay[:, :, c] = overlay[:, :, c] * (1 - mask_alpha) + mask_image[:, :, c] * mask_alpha

        # Convert the result back to uint8
        result_image = (overlay * 255).astype(np.uint8)
        
        return result_image

    def display_segmented_image(self, labeled_image, masks):
        labeled_image = cv2.cvtColor(labeled_image, cv2.COLOR_BGR2RGB)
        plt.figure(figsize=(10, 7))
        plt.imshow(labeled_image)
        for mask in masks:
            self.show_mask(mask.cpu().numpy(), plt.gca(), random_color=True)
        plt.axis('off')
        plt.show()

    @staticmethod
    def show_mask(mask, ax, random_color=False):
        color = np.concatenate([np.random.random(3), np.array([0.6])], axis=0) if random_color else np.array(
            [30 / 255, 144 / 255, 255 / 255, 0.6])
        h, w = mask.shape[-2:]
        mask_image = mask.reshape(h, w, 1) * color.reshape(1, 1, -1)
        ax.imshow(mask_image)


if __name__ == "__main__":
    processor = ImageProcessor(
        yolo_model_path='C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/best.pt',
        sam_checkpoint='C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/sam_vit_h_4b8939.pth'
    )

    img_path = 'C:/Users/91789/OneDrive - playbox/Desktop/Project 2025/Backend/diet_calculator/test2.jpg'
    image = processor.load_image(img_path)

    print("Draw bounding boxes using your mouse. Press 'q' to quit.")
    processor.draw_bounding_boxes()

    print(f"Bounding boxes: {processor.bounding_boxes}")

    labeled_image = processor.label_image()
    cv2.imshow("Labeled Image", labeled_image)
    cv2.waitKey(0)
    cv2.destroyAllWindows()

    masks = processor.segment_image(labeled_image)
    processor. segment_objects_return_image(labeled_image, masks)
