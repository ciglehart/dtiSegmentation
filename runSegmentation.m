close all;
clear all;
clc;

dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation';
codeDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/code';
addpath(codeDir);
addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122');

d = dir(dataDir);

for i = 1:numel(d)
    
    if ~(strcmp(d(i).name(1),'.')||strcmp(d(i).name(1),'segmentation'))
           
            disp(d(i).name);
            inputPath = fullfile(dataDir,d(i).name);
            cd(inputPath);
            
            maskFileL = 'TEMPORARY_crop_L_ST_mask.nii.gz';
            maskFileR = 'TEMPORARY_crop_R_ST_mask.nii.gz';
            odfFileL = 'TEMPORARY_QBI_L_ST_masked.nii.gz';
            odfFileR = 'TEMPORARY_QBI_R_ST_masked.nii.gz';
            outFileL  = fullfile(inputPath,'QBI_L_segmentation_ST_mask_11.nii.gz');
            outFileR  = fullfile(inputPath,'QBI_R_segmentation_ST_mask_11.nii.gz');
            
            [~] = Thalamus_Clustering(odfFileL,maskFileL,maskFileL,outFileL);
            [~] = Thalamus_Clustering(odfFileR,maskFileR,maskFileR,outFileR);
            
            cd(codeDir);

    end
    
end