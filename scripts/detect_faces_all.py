import cv2
import os
from mtcnn import MTCNN
from tqdm import tqdm

# Initialize MTCNN face detector
detector = MTCNN()

# Input and output directories
input_folders = {
    "real": "../real-frames/",  # Change path if needed
    "fake": "../fake-frames/"
}
output_folder = "../cropped-faces/"

# Ensure output directories exist
for label in input_folders.keys():
    os.makedirs(os.path.join(output_folder, label), exist_ok=True)

# Process each image in both folders
for label, folder in input_folders.items():
    save_path = os.path.join(output_folder, label)
    
    for image_name in tqdm(os.listdir(folder), desc=f"Processing {label} images"):
        image_path = os.path.join(folder, image_name)
        image = cv2.imread(image_path)

        # Detect faces
        faces = detector.detect_faces(image)
        if faces:
            x, y, w, h = faces[0]['box']
            face = image[y:y+h, x:x+w]
            face_resized = cv2.resize(face, (299, 299))

            # Save cropped face
            cv2.imwrite(os.path.join(save_path, image_name), face_resized)

print("Face detection complete!")
