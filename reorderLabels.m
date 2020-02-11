clear all;
clc;

addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122');
casePath = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case';
runDirs = [1:7,10:17,19:21];

newLabels = [5	4	3	2	6	1	7;
6	5	7	1	2	4	3;
3	7	2	1	5	4	6;
3	2	6	7	1	5	4;
5	2	4	6	7	1	3;
6	5	7	2	3	1	4;
4	7	3	2	5	6	1;
6	1	4	3	7	2	5;
7	5	4	1	3	6	2;
2	7	6	1	5	4	3;
3	6	2	5	7	1	4;
6	2	7	5	4	3	1;
5	7	6	4	3	1	2;
2	6	1	5	5	3	4;
3	4	5	2	1	6	7;
3	1	5	2	6	7	4;
1	4	7	2	5	3	6;
3	5	6	7	2	1	4];

for i = 1:numel(runDirs)
   
    thisCase = [casePath,num2str(runDirs(i))];
    cd(thisCase);
    fileName = 'QBI_R_segmentation.nii.gz';
    nii = load_untouch_nii(fileName);
    
    ind1 = find(nii.img == 1);
    ind2 = find(nii.img == 2);
    ind3 = find(nii.img == 3);
    ind4 = find(nii.img == 4);
    ind5 = find(nii.img == 5);
    ind6 = find(nii.img == 6);
    ind7 = find(nii.img == 7);
   
    niiOut = nii;
    imgOut = 0*nii.img;
    
    imgOut(ind1) = newLabels(i,1);
    imgOut(ind2) = newLabels(i,2);
    imgOut(ind3) = newLabels(i,3);
    imgOut(ind4) = newLabels(i,4);
    imgOut(ind5) = newLabels(i,5);
    imgOut(ind6) = newLabels(i,6);
    imgOut(ind7) = newLabels(i,7);
    
    niiOut.img = imgOut;
    outName = ['re_',fileName];
    save_untouch_nii(niiOut,outName);

end


