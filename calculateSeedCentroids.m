function seedCentroids = calculateSeedCentroids(maskFile,nIterations,nNuclei)

warning('off','all');

niiTemplate1 = load_untouch_nii(maskFile);

ind = find(niiTemplate1.img == 1);
[subX,subY,subZ] = ind2sub(size(niiTemplate1.img),ind);
points = [subX,subY,subZ];

for i = 1:numel(nNuclei)
    
    seedCentroids = zeros(nNuclei(i),3);
    
    for j = 1:nIterations
        
        [~,C] = kmeans(points,nNuclei(i));
        C = sortrows(C,1);
        seedCentroids = seedCentroids + C;
        
    end
    
    seedCentroids = seedCentroids/nIterations;
    
end

end