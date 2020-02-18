function clusters = dtiSegmentation(maskFile,qbFile,seedCentroids,fileOut)

addpath('../NIfTI_20140122');

nNuclei = 11;

niiSH = load_untouch_nii(qbFile);
niiTemplate1 = load_untouch_nii(maskFile);

ind = find(niiTemplate1.img == 1);
[subX,subY,subZ] = ind2sub(size(niiTemplate1.img),ind);
points = [subX,subY,subZ];

SH = zeros(numel(subX),size(niiSH.img,4));

for i = 1:numel(ind)
    SH(i,:) = squeeze(niiSH.img(subX(i),subY(i),subZ(i),:));
end

[clusters] = clustering(points,SH,seedCentroids);

niiOut = niiTemplate1;
ind = find(niiTemplate1.img == 1);
[subX,subY,subZ] = ind2sub(size(niiTemplate1.img),ind);

niiOut.img = zeros(size(niiOut.img));

for n = 1:nNuclei
    
    ind = find(clusters == n);
    for i = 1:numel(ind)
        niiOut.img(subX(ind(i)),subY(ind(i)),subZ(ind(i))) = n;
    end
    
    
end

niiOut.img = single(niiOut.img);
% 
% niiOut.fileprefix = fileString;
save_untouch_nii(niiOut,fileOut);

end