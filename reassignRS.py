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
labels = np.arange(1,31)
dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/rsFMRISegmentation'
recomputeCentroids = 0
largeNumber = 1000000

#Compute centroids in template space
if recomputeCentroids:
    points = np.zeros([largeNumber,3])
    n = 0
    for case in cases:
        print(case)
        niiPath = os.path.join(dataDir,'case'+str(case)+'_RS_R_TMP.nii.gz')
        nii = nib.load(niiPath)
        img = nii.dataobj.get_unscaled()
        for i in range(img.shape[0]):
            for j in range(img.shape[1]):
                for k in range(img.shape[2]):
                    if img[i,j,k]>0:
                        points[n,0] = i
                        points[n,1] = j
                        points[n,2] = k
                        n = n+1
                        
    points = points[:n,:]
    kmeans = clt.KMeans(n_clusters=len(labels)).fit(points)
    centroidsR = kmeans.cluster_centers_

#These values are obtained from the above code and are hard-coded here to save time   
centroidsL = np.array([[38.532,	81.531,	45.344],
[23.785,	62.379,	35.044],
[31.608,	95.925,	35.085],
[32.110,	60.765,	27.693],
[33.243,	81.226,	37.948],
[39.519,	80.734,	30.264],
[24.698,	79.958,	37.351],
[39.507,	100.175,	30.305],
[40.297,	98.102,	40.150],
[21.647,	71.703,	33.325],
[35.637,	90.670,	46.220],
[36.211,	62.846,	36.824],
[27.150,	89.284,	41.773],
[39.450,	90.711,	29.596],
[30.531,	70.647,	36.126],
[33.678,	105.173,	40.346],
[36.568,	70.671,	29.736],
[25.053,	71.466,	43.348],
[37.674,	108.320,	33.924],
[23.548,	56.624,	25.405],
[30.330,	53.649,	32.693],
[29.563,	62.217,	43.750],
[28.821,	77.642,	27.980],
[26.234,	67.181,	26.272],
[29.070,	80.705,	47.151],
[40.100,	74.851,	37.656],
[29.836,	87.002,	31.505],
[41.005,	88.000,	38.159],
[30.728,	98.060,	44.612],
[34.881,	71.594,	45.452]])    
    
centroidsR = np.array([[69.085,	64.651,	38.410],
[58.032,	108.287,	41.385],
[61.518,	76.809,	37.611],
[53.791,	89.418,	29.761],
[61.234,	63.504,	29.621],
[52.244,	81.589,	38.363],
[55.706,	86.782,	47.462],
[51.780,	99.275,	30.233],
[67.563,	73.000,	43.956],
[67.688,	83.477,	39.415],
[64.202,	83.102,	30.068],
[60.611,	66.022,	43.461],
[63.409,	100.598,	43.509],
[69.027,	56.272,	28.510],
[53.930,	109.278,	33.269],
[61.732,	58.074,	36.313],
[51.242,	91.987,	38.269],
[64.002,	91.883,	45.442],
[59.326,	99.587,	34.876],
[55.707,	96.945,	45.913],
[57.137,	69.707,	35.207],
[63.641,	81.692,	47.604],
[69.867,	73.857,	33.613],
[57.042,	75.568,	45.538],
[69.527,	64.915,	28.279],
[64.042,	92.380,	34.236],
[63.953,	73.713,	27.687],
[51.068,	102.086,	39.315],
[59.029,	86.941,	38.463],
[55.136,	78.909,	30.203]])    
    
centroids = centroidsR
side = 'R'
assignments = np.zeros([len(labels),len(cases)])

allCentroids = np.zeros([len(labels),1])
for case in cases:
    niiPath = os.path.join(dataDir,'case'+str(case)+'_RS_'+side+'_TMP.nii.gz')
    nii = nib.load(niiPath)
    img = nii.dataobj.get_unscaled()
    individualCentroids = np.zeros([len(labels),3])
    for label in labels:
        points = np.zeros([largeNumber,3])
        n = 0
        for i in range(img.shape[0]):
            for j in range(img.shape[1]):
                for k in range(img.shape[2]):
                    if img[i,j,k]==label:
                        points[n,0] = i
                        points[n,1] = j
                        points[n,2] = k
                        n = n+1
        points = points[:n,:]
        points = np.mean(points,0)
        individualCentroids[label-1,0] = points[0]
        individualCentroids[label-1,1] = points[1]
        individualCentroids[label-1,2] = points[2]
    allCentroids = np.hstack((allCentroids,individualCentroids))
allCentroids = allCentroids[:,1:]

for l in range(len(labels)):
    c = np.tile(np.array(centroids[l,:]),(len(labels),1)) 
    for i in range(len(cases)):
        indCents = allCentroids[:,(3*i):(3*i+3)]
        delta = np.abs(c - indCents)
        delta = delta[:,0]*delta[:,0] + delta[:,1]*delta[:,1] + delta[:,2]*delta[:,2]
        index = np.argmin(delta)
        assignments[index,i] = l+1
        allCentroids[index,(3*i):(3*i+3)] = largeNumber
        
for i in range(len(cases)):
    niiPath = os.path.join(dataDir,'case'+str(cases[i])+'_RS_'+side+'_T1W.nii.gz')
    nii = nib.load(niiPath)
    img = nii.dataobj.get_unscaled()
    imgOut = 0*nii.get_fdata()
    
    for l in labels:
        imgOut[img==l] = assignments[l-1,i]           
    niiOut = nib.Nifti1Image(imgOut, nii.affine, nii.header)
    nib.save(niiOut,os.path.join(dataDir,'case'+str(cases[i])+'_RS_'+side+'_T1W_reordered.nii.gz'))