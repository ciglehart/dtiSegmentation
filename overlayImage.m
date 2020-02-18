caseNum = 1;

space = 'DWI'; %DWI, WMN, T1, TMP, MNI
slice = 10;
dimension = 3; %1-sag, 2-cor, 3-ax
alpha = 1.0; %Transparency
edgeAlpha = 1.0;
rescaleFactor = 1;
grayRange = [0.25,0.85]; %Gray scale for the template image
saveImage = 0;

% templateDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/templates';
addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122');
load('/home/charlesiglehart/Documents/Research/comparisonStudy/code/cMap.mat');

%Load desired base image
if (strcmp(space,'DWI'))
    baseImage = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNum),'/registration/b0_crop_1mm.nii.gz'];
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation';
    segType = 'QB'; %QB, ST, RS
    N = 7;
elseif (strcmp(space,'WMN'))
    baseImage = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNum),'/registration/wmn.nii.gz'];
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/stSegmentation';
    N = 14;
    segType = 'ST'; %QB, ST, RS
elseif (strcmp(space,'T1'))
    baseImage = ['/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/case',num2str(caseNum),'/registration/t1_crop.nii.gz'];
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/rsFMRISegmentation';
    N = 30;
    segType = 'RS'; %QB, ST, RS
end

%Load overlay image
fileName = ['case',num2str(caseNum),'_',segType,'_L_',space,'.nii.gz'];
overNii = load_untouch_nii(fullfile(strrep(segmentationDir,'AAA',num2str(caseNum)),fileName));
baseNii = load_untouch_nii(baseImage);

if (dimension == 1)
    im = single(rot90(fliplr(squeeze(baseNii.img(slice,:,:))),3));
    overIm = rot90(fliplr(squeeze(overNii.img(slice,:,:))),3);
elseif (dimension == 2)
    im = single(rot90(fliplr(squeeze(baseNii.img(:,slice,:))),3));
    overIm = rot90(fliplr(squeeze(overNii.img(:,slice,:))),3);
else
    im = fliplr(rot90(fliplr(squeeze(baseNii.img(:,:,slice))),3));
    im = single(rot90(     fliplr(squeeze(baseNii.img(:,:,slice))),3)); %For WMN
    overIm = rot90(fliplr(squeeze(overNii.img(:,:,slice))),3);
    
    if strcmp(segType,'RS')
        overIm = fliplr(overIm);
    end
end

overIm = fix(overIm);

%Normalize image values to specified scale
im = normalizeImage(im,grayRange);

%Resample colormap to match number of labels
% N = fix(max(overNii.img(:)));
c = resampleColormap(cMap,N);

nonzero = find(overIm > 0);
[row,col] = ind2sub(size(overIm),nonzero);

combinedImage = im;
for i = 1:numel(nonzero)    

        combinedImage(row(i),col(i),:) = alpha*c(overIm(row(i),col(i)),:) + (1-alpha)*im(row(i),col(i));
    
end

combinedImage = imresize(combinedImage,rescaleFactor);

imagesc(combinedImage);
axis equal;