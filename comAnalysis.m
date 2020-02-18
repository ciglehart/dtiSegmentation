close all;
segType = 'ST'; %QB, ST, RS
space = 'TMP'; %DWI, WMN, T1, TMP, MNI
grayRange = [0.25,0.75]; %Gray scale for the template image
sagSlice = 36;
sagRange = [60,160,18,60];
coSlice = 82;
coRange = [45,78,18,55];
axSlice = 34;
axRange = [45,90,40,125];

if strcmp(segType,'QB')
    nLabels = 7;
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/dtiSegmentation/segmentation';
elseif strcmp(segType,'ST')
    nLabels = 14;
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/stSegmentation';
elseif strcmp(segType,'RS')
    nLabels = 30;
    segmentationDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data/rsFMRISegmentation';
else
    nLabels = 12;
end

runDirs = [1:7,10:17,19:21];

templateDir = '/home/charlesiglehart/Documents/Research/template';
addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/dtiSegmentation/NIfTI_20140122');
load('/home/charlesiglehart/Documents/Research/comparisonStudy/code/cMap.mat');
c = resampleColormap(cMap,nLabels);

%Load desired base image
baseImage = 'templ_93x187x68.nii.gz';
baseNii = load_untouch_nii(fullfile(templateDir,baseImage));

centroids = zeros(3,nLabels,numel(runDirs));
for i = 1:numel(runDirs)
    
    fileName = ['case',num2str(runDirs(i)),'_',segType,'_L_',space,'.nii.gz'];
    nii = load_untouch_nii(fullfile(strrep(segmentationDir,'AAA',num2str(runDirs(i))),fileName));
    im = fix(nii.img);
    
    for j = 1:nLabels
        
        ind = find(im == j);
        [u,v,w] = ind2sub(size(im),ind);
        centroids(1,j,i) = mean(u(:));
        centroids(2,j,i) = mean(v(:));
        centroids(3,j,i) = mean(w(:));
        
    end
    
end

%Axial
figure;
hold on;
colormap(gray);
img = normalizeImage(squeeze(baseNii.img(:,:,axSlice)),grayRange);
imagesc(flipud(fliplr(rot90(img))));
for i = 1:nLabels
    for j = 1:numel(runDirs)
        if strcmp(segType,'RS')
            plot(size(im,1)-centroids(1,i,j),centroids(2,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'QB')
            plot(size(im,1)-centroids(1,i,j),centroids(2,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'ST')
            plot(size(im,1)-centroids(1,i,j),centroids(2,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        end
    end
end
axis equal;
axis(axRange);

%Sagittal
figure;
hold on;
colormap(gray);
img = rot90(normalizeImage(squeeze(baseNii.img(sagSlice,:,:)),grayRange),3);
imagesc(img);
for i = 1:nLabels
    for j = 1:numel(runDirs)
        if strcmp(segType,'RS')
            plot(size(im,2)-centroids(2,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'QB')
            plot(size(im,2)-centroids(2,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'ST')
            plot(size(im,2)-centroids(2,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        end
    end
end
axis equal;
axis(sagRange);

%Coronal
figure;
hold on;
colormap(gray);
img = rot90(normalizeImage(squeeze(baseNii.img(:,coSlice,:)),grayRange),3);
imagesc(img);
for i = 1:nLabels
    for j = 1:numel(runDirs)
        if strcmp(segType,'RS')
            plot(size(im,1)-centroids(1,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'QB')
            plot(size(im,1)-centroids(1,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        elseif strcmp(segType,'ST')
            plot(size(im,1)-centroids(1,i,j),centroids(3,i,j),'o','MarkerFaceColor',c(i,:),'MarkerSize',6,'MarkerEdgeColor','k');
        end
    end
end
axis equal;
axis(coRange);