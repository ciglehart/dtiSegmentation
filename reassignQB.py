# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""
import numpy as np
import os
import sklearn.cluster as clt
import nibabel as nib

cases = [1,2,3,4,5,6,7,10,11,12,13,14,15,16,17,19,20,21]
labels = np.arange(1,12)
dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation'
recomputeCentroids = 0
largeNumber = 1000000

#Compute centroids in template space
#if recomputeCentroids:
#    points = np.zeros([largeNumber,3])
#    n = 0
#    for case in cases:
#        print(case)
#        niiPath = os.path.join(dataDir,'case'+str(case)+'_QB_R_TMP.nii.gz')
#        nii = nib.load(niiPath)
#        img = nii.dataobj.get_unscaled()
#        for i in range(img.shape[0]):
#            for j in range(img.shape[1]):
#                for k in range(img.shape[2]):
#                    if img[i,j,k]>0:
#                        points[n,0] = i
#                        points[n,1] = j
#                        points[n,2] = k
#                        n = n+1
#                        
#    points = points[:n,:]
#    kmeans = clt.KMeans(n_clusters=len(labels)).fit(points)
#    centroidsR = kmeans.cluster_centers_
#
##These values are obtained from the above code and are hard-coded here to save time   
#centroidsL = np.array([[34.091,	100.986,	43.746],
#[30.430,	77.225,	26.638],
#[36.367,	111.404,	31.613],
#[22.066,	59.250,	27.131],
#[35.517,	93.363,	29.190],
#[32.057,	83.440,	42.245],
#[27.728,	67.683,	38.523]])    
#    
#centroidsR = np.array([[61.407,	103.383,	45.262],
#[62.798,	78.495,	28.137],
#[57.489,	94.135,	30.930],
#[67.357,	69.672,	40.266],
#[72.760,	61.713,	28.879],
#[64.022,	85.732,	43.306],
#[56.516,	111.577,	32.809]])    
#    
#centroids = centroidsL
#side = 'L'
#assignments = np.zeros([len(labels),len(cases)])
#
#allCentroids = np.zeros([len(labels),1])
#for case in cases:
#    niiPath = os.path.join(dataDir,'case'+str(case)+'_QB_'+side+'_TMP.nii.gz')
#    nii = nib.load(niiPath)
#    img = nii.dataobj.get_unscaled()
#    individualCentroids = np.zeros([len(labels),3])
#    for label in labels:
#        points = np.zeros([largeNumber,3])
#        n = 0
#        for i in range(img.shape[0]):
#            for j in range(img.shape[1]):
#                for k in range(img.shape[2]):
#                    if img[i,j,k]==label:
#                        points[n,0] = i
#                        points[n,1] = j
#                        points[n,2] = k
#                        n = n+1
#        points = points[:n,:]
#        points = np.mean(points,0)
#        individualCentroids[label-1,0] = points[0]
#        individualCentroids[label-1,1] = points[1]
#        individualCentroids[label-1,2] = points[2]
#    allCentroids = np.hstack((allCentroids,individualCentroids))
#allCentroids = allCentroids[:,1:]
#
#for l in range(len(labels)):
#    c = np.tile(np.array(centroids[l,:]),(len(labels),1)) 
#    for i in range(len(cases)):
#        indCents = allCentroids[:,(3*i):(3*i+3)]
#        delta = np.abs(c - indCents)
#        delta = delta[:,0]*delta[:,0] + delta[:,1]*delta[:,1] + delta[:,2]*delta[:,2]
#        index = np.argmin(delta)
#        assignments[index,i] = l+1
#        allCentroids[index,(3*i):(3*i+3)] = largeNumber

assignmentsL = np.array([[1,	11,	10,	8,	9,	2,	7,	3,	6,	5,	4],
[10,	1,	11,	9,	2,	8,	3,	7,	4,	6,	5],
[11,	7,	1,	10,	9,	8,	2,	3,	4,	5,	6],
[10,	11,	1,	9,	8,	2,	7,	5,	3,	4,	6],
[8,	11,	1, 2,	9,	10,	7,	3,	6,	5,	4],
[10,	11,	1,	3,	7,	9,	2,	8,	4,	6,	5],
[1,	3,	11,	10,	2,	7,	9,	5,	4,	6,	8],
[10,	11,	1,	8,	9,	7,	2,	3,	4,	5,	6],
[1,	2,	10,	8,	11,	3,	9,	7,	6,	4,	5],
[11,	10,	1,	9,	2,	4,	8,	3,	5,	6,	7],
[11,	10,	1,	9,	5,	8,	2,	7,	6,	4,	3],
[11,	1,	10,	3,	9,	2,	8,	7,	4,	5,	6],
[1,	11,	9,	10,	2,	6,	8,	3,	4,	5,	7],
[11,	1,	7,	3,	9,	10,	2,	4,	5,	8,	6],
[11,	1,	2,	8,	10,	4,	3,	5,	9,	7,	6],
[1,	11,	9,	10,	2,	8,	3,	7,	5,	4,	6],
[11,	1,	2,	7,	9,	10,	3,	8,	4,	5,	6],
[11,	1,	9,	10,	8,	2,	3,	7,	4,	5,	6]]).transpose()

assignmentsR = np.array([[8,	6,	5,	4,	2,	9,	7,	3,	1,	11,	10],
[7,	6,	5,	4,	2,	3,	8,	9,	10,	11,	1],
[8,	6,	5,	7,	4,	2,	9,	3,	1,	10,	11],
[8,	4,	5,	2,	9,	6,	3,	7,	11,	10,	1],
[6,	4,	3,	5,	9,	2,	7,	8,	10,	1,	11],
[6,	5,	4,	3,	7,	8,	2,	9,	10,	1,	11],
[7,	6,	5,	4,	3,	2,	9,	10,	8,	11,	1],
[6,	5,	4,	3,	2,	7,	8,	9,	1,	11,	10],
[6,	7,	4,	8,	2,	3,	5,	11,	1,	9,	10],
[5,	7,	6,	4,	3,	8,	2,	9,	10,	11,	1],
[6,	5,	2,	8,	3,	4,	9,	7,	1,	11,	10],
[5,	4,	6,	3,	7,	2,	8,	9,	1,	11,	10],
[3,	5,	4,	2,	6,	8,	7,	9,	1,	11,	10],
[6,	7,	5,	4,	9,	3,	8,	10,	11,	2,	1],
[6,	7,	5,	3,	8,	10,	4,	2,	9,	1,	11],
[5,	8,	4,	2,	7,	9,	6,	1,	3,	11,	10],
[5,	4,	7,	3,	6,	9,	2,	10,	8,	1,	11],
[6,	5,	7,	4,	9,	2,	3,	8,	10,	1,	11]]).transpose()

side = 'R'
assignments = assignmentsR

        
for i in range(len(cases)):
    niiPath = os.path.join(dataDir,'case'+str(cases[i])+'_QB_'+side+'_DTI_ST_mask_11_1mm.nii.gz')
    nii = nib.load(niiPath)
    img = nii.dataobj.get_unscaled()
    imgOut = 0*nii.get_fdata()
    
    for l in labels:
        imgOut[img==l] = assignments[l-1,i]           
    niiOut = nib.Nifti1Image(imgOut, nii.affine, nii.header)
    nib.save(niiOut,os.path.join(dataDir,'case'+str(cases[i])+'_QB_'+side+'_DTI_ST_mask_11_reordered.nii.gz'))