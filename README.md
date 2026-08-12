## 👥 Contributor Guide: Adding New Data & Dataset Rules

If you are adding new images, signs, or phrases to the dataset, follow the guidelines below to keep the dataset balanced, clean, and synchronized across the team.

---

### ⚡ Quick Summary (TL;DR)
If you want to add new pictures or manage classes, **you just need to modify the `cropped_7k_dataset/` folder directly**:
* **Remove Unused Classes:** Feel free to delete any class folders that we are not using or identifying for our project—that is completely fine!
* **Maintain the Base Dataset:** Build upon the standardized dataset provided in the **Google Drive**, rather than starting from scratch.
* **Sync Everything to GDrive:** Every new cropped image, newly added word, or modified folder **must be uploaded to the shared Google Drive** so everyone stays on the exact same dataset version.

---

### 🔄 Workflow for Adding New Pictures / Words

1. **Upload & Annotate on Roboflow:**
   * Add your new images to Roboflow and draw tight bounding boxes around the hand gesture.
2. **Run `crop_dataset.m`:**
   * Run the cropping script in MATLAB whenever you add new pictures, phrases, or words so MATLAB can auto-crop and resize them based on the annotation boxes.
3. **Move to Local Dataset Folder:**
   * Place the preprocessed outputs into the corresponding class subfolders inside `cropped_7k_dataset/`.
4. **Upload Updates to Google Drive:**
   * Upload all new cropped images and any newly added word folders directly to the shared **Google Drive** folder immediately after cropping.

---

### ✂️ Hand-Pruning & Dataset Rules

#### **1. Pick the Most "Stand-Out" Frame Only**
* **MobileNetV2 Limitation:** MobileNetV2 evaluates **static images**, not continuous video feeds.
* **Keyframe Selection:** Do not train on transitional frames or setup poses. Identify the **single most distinct, representative moment** of the sign gesture and only include those frames. *(We are framing this design choice around project time constraints!)*

#### **2. Maintain Balanced Sample Sizes**
* Keep the number of images per class roughly equal across all signs/phrases. 
* **Avoid Imbalance:** Giving one phrase significantly fewer or more images will introduce heavy model bias towards/against specific words.

#### **3. Vary Lighting & Conditions**
* When capturing new pictures, take them under different lighting conditions, angles, and backgrounds to improve real-time detection robustness.

---

### 🔗 Links & Resources

* **Dataset (Google Drive):** [FSL Dataset Folder](https://drive.google.com/drive/folders/1eO-flRL4MXVITNtlAHlL1M6mtlzcahde)
