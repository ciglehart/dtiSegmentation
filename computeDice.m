function dice = computeDice(A,B,labelsA,labelsB)

nA = 1+numel(labelsA);
nB = 1+numel(labelsB);
dice = zeros(nA,nB);
dice(:,1) = [0;labelsA'];
dice(1,:) = [0,labelsB];

for i = 2:nA
    
    imA = 0*A;
    imA(find(A == dice(i,1))) = 1;
    
    for j = 2:nB
        
        imB = 0*B;
        imB(find(B == dice(1,j))) = 1;
        intersection = imA.*imB;
        dice(i,j) = 2*numel(find(intersection > 0))/(numel(find(imA > 0)) + numel(find(imB > 0)));
        
    end
    
end

end