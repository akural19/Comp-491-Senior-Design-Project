import joblib
import cv2
import mediapipe as mp
import pandas as pd
import warnings
import numpy as np

warnings.filterwarnings("ignore") 

mp_drawing = mp.solutions.drawing_utils
mp_drawing_styles = mp.solutions.drawing_styles
mp_hands = mp.solutions.hands

data = {f"Feature{ii}": None for ii in range(1, 24)}
data["Label"] = None 
df = pd.DataFrame(columns = data.keys()) 

cap = cv2.VideoCapture(0)

model = joblib.load('gesture recognition model.pkl')

with mp_hands.Hands(
    model_complexity = 0,
    min_detection_confidence = 0.8,
    min_tracking_confidence = 0.8) as hands:
    
    while cap.isOpened():
        success, image = cap.read()

        if not success:
            print("Ignoring empty camera frame.")
            continue

        image.flags.writeable = False
        image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        results = hands.process(image)

        image.flags.writeable = True
        image = cv2.cvtColor(image, cv2.COLOR_RGB2BGR)
        
        prediction = "None"

        if results.multi_hand_landmarks:
            for hand_landmarks in results.multi_hand_landmarks:
                
                temp = {}
                
                for ii in range(21):
                    temp[f"Index{ii}_x"] = float(hand_landmarks.landmark[ii].x)
                    temp[f"Index{ii}_y"] = float(hand_landmarks.landmark[ii].y)
                    
                tf = {}
                
                for ii in range(1, 21):
                        tf[f"Feature{ii}"] = np.sqrt(np.square(temp[f"Index{ii}_x"] - temp["Index0_x"]) 
                                                            + np.square(temp[f"Index{ii}_y"] - temp["Index0_y"]))
                
                tf["Feature21"] = np.sqrt(np.square(temp["Index12_x"] - temp["Index8_x"]) 
                                                            + np.square(temp["Index12_y"] - temp["Index8_y"]))
                
                tf["Feature22"] = np.arctan2(temp["Index8_y"] - temp["Index5_y"], temp["Index8_x"] - temp["Index5_x"])
                tf["Feature23"] = np.arctan2(temp["Index20_y"] - temp["Index17_y"], temp["Index20_x"] - temp["Index17_x"])

    
                key = cv2.waitKey(20) & 0xFF
                if key != 255:  
                    label = chr(key)
                    tf["Label"] = label

                    new_df = pd.DataFrame([tf])
                    df = pd.concat([df, new_df], ignore_index = True)
                    
                    print("\nKey is pressed: " + label.upper())
                
                tf = pd.DataFrame([tf])  

                if "Label" in tf.columns:
                    tf = tf.drop(columns = ["Label"])

                prediction = model.predict(tf)[0].upper()

                mp_drawing.draw_landmarks(
                    image,
                    hand_landmarks,
                    mp_hands.HAND_CONNECTIONS,
                    mp_drawing_styles.get_default_hand_landmarks_style(),
                    mp_drawing_styles.get_default_hand_connections_style())
        
        flipped_image = cv2.flip(image, 1)

        cv2.putText(
            flipped_image,                             
            f"Prediction: {prediction}", 
            (10, 50),                        
            cv2.FONT_HERSHEY_SIMPLEX,        
            1,                              
            (0, 0, 0),                     
            2,                                
            cv2.LINE_AA    
        )
        
        cv2.imshow('MediaPipe Hands', flipped_image)

        if cv2.waitKey(5) & 0xFF == 27:
            break

cap.release()
cv2.destroyAllWindows()

if len(df) != 0:
    df.to_excel("gesture_data.xlsx", index = False)