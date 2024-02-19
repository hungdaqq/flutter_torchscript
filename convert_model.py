import torch
import torch.nn as nn
from torchvision import transforms, models

num_classes = 16

# Instantiate your PyTorch model
model = models.efficientnet_b0(pretrained=True)
model.classifier[1] = nn.Linear(in_features=model.classifier[1].in_features, out_features=num_classes, bias=True)

# Example input
example_input = torch.rand(1, 3, 224, 224)  # Adjust the shape according to your input

# Trace the model
traced_model = torch.jit.trace(model, example_input)

# Save the traced model to a file
traced_model.save("traced_model.pt")
