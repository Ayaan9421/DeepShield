import cv2
import numpy as np
import os
from mtcnn import MTCNN
import matplotlib.pyplot as plt

#initialize the facec detector
detector = MTCNN()

def detect_face(image_path):
	#load the image
	img = cv2.imread(image_path)
	if img is None:
		print("Error: Unable to load the image " +  image_path)
		return None
	
	#convert image to RGB (MTCNN expects RGB format)
	img_rgb = cv2. cvtColor(img, cv2.COLOR_BGR2RGB)
	
	#detect faces 
	faces = detector.detect_faces(img_rgb)
	
	if len(faces) == 0:
		print("No Face detected in the image.")
		return None

	print("Number of faces found: " , len(faces))
	#extract the first detected face
	x,y,width,height = faces[0]['box']
	x,y = abs(x) , abs(y)	#ensures no negative values
	
	face_img = img[y:y+height , x:x+width]
	face_img = cv2.resize(face_img , (299,299))	#XceptionNet Deepfake model needs this ratio of img
	
	return face_img

if __name__ == "__main__":
	image_path = input("Enter the img path ")
	face = detect_face(image_path)
	
	if face is not None:
		print("Face detected Successfully.")
		plt.imshow(cv2.cvtColor(face, cv2.COLOR_BGR2RGB))
		plt.axis("off")
		plt.title("Detected Face")
		plt.show()