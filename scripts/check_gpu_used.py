import tensorflow as tf

#Check if TensorFlow is using the GPU
if tf.config.list_physical_devices('GPU'):
    print("TensorFlow is using the GPU!")
    
    #Get list of available GPUs
    gpus = tf.config.list_physical_devices('GPU')
    print("Available GPUs:", gpus)
    
    #Get details of each GPU
    for gpu in gpus:
        details = tf.config.experimental.get_device_details(gpu)
        print("GPU Details:", details)
else:
    print("TensorFlow is using the CPU.")