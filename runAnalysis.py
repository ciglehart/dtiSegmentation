#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Fri Feb  7 08:33:14 2020

@author: iglehartc
"""
import os
import computeStats

stPath = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/stNuclei/right4ci/'
rsPath = '/home/iglehartc/Downloads/rsSegmentation'
qbPath = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation'

cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]
#cases = [7]
typeStr = 'ST'
sideStr = 'L'

#for case in cases:
#    
#    if typeStr.startswith('ST'):
#        niiPath = os.path.join(stPath,'case'+str(case)+'_ST_'+sideStr+'_WMN.nii.gz')
#    elif typeStr.startswith('QB'):
#        niiPath = os.path.join(qbPath,'case'+str(case)+'_QB_'+sideStr+'_DTI.nii.gz')
#    else:
#        niiPath = os.path.join(rsPath,'case'+str(case)+'_RS_'+sideStr+'_T1W.nii.gz')
#        
#    vol = computeStats.computeVolume(niiPath)
#    
#    print(vol)

for i in cases:
    filePath = os.path.join(qbPath,'case'+str(i),'TEMPORARY_R_mask.nii.gz')
    vol = computeStats.computeVolume(filePath)
    print(vol)