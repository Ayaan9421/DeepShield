import cv2
import os

# Define paths using os.path.join for compatibility
script_dir = os.path.dirname(os.path.abspath(__file__))  # Get the current script directory

video_folder = os.path.join(script_dir, "..", "real videos")
output_folder = os.path.join(script_dir, "..", "real-frames")

# Create output directory if it does not exist
os.makedirs(output_folder, exist_ok=True)

# Extract frames from all videos
for video_name in os.listdir(video_folder):
    video_path = os.path.join(video_folder, video_name)
    cap = cv2.VideoCapture(video_path)
    
    frame_count = 0
    success = True
    
    while success:
        success, frame = cap.read()
        if frame_count % 30 == 0 and success:  # Extract 1 frame per second
            frame_name = f"{video_name}_frame_{frame_count}.jpg"
            frame_path = os.path.join(output_folder, frame_name)
            cv2.imwrite(frame_path, frame)
        frame_count += 1

    cap.release()

print("✅ Frames extracted successfully!")
