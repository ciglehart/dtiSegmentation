function [clusters] = clustering(points,SH,seedCentroids)

%Turn off warnings for a moment
warning('off','all');

alpha = 0.5;
voxelCentroids = seedCentroids;

%Settings
nPoints = size(points,1);
nClusters = size(voxelCentroids,1);
%Convergence criterion
tolerance = 1e-5;
delta = tolerance + 1;
maxIterations = 1e3;
nIterations = 0;

shCentroids = zeros(nClusters,size(SH,2));

%Assign initial labels based on voxelCentroids
vDistance = zeros(nPoints,nClusters);
shDistance = zeros(nPoints,nClusters);

for i = 1:nClusters
    
    centroid = repmat(voxelCentroids(i,:),nPoints,1);
    vDistance(:,i) = sum((centroid - points).^2,2);
    
end

[~,clusters] = min(vDistance,[],2);

%Adjust SH coefficient magnitidues
gamma = 55;
SH = gamma*SH;

%Perform clustering
while (delta > tolerance)&&(nIterations < maxIterations)
    
    %Compute position/ODF distances to centroids
    
        for i = 1:nClusters
            ind = find(clusters == i);
            
            %Voxel distance
            voxelCluster = points(ind,:);
            voxelCentroids(i,:) = mean(voxelCluster,1);
            vCentroid = repmat(voxelCentroids(i,:),nPoints,1);
            vDistance(:,i) = sqrt(sum((vCentroid - points).^2,2));
            
            %SH distance
            shCluster = SH(ind,:);
            shCentroids(i,:) = mean(shCluster,1);
            shCentroid = repmat(shCentroids(i,:),nPoints,1);
            shDistance(:,i) = sqrt(sum((shCentroid - SH).^2,2));
        end
        

    
    %Compute total distance as a weighted sum. Assign new clusters.
    totalDistance = alpha*vDistance + (1-alpha)*shDistance;
    minima = min(totalDistance,[],2);
    difference = totalDistance - repmat(minima,1,nClusters) + 1;
    difference(difference > 1) = 0;
    difference = difference.*repmat(1:nClusters,nPoints,1);
    clusters = sum(difference,2);
    
    %Compute new centroids and max difference from previous centroids.
    for i = 1:nClusters
        
        %Compute new spatial centroids
        cluster = points((clusters == i),:);
        newVoxelCentroids(i,:) = mean(cluster,1); %#ok<*AGROW>
        
    end
    
    delta = max(sqrt(sum((newVoxelCentroids - voxelCentroids).^2,2)));
    nIterations = nIterations + 1;
    
end

%Compute SSE
% SSE = 0;
% for i = 1:nClusters
%     
%     voxels = points((clusters == i),:);
%     odf = SH((clusters == i),:);
%     
%     vMean = mean(voxels,1);
%     oMean = mean(odf,1);
%     
%     vMean = repmat(vMean,size(voxels,1),1);
%     oMean = repmat(oMean,size(odf,1),1);
% 
%     vDist = sum(sum((voxels - vMean).^2));
%     oDist = sum(sum((odf - oMean).^2));
% 
%     SSE = SSE + alpha*vDist + (1-alpha)*oDist;
%     
% end

warning('off','all');
end