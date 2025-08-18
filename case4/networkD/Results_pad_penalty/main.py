import torch
import torch.nn as nn
import torch.nn.functional as F
import numpy as np
import scipy
import matplotlib.pyplot as plt
import os
import time
from timeit import default_timer
from utilities3 import *
from Adam import Adam
import time
from NN1 import *
from torchinfo import summary

torch.manual_seed(123)
np.random.seed(123)

# ====================================
# saving settings
# ====================================
current_directory = os.getcwd()
case = "Heatmap"
save_index = 1  
folder_index = str(save_index)

results_dir = "/" + case + folder_index +"/"
save_results_to = current_directory + results_dir
if not os.path.exists(save_results_to):
    os.makedirs(save_results_to)
save_models_to = save_results_to +"model/"
if not os.path.exists(save_models_to):
    os.makedirs(save_models_to)

# ====================================
#  Define parameters and Load data
# ====================================     

batch_size_train = 20
batch_size_vali = 20

learning_rate = 0.001

epochs = 5000

modes1 = 8  
modes2 = 8   
width = 32

reader = MatReader('Data/mixed_data_heat_pad.mat')
F1_train = reader.read_field('F1_train')
F2_train = reader.read_field('F2_train')
U1_train = reader.read_field('U1_train')
U2_train = reader.read_field('U2_train')
F1_test = reader.read_field('F1_test')
F2_test = reader.read_field('F2_test')
U1_test = reader.read_field('U1_test')
U2_test = reader.read_field('U2_test')

theta_ori = np.linspace(0, 1, 41)
z_ori = np.linspace(0, 1, 41)


F1_train = F1_train.reshape(F1_train.shape[0], F1_train.shape[1], F1_train.shape[2], 1)
F2_train = F2_train.reshape(F2_train.shape[0], F2_train.shape[1], F2_train.shape[2], 1)
F1_test = F1_test.reshape(F1_test.shape[0], F1_test.shape[1], F1_test.shape[2], 1)
F2_test = F2_test.reshape(F2_test.shape[0], F2_test.shape[1], F2_test.shape[2], 1)
U1_train = U1_train.reshape(U1_train.shape[0], U1_train.shape[1], U1_train.shape[2], 1)
U2_train = U2_train.reshape(U2_train.shape[0], U2_train.shape[1], U2_train.shape[2], 1)
U1_test = U1_test.reshape(U1_test.shape[0], U1_test.shape[1], U1_test.shape[2], 1)
U2_test = U2_test.reshape(U2_test.shape[0], U2_test.shape[1], U2_test.shape[2], 1)


f1_normalizer = MaxMinNormalizer(F1_train)
f2_normalizer = MaxMinNormalizer(F2_train)
f1_train = f1_normalizer.encode(F1_train)
f2_train = f2_normalizer.encode(F2_train)
f1_test = f1_normalizer.encode(F1_test)
f2_test = f2_normalizer.encode(F2_test)
x_train = torch.cat((f1_train, f2_train), 3).cuda()
x_test = torch.cat((f1_test, f2_test), 3).cuda()


#U_train = torch.cat((U1_train[..., None], U2_train[...,None]), 3).cuda()
U_true = torch.cat((U1_test, U2_test), 3).cuda()
u1_normalizer = MaxMinNormalizer(U1_train)
u2_normalizer = MaxMinNormalizer(U2_train)
U1_train = u1_normalizer.encode(U1_train)
U2_train = u2_normalizer.encode(U2_train)
U1_test = u1_normalizer.encode(U1_test)
U2_test = u2_normalizer.encode(U2_test)
U_train = torch.cat((U1_train, U2_train), 3).cuda()
U_test = torch.cat((U1_test, U2_test), 3).cuda()


train_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(x_train, U_train), batch_size=batch_size_train, shuffle=True)
vali_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(x_test, U_test), batch_size=batch_size_vali, shuffle=True)
# model
model = LNO(width, modes1, modes2).cuda()
summary(model, input_size=(1,)+x_train.shape[1:]) 
# # Adjust the dimensions as per your model's input size
# dummy_input = x_train[0:1].to(device) #torch.tensor(torch.randn(1, Par['nf'], Par['lb'], Par['nx'],Par['ny']),   dtype=DTYPE, device=device)

# # Profile the model
# flops = torchprofile.profile_macs(model, dummy_input)
# print(f"FLOPs: {flops:.2e}")

# ====================================
# Training 
# ====================================
optimizer = torch.optim.Adam(model.parameters(), lr=learning_rate)
decay_rate = 0.5**(1/5000)
scheduler = torch.optim.lr_scheduler.ExponentialLR(optimizer, decay_rate)
start_time = time.time()
myloss = LpLoss(size_average=True)


train_loss = np.zeros((epochs, 1))
vali_loss = np.zeros((epochs, 1))
min_loss = 100
for ep in range(epochs):
    model.train()
    t1 = default_timer()
    train_l2 = 0
    n_train=0
    for x, y in train_loader:
        x, y = x.cuda(), y.cuda()

        optimizer.zero_grad()
        out = model(x)  
        l2 = torch.norm(y-out, p=2)/torch.norm(y, p=2) + torch.norm(y[:,:,0:1,:]-out[:,:,40:41,:], p=2)/torch.norm(y[:,:,0:1,:], p=2)
        l2.backward()

        optimizer.step()
        train_l2 += l2.item()
        n_train += 1

    scheduler.step()
    model.eval()
    vali_l2 = 0.0
    with torch.no_grad():
        n_vali=0
        for x, y in vali_loader:
            x, y = x.cuda(), y.cuda()
            out = model(x)
            vali_l2 += torch.norm(y-out, p=2)/torch.norm(y, p=2)
            n_vali += 1

    train_l2 /= n_train
    vali_l2 /= n_vali
    if vali_l2 < min_loss:
        min_loss = vali_l2
        torch.save(model, save_models_to+'model')
    train_loss[ep,0] = train_l2
    vali_loss[ep,0] = vali_l2
    t2 = default_timer()
    print("Epoch: %d, time: %.3f, Train loss: %.4f, Vali loss: %.4f" % (ep, t2-t1, train_l2, vali_l2))
elapsed = time.time() - start_time
print("\n=============================")
print("Training done...")
print('Training time: %.3f'%(elapsed))
print("=============================\n")



x = np.linspace(0, epochs-1, epochs)
np.savetxt(save_results_to+'/epoch.txt', x)
np.savetxt(save_results_to+'/train_loss.txt', train_loss)
np.savetxt(save_results_to+'/vali_loss.txt', vali_loss)    

    
################################################################
# testing
################################################################
test_loader = torch.utils.data.DataLoader(torch.utils.data.TensorDataset(x_test, U_test), batch_size=1, shuffle=False)
pred_u = torch.zeros(U1_test.shape[0],U1_test.shape[1],U1_test.shape[2],2).cuda()
index = 0
test_l2_norm = 0.0
with torch.no_grad():
    for x, y in test_loader:
        x, y = x.cuda(), y.cuda()
        out = model(x)
        test_l2_norm += torch.norm(y-out, p=2)/torch.norm(y, p=2)
        out1 = out[:,:,:,0:1]
        out2 = out[:,:,:,1:2] 
        out1 = u1_normalizer.decode(out1)
        out2 = u2_normalizer.decode(out2)
        out_new = torch.cat((out1, out2),dim=-1)
        pred_u[index,:,:,:] = out_new
        index = index + 1
test_l2_norm /= index
test_l2 = torch.norm(U_true-pred_u, p=2)/torch.norm(U_true, p=2)




np.save(save_results_to+'u_pred.npy', pred_u.cpu().numpy())
np.save(save_results_to+'u_true.npy', U_true.cpu().numpy())
    
    
print("\n=============================")
print("Testing done...")
print('Testing l2-norm: %.3e'%(test_l2_norm))
print('Testing error: %.3e'%(test_l2))
print("=============================\n")