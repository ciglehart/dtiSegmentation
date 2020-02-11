close all;
clear all;
clc;

codeDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/code';
addpath(codeDir);

addpath('/home/charlesiglehart/Documents/Research/comparisonStudy/code/NIfTI_20140122');

dataDir = '/home/charlesiglehart/Documents/Research/comparisonStudy/data';
qbPath = fullfile(dataDir,'dtiSegmentation','segmentation');
stPath = fullfile(dataDir,'stSegmentation');
rsPath = fullfile(dataDir,'rsFMRISegmentation');

qb_st_l_Dice = [];
qb_st_r_Dice = [];
qb_rs_l_Dice = [];
qb_rs_r_Dice = [];
rs_st_l_Dice = [];
rs_st_r_Dice = [];

labelsST = [2,4:13];
labelsQB = 1:7;
labelsRS = 1:30;

cases = [1:7,10:17,19:21];

for i = cases
   
    caseStr = num2str(i);
    disp(caseStr);
    qb_l_nii = load_untouch_nii(fullfile(qbPath,['case',caseStr,'_QB_L_DTI.nii.gz']));
    qb_r_nii = load_untouch_nii(fullfile(qbPath,['case',caseStr,'_QB_R_DTI.nii.gz']));
    rs_l_nii = load_untouch_nii(fullfile(rsPath,['case',caseStr,'_RS_L_DTI.nii.gz']));
    rs_r_nii = load_untouch_nii(fullfile(rsPath,['case',caseStr,'_RS_R_DTI.nii.gz']));    
    st_l_nii = load_untouch_nii(fullfile(stPath,['case',caseStr,'_ST_L_DTI.nii.gz']));
    st_r_nii = load_untouch_nii(fullfile(stPath,['case',caseStr,'_ST_R_DTI.nii.gz'])); 
    
    d = computeDice(qb_l_nii.img,rs_l_nii.img,labelsQB,labelsRS);
    qb_rs_l_Dice = [qb_rs_l_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM>
    
    d = computeDice(qb_r_nii.img,rs_r_nii.img,labelsQB,labelsRS);
    qb_rs_r_Dice = [qb_rs_r_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM>   
    
    d = computeDice(qb_l_nii.img,st_l_nii.img,labelsQB,labelsST);
    qb_st_l_Dice = [qb_st_l_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM>
    
    d = computeDice(qb_r_nii.img,st_r_nii.img,labelsQB,labelsST);
    qb_st_r_Dice = [qb_st_r_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM> 
    
    rs_l_nii = load_untouch_nii(fullfile(rsPath,['case',caseStr,'_RS_L_T1W.nii.gz']));
    rs_r_nii = load_untouch_nii(fullfile(rsPath,['case',caseStr,'_RS_R_T1W.nii.gz']));    
    st_l_nii = load_untouch_nii(fullfile(stPath,['case',caseStr,'_ST_L_T1W.nii.gz']));
    st_r_nii = load_untouch_nii(fullfile(stPath,['case',caseStr,'_ST_R_T1W.nii.gz'])); 
    
    d = computeDice(rs_l_nii.img,st_l_nii.img,labelsRS,labelsST);
    rs_st_l_Dice = [rs_st_l_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM>
    
    d = computeDice(rs_r_nii.img,st_r_nii.img,labelsRS,labelsST);
    rs_st_r_Dice = [rs_st_r_Dice,max(d(2:end,2:end)')']; %#ok<*AGROW,*UDIM>     
    
end

% 
% for n = 1:numel(dirContents)
%     
%     if ~strcmp(dirContents(n).name(1),'.')
%         
%         disp(dirContents(n).name);
%         
% %         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_L_FS.nii.gz'));
% %         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','QBI_singleShell_L_FS_segmentation.nii.gz'));
% %         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
% %         qbi_L_Dice = [qbi_L_Dice,max(d(2:end,2:end)')'];
% %         
% %         
% %         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_R_FS.nii.gz'));
% %         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','QBI_singleShell_R_FS_segmentation.nii.gz'));
% %         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
% %         qbi_R_Dice = [qbi_R_Dice,max(d(2:end,2:end)')'];
% %         
% %         
% %         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_L_TM.nii.gz'));
% %         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','CSD_singleShell_L_TM_segmentation.nii.gz'));
% %         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
% %         csd_SS_L_Dice = [csd_SS_L_Dice,max(d(2:end,2:end)')'];
% %         
% %         
% %         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_R_TM.nii.gz'));
% %         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','CSD_singleShell_R_TM_segmentation.nii.gz'));
% %         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
% %         csd_SS_R_Dice = [csd_SS_R_Dice,max(d(2:end,2:end)')'];
%         
%         
%         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_L_TM.nii.gz'));
%         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','PC_L_TM_segmentation.nii.gz'));
%         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
%         l_Dice = [l_Dice,max(d(2:end,2:end)')'];
%         
%         
%         tmNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','fused_R_TM.nii.gz'));
%         segNii = load_untouch_nii(fullfile(dataDir,dirContents(n).name,'DiffPreproc','dwiProcessing','PC_R_TM_segmentation.nii.gz'));
%         d = computeDice(tmNii.img,segNii.img,labelsTM,labelsDWI);
%         r_Dice = [r_Dice,max(d(2:end,2:end)')'];
%         
%         
%     end
%     
% end