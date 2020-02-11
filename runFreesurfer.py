#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 17 20:38:44 2020

@author: charlesiglehart
"""
import os

dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/T1w'
os.chdir(dataDir)
#dirlist = os.listdir()
dirlist = ['LIFUP019_MPRAGE_T1.nii.gz','LIFUP020_MPRAGE_T1.nii.gz','LIFUP021_MPRAGE_T1.nii.gz']

for inputFile in dirlist:
    if inputFile.startswith('LIFUP'):
        subjid = inputFile[0:8]
        print('Processing '+subjid)
        os.chdir(dataDir)
        os.system('recon-all -i '+inputFile+' -subjid '+subjid)
        os.system('recon-all -all -subjid '+subjid)