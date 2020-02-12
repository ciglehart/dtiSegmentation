clear all;
close all;

N = numel([2,4,5,6,7,8,9,10,11,12,13,14]);
runDirs = [1:7,10:17,19:21];
d = [70,102,61];
outputName = 'stProbMap';

tau = 0.01;
M = numel(runDirs);
if ispc
    load('C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\cmap.mat');
else
    load('/Users/charlesiglehart/Documents/School/Research/data/Monti/templates/cmap.mat');
end
c = resampleColormap(cMap,N);
counts = zeros(d(1),d(2),d(3),numel(runDirs));
cMap = zeros(d(1),d(2),d(3),3);
pMap = zeros(d(1),d(2),d(3),N);
indicator = zeros(d(1),d(2),d(3));
maxMap = cMap;

if ispc
    fileTemplate = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\reordered\caseNNN\caseNNNTM.nii.gz';
    addpath('C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation\NIfTI_20140122');
    outputDir = 'C:\Users\z1102497\Desktop\Main\Misc\dwiSegmentation';
else
    fileTemplate = '/Users/charlesiglehart/Documents/School/Research/data/Monti/segmentation/caseNNN/caseNNN_ST_MNI.nii.gz';
    addpath('/Users/charlesiglehart/Documents/School/Research/code/dtiSegmentation/NIfTI_20140122');
    outputDir = '/Users/charlesiglehart/Documents/School/Research/data/Monti/probMaps';
end

for j = 1:M
    
    fileName = fullfile(strrep(fileTemplate,'NNN',num2str(runDirs(j))));
    nii = load_untouch_nii(fileName);
    counts(:,:,:,j) = nii.img;
    
end

m = max(counts,[],4);

for i = 1:size(counts,1)
    for j = 1:size(counts,2)
        for k = 1:size(counts,3)
            
            if (m(i,j,k) > 0)
                
                inds = squeeze(counts(i,j,k,:));
                indicator(i,j,k) = 1;
                
                for l = 1:N
                    
                    pMap(i,j,k,l) = numel(find(inds == l));
                    
                end
                
                maxMap(i,j,k,:) = c(min(find(squeeze(pMap(i,j,k,:)) == max(squeeze(pMap(i,j,k,:))))),:);
                
                weights = repmat(squeeze(pMap(i,j,k,:)),1,3);
                cMap(i,j,k,:) = sum(weights.*c);
                
            end
            
        end
    end
end

probMap.p = pMap/M;
probMap.c = cMap/M;
probMap.cMap = c;
probMap.indicator = indicator;
probMap.maxMap = maxMap;

saveFile = fullfile(outputDir,[outputName,'.mat']);
save(saveFile,'probMap');
