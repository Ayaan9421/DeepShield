import os
import cv2
import sys
import json
import numpy as np
import tensorflow as tf
from tqdm import tqdm
from mtcnn import MTCNN
from tensorflow.keras.models import load_model
#from moviepy.editor import VideoFileClip

#Load trained model
MODEL_PATH = "detector/deepfake_detector.h5"
model = load_model(MODEL_PATH)


# Define base directory for processing
BASE_DIR = "./processed_videos"
os.makedirs(BASE_DIR, exist_ok=True)

def get_frame_interval(video_path):
    """Determine frame extraction interval based on video length."""
    cap = cv2.VideoCapture(video_path)
    fps = cap.get(cv2.CAP_PROP_FPS)
    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    duration = total_frames / fps  # Video duration in seconds
    cap.release()

    if duration <= 5:
        return 1   # Extract all frames (max accuracy)
    elif duration <= 10:
        return 5   # Extract more frames per second
    elif duration <= 30:
        return 10  # Balanced performance
    else:
        return 30  # Extract 1 frame per second (for long videos)

def extract_frames(video_path, frames_dir):
    """Extract frames from a video using dynamic frame intervals."""
    os.makedirs(frames_dir, exist_ok=True)
    cap = cv2.VideoCapture(video_path)
    
    frame_interval = get_frame_interval(video_path)
    frame_count = 0
    extracted_count = 0

    while cap.isOpened():
        success, frame = cap.read()
        if not success:
            break
        if frame_count % frame_interval == 0:  # Extract frames dynamically
            frame_name = f"frame_{frame_count}.jpg"
            cv2.imwrite(os.path.join(frames_dir, frame_name), frame)
            extracted_count += 1
        frame_count += 1

    cap.release()
    print(f"✅ Extracted {extracted_count} frames from {video_path} (Interval: {frame_interval})")

def detect_faces(frames_dir, faces_dir):
    """Detect and crop faces from extracted frames."""
    os.makedirs(faces_dir, exist_ok=True)
    detector = MTCNN()

    for frame_file in tqdm(os.listdir(frames_dir), desc="Detecting faces"):
        frame_path = os.path.join(frames_dir, frame_file)
        img = cv2.imread(frame_path)
        faces = detector.detect_faces(img)

        for i, face in enumerate(faces):
            x, y, w, h = face['box']
            face_crop = img[y:y+h, x:x+w]
            face_resized = cv2.resize(face_crop, (299, 299))
            face_path = os.path.join(faces_dir, f"face_{frame_file[:-4]}_{i}.jpg")
            cv2.imwrite(face_path, face_resized)

    print(f"✅ Faces detected and saved in {faces_dir}")

def predict_faces(faces_dir):
    """Pass cropped faces to the trained model and determine deepfake probability."""
    real_count, fake_count, total_faces = 0, 0, 0

    for face_file in tqdm(os.listdir(faces_dir), desc="Predicting deepfake probability"):
        face_path = os.path.join(faces_dir, face_file)
        img = cv2.imread(face_path)
        img = cv2.resize(img, (299, 299)) / 255.0
        img = np.expand_dims(img, axis=0)

        prediction = model.predict(img)[0][0]
        fake_count += 1 if prediction >= 0.5 else 0
        real_count += 1 if prediction < 0.5 else 0
        total_faces += 1

    return real_count, fake_count, total_faces

def detect_video(video_path):
    """Main function to process video and detect deepfake probability."""
    video_name = os.path.splitext(os.path.basename(video_path))[0]
    video_folder = os.path.join(BASE_DIR, video_name)
    frames_dir = os.path.join(video_folder, "frames")
    faces_dir = os.path.join(video_folder, "cropped_faces")

    os.makedirs(video_folder, exist_ok=True)

    extract_frames(video_path, frames_dir)
    detect_faces(frames_dir, faces_dir)

    real, fake, total = predict_faces(faces_dir)
    fake_percentage = (fake / total) * 100 if total > 0 else 0

    result = {
        "total_faces": total,
        "real_faces": real,
        "fake_faces": fake,
        "fake_percentage": round(fake_percentage, 2),
        "verdict": "Fake" if fake_percentage > 50 else "Real"
    }

    # Save result as JSON
    result_path = os.path.join(video_folder, "results.json")
    with open(result_path, "w") as f:
        json.dump(result, f, indent=4)

    print("✅ Deepfake Detection Completed!")
    print(f"Total Faces: {total}, Real: {real}, Fake: {fake}, Fake %: {fake_percentage:.2f}%")
    print(f"Final Verdict: {result['verdict']}")
    print(f"Results saved in {result_path}")
	
    return result
