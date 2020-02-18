#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Feb 17 14:04:54 2020

@author: iglehartc
"""

import os
import numpy as np
import nibabel as nib
from matplotlib.colors import ListedColormap

dataPath = '/home/iglehartc/Documents/Main/Misc/data/qbSegmentation'
outputDir = '/home/iglehartc/Documents/Main/Misc/data/probMaps'
pMapOutputName = 'qbProbMapCombined.nii.gz'
maxMapOutputName = 'qbMaxMapCombined.nii.gz'
cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]
labels = np.arange(1,8)
dims = [93,187,68,len(cases)]

ims = np.zeros(dims)
for i in range(len(cases)):
    niiPath = os.path.join(dataPath,'case'+str(cases[i])+'_QB_L_TMP.nii.gz')
    nii = nib.load(niiPath)
    ims[:,:,:,i] = nii.dataobj.get_unscaled()
    niiPath = os.path.join(dataPath,'case'+str(cases[i])+'_QB_R_TMP.nii.gz')
    nii = nib.load(niiPath)
    ims[:,:,:,i] = ims[:,:,:,i] + nii.dataobj.get_unscaled()
    
stcmap = np.array([[0,	0.447058823529412,	0.698039215686275],
[0.650980392156863,	0.0235294117647059,	0.156862745098039],
[0,	0.619607843137255,	0.450980392156863],
[0.835294117647059,	0.368627450980392,	0],
[0.603921568627451,	0.462745098039216,	0.952941176470588],
[0.803921568627451,	0,	0.454901960784314],
[1,	0.780392156862745,	0.619607843137255],
[0.815686274509804,	0.709803921568628,	0.231372549019608],
[0.200000000000000,	0.800000000000000,	0.800000000000000],
[0.556862745098039,	0.921568627450980,	0],
[1,	0.450980392156863,	0.450980392156863]])
stcmap = np.hstack((stcmap,np.ones([stcmap.shape[0],1])))
stcmap = ListedColormap(stcmap)
stcmap = stcmap(np.linspace(0,1,len(labels)))
stcmap = ListedColormap(stcmap)
    
indicator = np.sum(ims>0,axis=3)>0
counts = np.zeros([dims[0],dims[1],dims[2],len(labels)])
pMap = np.zeros([dims[0],dims[1],dims[2],4])
maxMap = np.zeros([dims[0],dims[1],dims[2],4])

for i in range(dims[0]):
    for j in range(dims[1]):
        for k in range(dims[2]):
            if indicator[i,j,k]:
                for l in range(len(labels)):
                    counts[i,j,k,l] = np.count_nonzero(ims[i,j,k,:]==labels[l])
                weights = np.array([np.squeeze(counts[i,j,k,:])]).transpose()
                weights = weights/np.sum(weights)
                pMap[i,j,k,:] = np.squeeze(np.matmul(stcmap.colors.transpose(),weights))
                pMap[i,j,k,3] = np.sum(counts[i,j,k,:])/(len(labels)*len(cases))
                maxMap[i,j,k,:] = stcmap.colors[np.argmax(counts[i,j,k,:])]
                
pMap[:,:,:,3] = pMap[:,:,:,3]/np.max(pMap[:,:,:,3])    

imgOut1 = pMap
imgOut2 = maxMap    
nii.header['dim'][0] = 5
nii.header['dim'][5] = 4
nii.header['intent_code'] = 2004
niiOut1 = nib.Nifti1Image(imgOut1,nii.affine, nii.header)
niiOut2 = nib.Nifti1Image(imgOut2,nii.affine, nii.header)
nib.save(niiOut1,os.path.join(outputDir,pMapOutputName))
nib.save(niiOut2,os.path.join(outputDir,maxMapOutputName))