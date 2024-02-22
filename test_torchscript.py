import torch
from PIL import Image
from torchvision import transforms

# Load the TorchScript model
model = torch.jit.load("assets/models/mobilevit_xxs_torchscript.pt")
model.eval()

# Preprocess the input image
transform = transforms.Compose([
    transforms.Resize((224,224)),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225]),
])

# Load and preprocess the test image
image_path = '/home/hung/Desktop/test/RGB1_SUB47ACT9F158.jpg'  # Change this to the path of your test image
image = Image.open(image_path)
image = transform(image).unsqueeze(0)  # Add batch dimension

# Perform inference
with torch.no_grad():
    output = model(image)

print(output)
# Interpret the output
predicted_class = torch.argmax(output, dim=1).item()
print("Predicted class:", predicted_class)
