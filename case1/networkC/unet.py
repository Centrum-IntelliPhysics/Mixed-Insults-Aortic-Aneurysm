import torch
import torch.nn as nn
import numpy as np
import sys
import torch.nn.functional as F
from torch.cuda.amp import autocast
from einops import rearrange

class Conv_Block(nn.Module):
    def __init__(self,in_c,out_c,k,num_groups=1):
        super(Conv_Block, self).__init__()
        
        self.block = nn.Sequential(
                     nn.Conv2d(in_c, out_c, k, padding='same'),
                     nn.GroupNorm(num_groups,out_c),
                     nn.GELU())

    def forward(self, x):
        return self.block(x)

class M_Block(nn.Module):
    def __init__(self, block_type_ls, in_c, out_c, Nx, Ny, k=3, modes=6, num_groups=1):
        super(M_Block, self).__init__()

        self.block_ls = nn.ModuleList()

        if 'Conv' in block_type_ls:
            self.block_ls.append(Conv_Block(in_c, in_c, k, num_groups))

        self.block_ls.append(nn.Identity())

        self.comb = nn.Conv2d(in_c * len(self.block_ls), out_c, kernel_size=1)

    def forward(self, x):
        out_ls = []
        for i in range(len(self.block_ls)):
            block = self.block_ls[i]
            out_ls.append( block(x) )
        out = torch.cat(out_ls, dim=1)
        out = self.comb(out)

        return out
    
class Enc_Block(nn.Module):
    def __init__(self, block_type_ls, in_c, out_c, lat_c, Nx, Ny, k, modes, is_down, is_lat, num_groups=1, factor=2):
        super(Enc_Block, self).__init__()

        self.is_lat = is_lat
        if is_down==True:
            self.down_sample = nn.MaxPool2d(2, stride=2)
        else:
            self.down_sample = nn.Identity()
        self.conv_block      = M_Block(block_type_ls, in_c, out_c, Nx, Ny, k, modes, num_groups)
        if is_lat==True:
            self.latent_block= Conv_Block(out_c,lat_c, 1, num_groups)
            
    def forward(self, x):
        down = self.down_sample(x)
        out  = self.conv_block(down)
        if self.is_lat==True:
            lat  = self.latent_block(out)
        else:
            lat = None
        return out,lat

class Dec_Block(nn.Module):
    def __init__(self, block_type_ls, in_c, out_c, lat_c, Nx, Ny, k, modes, is_lat, is_d, is_up, num_groups=1, factor=2):
        super(Dec_Block, self).__init__()
        
        temp_c = 0

        if is_lat==True:
            self.latent_block  = Conv_Block(lat_c, in_c, 1, num_groups)
            temp_c = temp_c + in_c

        if is_d==True:
            temp_c = temp_c + in_c

        self.conv_block    = M_Block(block_type_ls, temp_c, out_c, Nx, Ny, k, modes, num_groups)

        if is_up==True:
            self.up_sample = nn.ConvTranspose2d(out_c,out_c,kernel_size=2,stride=2)
        else:
            self.up_sample = nn.Identity()


    def forward(self,lat=None,d=None):
        # d: [B,in_c,X,Y]
        if lat is not None and d is not None:
            lat = self.latent_block(lat)
            inp = torch.cat([lat,d], axis=1)
        elif lat is not None and d is None:
            lat = self.latent_block(lat)
            inp = lat
        elif lat is None and d is not None:
            inp = d

        inp = self.conv_block(inp)            # [B,out_c,2X,2Y]
        out = self.up_sample(inp)             # [B,out_c,2X,2Y]
        return out                     


class Unet(nn.Module):
    def __init__(self,par):
        super(Unet,self).__init__()

        self.par = par
        
        n_channels = self.par['n_channels']
        k = self.par['k']
        Nx = self.par['nx']
        Ny = self.par['ny']
        block_type_ls = self.par['block_type_ls']

        self.init_conv = Conv_Block(self.par['inp_ch'], n_channels, k=1 )

        self.enc1 = Enc_Block(block_type_ls, n_channels, n_channels,  1*n_channels, Nx//1, Ny//1, k, [24,32], is_down=False, is_lat=True)                         # [B,C,X,Y]
        self.enc2 = Enc_Block(block_type_ls, n_channels, 2*n_channels, 2*n_channels, Nx//2, Ny//2, k, [16,24], is_down=True, is_lat=True)                        # [B,2C,X/2,Y/2]
        self.enc3 = Enc_Block(block_type_ls, 2*n_channels, 4*n_channels, 4*n_channels, Nx//4, Ny//4, k, [8,16], is_down=True, is_lat=True)                     # [B,4C,X/4,Y/4]
        self.enc4 = Enc_Block(block_type_ls, 4*n_channels, 8*n_channels, 8*n_channels, Nx//8, Ny//8, k, [0,8], is_down=True, is_lat=True)                     # [B,8C,X/8,Y/8]

        self.dec4 = Dec_Block(block_type_ls, 8*n_channels, 4*n_channels, 8*n_channels, Nx//8, Ny//8, k, [0,8], is_lat=True, is_d=False, is_up=True)            # [B,4C,X/4,Y/4]
        self.dec3 = Dec_Block(block_type_ls, 4*n_channels, 2*n_channels, 4*n_channels, Nx//4, Ny//4, k, [8,16], is_lat=True, is_d=True, is_up=True)            # [B,2C,X/2,Y/2]
        self.dec2 = Dec_Block(block_type_ls, 2*n_channels, 1*n_channels, 2*n_channels, Nx//2, Ny//2, k, [16,24], is_lat=True, is_d=True, is_up=True)             # [B,C,X,Y]
        self.dec1 = Dec_Block(block_type_ls, 1*n_channels, 1*n_channels, 1*n_channels, Nx//1, Ny//1, k, [24,32], is_lat=True, is_d=True, is_up=False)            # [B,C,X,Y]
       
        self.dec0 = nn.Sequential(nn.GroupNorm(int(n_channels/4), n_channels),
                                  nn.Conv2d(n_channels,self.par['out_ch'],kernel_size=1),
                                  nn.Sigmoid())

    def encode(self, x):
        x = (x-self.par['inp_shift'])/(self.par['inp_scale'])
        
        e0 = self.init_conv(x)
        e1,l1 = self.enc1(e0)          # [B,C,X,Y]
        e2,l2 = self.enc2(e1)          # [B,2C,X/2,Y/2]
        e3,l3 = self.enc3(e2)          # [B,4C,X/4,Y/4]
        e4,l4 = self.enc4(e3)          # [B,8C,X/8,Y/18]

        return [l1,l2,l3,l4]
    
    def decode(self, l_ls):
        
        l1, l2, l3, l4 = l_ls

        d4 = self.dec4(l4,None)          # [B,4C,X/4,Y/4] 
        d3 = self.dec3(l3,d4)          # [B,2C,X/2,Y/2]
        d2 = self.dec2(l2,d3)          # [B,C,X,Y]  
        d1 = self.dec1(l1,d2)          # [B,C,X,Y]

        d0 = self.dec0(d1)

        out = d0*self.par["out_scale"] + self.par["out_shift"]

        return out
    
    def forward(self, x):
        l_ls = self.encode(x)
        out  = self.decode(l_ls)
        
        return out
