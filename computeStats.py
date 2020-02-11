#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Feb  7 08:30:15 2020

@author: iglehartc
"""

def computeVolume(niiPath):
    import nibabel as nib
    import numpy as np
    nii = nib.load(niiPath)
    hdr = nii.header
    pixdim = hdr['pixdim']
    voxVol = pixdim[1] * pixdim[2] * pixdim[3]
    img = nii.dataobj.get_unscaled()
    nvox = float(np.count_nonzero(img))
    vol = nvox*voxVol        
    return vol

def computeDiceAndVSI(niiPath1,niiPath2,flip):
    import nibabel as nib
    import numpy as np
    nii1 = nib.load(niiPath1)
    img1 = nii1.dataobj.get_unscaled()

    nii2 = nib.load(niiPath2)
    img2 = nii2.dataobj.get_unscaled()

    if flip:
        img2 = np.flip(img2,axis=0)

    #Correct erroneous values - just for ST
    img1[img1>13] = 0
    
    labels1 = np.unique(img1)[1:]
    labels2 = np.unique(img2)[1:]
    diceArray = np.zeros([len(labels1),len(labels2)])
    vsiArray  = np.zeros([len(labels1),len(labels2)])
    
    i = 0
    for l1 in labels1:
        j = 0
        for l2 in labels2:
            nvox1 = float(np.count_nonzero(img1==l1))
            nvox2 = float(np.count_nonzero(img2==l2))
            nvox  = float(np.count_nonzero((img1==l1)*(img2==l2)))
            diceArray[i,j] = 2*nvox/(nvox1+nvox2)
            vsiArray[i,j]  = 1 - np.abs(nvox1 - nvox2)/(nvox1 + nvox2)
            j = j+1
        i = i+1
    dice = np.max(diceArray,axis=1)
    vsi  = np.max(vsiArray ,axis=1)
    
    return dice, vsi