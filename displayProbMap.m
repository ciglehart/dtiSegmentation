close all;
clear all;

slice = 38;
plane = 3; %1-sag, 2-cor,3-ax
method =3; %1-CSD; 2-QBI; 3-STTHOMAS; 4-rsFMRI
arange = [10,48,25, 58];

threshold = 0.01;
grayRange = [0.25,0.95]; %Gray scale for the template image
saveFolder = '~/Documents/Research/code/dtiSegmentation/Images/02252019';
templateFile = '~/Documents/Research/template/templ_93x187x68.nii.gz';
mapDir = '~/Documents/Research/comparisonStudy/data/probMaps/';
addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122')

if (method == 1)
    load('/Users/charlesiglehart/Documents/School/Research/data/Monti/probMaps/ProbMap_0_50_300_7_L2_gAuto.mat');
elseif (method == 2)
    load(fullfile(mapDir,'qbProbMapSTmaskCombined.mat'));
elseif (method == 3)
    load(fullfile(mapDir,'stProbMapCombined.mat'));
elseif (method == 4)
    load(fullfile(mapDir,'rsProbMapCombined.mat'));
else
    disp('Select valid segmentation method.')
end

tmNii = load_untouch_nii(templateFile);

if (plane == 1)

    inds = fliplr(rot90(squeeze(probMap.indicator(slice,:,:))));
    tm = fliplr(rot90(squeeze(tmNii.img(slice,:,:))));
    cDat = fliplr(rot90(squeeze(probMap.c(slice,:,:,:))));
    mDat = fliplr(rot90(squeeze(probMap.maxMap(slice,:,:,:))));
elseif (plane == 2)
    inds = rot90(squeeze(probMap.indicator(:,slice,:)));
    tm = rot90(squeeze(tmNii.img(:,slice,:)));
     cDat = fliplr(rot90(squeeze(probMap.c(:,slice,:,:))));
     mDat = fliplr(rot90(squeeze(probMap.maxMap(:,slice,:,:))));
%     cDat = rot90(squeeze(probMap.c(:,slice,:,:)));
%     mDat = rot90(squeeze(probMap.maxMap(:,slice,:,:))); 
elseif (plane == 3)
    inds = fliplr(rot90(squeeze(probMap.indicator(:,:,slice))));
    tm = fliplr(rot90(squeeze(tmNii.img(:,:,slice))));
    cDat = fliplr(rot90(squeeze(probMap.c(:,:,slice,:))));
    mDat = fliplr(rot90(squeeze(probMap.maxMap(:,:,slice,:))));
else
    disp('Invalid plane selection. (1-Sagittal, 2-Coronal, 3-Axial)');
end

cmap = probMap.cMap;
tm = normalizeImage(tm,grayRange);

pMap = tm;
maxMap = tm;

overlay = find(inds > 0);
[row,col] = ind2sub(size(tm),overlay);

for i = 1:numel(overlay)
    
    if (norm(squeeze(cDat(row(i),col(i),:))) > threshold)
        pMap(row(i),col(i),:) = cDat(row(i),col(i),:);
        maxMap(row(i),col(i),:) = mDat(row(i),col(i),:);
    end
    
end

figure;
hold on;
imagesc(flipud(pMap));
axis equal;
% axis(arange);

figure;
hold on;
imagesc(flipud(maxMap));
axis equal;
% axis(arange);

