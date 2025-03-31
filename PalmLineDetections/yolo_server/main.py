##import torch
##from ultralytics import YOLO
##import numpy as np
##import cv2
##import os
##import shutil
##from fastapi import FastAPI, File, UploadFile
##from fastapi.responses import FileResponse
##
### Initialize FastAPI app
##app = FastAPI()
##
### Load YOLOv8 model
##model = YOLO("best.pt")
##
### Create directories if they don't exist
##input_dir = "Images/input"
##output_dir = "Images/output"
##os.makedirs(input_dir, exist_ok=True)
##os.makedirs(output_dir, exist_ok=True)
##
### Function to generate unique filename
##def get_unique_filename(base_name, extension, output_dir):
##    index = 1
##    output_path = os.path.join(output_dir, f"{base_name}{extension}")
##    while os.path.exists(output_path):
##        output_path = os.path.join(output_dir, f"{base_name}_{index}{extension}")
##        index += 1
##    return output_path
##
##@app.post("/predict/")
##async def predict(file: UploadFile = File(...)):
##    # Save uploaded file
##    input_path = os.path.join(input_dir, file.filename)
##    with open(input_path, "wb") as f:
##        shutil.copyfileobj(file.file, f)
##    
##    # Read image using OpenCV
##    image = cv2.imread(input_path)
##    results = model(input_path)  # Run inference
##    
##    keypoints_data = []
##
##    # Process results
##    for result in results:
##        keypoints = result.keypoints.xy.cpu().numpy()  # Get keypoints (x, y)
##        keypoints_data.append(keypoints.tolist())  # Convert to list for JSON response
##
##        # Draw keypoints on the image
##        for kp in keypoints:
##            for x, y in kp:
##                cv2.circle(image, (int(x), int(y)), 5, (0, 255, 0), -1)  # Green keypoints
##    
##    # Generate unique output filename
##    output_path = get_unique_filename("output", ".jpg", output_dir)
##    
##    # Save output image
##    cv2.imwrite(output_path, image)
##    
##    return {
##        "keypoints": keypoints_data,
##        "image_url": f"/output/{os.path.basename(output_path)}"
##    }
##
##@app.get("/output/{filename}")
##async def get_output_image(filename: str):
##    output_path = os.path.join(output_dir, filename)
##    return FileResponse(output_path, media_type="image/jpeg")
#
#
#
#
##===========================================================
##===========================================================
##Without storing anywhere
#import torch
#from ultralytics import YOLO
#import numpy as np
#import cv2
#import os
#import base64
#from fastapi import FastAPI, File, UploadFile
#from fastapi.responses import JSONResponse
#
## Initialize FastAPI app
#app = FastAPI()
#
## Load YOLOv8 model
#model = YOLO("best.pt")
#
#@app.post("/predict/")
#async def predict(file: UploadFile = File(...)):
#    # Read image from memory
#    image_bytes = await file.read()
#    np_arr = np.frombuffer(image_bytes, np.uint8)
#    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)  # Decode image
#
#    # Run YOLO inference
#    results = model(image)
#    
#    keypoints_data = []
#
#    # Process results
#    for result in results:
#        keypoints = result.keypoints.xy.cpu().numpy()  # Get keypoints (x, y)
#        keypoints_data.append(keypoints.tolist())  # Convert to list for JSON response
#
#        # Draw keypoints on the image
#        for kp in keypoints:
#            for x, y in kp:
#                cv2.circle(image, (int(x), int(y)), 5, (0, 255, 0), -1)  # Green keypoints
#
#    # Encode image as Base64
#    _, encoded_image = cv2.imencode(".jpg", image)
#    base64_image = base64.b64encode(encoded_image.tobytes()).decode("utf-8")
#
#    # Return JSON response with keypoints and image
#    return JSONResponse(content={
#        "keypoints": keypoints_data,
#        "image_base64": base64_image
#    })
#




#===================================================================
#===================================================================
#Keypoints along with class name

import torch
from ultralytics import YOLO
import numpy as np
import cv2
import base64
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse

# Initialize FastAPI app
app = FastAPI()

# Load YOLOv8 model
model = YOLO("best.pt")

# Define colors for different categories
colors = {
    "head": (0, 255, 0),  # Green
    "heart": (255, 0, 0),  # Blue
    "life": (0, 0, 255),  # Red
    "fate": (255, 192, 203)  # Pink
}

CONFIDENCE_THRESHOLD = 0.4  # Set confidence threshold

@app.post("/predict/")
async def predict(file: UploadFile = File(...)):
    # Read image from memory
    image_bytes = await file.read()
    np_arr = np.frombuffer(image_bytes, np.uint8)
    image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)  # Decode image

    # Run YOLO inference
    results = model(image)
    
    # Initialize dictionary to store keypoints by class
    keypoints_dict = {key: [] for key in colors.keys()}  # {"head": [], "heart": [], "life": [], "fate": []}

    # Process results
    for result in results:
        keypoints = result.keypoints.xy.cpu().numpy()  # Extract keypoints (x, y)
        class_ids = result.boxes.cls.tolist()  # Detected class indices
        confidences = result.boxes.conf.tolist()  # Confidence scores
        class_names = [model.names[int(cls_id)] for cls_id in class_ids]  # Map indices to class names

        for kp, cls_name, conf in zip(keypoints, class_names, confidences):
            if conf >= CONFIDENCE_THRESHOLD and cls_name in keypoints_dict:
                keypoints_dict[cls_name].append(kp.tolist())  # Store keypoints under class name

    # Keep only the largest set of keypoints per class
    for cls_name in keypoints_dict:
        if keypoints_dict[cls_name]:
            keypoints_dict[cls_name] = max(keypoints_dict[cls_name], key=len)  # Keep the longest list
    
        # Draw only the selected keypoints on the image
    for cls_name, keypoints in keypoints_dict.items():
        color = colors.get(cls_name, (255, 255, 255))  # Default white if unknown class
        for x, y in keypoints:
            cv2.circle(image, (int(x), int(y)), 5, color, -1)  # Draw circle

    # Encode image as Base64
    _, encoded_image = cv2.imencode(".jpg", image)
    base64_image = base64.b64encode(encoded_image.tobytes()).decode("utf-8")
    
    return JSONResponse(content={
        "keypoints": keypoints_dict,  # Organized by class
        "image_base64": base64_image  # Base64 encoded processed image
    })
