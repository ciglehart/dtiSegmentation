#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Tue Feb 11 11:08:09 2020

@author: iglehartc
"""

import numpy as np
import matplotlib.pyplot as plt

stl = np.array([6008.00,6226.00,5958.00,5121.00,6407.00,7022.00,5337.00,6342.00,5787.00,6222.00,6063.00,5656.00,6036.00,7281.00,6905.00,6129.00,6141.00,6347.00])
str = np.array([6049.00,6101.00,6046.00,5150.00,6503.00,7002.00,5329.00,6244.00,5728.00,6023.00,6089.00,5606.00,5901.00,7281.00,6892.00,6126.00,6078.00,6331.00])
qbl = np.array([7532.58,6827.51,7403.32,5899.15,7520.83,8554.95,6921.52,7826.37,7708.85,6451.46,8108.40,6286.95,7015.53,8343.42,8449.19,7673.60,7203.55,7415.07])
qbr = np.array([7685.35,6686.49,7520.83,5523.11,7720.60,7673.60,6122.43,7344.56,7262.30,7086.03,7497.33,6804.00,6886.26,8026.14,7168.29,7462.08,6921.52,7661.85])
rsl = np.array([5812.40,5473.00,5718.00,5869.00,6512.00,6836.00,5263.00,5903.00,5221.00,5521.00,5619.00,5281.00,5079.00,6352.00,6182.00,6148.00,5459.00,6358.00])
rsr = np.array([5714.50,5520.00,5766.00,5639.00,6475.00,6516.00,5189.00,5899.00,5195.00,5498.00,5506.00,5281.00,5321.00,6257.00,5846.00,5833.00,5338.00,6163.00])

fs = 14
ft = "Arial"
fig = plt.violinplot((stl,str,qbl,qbr,rsl,rsr),positions=[1,2,4,5,7,8],showmedians=True,vert=False,widths=0.75)
plt.yticks([8,7,5,4,2,1],['Structural left','Structural right','DTI left','DTI right','rsFMRI left','rsFMRI right'],fontweight='bold',fontsize=fs,fontname=ft)
plt.xticks(fontsize=fs,fontweight='bold',fontname=ft)
plt.xlabel('Mask volume, $mm^{3}$',fontweight='bold',fontsize=16,fontname=ft)
plt.ylabel('Parcellation',fontweight='bold',fontsize=16,fontname=ft)