function [Cgroup] = centr_group(Ckm,nc)
%
% Syntax :
% [Cgroup] = centr_group(Ckm,nc)
%
%
% This function groups the corresponding centroids resulting from the iterative
% k-means runs with random initialization and using only the voxel position as
% feature. This is done by reordering the lines of the Ckm matrix containg the
% centroids randomly labeled from the k-means runs.
%
% Input Parameters:
%   Ckm  : a nc-by-3-by-n_stat data matrix containing the centroids resulting
%          from all the randomly initialized k-means using the voxel position
%          as the only feature
%          (n_stat: number of randomly initialized k-means, defined in the
%           function Thalamus_Clustering.m)
%   nc   : number of clusters
%
%
% Output Parameter:
%   Cgroup  : the reordered nc-by-3-by-n_stat data matrix where each line
%             corresponds to a centroid that represents one unique label of the
%             clustering resulting from the randomly-initialized k-means.
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
% Authors: Elena Najdenovska and Giovanni Battistella
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



Cgroup=Ckm(:,:,1);
 
 for ii=2:size(Ckm,3)
     
     Cii=Ckm(:,:,ii);
     Cm=mean(Cgroup(:,:,1:(ii-1)),3);

     % Mutual distances between the centroids from one k-means run and the
     % mean centroids obtained from the previous k-means run already ordered
     D=zeros(nc,nc);
     for jj=1:nc
         for kk=1:nc
             D(jj,kk)=sum((Cii(jj,1:3)-Cm(kk,1:3)).^2).^(0.5);
         end
     end
     
     % reordering the lines with respect the minumum mutual distance
     [ind_current,ind_first]=choose_minDist(D);   
     Cgroup(ind_first,:,ii)=Ckm(ind_current,:,ii);
     
     clear Cii
     
end

end