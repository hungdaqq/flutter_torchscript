import torch
import timm
import torch.nn as nn
from torchvision import transforms, models
device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')

num_classes = 16

import torch
from torch.utils.mobile_optimizer import optimize_for_mobile


model = models.efficientnet_b0(pretrained=True)
model.classifier[1] = nn.Linear(in_features=model.classifier[1].in_features, out_features=num_classes, bias=True)

pretrained = 'pretrained/mymodel_0.8633.pt'

model.load_state_dict(torch.load(pretrained, map_location=device),strict=False)
model.eval()
example = torch.rand(1, 3, 224, 224)
traced_script_module = torch.jit.script(model, example)
optimized_traced_model = optimize_for_mobile(traced_script_module)
optimized_traced_model._save_for_lite_interpreter("assets/models/mobilevit_xxs_torchscript.pt")