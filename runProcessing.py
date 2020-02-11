#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Sun Aug 26 11:06:29 2018

@author: charlesiglehart
"""
import os
import dtiProcessingFunctions as df

codeDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/code'
stDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/stSegmentation'
rsDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/rsFMRISegmentation'
dtDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation'

dtiFile = 'LIFUP*DTI*.nii.gz'
templateDir = '/home/charlesiglehart/Documents/Research/template/'
cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]

cases = [11]
for case in cases:
    caseStr = str(case)
    if case < 10:
        caseStr = str(0)+caseStr
    dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)
    fsDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/T1w/sdir/LIFUP0'+caseStr+'/mri'
    fullTemplate = '/home/charlesiglehart/Documents/Research/template/template.nii.gz'
    cropTemplate = '/home/charlesiglehart/Documents/Research/template/templ_93x187x68.nii.gz'
    maskTemplate = '/home/charlesiglehart/Documents/Research/template/mask_templ_93x187x68.nii.gz'
    t1File = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)+'/LIFUP0'+caseStr+'_MPRAGE_T1.nii.gz'
    wmnFile = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)+'/LIFUP0'+caseStr+'_MPRAGE_WMn.nii.gz'
    b0File = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)+'/TEMPORARY_b0.nii.gz'
    regDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)+'/registration'

    
#    df.splitDWI(dataDir,dtiFile)
#    df.extractThalamicLabelsFromFSSeg(dataDir,fsDir)
#    df.refineMasks(dataDir)
    df.cropDWI(dataDir)
    df.generateODFs(dataDir)
    df.maskODFs(dataDir)
    
# Postprocessing: transform ST labels to DTI and T1W spaces; transform RS to DTI space; transform all to template space
#    os.chdir(regDir)
#    os.system('mrtransform -template ../case'+str(case)+'/registration/b0_crop.nii.gz ../case'+str(case)+'/QBI_L_segmentation.nii.gz case' +str(case)+ '_QB_L_DTI.nii.gz -interp nearest -force')
#    os.system('mrtransform -template ../case'+str(case)+'/registration/b0_crop.nii.gz ../case'+str(case)+'/QBI_R_segmentation.nii.gz case' +str(case)+ '_QB_R_DTI.nii.gz -interp nearest -force')
