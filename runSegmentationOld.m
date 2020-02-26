addpath('NIfTI_20140122');

caseNums = [1:7,10:17,19:21];
nReps = 5000;
allCentroidsL = zeros(11,3,18);
allCentroidsR = zeros(11,3,18);

for i = 1:numel(caseNums)
    disp(i);
       
    maskFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_crop_L_ST_mask.nii.gz'];
    qbFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_L_ST_masked.nii.gz'];
    fileOut = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_L_seg_11.nii.gz'];
    
    seedCentroids = zeros(11,3);
    n = 0;
    while (n < nReps)
        centroids = calculateSeedCentroids(maskFile,1,11);
        if ~isnan(sum(centroids(:)))
            n = n+1;
            seedCentroids = seedCentroids + centroids;
        end
    end
    seedCentroids = seedCentroids/n;
    allCentroidsL(:,:,i) = seedCentroids;
    clusters = dtiSegmentation(maskFile,qbFile,seedCentroids,fileOut);
    
    maskFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_crop_R_ST_mask.nii.gz'];
    qbFile = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_R_ST_masked.nii.gz'];
    fileOut = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNums(i)),'/TEMPORARY_QBI_R_seg_11.nii.gz'];

    seedCentroids = zeros(11,3);
    n = 0;
    while (n < nReps)
        centroids = calculateSeedCentroids(maskFile,1,11);
        if ~isnan(sum(centroids(:)))
            n = n+1;
            seedCentroids = seedCentroids + centroids;
        end
    end
    seedCentroids = seedCentroids/n;
    allCentroidsR(:,:,i) = seedCentroids;
    clusters = dtiSegmentation(maskFile,qbFile,seedCentroids,fileOut);
    
    
end



