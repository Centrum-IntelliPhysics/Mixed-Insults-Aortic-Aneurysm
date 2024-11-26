import os
import sys

import math
import time
import datetime
import numpy as np
from numpy.lib.stride_tricks import sliding_window_view
import torch
from torch.utils.data import Dataset
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, random_split
from torch.optim.lr_scheduler import CosineAnnealingLR, LambdaLR
from unet import Unet
from torchinfo import summary
import torchprofile
import scipy.io

# from YourDataset import YourDataset  # Import your custom dataset here
from tqdm import tqdm
# from torch.cuda.amp import autocast, GradScaler

import pickle
torch.manual_seed(23)

DTYPE = torch.float32

# scaler = GradScaler()

device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print("Using device:", device)

def error_metric(pred, true, Par):
    # - B,C,X,Y
    B,_,_,_ = true.shape
    true = true.reshape(B, -1)
    pred = pred.reshape(B, -1)
    err = torch.mean( torch.norm(true-pred, p=2, dim=1)/torch.norm(true, p=2, dim=1) )
    return err


class CustomLoss(nn.Module):
    def __init__(self):
        super(CustomLoss, self).__init__()

    def forward(self, y_pred, y_true, Par):
        # Implement your custom loss calculation here
        y_pred = (y_pred - Par['out_shift_loss'])/Par['out_scale_loss']
        y_true = (y_true - Par['out_shift_loss'])/Par['out_scale_loss']

        loss = ( torch.mean( (torch.mean(torch.square(y_true - y_pred)) )/(torch.mean(torch.square(y_true) )) ) 
                + torch.mean( (torch.mean(torch.square(y_true[:,:,:,0:1] - y_pred[:,:,:,40:41])) )/(torch.mean(torch.square(y_true[:,:,:,0:1]) )) ) )

        return loss


class YourDataset(Dataset):
    def __init__(self, x, y, transform=None):
        self.x = x
        self.y = y
        self.transform = transform

    def __len__(self):
        return len(self.x)

    def __getitem__(self, idx):
        x_sample = self.x[idx]
        y_sample = self.y[idx]

        if self.transform:
            x_sample, y_sample = self.transform(x_sample, y_sample)

        return x_sample, y_sample


def preprocess(x, y, Par):

    print('x: ', x.shape)
    print('y: ', y.shape)
    print()

    return x.astype(np.float32), y.astype(np.float32)

def combined_scheduler(optimizer, total_epochs, warmup_epochs, last_epoch=-1):
    def lr_lambda(epoch):
        if epoch < warmup_epochs:
            return float(epoch + 1) / warmup_epochs
        else:
            return 0.5 * (1 + math.cos(math.pi * (epoch - warmup_epochs) / (total_epochs - warmup_epochs)))

    return LambdaLR(optimizer, lr_lambda, last_epoch)


def load_data(data, key, cond):
    x1 = np.expand_dims(data[f"F1_{key}"], axis=1)
    x2 = np.expand_dims(data[f"F2_{key}"], axis=1)
    if cond=='dil_and_dist':
        x  = np.concatenate([x1,x2], axis=1)#[:,:,:40]
    elif cond=='dil':
        x  = x1#[:,:,:40]

    y1 = np.expand_dims(data[f"U1_{key}"], axis=1)
    y2 = np.expand_dims(data[f"U2_{key}"], axis=1)
    y  = np.concatenate([y1,y2], axis=1)#[:,:,:40]

    print(f"x: {x.shape}")
    print(f"y: {y.shape}")

    return x.astype(np.float32), y.astype(np.float32)


# Load your data into NumPy arrays (x_train, t_train, y_train, x_val, t_val, y_val, x_test, t_test, y_test)
#########################

cond = 'dil'

print("Loading Dataset ...")
temp = os.getcwd().split('/')[-2][:4]

data = scipy.io.loadmat(f"../data/mixed_data_{temp}.mat")
print("Train Dataset")
x_train, y_train = load_data(data, "train", cond)

print("Test Dataset")
x_test, y_test = load_data(data, "test", cond)

print("Loaded Dataset")
print("Dataset type: ", x_train.dtype)

inp_shift = np.min(x_train, axis=(0,2,3)).reshape(1,-1,1,1)
inp_scale = ( np.max(x_train, axis=(0,2,3)) - np.min(x_train, axis=(0,2,3)) ).reshape(1,-1,1,1)

out_shift = np.min(y_train, axis=(0,2,3)).reshape(1,-1,1,1)
out_scale = ( np.max(y_train, axis=(0,2,3)) - np.min(y_train, axis=(0,2,3)) ).reshape(1,-1,1,1)

print(f"inp_shift: {inp_shift}\ninp_scale: {inp_scale}\nout_shift: {out_shift}\nout_scale: {out_scale}")

'''
change n_channels
'''

Par = {
       'DEVICE'          : device,
       'nx'              : x_train.shape[-2],
       'ny'              : x_train.shape[-1]
       }

print('\nTrain Dataset')
x_train,y_train = preprocess(x_train, y_train, Par)
print('\nValidation Dataset')
x_val,y_val = preprocess(x_test, y_test, Par)
print('\nTest Dataset')
x_test,y_test = preprocess(x_test, y_test, Par)

# sys.exit()

Par.update(
       {
       'inp_ch'          : x_train.shape[1],
       'out_ch'          : y_train.shape[1],
       'n_channels'      : 32,
       'k'               : 3,
       'block_type_ls'  : ['Conv'],
       'inp_shift'       : torch.tensor(inp_shift, dtype=DTYPE, device=device),
       'inp_scale'       : torch.tensor(inp_scale, dtype=DTYPE, device=device),
       'out_shift'       : torch.tensor(out_shift, dtype=DTYPE, device=device),
       'out_scale'       : torch.tensor(out_scale, dtype=DTYPE, device=device),
       'out_shift_loss'  : torch.tensor(out_shift, dtype=DTYPE, device=device),
       'out_scale_loss'  : torch.tensor(out_scale, dtype=DTYPE, device=device),
       }
)



Par['num_epochs']  = 100000 #50000 #500


print('Par:\n', Par)

with open('Par.pkl', 'wb') as f:
    pickle.dump(Par, f)

# sys.exit()
#########################


# Create custom datasets
x_train_tensor = torch.tensor(x_train, dtype=DTYPE)
y_train_tensor = torch.tensor(y_train, dtype=DTYPE)

x_val_tensor   = torch.tensor(x_val,   dtype=DTYPE)
y_val_tensor   = torch.tensor(y_val,   dtype=DTYPE)

x_test_tensor  = torch.tensor(x_test,  dtype=DTYPE)
y_test_tensor  = torch.tensor(y_test,  dtype=DTYPE)

train_dataset = YourDataset(x_train_tensor, y_train_tensor)
val_dataset = YourDataset(x_val_tensor, y_val_tensor)
test_dataset = YourDataset(x_test_tensor, y_test_tensor)

# Define data loaders
train_batch_size = 250
val_batch_size   = 250 
test_batch_size  = 250 
train_loader = DataLoader(train_dataset, batch_size=train_batch_size, shuffle=True)
val_loader = DataLoader(val_dataset, batch_size=val_batch_size)
test_loader = DataLoader(test_dataset, batch_size=test_batch_size)

# Initialize your Unet2D model
model = Unet(Par).to(device).to(DTYPE)
summary(model, input_size=(1,)+x_train.shape[1:]) 

# Adjust the dimensions as per your model's input size
dummy_input = x_train_tensor[0:1].to(device) #torch.tensor(torch.randn(1, Par['nf'], Par['lb'], Par['nx'],Par['ny']),   dtype=DTYPE, device=device)

# Profile the model
flops = torchprofile.profile_macs(model, dummy_input)
print(f"FLOPs: {flops:.2e}")

# Define loss function and optimizer
criterion = CustomLoss()
optimizer = optim.Adam(model.parameters(), lr=1e-4, weight_decay=1e-5)

# Learning rate scheduler (Cosine Annealing)
scheduler = CosineAnnealingLR(optimizer, T_max= Par['num_epochs'] * len(train_loader) )  # Adjust T_max as needed
# scheduler = combined_scheduler(optimizer, Par['num_epochs'] * len(train_loader), int(0.05 * Par['num_epochs']) * len(train_loader))


# Training loop
num_epochs = Par['num_epochs']
best_val_loss = float('inf')
best_err_metric = float('inf')
best_model_id = 0

os.makedirs('models', exist_ok=True)

for epoch in range(num_epochs):
    begin_time = time.time()
    model.eval()
    train_loss = 0.0
    L_theta = []

    model.train()
    for x, y_true in tqdm(train_loader, desc=f'Epoch {epoch + 1}/{num_epochs}'):
        optimizer.zero_grad()
        y_pred = model(x.to(device))
        loss = criterion(y_pred, y_true.to(device), Par)

        loss.backward()
        optimizer.step()
        train_loss += loss.item()

        # Update learning rate
        scheduler.step()

    train_loss /= len(train_loader)


    # Validation
    model.eval()
    val_loss = 0.0
    err_metric = 0.0
    with torch.no_grad():
        for x, y_true in val_loader:
            y_pred = model(x.to(device))
            loss = criterion(y_pred, y_true.to(device), Par)
            err  = error_metric(y_pred, y_true.to(device), Par)
            val_loss += loss.item() 
            err_metric += err.item()

    val_loss /= len(val_loader)
    err_metric /= len(val_loader)

     # Save the model if validation loss is the lowest so far
    if err_metric < best_err_metric:
        best_err_metric = err_metric
        best_model_id = epoch+1
        torch.save(model.state_dict(), f'models/best_model.pt')
    
    time_stamp = str('[')+datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")+str(']')
    elapsed_time = time.time() - begin_time
    print(time_stamp + f' - Epoch {epoch + 1}/{num_epochs}, Train Loss: {train_loss:.4e}, Val Loss: {val_loss:.4e}, Err Metric: {err_metric:.4e}, best model: {best_model_id}, LR: {scheduler.get_last_lr()[0]:.4e}, epoch time: {elapsed_time:.2f}'
          )

print('Training finished.')

# Testing loop
model.eval()
test_loss = 0.0
with torch.no_grad():
    for x, y_true in test_loader:
        y_pred = model(x.to(device))
        loss = error_metric(y_pred, y_true.to(device), Par)
        test_loss += loss.item()  
test_loss /= len(test_loader)
print(f'Test Loss: {test_loss:.4e}')
