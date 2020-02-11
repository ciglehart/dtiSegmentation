#!/bin/sh

cd $1
fslmaths 2-AV.nii.gz -mul 2 test2.nii.gz
fslmaths 4-VA.nii.gz -mul 4 test4.nii.gz
fslmaths 5-VLa.nii.gz -mul 5 test5.nii.gz
fslmaths 6-VLP.nii.gz -mul 6 test6.nii.gz
fslmaths 7-VPL.nii.gz -mul 7 test7.nii.gz
fslmaths 8-Pul.nii.gz -mul 8 test8.nii.gz
fslmaths 9-LGN.nii.gz -mul 9 test9.nii.gz
fslmaths 10-MGN.nii.gz -mul 10 test10.nii.gz
fslmaths 11-CM.nii.gz -mul 11 test11.nii.gz
fslmaths 12-MD-Pf.nii.gz -mul 12 test12.nii.gz
fslmaths 13-Hb.nii.gz -mul 13 test13.nii.gz
fslmaths test2.nii.gz -add test4.nii.gz -add test5.nii.gz -add test6.nii.gz -add test7.nii.gz -add test8.nii.gz -add test9.nii.gz -add test10.nii.gz -add test11.nii.gz -add test12.nii.gz -add test13.nii.gz combined.nii.gz
cp combined.nii.gz $2
rm -rf test*.nii.gz
