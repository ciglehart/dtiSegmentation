% close all;
clear all;

slice = 25;
plane = 3; %1-sag, 2-cor,3-ax
method = 4; %1-CSD; 2-QBI; 3-STTHOMAS; 4-rsFMRI
makeColorbar = 0;
saveImage = 0;

threshold = 0.0;
grayRange = [0.25,0.85]; %Gray scale for the template image
saveFolder = '/Users/charlesiglehart/Documents/School/Research/code/dtiSegmentation/Images/02252019';
% baseDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\probMaps';

if ispc
    templateDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\templates';
    mapDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\probMaps\';
else
    templateDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/templates';
    mapDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/probMaps';
end

templateFile = fullfile(templateDir,'crop_mni.nii.gz');

if (method == 1)
    load('/Users/charlesiglehart/Documents/School/Research/data/Monti/probMaps/ProbMap_0_50_300_7_L2_gAuto.mat');
    labels = {'MD','AV + VA','VLPd','VLa + VLPv + VPL','Pul Med','Pul Lat','Pul'};
elseif (method == 2)
    load(fullfile(mapDir,'dwiProbmap.mat'));
    labels = {'MD','AV + VA','VLPd','VLa + VLPv + VPL','Pul Med','Pul Lat','Pul'};
elseif (method == 3)
    load(fullfile(mapDir,'stProbMap.mat'));
    labels = {'AV','VA','VLa','VLPd','VLPv','VPL','Pul','LGN','MGN','CM','MD','Hb','MTT'};
elseif (method == 4)
    load(fullfile(mapDir,'rsFMRIProbMap.mat'));
else
    disp('Select valid segmentation method.')
end

tmNii = load_untouch_nii(templateFile);

if (plane == 1)
    im = fliplr(rot90(squeeze(probMap.p(slice,:,:))));
    inds = fliplr(rot90(squeeze(probMap.indicator(slice,:,:))));
    tm = fliplr(rot90(squeeze(tmNii.img(slice,:,:))));
    cDat = fliplr(rot90(squeeze(probMap.c(slice,:,:,:))));
    mDat = fliplr(rot90(squeeze(probMap.maxMap(slice,:,:,:))));
    fileString = ['Sag_slice',num2str(slice),'_method',num2str(method),'.png'];
elseif (plane == 2)
    im = rot90(squeeze(probMap.p(:,slice,:)));
    inds = rot90(squeeze(probMap.indicator(:,slice,:)));
    tm = rot90(squeeze(tmNii.img(:,slice,:)));
    cDat = fliplr(rot90(squeeze(probMap.c(:,slice,:,:))));
    mDat = fliplr(rot90(squeeze(probMap.maxMap(:,slice,:,:))));
    fileString = ['Cor_slice',num2str(slice),'_method',num2str(method),'.png'];
elseif (plane == 3)
    im = fliplr(rot90(squeeze(probMap.p(:,:,slice))));
    inds = fliplr(rot90(squeeze(probMap.indicator(:,:,slice))));
    tm = fliplr(rot90(squeeze(tmNii.img(:,:,slice))));
    cDat = fliplr(rot90(squeeze(probMap.c(:,:,slice,:))));
    mDat = fliplr(rot90(squeeze(probMap.maxMap(:,:,slice,:))));
    fileString = ['Ax_slice',num2str(slice),'_method',num2str(method),'.png'];
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

if saveImage
    saveas(gcf,fullfile(saveFolder,fileString));
end

figure;
hold on;
imagesc(flipud(maxMap));
axis equal;

if saveImage
    saveas(gcf,fullfile(saveFolder,fileString));
end

%Create colorbar plot
% N = 20;
% cols = [];
% n = (0:1:N)/N;
% n = [n',n',n'];
% width = 10;
% for i = 1:size(cmap,1)
%
%     c = repmat(cmap(i,:),N+1,1);
%     cols = [cols;c.*n];
%
% end
% t = repmat((1:size(cols,1))',1,width);
% offset = (N+1)/2;
%
% if makeColorbar
%     figure;
%     hold on;
%     imagesc(t);
%     colormap(cols);
%     axis equal;
%
%     for i = 1:numel(labels)
%
%         text(width + 5,offset + (i-1)*(N+1),labels{i},'FontWeight','bold');
%         if (i == 1)||(i == numel(labels))
%             text(-5,(i-1)*(N+1)+5,num2str(0),'FontWeight','bold');
%             text(-5,(i-1)*(N+1)+N-5,num2str(1),'FontWeight','bold');
%         end
%
%     end
%
%     set(gca,'XTickLabel','');
%     set(gca,'XTick','');
%     h = gca;
%     yLim = h.YLim;
%     h.YLim = [yLim(1)-5,yLim(2)+5];
%
%     if saveImage
%         saveas(gcf,fullfile(saveFolder,['Method_',num2str(method),'_colorbar.png']));
%     end
% end