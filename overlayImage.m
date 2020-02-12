caseNum = 1;
segType = 'ST'; %QB, ST, RS
space = 'MNI'; %DWI, WMN, T1, TMP, MNI
slice = 30;
dimension = 3; %1-sag, 2-cor, 3-ax
alpha = 1.0; %Transparency
edgeAlpha = 1.0;
rescaleFactor = 1;
grayRange = [0.25,0.85]; %Gray scale for the template image
saveImage = 0;

if ispc
    segmentationDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\segmentation\caseAAA';
    templateDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\templates';
    addpath('C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\code\dtiSegmentation\NIfTI_20140122');
else
    segmentationDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/segmentation/caseAAA';
    templateDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/templates';
    addpath('/Users/charlesiglehart/Documents/School/Research/code/dtiSegmentation/NIfTI_20140122');
end
load(fullfile(templateDir,'cMap.mat'));

%Load overlay image
fileName = ['case',num2str(caseNum),'_',segType,'_',space,'.nii.gz'];
overNii = load_untouch_nii(fullfile(strrep(segmentationDir,'AAA',num2str(caseNum)),fileName));

%Load desired base image
if (strcmp(space,'DWI'))
    baseImage = '';
elseif (strcmp(space,'WMN'))
    baseImage = 'wmnCrop.nii.gz';
elseif (strcmp(space,'T1'))
    baseImage = '';
elseif (strcmp(space,'TMP'))
    baseImage = 'templ_93x187x68.nii.gz';
elseif (strcmp(space,'MNI'))
    baseImage = 'crop_mni.nii.gz';
else
    disp('Invalid space selection.')
end

segmentationDir = strrep(segmentationDir,'AAA',num2str(caseNum));
baseNii = load_untouch_nii(fullfile(segmentationDir,baseImage));

if (dimension == 1)
    im = rot90(fliplr(squeeze(baseNii.img(slice,:,:))),3);
    overIm = rot90(fliplr(squeeze(overNii.img(slice,:,:))),3);
elseif (dimension == 2)
    im = rot90(fliplr(squeeze(baseNii.img(:,slice,:))),3);
    overIm = rot90(fliplr(squeeze(overNii.img(:,slice,:))),3);
else
    im = fliplr(rot90(fliplr(squeeze(baseNii.img(:,:,slice))),3));
    im = rot90(     fliplr(squeeze(baseNii.img(:,:,slice))),3); %For WMN
    overIm = rot90(fliplr(squeeze(overNii.img(:,:,slice))),3);
    
    if strcmp(segType,'RS')
        overIm = fliplr(overIm);
    end
end

overIm = fix(overIm);

%Normalize image values to specified scale
im = normalizeImage(im,grayRange);

%Resample colormap to match number of labels
N = fix(max(overNii.img(:)));
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