import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from tensorflow.keras.applications import Xception
from tensorflow.keras.layers import Dense, Flatten, GlobalAveragePooling2D
from tensorflow.keras.models import Model
import os

# Define dataset path
dataset_path = "../cropped-faces/"

# Image Data Generator (with augmentation)
datagen = ImageDataGenerator(
    rescale=1./255, 
    validation_split=0.2,  # 80% training, 20% validation
    rotation_range=10,
    zoom_range=0.1,
    horizontal_flip=True
)

# Load dataset with labels (real vs fake)
train_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=(299, 299),
    batch_size=32,
    class_mode='binary',
    subset='training'
)

val_generator = datagen.flow_from_directory(
    dataset_path,
    target_size=(299, 299),
    batch_size=32,
    class_mode='binary',
    subset='validation'
)

# Load pre-trained Xception model (for feature extraction)
base_model = Xception(weights='imagenet', include_top=False, input_shape=(299, 299, 3))

# Freeze base model layers
for layer in base_model.layers:
    layer.trainable = False

# Add custom classifier
x = GlobalAveragePooling2D()(base_model.output)
x = Dense(512, activation='relu')(x)
x = Dense(256, activation='relu')(x)
output = Dense(1, activation='sigmoid')(x)  # Binary classification

model = Model(inputs=base_model.input, outputs=output)

# Compile the model
model.compile(
    optimizer=tf.keras.optimizers.Adam(learning_rate=0.0001),
    loss='binary_crossentropy',
    metrics=['accuracy']
)

# Train the model
model.fit(
    train_generator,
    validation_data=val_generator,
    epochs=10,
    verbose=1
)

# Save the trained model
model.save("../deepfake_detector.h5")

print("✅ Model training complete! Model saved as deepfake_detector.h5")
