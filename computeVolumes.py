#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sat Feb 15 16:12:09 2020

@author: charlesiglehart
"""

# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import os
import numpy as np
import computeStats
#import matplotlib.pyplot as plt

dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation'
cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]
labels = np.arange(1,8)
volumes = np.zeros([len(labels),len(cases)])

for i in range(len(cases)):
    fileName = os.path.join(dataDir,'case'+str(cases[i])+'_QB_L_DTI_ST_mask_reordered.nii.gz')
    for j in range(len(labels)):
        volumes[j,i] = computeStats.computeVolume(fileName,labels[j])