#===========================================================
#===========================================================
#To Return only points
#===========================================================
#===========================================================
##import torch
##from ultralytics import YOLO
##import numpy as np
##
### Load trained YOLOv8 Pose model
##model = YOLO("best.pt")
##
### Load image and run inference
##image_path = "fddf2ff7f6f2e82db24959ef32bb6efa.jpg"
##results = model(image_path)
##for result in results:
##    print(result.keypoints.xy)  # Keypoints as (x, y)
##    print(result.keypoints.xyn) # Keypoints as normalized (0-1)
##    print(result)
#




#===========================================================
#===========================================================
#To handle Single Image
#===========================================================
#===========================================================
import torch
from ultralytics import YOLO
import numpy as np
import cv2
import os

# Load trained YOLOv8 Pose model
model = YOLO("best.pt")

# Load image and run inference
image_path = "Images/input/images.jpeg"
image = cv2.imread(image_path)  # Read image using OpenCV
results = model(image_path)

# Create output directory if it doesn't exist
output_dir = "Images/output"
os.makedirs(output_dir, exist_ok=True)

# Function to generate unique filename
def get_unique_filename(base_name, extension, output_dir):
    index = 1
    output_path = os.path.join(output_dir, f"{base_name}{extension}")
    while os.path.exists(output_path):
        output_path = os.path.join(output_dir, f"{base_name}_{index}{extension}")
        index += 1
    return output_path


# Loop through results
for result in results:

    keypoints = result.keypoints.xy.cpu().numpy()  # Get keypoints (x, y)
        
    print(keypoints)  # Keypoints as (x, y)

    # Draw keypoints on the image
    for kp in keypoints:
        for x, y in kp:
            cv2.circle(image, (int(x), int(y)), 5, (0, 255, 0), -1)  # Green keypoints
    
    # Generate unique output filename
    output_path = get_unique_filename("output", ".jpg", output_dir)
    
    # Save the image
    cv2.imwrite(output_path, image)
    print(f"✅ Image saved as {output_path}")




#===========================================================
#===========================================================
#To handle multiple images at a time
#===========================================================
#===========================================================
#import torch
#from ultralytics import YOLO
#import numpy as np
#import cv2
#import os
#
## Load trained YOLOv8 Pose model
#model = YOLO("best.pt")
#
## Define input and output directories
#input_dir = "Images/input"
#output_dir = "Images/output"
#os.makedirs(output_dir, exist_ok=True)
#
## Function to generate unique filename
#def get_unique_filename(base_name, extension, output_dir):
#    index = 1
#    output_path = os.path.join(output_dir, f"{base_name}{extension}")
#    while os.path.exists(output_path):
#        output_path = os.path.join(output_dir, f"{base_name}_{index}{extension}")
#        index += 1
#    return output_path
#
## Get list of image files in the input directory
#image_files = [f for f in os.listdir(input_dir) if f.lower().endswith(('.jpg', '.jpeg', '.png'))]
#
#if not image_files:
#    print("⚠️ No images found in the input directory.")
#else:
#    print(f"📷 Found {len(image_files)} images. Processing...")
#
## Process each image
#for image_file in image_files:
#    image_path = os.path.join(input_dir, image_file)
#    image = cv2.imread(image_path)  # Read image using OpenCV
#    results = model(image_path)
#
#    for result in results:
#        keypoints = result.keypoints.xy.cpu().numpy()  # Get keypoints (x, y)
#        print(f"🔹 Processing {image_file} - Keypoints:\n", keypoints)
#
#        # Draw keypoints on the image
#        for kp in keypoints:
#            for x, y in kp:
#                cv2.circle(image, (int(x), int(y)), 5, (0, 255, 0), -1)  # Green keypoints
#        
#        # Generate unique output filename based on input file name
#        base_name, ext = os.path.splitext(image_file)
#        output_path = get_unique_filename(base_name, ".jpg", output_dir)
#
#        # Save the image
#        cv2.imwrite(output_path, image)
#        print(f"✅ Saved: {output_path}")
#
#print("🎉 All images processed successfully!")
