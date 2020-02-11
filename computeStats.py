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

def computeDice(niiPath1,niiPath2):
    import nibabel as nib
    import numpy as np
    nii1 = nib.load(niiPath1)
    #hdr1 = nii1.header
    img1 = nii1.dataobj.get_unscaled()
    nvox1 = float(np.count_nonzero(img1))
    nii2 = nib.load(niiPath2)
    #hdr2 = nii2.header
    img2 = nii2.dataobj.get_unscaled()
    nvox2 = float(np.count_nonzero(img2))
    prod = img1*img2
    nvox = float(np.count_nonzero(prod))
    dice = 2*nvox/(nvox1+nvox2)
    return dice