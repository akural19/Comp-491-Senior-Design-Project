import os
import shutil

def move_files_to_directory(base_directory):
    for folder in os.listdir(base_directory):
        folder_path = os.path.join(base_directory, folder)
        if os.path.isdir(folder_path):
            for file in os.listdir(folder_path):
                file_path = os.path.join(folder_path, file)
                shutil.move(file_path, base_directory)
            os.rmdir(folder_path)

base_directory = "asl_dataset"
move_files_to_directory(base_directory)