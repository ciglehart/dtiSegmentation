function output = resampleColormap(cMap,M)

%Assumes cMap is an Nx3 array
%M: size of resampled colormap

N = size(cMap,1);
x = 1:N;
m = (N-1)/(M-1);
b = (M-N)/(M-1);
xInt = m*(1:M)+b;

output = zeros(M,3);
output(:,1) = interp1(1:N,cMap(:,1),xInt)';
output(:,2) = interp1(1:N,cMap(:,2),xInt)';
output(:,3) = interp1(1:N,cMap(:,3),xInt)';

output(1,:) = cMap(1,:);

end