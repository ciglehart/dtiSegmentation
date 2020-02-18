function varargout = Thalamus_Clustering(varargin)
%
% Syntax :
% varargout = Thalamus_Clustering(odfFile, leftThalmask, rightThalmask, outThalClust)
%
%
% This function segments the left and the right thalamus in seven different groups
% of thalamic nuclei per hemisphere, according to the method developed by Battistella
% et al. in 'Brain Structure and Function' (2017).
%
% Input Parameters:
%   odfFile       : ODF image. 4D image containing the spherical harmonics
%                   coefficients.
%   leftThalmask  : Left thalamic mask (1 = left thalamus, 0 = otherwise).
%   rightThalmask : Right thalamic mask (1 = right thalamus, 0 = otherwise).
%   outThalClust  : name of the output NIFTI file
%
%
% Output Parameters:
%   outThalClust  : Thalamic clusters.
% 
%
%   Related reference:
%       G. Battistella*, E. Najdenovska*, P. Maeder, N. Ghazaleh, A. Daducci,
%       J.-P. Thiran, S. Jacquemont, C. Tuleasca, M. Levivier, M. Bach Cuadra*,
%       and Eleonora Fornari*
%       "Robust thalamic nuclei segmentation method based on local diffusion
%        magnetic resonance properties" 
%       Brain Structure & Function, 222(5):2203-2216, 2017
%
%       *Equally contributing authors
%
%_________________________________________________________________________
% Authors: Elena Najdenovska, Giovanni Battistella and Yasser Aleman Gomez
%
%   Medica Image Analysis Laboratory https://www.unil.ch/mial
%   Centre d'Imagerie BioMedical (CIBM)
%   Department of Radiology, Centre Hospitalier Universitaire Vaudois (CHUV) 
%   and University of Lausanne (UNIL), Lausanne, Switzerland
%
%   April 30th 2018
%   Version $1.0
%
%   Copyright (c) - All rights reserved. University of Lausanne. 2018.

%% ====================== Checking input parameters ===================== %

if nargin<3 % the indispensable input arguments are not provided
    error('Three inputs are mandatory');
else
    odfFile = varargin{1};
    leftThalmask = varargin{2};
    rightThalmask = varargin{3};
    
    if~exist(odfFile,'file')
        error('The ODF file does not exist');
    end
    if~exist(leftThalmask,'file')
        error('The left thalamus mask does not exist');
    end
    if~exist(rightThalmask,'file')
        error('The right thalamus mask does not exist');
    end
end

if nargin == 4
    outThalClust = varargin{4};
else
    outThalClust = 'thalamic_nuclei.nii.gz';     
end

%% ================= End of Checking input parameters =================== %

%% ========================== Main Program ============================== %

%% Initialization parameters
nc=11; % number of clusters

s_position=1; % scaling factor of the feature 'position'
s_odf=55;    % scaling factor of the feature 'ODF'; 55 for DWI with spatial resolution of ~2x2x2mm3, 100 for ~1x1x1mm3; to be determined in other cases
w_pos=0.5; % weighting factor of the feature 'position'
w_odf=0.5; % weighting factor of the feature 'ODF'

n_stat=2; % number of randomly initialized k-means using only the position as a feature

% Reading the ODF image
% h_odf=MRIread(odfFile);
% SH=h_odf.vol;
niiSH = load_untouch_nii(odfFile);
SH = niiSH.img;

disp(['Segmenting ',odfFile,' ...'])
%% ========================  LEFT Hemisphere =========================== %%
% Reading the left thalamic mask
% h_mt=MRIread(leftThalmask);
% mask_thalamus=h_mt.vol;
niiMask = load_untouch_nii(leftThalmask);
mask_thalamus = niiMask.img;

% Taking the ODF information inside the left thalamic mask only
SHt = SH.*repmat(mask_thalamus,[1 1 1 size(SH,4)]);

% % Linear Indices of each image coordinates 
[x,y,z]=size(mask_thalamus);
s=size(mask_thalamus);
dd=1:x*y*z;
[I,J,K] = ind2sub(s,dd);


% % Indices of the vectors non-zero values
ind_nz=find(mask_thalamus);


% % Non-Zero Values used for the custering
nzv(:,1)=I(ind_nz);  % x values
nzv(:,2)=J(ind_nz);  % y values
nzv(:,3)=K(ind_nz);  % z values

for k_nz=1:size(SHt,4)
    temp=SHt(:,:,:,k_nz);
    nzv(:,3+k_nz)=temp(ind_nz);
end


% % Scaling the data
nzv(:,1:3)=nzv(:,1:3).*s_position;
nzv(:,4:end)=nzv(:,4:end).*s_odf;


% % Determining the data-driven centroids
Ckm=zeros(nc,3,n_stat);

for i=1:n_stat
 [~,Ckm(:,:,i)]=kmeans(nzv(:,1:3),nc,'emptyaction','singleton');
end

C_group=centr_group(Ckm,nc);
centr=mean(C_group,3);
centr=round(centr);

for kk=1:nc
    for k_sh=1:size(SHt,4)
        centr(kk,3+k_sh)=SHt(centr(kk,1),centr(kk,2),centr(kk,3),k_sh);
    end
end

%scaling the centroids
centr(:,1:3)=centr(:,1:3).*s_position;
centr(:,4:end)=centr(:,4:end).*s_odf;


% % Final clustering with the data-driven centroids
[p]= kmeans_tns(nzv,nc,w_pos,w_odf,'distance','tns','Start',centr,'emptyaction','singleton');

 
% Results Storing
clustered_image=zeros(s);
clustered_image(ind_nz)=p;

Il = clustered_image;
 
clear h_mt mask_thalamus SHt nzv
%% ======================  End of Left Hemisphere ====================== %%

%% ========================  Right Hemisphere =========================== %%
% % Reading the right thalamic mask
% h_mt=MRIread(rightThalmask);
% mask_thalamus=h_mt.vol;
% 
% % Taking the ODF information inside the left thalamic mask only
% SHt = SH.*repmat(mask_thalamus,[1 1 1 size(SH,4)]);
% 
% 
% % % Linear Indices of each image coordinates 
% [x,y,z]=size(mask_thalamus);
% s=size(mask_thalamus);
% dd=1:x*y*z;
% [I,J,K] = ind2sub(s,dd);
% 
% 
% % % Indices of the vectors non-zero values
% ind_nz=find(mask_thalamus);
% 
% 
% % % Non-Zero Values used for the custering
% nzv(:,1)=I(ind_nz);  % x values
% nzv(:,2)=J(ind_nz);  % y values
% nzv(:,3)=K(ind_nz);  % z values
% 
% for k_nz=1:size(SHt,4)
%     temp=SHt(:,:,:,k_nz);
%     nzv(:,3+k_nz)=temp(ind_nz);
% end
% 
% 
% % % Scaling the data
% nzv(:,1:3)=nzv(:,1:3).*s_position;
% nzv(:,4:end)=nzv(:,4:end).*s_odf;
% 
% 
% % % Determining the data-driven centroids
% Ckm=zeros(nc,3,n_stat);
% 
% for i=1:n_stat
%  [~,Ckm(:,:,i)]=kmeans(nzv(:,1:3),nc,'emptyaction','singleton');
% end
% 
% C_group=centr_group(Ckm,7);
% centr=mean(C_group,3);
% centr=round(centr);
% 
% for kk=1:nc
%     for k_sh=1:size(SHt,4)
%         centr(kk,3+k_sh)=SHt(centr(kk,1),centr(kk,2),centr(kk,3),k_sh);
%     end
% end
% 
% % Scaling the centroids
% centr(:,1:3)=centr(:,1:3).*s_position;
% centr(:,4:end)=centr(:,4:end).*s_odf;
% 
% 
% % % Final clustering with the data-driven centroids
%     [p]=kmeans_tns(nzv,nc,w_pos,w_odf,'distance','tns','Start',centr,'emptyaction','singleton');
% 
%  % Results Storing
%  clustered_image=zeros(s);
%  clustered_image(ind_nz)=p;
% 
%  Ir = clustered_image;

 %% ===================== End of Right Hemisphere ====================== %%

 %% ================ Storing the Final Clustering Image ================ %%

%  indl = find(Il);
%  indr = find(Ir);
%  Ir(indr) = Ir(indr) + nc;
%  
%  ind2del = [indl(find(ismember(indl,indr)));indr(find(ismember(indr,indl)))];
%  Is = Il + Ir;
%  Is(ind2del) = 0;
% 
%  h_mt.vol=Is;
%  MRIwrite(h_mt,outThalClust,'double');

niiOut = niiMask;
niiOut.img = Il;
save_untouch_nii(niiOut,outThalClust);

%% ============= End of Storing the Final Clustering Image ============= %%

varargout{1} = outThalClust;
end
