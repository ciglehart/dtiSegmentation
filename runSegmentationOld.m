addpath('../NIfTI_20140122');

caseNums = [1:7,10:17,19:21];

nReps = 10;


for i = 1:numel(caseNums)
    
    disp(caseNums(i));
   
    maskFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_crop_L_ST_mask.nii.gz'];
    qbFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_L_ST_masked.nii.gz'];
    fileOut = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_L_seg_11.nii.gz'];
    seedCentroids = calculateSeedCentroids(maskFile,nReps,11);
    clusters = dtiSegmentation(maskFile,qbFile,seedCentroids,fileOut);
    
    disp(sum(clusters));
    
    maskFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_crop_R_ST_mask.nii.gz'];
    qbFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_R_ST_masked.nii.gz'];
    fileOut = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_R_seg_11.nii.gz'];
    seedCentroids = calculateSeedCentroids(maskFile,nReps,11);
    clusters = dtiSegmentation(maskFile,qbFile,seedCentroids,fileOut);
    
    disp(sum(clusters));    
    
end



