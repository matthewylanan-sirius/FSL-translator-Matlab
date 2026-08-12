## 👥 Contributor Guide: Adding New Data & Dataset Rules

If you are adding new images, signs, or phrases to the dataset, please follow the workflow and pruning guidelines below to ensure model accuracy and balance.

---

### 🔄 Workflow for Adding New Data

1. **Upload Images to Roboflow:**
   * Upload your raw hand sign photos/frames to the project on Roboflow.
2. **Annotate the Images:**
   * Draw tight bounding boxes around the hand performing the gesture. 
   * *Note: MATLAB reads these annotation coordinates directly to crop the hands during preprocessing.*
3. **Run `crop_dataset.m`:**
   * Execute `crop_dataset.m` in MATLAB to automatically crop the newly annotated hand regions and resize them to **227 × 227**.

---

### ✂️ Preprocessing & Hand-Pruning Strategy

> **Distribution Note:** The fully hand-pruned dataset is shared via **Google Drive**. Download and place it into your local workspace prior to training.

#### **Why the Dataset Was Reduced (7,000+ → ~400 Images)**
* **MobileNetV2 Limitation:** MobileNetV2 evaluates **static images**, not sequential video frames.
* **Keyframe Selection:** Rather than training on blurry transitions or setup frames, dynamic sign sequences were manually hand-pruned to retain only the single most distinct, "stand-out" moment of each gesture.
* **Current Dataset Target:** The raw 7k+ image set was distilled down to **~400 total images**, targeting roughly **60 images per sign/phrase**.

---

### ⚠️ Essential Rules for Contributors

* ⚖️ **Maintain Class Balance:** Each word or phrase **must have a similar number of images** (aim for **~60 images per class**). Having too few images for a specific class will introduce model bias toward over-represented signs.
* 🎯 **Pick Keyframes Only:** Avoid uploading multi-frame video dumps. Choose only the clearest, most representative static pose of the sign.
* 📌 **Team Sync & Tracking:** Before adding new phrases or uploading new image batches, notify the team to keep track of added words and maintain clean, standardized class labels.
