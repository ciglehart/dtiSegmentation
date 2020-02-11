function [ind_corr,ind_init] = choose_minDist(D)
%
% Syntax :
% [ind_current,ind_first] = choose_minDist(D)
%
%
% This function determines the correct order of lines of the data matrix
% containing the centroids extracted from all the k-means runs with random
% initialization and using the voxel position as the only feature
%
%
% Input Parameters:
%   D : a nc-by-nc data matrix containing all mutual distances between the
%       centroids from one randomly-initialized k-means and the  mean centroids 
%       taken as a reference
%        (nc: number of clusters)
%          
%
% Output Parameter:
%   ind_corr  : the correct order of the lines of the matrix containing the
%               centroids
%   ind_corr  : the initial order of the lines of the matrix containing the
%               centroids
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

 ind_corr=1:size(D,1);
 ind_init=[];
 
 min_glob=1000;
 IRM=perms(ind_corr);
 
 for i=1:size(IRM,1)
     
     ind_first_t=IRM(i,:);     
     min = D(1,ind_first_t(1))+D(2,ind_first_t(2))+D(3,ind_first_t(3))+ ...
         + D(4,ind_first_t(4))+D(5,ind_first_t(5))+D(6,ind_first_t(6))+ ...
         + D(7,ind_first_t(7));
     
     if (min<min_glob)
         min_glob=min;
         ind_init=ind_first_t;
     end
 end
 
end