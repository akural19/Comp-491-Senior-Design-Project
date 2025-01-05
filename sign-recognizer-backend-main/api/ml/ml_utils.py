import joblib
import cv2
import mediapipe as mp
import numpy as np
import pandas as pd
from pathlib import Path
import threading
from django.conf import settings
import tempfile
import os
import logging
import requests
import cloudinary.uploader

logger = logging.getLogger(__name__)

class VideoProcessor(threading.Thread):
    def __init__(self, video_instance):
        threading.Thread.__init__(self)
        self.video_instance = video_instance
        
        model_path = Path(settings.BASE_DIR) / 'api' / 'ml' / 'gesture_recognition_model2.pkl'
        logger.info(f"Loading model from: {model_path}")
        
        try:
            self.model = joblib.load(model_path)
            logger.info("Model successfully loaded")
        except Exception as e:
            logger.error(f"Model loading error: {str(e)}")
            self.video_instance.status = 'failed'
            self.video_instance.result = f"Model loading error: {str(e)}"
            self.video_instance.save()
            raise
            
        self.mp_hands = mp.solutions.hands

    def run(self):
        logger.info(f"Starting processing for video ID: {self.video_instance.id}")
        try:
            self.video_instance.status = 'processing'
            self.video_instance.save()
            
            # Cloudinary URL'ini al
            video_url = self.video_instance.video_file.url
            logger.info(f"Video URL: {video_url}")
            
            # Video içeriğini indir
            response = requests.get(video_url, stream=True)
            if response.status_code != 200:
                raise Exception(f"Failed to download video: {response.status_code}")
            
            # Geçici dosyaya kaydet
            with tempfile.NamedTemporaryFile(suffix='.mp4', delete=False) as temp_video:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        temp_video.write(chunk)
                temp_video_path = temp_video.name
                logger.info(f"Temporary video saved at: {temp_video_path}")
            
            result_text = self.process_video(temp_video_path)
            logger.info(f"Video processing completed. Result: {result_text}")
            
            self.video_instance.result = result_text
            self.video_instance.status = 'completed'
            self.video_instance.save()
            
            # Temizlik
            os.unlink(temp_video_path)
            logger.info("Temporary file cleaned up")
            
        except Exception as e:
            logger.error(f"Error processing video: {str(e)}")
            self.video_instance.status = 'failed'
            self.video_instance.result = str(e)
            self.video_instance.save()

    def process_video(self, video_path):
        predictions = []
        
        with self.mp_hands.Hands(
            static_image_mode=False,
            max_num_hands=1,
            min_detection_confidence=0.8,
            min_tracking_confidence=0.8
        ) as hands:
            cap = cv2.VideoCapture(video_path)
            
            while cap.isOpened():
                success, frame = cap.read()
                if not success:
                    break
                    
                features = self.extract_features(frame, hands)
                if features is not None:
                    prediction = self.model.predict(features)[0]
                    predictions.append(prediction)
            
            cap.release()
            
        return self.post_process_predictions(predictions)

    def extract_features(self, frame, hands):
        results = hands.process(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
        
        if not results.multi_hand_landmarks:
            return None
            
        features = {}
        for hand_landmarks in results.multi_hand_landmarks:
            temp = {}
            for ii in range(21):
                temp[f"Feature{ii}_x"] = float(hand_landmarks.landmark[ii].x)
                temp[f"Feature{ii}_y"] = float(hand_landmarks.landmark[ii].y)
            
            for base in range(21):
                for ii in range(21):
                    features[f"Feature{base}_{ii}"] = np.sqrt(
                        (temp[f"Feature{ii}_x"] - temp[f"Feature{base}_x"]) ** 2 +
                        (temp[f"Feature{ii}_y"] - temp[f"Feature{base}_y"]) ** 2
                    )
                    
        return pd.DataFrame([features])

    def post_process_predictions(self, predictions):
        if not predictions:
            return "No hand signs detected"
            
        result = []
        current_char = predictions[0]
        count = 1
        
        for pred in predictions[1:]:
            if pred == current_char:
                count += 1
            else:
                if count > 10:
                    result.append(current_char)
                current_char = pred
                count = 1
                
        if count > 10:
            result.append(current_char)
            
        return "".join(result) if result else "No clear hand signs detected"