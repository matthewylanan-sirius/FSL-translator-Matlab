## ➕ How to Add to Dataset, Annotate, and Retrain

Follow this step-by-step guide to expand the dataset with new hand sign images, annotate them, and retrain the MobileNetV2 model.

---

### **Step 1: Collect & Annotate Images**
* **Capture Images:** Take high-quality photos/videos of the hand signs under varied lighting conditions, angles, and backgrounds.
* **Annotate Bounding Boxes:**
  * Upload your new images to **Roboflow** (or use an annotation tool like **LabelImg** or **CVAT**).
  * Draw tight bounding boxes around the hand performing the gesture.
  * Assign the proper class label (e.g., `A`, `B`, `Hello`, etc.).
* **Export Annotations:** Export the annotated dataset in the format matching your raw Roboflow folder setup (containing images and annotation files/JSON/Pascal VOC XML).

---

### **Step 2: Add Images to Raw Dataset**
* Place the newly annotated images and their corresponding annotation files into your raw dataset directory alongside the existing 7k+ images.
* If creating a **new sign/class**, ensure the new class folder or label matches the structure expected by the preprocessing pipeline.

---

### **Step 3: Re-Run Preprocessing Scripts**
Open MATLAB and re-execute the cropping and renaming workflow to incorporate the new data:

1. **Run `crop_dataset.m`:**
   * Crops the newly added images using their bounding boxes.
   * Resizes them to the required **227 × 227** pixel dimensions.
2. **Run `rename_crop.m`:**
   * Updates folder/file names to proper human-readable class labels.
   * Refreshes the `cropped_7k_dataset/` folder.

---

### **Step 4: Retrain the Model**
Run `train_fsl_mobilenetv2.m` in MATLAB:
* The script reads the refreshed `cropped_7k_dataset/` directory (including all new/updated classes).
* Training fine-tunes MobileNetV2 with the augmented dataset.
* Upon completion, it overwrites `fsl_mobilenetv2.mat` with the newly updated weights.

---

### **Step 5: Re-Export & Test ONNX Model**
1. Run `export_model.m` in MATLAB to convert the updated `fsl_mobilenetv2.mat` into `fsl_mobilenetv2.onnx`.
2. Launch Python and run:
   ```bash
   python live_demo.py
