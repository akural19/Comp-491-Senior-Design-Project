import joblib
import cv2
import mediapipe as mp
import pandas as pd
import warnings
import numpy as np

warnings.filterwarnings("ignore")

mp_hands = mp.solutions.hands
model = joblib.load('gesture recognition model.pkl')

def recognizer(video_path):
    text_arr = []  
    
    cap = cv2.VideoCapture(video_path)
    
    if not cap.isOpened():
        print("Error opening video stream or file.")
        return text_arr
    
    with mp_hands.Hands(
        model_complexity=0,
        min_detection_confidence=0.8,
        min_tracking_confidence=0.8) as hands:
        
        while cap.isOpened():
            success, image = cap.read()
            
            if not success:
                break

            image.flags.writeable = False
            image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
            
            results = hands.process(image)
            
            prediction = "None"
            
            if results.multi_hand_landmarks:
                for hand_landmarks in results.multi_hand_landmarks:
                    temp = {}
                        
                    for ii in range(21): 
                        temp[f"Feature{ii}_x"] = float(hand_landmarks.landmark[ii].x)
                        temp[f"Feature{ii}_y"] = float(hand_landmarks.landmark[ii].y)
                            
                    tf = {}
                        
                    for base in range(21):
                        for ii in range(21):
                            tf[f"Feature{base}_{ii}"] = np.sqrt(
                                (temp[f"Feature{ii}_x"] - temp[f"Feature{base}_x"]) ** 2 +
                                (temp[f"Feature{ii}_y"] - temp[f"Feature{base}_y"]) ** 2)
                    
                    tf = pd.DataFrame([tf])
                    prediction = model.predict(tf)[0].upper()
        
                    text_arr.append(prediction)
    res = []
    counter = 1
    previous = text_arr[0]
    for ii in range(1, len(text_arr)):        
        if text_arr[ii] == previous:
            counter += 1
        else:
            if counter > 10:
                res.append(previous)
            counter = 1
            previous = text_arr[ii]
            
        if (ii == len(text_arr) - 1) and (counter > 10):
            res.append(previous)   
            
    cap.release()
    return "".join(res)

video_path = "video_file.mp4"
prediction = recognizer(video_path)
print(prediction)
