# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
import os
import nibabel as nib

cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]
labels = np.arange(1,12)
dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation'
recomputeCentroids = 0
largeNumber = 1000000

assignmentsL = np.array([[1,	11,	10,	9,	8,	2,	7,	3,	6,	5,	4],
[11,	1,	2,	10,	8,	3,	9,	7,	6,	4,	5],
[10,	11,	1,	9,	7,	8,	2,	3,	4,	5,	6],
[11,	1,	2,	9,	10,	3,	8,	4,	5,	7,	6],
[8,	11,	1,	10,	7,	2,	9,	3,	4,	6,	5,],
[11,	1,	2,	10,	8,	9,	3,	7,	4,	6,	5],
[1,	10,	11,	9,	2,	8,	7,	3,	4,	5,	6,],
[10,	11,	1,	9,	8,	2,	7,	3,	4,	5,	6],
[1,	11,	10,	7,	8,	9,	3,	2,	4,	6,	5,],
[11,	1,	2,	10,	9,	3,	5,	4,	8,	6,	7],
[1,	11,	10,	6,	2,	5,	9,	3,	8,	4,	7,],
[11,	1,	7,	10,	8,	3,	9,	2,	4,	5,	6],
[11,	10,	1,	9,	8,	7,	2,	3,	5,	4,	6],
[10,	11,	1,	9,	8,	7,	2,	3,	4,	5,	6],
[1,	11,	2,	9,	10,	3,	8,	4,	7,	5,	6,],
[1,	11,	10,	9,	2,	3,	8,	7,	4,	5,	6,],
[11,	10,	1,	9,	8,	7,	2,	5,	3,	4,	6],
[10,	11,	1,	9,	8,	5,	3,	2,	4,	6,	7]]).transpose()

assignmentsR = np.array([[5,	6,	4,	7,	2,	3,	8,	9,	1,	11,	10],
[4,	6,	5,	3,	2,	7,	9,	8,	11,	10,	1],
[7,	6,	4,	5,	8,	9,	3,	11,	2,	10,	1],
[7,	6,	4,	5,	3,	8,	9,	2,	10,	11,	1],
[5,	6,	4,	3,	7,	2,	8,	9,	1,	10,	11],
[7,	6,	5,	4,	9,	3,	2,	8,	10,	1,	11],
[4,	6,	5,	3,	7,	8,	9,	10,	2,	11,	1],
[7,	6,	5,	4,	3,	9,	10,	8,	2,	1,	11],
[5,	6,	4,	7,	2,	3,	10,	8,	1,	9,	11],
[4,	5,	3,	7,	6,	2,	9,	8,	10,	11,	1],
[5,	6,	4,	2,	3,	8,	10,	7,	1,	9,	11],
[5,	6,	7,	4,	3,	9,	10,	8,	2,	1,	11],
[5,	6,	4,	3,	8,	10,	9,	7,	2,	11,	1],
[7,	6,	5,	4,	8,	3,	9,	10,	11,	2,	1],
[4,	6,	5,	2,	3,	8,	9,	7,	1,	11,	10],
[4,	6,	5,	8,	3,	2,	9,	7,	1,	10,	11],
[5,	6,	7,	4,	8,	10,	3,	9,	11,	2,	1],
[5,	6,	4,	7,	3,	2,	8,	10,	9,	1,	11]]).transpose()

side = 'L'
assignments = assignmentsL
        
for i in range(len(cases)):
    niiPath = os.path.join(dataDir,'case'+str(cases[i])+'_QB_'+side+'_DTI_ST_mask_11_1mm.nii.gz')
    nii = nib.load(niiPath)
    img = nii.dataobj.get_unscaled()
    imgOut = 0*nii.get_fdata()
    
    for l in labels:
        imgOut[img==l] = assignments[l-1,i]           
    niiOut = nib.Nifti1Image(imgOut, nii.affine, nii.header)
    nib.save(niiOut,os.path.join(dataDir,'case'+str(cases[i])+'_QB_'+side+'_DTI_ST_mask_11_reordered.nii.gz'))