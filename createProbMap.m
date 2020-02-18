clear all;
close all;

labels = [2,4:13];
N = numel(labels);
outputName = 'stProbMapL';
fileTemplate = '~/Documents/Research/comparisonStudy/data/stSegmentation/caseNNN_ST_L_TMP.nii.gz';

runDirs = [1:7,10:17,19:21];
d = [93,187,68];
load('~/Documents/Research/comparisonStudy/code/cMap11.mat');

M = numel(runDirs);
c = cMap;
% c = resampleColormap(cMap,N);

counts = zeros(d(1),d(2),d(3),numel(runDirs));
cMap = zeros(d(1),d(2),d(3),3);
pMap = zeros(d(1),d(2),d(3),N);
indicator = zeros(d(1),d(2),d(3));
maxMap = cMap;
addpath('~/Documents/Research/comparisonStudy/code/dtiSegmentation/NIfTI_20140122');
outputDir = '~/Documents/Research/comparisonStudy/data/probMaps';

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
                    
                    pMap(i,j,k,l) = numel(find(inds == labels(l)));
                    
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
