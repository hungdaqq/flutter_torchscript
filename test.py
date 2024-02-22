# import timm
import torch
import torchvision.transforms as transforms
from PIL import Image
import torch.nn.functional as F
import timm

device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

model = timm.create_model('mobilenetv2_100.ra_in1k', pretrained=False, num_classes=16)
pretrained = 'pretrained/mymodel_0.9734.pt'
model.load_state_dict(torch.load(pretrained, map_location=device))
model.eval()
transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

# Load and preprocess the test image
image_path = '/home/hung/Downloads/b878d6f3-69b7-4f62-b1f8-ca074f95cbec.jpeg'  # Change this to the path of your test image
image = Image.open(image_path)
image = transform(image).unsqueeze(0).to(device)  # Add batch dimension and move to device
print(image.shape)
# Perform inference
with torch.no_grad():
    output = model(image)

# Get predicted class
print(output)
predicted_class = torch.argmax(output, dim=1).item()
print("Predicted class:", predicted_class)

