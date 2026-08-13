#  Filipino Sign Language (FSL) Recognition System

**Authors / Project Team:**
1. **Joaquin Carlo E. Cardino**
2. **Luis Antonio Quijano Roa**
3. **Ericson Adler Yang Tan**
4. **Matthew Ylanan**

---

##  Project Overview

This project is a **computer vision and machine learning system** designed to recognize and classify **Filipino Sign Language (FSL)** gestures, signs, and transactional phrases into standard text. 

The primary goal is to bridge the communication gap between the Deaf community and non-signers in public, commercial, and transactional settings. Because continuous real-time video processing can be computationally heavy and resource-intensive, the system is designed to evaluate **static keyframe images**—focusing on the single most distinct moment of a hand gesture to deliver fast, accurate predictions.

---

##  How the Program Works

The system processes sign language data through an end-to-end computer vision pipeline:

```
[ Raw Gesture Video / Photos ]
             │
             ▼
[ Bounding Box Annotation (Roboflow) ]
             │
             ▼
[ Auto-Cropping & Resizing (MATLAB: crop_dataset.m) ]
             │
             ▼
[ Centralized Dataset Management (cropped_7k_dataset/) ]
             │
             ▼
[ Feature Extraction & Classification (MobileNetV2) ]
             │
             ▼
[ Predicted Text / Sign Label Output ]
```

1. **Data Acquisition & Annotation:** Raw images or recorded video frames of hand gestures are captured across diverse real-world environments. Contributors draw tight bounding boxes around the active hand gestures using **Roboflow**.
2. **Automated Bounding Box Cropping:** The MATLAB script (`crop_dataset.m`) reads the annotation metadata, isolates the region of interest (the hand/gesture), and crops and resizes the image into a uniform aspect ratio.
3. **Dataset Standardization:** The cropped images are organized into class folders within `cropped_7k_dataset/` and synchronized to a shared **Google Drive** repository to ensure model versioning and dataset balance.
4. **Static Keyframe Classification:** Preprocessed images are fed into **MobileNetV2**, a lightweight convolutional neural network (CNN). MobileNetV2 extracts spatial feature maps from the cropped image and classifies the hand shape into its corresponding FSL phrase or letter.

---

##  Tech Stack & Tooling

| Component | Technology | Purpose & Function |
| :--- | :--- | :--- |
| **Model Architecture** | **MobileNetV2** | Lightweight convolutional neural network optimized for fast image classification on edge devices and standard hardware. |
| **Annotation Platform** | **Roboflow** | Cloud-based tool used to upload raw images and draw precise bounding boxes around hand gestures. |
| **Data Processing** | **MATLAB (`crop_dataset.m`)** | Custom script used to automatically crop, resize, and pre-process target gestures based on Roboflow bounding box data. |
| **Dataset Domain** | **FSL (Filipino Sign Language)** | Specialized domain covering numbers, letters, and transactional phrases. |

---

###  Links & Resources

* **Dataset (Google Drive):** [FSL Dataset Folder](https://drive.google.com/drive/folders/1eO-flRL4MXVITNtlAHlL1M6mtlzcahde)
