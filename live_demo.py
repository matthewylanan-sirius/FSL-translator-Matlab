import os
import cv2
import numpy as np
import onnxruntime as ort
import mediapipe as mp

# 1. Exact Class Order matching MATLAB's ASCII-sorted labels
CLASS_NAMES = [
    'Magandang-umaga',
    'Pasensya-na',
    'ano-pangalan-mo',
    'kamusta-ka',
    'mahal-kita',
    'maraming-salamat'
]

# 2. Resolve Path and Load MATLAB ONNX Model
script_dir = os.path.dirname(os.path.abspath(__file__))
onnx_path = os.path.join(script_dir, "fsl_mobilenetv2.onnx")

if not os.path.exists(onnx_path):
    raise FileNotFoundError(f"Model file not found at: {onnx_path}")

session = ort.InferenceSession(onnx_path)
input_name = session.get_inputs()[0].name
output_name = session.get_outputs()[0].name
input_shape = session.get_inputs()[0].shape

# 3. Initialize MediaPipe Hand Detector
mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=2,
    min_detection_confidence=0.5,
    min_tracking_confidence=0.5
)

# 4. Start Webcam
cap = cv2.VideoCapture(0)

print("Starting Live FSL Recognition... Press 'q' to quit.")

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break

    # Flip image horizontally for mirror view
    frame = cv2.flip(frame, 1)
    h, w, _ = frame.shape

    # Convert BGR to RGB for MediaPipe
    rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb_frame)

    if results.multi_hand_landmarks:
        x_coords = []
        y_coords = []
        for hand_landmarks in results.multi_hand_landmarks:
            for lm in hand_landmarks.landmark:
                x_coords.append(int(lm.x * w))
                y_coords.append(int(lm.y * h))

        # Calculate base hand dimensions
        x_min, x_max = min(x_coords), max(x_coords)
        y_min, y_max = min(y_coords), max(y_coords)
        box_w = x_max - x_min
        box_h = y_max - y_min

        # EXPAND PADDING: Include surrounding torso/chin context matching dataset
        pad_x = int(box_w * 0.8)  # 80% extra side padding
        pad_y = int(box_h * 0.9)  # 90% extra vertical padding

        crop_xmin = max(0, x_min - pad_x)
        crop_xmax = min(w, x_max + pad_x)
        crop_ymin = max(0, y_min - pad_y)
        crop_ymax = min(h, y_max + pad_y)

        # Extract crop
        hand_crop = frame[crop_ymin:crop_ymax, crop_xmin:crop_xmax]

        if hand_crop.size > 0:
            # Resize crop to 224x224 RGB
            crop_rgb = cv2.cvtColor(hand_crop, cv2.COLOR_BGR2RGB)
            resized_crop = cv2.resize(crop_rgb, (224, 224))

            # Format float array for MobileNetV2 ONNX
            img_data = resized_crop.astype(np.float32)

            if len(input_shape) == 4 and input_shape[1] == 3:
                img_data = np.transpose(img_data, (2, 0, 1))  # [H, W, C] -> [C, H, W]
            
            img_data = np.expand_dims(img_data, axis=0)       # Add batch dim -> [1, C, H, W]

            # Run ONNX inference
            outputs = session.run([output_name], {input_name: img_data})
            scores = outputs[0][0]

            # Softmax
            probs = scores

            pred_class_idx = np.argmax(probs)
            confidence = probs[pred_class_idx] * 100

            # Confidence thresholding
            if confidence > 45.0:
                label_text = f"{CLASS_NAMES[pred_class_idx]} ({confidence:.1f}%)"
                box_color = (0, 255, 0)
            else:
                label_text = "Uncertain Pose"
                box_color = (0, 165, 255)

            # Draw green bounding box around hand + torso context
            cv2.rectangle(frame, (crop_xmin, crop_ymin), (crop_xmax, crop_ymax), box_color, 2)
            cv2.putText(frame, label_text, (crop_xmin, max(30, crop_ymin - 10)),
                        cv2.FONT_HERSHEY_SIMPLEX, 0.8, box_color, 2)

    cv2.imshow("FSL AI Recognition (MediaPipe + MATLAB ONNX)", frame)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()