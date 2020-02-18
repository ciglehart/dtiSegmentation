#!/usr/bin/env python2
# -*- coding: utf-8 -*-

def splitDWI(dataDir,dtiFile):
    import os
    os.chdir(dataDir)
    #Extract first b0 volume
    print('Splitting DWI and extracting first b=0 volume...')
    os.system('fslsplit '+dtiFile+' TEMPORARY_DWI_ -t')  
    os.system('cp TEMPORARY_DWI_0000.nii.gz TEMPORARY_b0.nii.gz')

def extractThalamicLabelsFromFSSeg(dataDir,fsDir):
    
    import nibabel as nib
    import os
    
    os.chdir(fsDir)
    os.system('mrconvert aseg.mgz aseg.nii.gz -force')
    nii = nib.load('aseg.nii.gz')
    img = nii.get_fdata()
    maskR = 0*img
    maskL = 0*img
    maskR[img==49] = 1
    maskL[img==10] = 1
    hdr = nii.header.copy()
    maskRNii = nib.nifti1.Nifti1Image(maskR, None, header=hdr)
    maskLNii = nib.nifti1.Nifti1Image(maskL, None, header=hdr)       
    nib.save(maskRNii,os.path.join(dataDir,'TEMPORARY_R_FS_mask.nii'))  
    nib.save(maskLNii,os.path.join(dataDir,'TEMPORARY_L_FS_mask.nii'))
    os.chdir(dataDir)
    os.system('antsApplyTransforms -d 3 -i TEMPORARY_R_FS_mask.nii -r TEMPORARY_b0.nii.gz -o TEMPORARY_R_FS_mask.nii -t ./registration/t1_to_wmn_combined_warp.nii.gz -n NearestNeighbor -v')
    os.system('antsApplyTransforms -d 3 -i TEMPORARY_L_FS_mask.nii -r TEMPORARY_b0.nii.gz -o TEMPORARY_L_FS_mask.nii -t ./registration/t1_to_wmn_combined_warp.nii.gz -n NearestNeighbor -v')
    
def refineMasks(dataDir):
    
    import os
    os.chdir(dataDir)

    #Save off a copy of the original masks
    #Binarize masks and save off a copy
    os.system('mrthreshold TEMPORARY_L_FS_mask.nii TEMPORARY_L_mask.nii.gz -abs 0.7 -force')
    os.system('mrthreshold TEMPORARY_R_FS_mask.nii TEMPORARY_R_mask.nii.gz -abs 0.7 -force')
    os.system('cp TEMPORARY_L_mask.nii.gz TEMPORARY_L_mask_original.nii.gz')
    os.system('cp TEMPORARY_R_mask.nii.gz TEMPORARY_R_mask_original.nii.gz')

    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_L_mask_original.nii.gz TEMPORARY_L_mask_original.nii.gz -interp nearest -force')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_R_mask_original.nii.gz TEMPORARY_R_mask_original.nii.gz -interp nearest -force')

    os.system('mrcrop TEMPORARY_L_mask_original.nii.gz TEMPORARY_L_mask_original.nii.gz -mask TEMPORARY_L_mask_original.nii.gz -force')
    os.system('mrcrop TEMPORARY_R_mask_original.nii.gz TEMPORARY_R_mask_original.nii.gz -mask TEMPORARY_R_mask_original.nii.gz -force')

    #Reslice to b0 resolution
    print('Reslicing to DWI resolution...')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_L_mask.nii.gz TEMPORARY_L_mask.nii.gz -interp nearest -force')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_R_mask.nii.gz TEMPORARY_R_mask.nii.gz -interp nearest -force')

    print('Generating CSF masks...')
    os.system('antsApplyTransforms -d 3 -i c3t1.nii -r TEMPORARY_b0.nii.gz -o TEMPORARY_CSF_mask.nii.gz -t ./registration/t1_to_b0_combined_warp.nii.gz -v')
    os.system('mrconvert TEMPORARY_CSF_mask.nii.gz -strides -1,2,3 TEMPORARY_CSF_mask.nii.gz -force')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_CSF_mask.nii.gz TEMPORARY_CSF_mask.nii.gz -interp cubic -force')
    os.system('mrthreshold -abs 0.05 -invert TEMPORARY_CSF_mask.nii.gz TEMPORARY_CSF_mask.nii.gz -force')

    os.system('mrcrop TEMPORARY_CSF_mask.nii.gz TEMPORARY_CSF_mask_L.nii.gz -mask TEMPORARY_L_mask.nii.gz -force')
    os.system('mrcrop TEMPORARY_CSF_mask.nii.gz TEMPORARY_CSF_mask_R.nii.gz -mask TEMPORARY_R_mask.nii.gz -force')

    print('Generating DTI...')
    os.system('dwi2tensor dwiCorrected.nii.gz TEMPORARY_tensors.nii.gz -fslgrad LIFUP*.bvec LIFUP*.bval -force')

    print('Creating FA masks...')
    os.system('tensor2metric TEMPORARY_tensors.nii.gz -fa TEMPORARY_FA.nii.gz -force')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_FA.nii.gz TEMPORARY_FA.nii.gz -interp cubic -force')
    os.system('mrthreshold -abs 0.55 TEMPORARY_FA.nii.gz TEMPORARY_FA.nii.gz -force')

    print('Eroding masks to obtain boundaries...')
    os.system('maskfilter TEMPORARY_L_mask.nii.gz erode -npass 1 TEMPORARY_1L_FS_eroded.nii.gz -force')
    os.system('fslmaths TEMPORARY_L_mask.nii.gz -sub TEMPORARY_1L_FS_eroded.nii.gz TEMPORARY_1L_FS_boundary.nii.gz')
    os.system('maskfilter TEMPORARY_R_mask.nii.gz erode -npass 1 TEMPORARY_1R_FS_eroded.nii.gz -force')
    os.system('fslmaths TEMPORARY_R_mask.nii.gz -sub TEMPORARY_1R_FS_eroded.nii.gz TEMPORARY_1R_FS_boundary.nii.gz')

    os.system('mrcrop TEMPORARY_FA.nii.gz TEMPORARY_FA_1L_FS.nii.gz -mask TEMPORARY_L_mask.nii.gz -force')
    os.system('mrcrop TEMPORARY_FA.nii.gz TEMPORARY_FA_1R_FS.nii.gz -mask TEMPORARY_R_mask.nii.gz -force')

    os.system('mrcrop TEMPORARY_1L_FS_boundary.nii.gz TEMPORARY_1L_FS_boundary.nii.gz -mask TEMPORARY_L_mask.nii.gz -force')
    os.system('mrcrop TEMPORARY_1R_FS_boundary.nii.gz TEMPORARY_1R_FS_boundary.nii.gz -mask TEMPORARY_R_mask.nii.gz -force')

    os.system('mrcalc TEMPORARY_1L_FS_boundary.nii.gz TEMPORARY_FA_1L_FS.nii.gz -multiply TEMPORARY_FA_mask_1L_FS.nii.gz -force')
    os.system('mrcalc TEMPORARY_1R_FS_boundary.nii.gz TEMPORARY_FA_1R_FS.nii.gz -multiply TEMPORARY_FA_mask_1R_FS.nii.gz -force')

    os.system('mrcalc 1 TEMPORARY_FA_mask_1L_FS.nii.gz -subtract TEMPORARY_FA_mask_1L_FS.nii.gz -force')
    os.system('mrcalc 1 TEMPORARY_FA_mask_1R_FS.nii.gz -subtract TEMPORARY_FA_mask_1R_FS.nii.gz -force')

    print('Combining masks...')
    os.system('mrcalc TEMPORARY_FA_mask_1L_FS.nii.gz TEMPORARY_CSF_mask_L.nii.gz -mult TEMPORARY_L_mask.nii.gz  -force')
    os.system('mrcalc TEMPORARY_FA_mask_1R_FS.nii.gz TEMPORARY_CSF_mask_R.nii.gz -mult TEMPORARY_R_mask.nii.gz  -force')

    os.system('mrcalc TEMPORARY_L_mask.nii.gz  TEMPORARY_L_mask_original.nii.gz -mult TEMPORARY_L_mask.nii.gz -force')       
    os.system('mrcalc TEMPORARY_R_mask.nii.gz  TEMPORARY_R_mask_original.nii.gz -mult TEMPORARY_R_mask.nii.gz -force')

    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_L_mask.nii.gz TEMPORARY_L_mask.nii.gz -interp nearest -force')
    os.system('mrtransform -template TEMPORARY_b0.nii.gz TEMPORARY_R_mask.nii.gz TEMPORARY_R_mask.nii.gz -interp nearest -force')
    
def cropDWI(dataDir):
    
    import os
    os.chdir(dataDir) 

    print('Cropping DWI to transformed template thalamus...')
    files = [f for f in os.listdir(dataDir) if os.path.isfile(os.path.join(dataDir, f))]
    index = 0
    for f in files:
        if f.startswith('TEMPORARY_DWI_0'):
            index = index + 1
            
    #Crop each DWI volume to TMP ... one at a time
    for i in range(index):
        
        dwiInFile = 'TEMPORARY_DWI_0'
        dwiOutFileLeft = 'TEMPORARY_Crop_L_0'
        dwiOutFileRight = 'TEMPORARY_Crop_R_0'
        
        if (i < 10):
            dwiInFile = dwiInFile + '00'
            dwiOutFileLeft = dwiOutFileLeft + '00'
            dwiOutFileRight = dwiOutFileRight + '00'
        elif (i < 100):
            dwiInFile = dwiInFile + '0'
            dwiOutFileLeft = dwiOutFileLeft + '0'
            dwiOutFileRight = dwiOutFileRight + '0'
            
        dwiInFile = dwiInFile + str(i) + '.nii.gz'    
        dwiOutFileLeft = dwiOutFileLeft + str(i) + '.nii.gz'
        dwiOutFileRight = dwiOutFileRight + str(i) + '.nii.gz'
        os.system('mrcrop '+dwiInFile+' '+dwiOutFileLeft+' -mask TEMPORARY_L_mask.nii.gz -force')
        os.system('mrcrop '+dwiInFile+' '+dwiOutFileRight+' -mask TEMPORARY_R_mask.nii.gz -force')
   
    #Combine cropped DWI volumes        
    os.system('mrconvert TEMPORARY_Crop_L_[].nii.gz TEMPORARY_dwiCropped_L.nii.gz -force')
    os.system('mrconvert TEMPORARY_Crop_R_[].nii.gz TEMPORARY_dwiCropped_R.nii.gz -force')
    
    #Convert to .mif (for Mrtrix processing)
    os.system('mrconvert TEMPORARY_dwiCropped_L.nii.gz TEMPORARY_dwiCropped_L.mif -force') 
    os.system('mrconvert TEMPORARY_dwiCropped_R.nii.gz TEMPORARY_dwiCropped_R.mif -force')

def generateODFs(dataDir):
    
    import os
   
    os.chdir(dataDir)
    print('Generating ODFs...')
    os.system('cp LIFUP*.bvec TEMPORARY.bvec')
    os.system('cp LIFUP*.bval TEMPORARY.bval')
    
    os.system('qboot --data=TEMPORARY_dwiCropped_L.nii.gz --mask=TEMPORARY_dwiCropped_L.nii.gz --bvecs=TEMPORARY.bvec --bvals=TEMPORARY.bval --npeaks=2 --ns=50 --savemeancoeff --lmax=6 --logdir=./TEMPORARY_QBI_logdir/')
    os.system('mv ./TEMPORARY_QBI_logdir/mean_SHcoeff.nii.gz TEMPORARY_QBI_L_ST_mask.nii.gz')
    os.system('rm -rf TEMPORARY_QBI_logdir*')
    
    os.system('qboot --data=TEMPORARY_dwiCropped_R.nii.gz --mask=TEMPORARY_dwiCropped_R.nii.gz --bvecs=TEMPORARY.bvec --bvals=TEMPORARY.bval --npeaks=2 --ns=50 --savemeancoeff --lmax=6 --logdir=./TEMPORARY_QBI_logdir/')
    os.system('mv ./TEMPORARY_QBI_logdir/mean_SHcoeff.nii.gz TEMPORARY_QBI_R_ST_mask.nii.gz')
    os.system('rm -rf TEMPORARY_QBI_logdir*')

def maskODFs(dataDir):
    
    #Get rid of ODFs outside of respective thalamic masks -- mostly for ODF display purposes
    
    import os

    os.chdir(dataDir)
    print('Cropping ODFs to respective thalamus masks...')

    os.system('mrcrop TEMPORARY_L_mask.nii.gz TEMPORARY_crop_L_ST_mask.nii.gz -mask TEMPORARY_L_mask.nii.gz -force')
    os.system('fslsplit TEMPORARY_QBI_L_ST_mask.nii.gz TEMPORARY_QBI_L_ST_mask -t')
    
    os.system('mrcrop TEMPORARY_R_mask.nii.gz TEMPORARY_crop_R_ST_mask.nii.gz -mask TEMPORARY_R_mask.nii.gz -force')
    os.system('fslsplit TEMPORARY_QBI_R_ST_mask.nii.gz TEMPORARY_QBI_R_ST_mask -t')

    nCoeffs = 28
    for j in range(nCoeffs):
        suffix = '00'+str(j)
        if j < 10:
            suffix = '0'+suffix
            
        fileName = 'TEMPORARY_QBI_L_ST_mask'+suffix+'.nii.gz'
        os.system('mrcalc TEMPORARY_crop_L_ST_mask.nii.gz '+fileName+' -mult '+fileName+' -force')
        
        fileName = 'TEMPORARY_QBI_R_ST_mask'+suffix+'.nii.gz'
        os.system('mrcalc TEMPORARY_crop_R_ST_mask.nii.gz '+fileName+' -mult '+fileName+' -force')
        
    os.system('mrconvert TEMPORARY_QBI_L_ST_mask[].nii.gz TEMPORARY_QBI_L_ST_masked.nii.gz -force')
    
    os.system('mrconvert TEMPORARY_QBI_R_ST_mask[].nii.gz TEMPORARY_QBI_R_ST_masked.nii.gz -force')