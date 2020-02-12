# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import os
import numpy as np
import computeStats
#import matplotlib.pyplot as plt

dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/'
qbDir = os.path.join(dataDir,'dtiSegmentation','segmentation')
rsDir = os.path.join(dataDir,'rsFMRISegmentation')
stDir = os.path.join(dataDir,'stSegmentation')

cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]

st_qb_L_dice = np.zeros((11,))
st_qb_R_dice = np.zeros((11,))
st_rs_L_dice = np.zeros((11,))
st_rs_R_dice = np.zeros((11,))

st_qb_L_vsi = np.zeros((11,))
st_qb_R_vsi = np.zeros((11,))
st_rs_L_vsi = np.zeros((11,))
st_rs_R_vsi = np.zeros((11,))

qb_rs_L_dice = np.zeros((7,))
qb_rs_R_dice = np.zeros((7,))
qb_rs_L_vsi = np.zeros((7,))
qb_rs_R_vsi = np.zeros((7,))

for case in cases:
    caseStr = str(case)
    
#    stFile = os.path.join(stDir,'case'+caseStr+'_ST_L_DTI.nii.gz')
#    qbFile = os.path.join(qbDir,'case'+caseStr+'_QB_L_DTI_1mm.nii.gz')
#    dice,vsi = computeStats.computeDiceAndVSI(stFile,qbFile,1)
#    st_qb_L_dice = np.column_stack((st_qb_L_dice,dice))
#    st_qb_L_vsi  = np.column_stack((st_qb_L_vsi ,vsi ))
#    
#    stFile = os.path.join(stDir,'case'+caseStr+'_ST_R_DTI.nii.gz')
#    qbFile = os.path.join(qbDir,'case'+caseStr+'_QB_R_DTI_1mm.nii.gz')
#    dice,vsi = computeStats.computeDiceAndVSI(stFile,qbFile,1)
#    st_qb_R_dice = np.column_stack((st_qb_R_dice,dice))
#    st_qb_R_vsi  = np.column_stack((st_qb_R_vsi ,vsi ))
#    
#    stFile = os.path.join(stDir,'case'+caseStr+'_ST_L_T1W.nii.gz')
#    rsFile = os.path.join(rsDir,'case'+caseStr+'_RS_L_T1W.nii.gz')
#    dice,vsi = computeStats.computeDiceAndVSI(stFile,rsFile,0)
#    st_rs_L_dice = np.column_stack((st_rs_L_dice,dice))
#    st_rs_L_vsi  = np.column_stack((st_rs_L_vsi ,vsi ))
#    
#    stFile = os.path.join(stDir,'case'+caseStr+'_ST_R_T1W.nii.gz')
#    rsFile = os.path.join(rsDir,'case'+caseStr+'_RS_R_T1W.nii.gz')
#    dice,vsi = computeStats.computeDiceAndVSI(stFile,rsFile,0)
#    st_rs_R_dice = np.column_stack((st_rs_R_dice,dice))
#    st_rs_R_vsi  = np.column_stack((st_rs_R_vsi ,vsi ))
    
    qbFile = os.path.join(qbDir,'case'+caseStr+'_QB_L_DTI_reordered.nii.gz')
    rsFile = os.path.join(rsDir,'case'+caseStr+'_RS_L_DTI_reordered.nii.gz')
    dice,vsi = computeStats.computeDiceAndVSI(qbFile,rsFile,1)
    qb_rs_L_dice = np.column_stack((qb_rs_L_dice,dice))
    qb_rs_L_vsi  = np.column_stack((qb_rs_L_vsi ,vsi ))
    
    qbFile = os.path.join(qbDir,'case'+caseStr+'_QB_R_DTI_reordered.nii.gz')
    rsFile = os.path.join(rsDir,'case'+caseStr+'_RS_R_DTI_reordered.nii.gz')
    dice,vsi = computeStats.computeDiceAndVSI(qbFile,rsFile,1)
    qb_rs_R_dice = np.column_stack((qb_rs_R_dice,dice))
    qb_rs_R_vsi  = np.column_stack((qb_rs_R_vsi ,vsi ))
    
#st_qb_L_dice = np.delete(st_qb_L_dice,0,1).transpose()
#st_qb_R_dice = np.delete(st_qb_R_dice,0,1).transpose()
#st_rs_L_dice = np.delete(st_rs_L_dice,0,1).transpose()
#st_rs_R_dice = np.delete(st_rs_R_dice,0,1).transpose()
#
#st_qb_L_vsi = np.delete(st_qb_L_vsi,0,1).transpose()
#st_qb_R_vsi = np.delete(st_qb_R_vsi,0,1).transpose()
#st_rs_L_vsi = np.delete(st_rs_L_vsi,0,1).transpose()
#st_rs_R_vsi = np.delete(st_rs_R_vsi,0,1).transpose()

qb_rs_L_dice = np.delete(qb_rs_L_dice,0,1).transpose()
qb_rs_R_dice = np.delete(qb_rs_R_dice,0,1).transpose()
qb_rs_L_vsi = np.delete(qb_rs_L_vsi,0,1).transpose()
qb_rs_R_vsi = np.delete(qb_rs_R_vsi,0,1).transpose()