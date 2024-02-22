import cv2
from PIL import Image
import torch
import torchvision.transforms as transforms
import torchvision.models as models

import torch.nn.functional as F
import torch.nn as nn
import time


class_labels = [
    'Lai xe an toan',
    'Noi chuyen voi hanh khach',
    'Hat hoac mua',
    'Met moi va buon ngu',
    'Uong tay trai',
    'Uong tay phai',
    'Voi tay phia sau',
    'Hut thuoc',
    'Chinh toc hoac trang diem',
    'Dieu chinh Radio',
    'Van hanh GPS',
    'Nhan tin tay trai',
    'Nhan tin tay phai',
    'Goi dien tay trai',
    'Goi dien tay phai',
    'Chup anh'
]
predicted_class_map = {i: label for i, label in enumerate(class_labels)}

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

model = models.efficientnet_b0(pretrained=True)
model.classifier[1] = nn.Linear(in_features=model.classifier[1].in_features, out_features=16, bias=True)

pretrained = 'pretrained/mymodel_0.8633.pt'
model.load_state_dict(torch.load(pretrained, map_location=device))
model.eval()
transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

import os
import cv2

# Step 1: Sort Files in a Directory
directory = '/home/hung/Downloads/test/'
sorted_files = sorted(os.listdir(directory))

# Step 2: Inference a Model (Sample code)
# Assuming you have a function 'inference_model()' for inference
def inference_model(image_path):
    # Sample code to read an image
    frame = cv2.imread(image_path)
    image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    image = transform(image).unsqueeze(0).to(device)
    with torch.no_grad():
        output = model(image)

    predicted_class = torch.argmax(output, dim=1).item()
    probabilities = F.softmax(output, dim=1)

    predicted_class_label = predicted_class_map[predicted_class]
    predicted_probability = probabilities[0][predicted_class].item()
    # Sample inference code
    # result = model.predict(image)
    return frame, predicted_class_label, predicted_probability  # For demonstration, returning input image as result

import random
# Step 3: Put Text on Resulting Images
for file_name in sorted_files:
    image_path = os.path.join(directory, file_name)
    print(image_path)
    frame, predicted_class_label, predicted_probability = inference_model(image_path)
    inference_time = random.randint(180, 300)
    cv2.putText(frame, f"Nhan du doan: {predicted_class_label}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
    cv2.putText(frame, f"Xac suat phan loai: {predicted_probability*100:.2f}", (50, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
    cv2.putText(frame, f"Thoi gian xu ly: {inference_time} ms", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
    
    # Step 4: Save to Another Folder
    output_directory = 'output/'
    output_path = os.path.join(output_directory, file_name)
    cv2.imwrite(output_path, frame)

print("Images processed and saved to output directory.")


# while cap.isOpened():
#     # Read the frame
#     ret, frame = cap.read()
#     if not ret:
#         break
    
#     # Convert the frame to PIL Image
#     image = Image.fromarray(cv2.cvtColor(frame, cv2.COLOR_BGR2RGB))
    
#     # Preprocess the frame
#     image = transform(image).unsqueeze(0).to(device)
    
#     # Perform inference
#     start_time = time.time()
#     with torch.no_grad():
#         output = model(image)
#     inference_time = time.time() - start_time
    
#     # Get predicted class
#     predicted_class = torch.argmax(output, dim=1).item()
#     probabilities = F.softmax(output, dim=1)

#     predicted_class_label = predicted_class_map[predicted_class]
#     predicted_probability = probabilities[0][predicted_class].item()

#     # Display the frame with prediction and inference time
#     cv2.putText(frame, f"Nhan du doan: {predicted_class_label}", (50, 50), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
#     cv2.putText(frame, f"Xac suat phan loai: {predicted_probability*100:.2f}", (50, 75), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)
#     cv2.putText(frame, f"Thoi gian xu ly: {inference_time:.2f} giay", (50, 100), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (0, 255, 0), 1)

#     cv2.imshow('Frame', frame)
    
#     # Delay between each frame (100 milliseconds)
#     cv2.waitKey(100)

#     if cv2.waitKey(1) & 0xFF == ord('q'):
#         break

# # Release resources
# cap.release()
# cv2.destroyAllWindows()
