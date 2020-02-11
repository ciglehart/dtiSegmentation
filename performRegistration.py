#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Sun Feb  9 08:10:08 2020

@author: charlesiglehart
"""

import os

codeDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/code'
dtiFile = 'LIFUP*DTI*.nii.gz'
templateDir = '/home/charlesiglehart/Documents/Research/template/'
cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]

for case in cases:
    caseStr = str(case)
    if case < 10:
        caseStr = str(0)+caseStr

    dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case'+str(case)    
    t1File = os.path.join(dataDir,'LIFUP0'+caseStr+'_MPRAGE_T1.nii.gz')
    wmnFile = os.path.join(dataDir,'LIFUP0'+caseStr+'_MPRAGE_WMn.nii.gz')
    b0File = os.path.join(dataDir,'TEMPORARY_b0.nii.gz')
    workingDir = os.path.join(dataDir,'registration')
    fullTemplate = '/home/charlesiglehart/Documents/Research/template/template.nii.gz'
    cropTemplate = '/home/charlesiglehart/Documents/Research/template/templ_93x187x68.nii.gz'
    maskTemplate = '/home/charlesiglehart/Documents/Research/template/mask_templ_93x187x68.nii.gz'
    
    #os.system('rm -rf '+workingDir)
    #os.system('mkdir '+workingDir)
    os.chdir(workingDir)
    os.system('cp '+os.path.join(codeDir,'registerImages.sh')+' .')
#    os.system('cp '+t1File+' t1.nii.gz')
#    os.system('cp '+wmnFile+' wmn.nii.gz')
#    os.system('cp '+b0File+' b0.nii.gz')
#    os.system('cp '+fullTemplate+' template.nii.gz')
#    os.system('cp '+cropTemplate+' cropTemplate.nii.gz')
#    os.system('cp '+maskTemplate+' maskTemplate.nii.gz')
    os.system('./registerImages.sh')