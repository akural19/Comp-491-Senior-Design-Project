import os
import cv2
import mediapipe as mp
import pandas as pd
import warnings
import numpy as np

warnings.filterwarnings("ignore") 

mp_hands = mp.solutions.hands

data = {f"Feature{ii}_{jj}": None for ii in range(21) for jj in range(21)} 
data["Label"] = None
df = pd.DataFrame(columns = data.keys())

image_dir = "./asl_dataset"
image_files = [os.path.join(image_dir, f) for f in os.listdir(image_dir)]

with mp_hands.Hands(
    static_image_mode = True,
    max_num_hands = 1,
    min_detection_confidence = 0.8
) as hands:
    counter = 1
    for file in image_files:
        
        if counter % 50 == 0:
            print(counter)
        
        counter += 1

        label = os.path.basename(file)[0].upper()

        image = cv2.imread(file)
        results = hands.process(cv2.cvtColor(image, cv2.COLOR_BGR2RGB))

        if not results.multi_hand_landmarks:
            continue

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
            tf["Label"] = label
            
            
            df = pd.concat([df, tf], ignore_index = True)
        

df.to_excel("gesture_data.xlsx", index = False)
print("Landmarks and labels saved to gesture_data.xlsx")