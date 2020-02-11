#/bin/sh

#mrtransform -template wmn.nii.gz t1.nii.gz t1.nii.gz -force

#antsRegistration -d 3 --float 0 --output [wmn_to_t1,wmn_to_t1.nii.gz] -t Rigid[0.1] -r [t1.nii.gz,wmn.nii.gz,1] --metric MI[t1.nii.gz,wmn.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox

#antsRegistration -d 3 --float 0 --output [template_to_wmn,template_to_wmn.nii.gz] -t Rigid[0.1] -r [wmn.nii.gz,template.nii.gz,1] --metric MI[wmn.nii.gz,template.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox

#antsApplyTransforms -d 3 -i maskTemplate.nii.gz -r wmn.nii.gz -o template_to_wmn_mask.nii.gz -t template_to_wmn0GenericAffine.mat -n NearestNeighbor -v

#antsApplyTransforms -d 3 -i template_to_wmn_mask.nii.gz -r t1.nii.gz -o template_to_t1_mask.nii.gz -t wmn_to_t10GenericAffine.mat -n NearestNeighbor -v

#mrcrop -mask template_to_t1_mask.nii.gz t1.nii.gz t1_crop.nii.gz -force

#mrcrop -mask template_to_wmn_mask.nii.gz wmn.nii.gz wmn_crop.nii.gz -force

#antsRegistration -d 3 --float 0 --output [wmn_to_t1_nonlinear,wmn_to_t1_nonlinear.nii.gz] --initial-moving-transform [t1_crop.nii.gz,wmn_crop.nii.gz,1] -t Rigid[0.1] --metric MI[t1_crop.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox -t Affine[0.1] --metric MI[t1_crop.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -f 8x4x2x1 -s 3x2x1x0vox -t SyN[0.1,3.0] --metric CC[t1_crop.nii.gz,wmn_crop.nii.gz,1,4] --convergence [100x50x20,1e-6,10] -f 4x2x1 -s 2x1x0vox -v

#antsApplyTransforms -d 3 -i wmn_crop.nii.gz -r t1_crop.nii.gz -o [wmn_to_t1_combined_warp.nii.gz,1] -t wmn_to_t1_nonlinear1Warp.nii.gz -t wmn_to_t1_nonlinear0GenericAffine.mat -n NearestNeighbor -v

#antsApplyTransforms -d 3 -i t1_crop.nii.gz -r wmn_crop.nii.gz -o [t1_to_wmn_combined_warp.nii.gz,1] -t [wmn_to_t1_nonlinear0GenericAffine.mat,1] -t wmn_to_t1_nonlinear1InverseWarp.nii.gz  -n NearestNeighbor -v

#antsRegistration -d 3 --float 0 --output [wmn_to_b0,wmn_to_b0.nii.gz] -t Rigid[0.1] -r [b0.nii.gz,wmn.nii.gz,1] --metric MI[b0.nii.gz,wmn.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox

#antsApplyTransforms -d 3 -i template_to_wmn_mask.nii.gz -r b0.nii.gz -o template_to_b0_mask.nii.gz -t wmn_to_b00GenericAffine.mat -n NearestNeighbor -v

#mrcrop -mask template_to_b0_mask.nii.gz b0.nii.gz b0_crop.nii.gz -force

#antsRegistration -d 3 --float 0 --output [wmn_to_b0_nonlinear,wmn_to_b0_nonlinear.nii.gz] --initial-moving-transform [b0_crop.nii.gz,wmn_crop.nii.gz,1] -t Rigid[0.1] --metric MI[b0_crop.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox -t Affine[0.1] --metric MI[b0_crop.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -f 8x4x2x1 -s 3x2x1x0vox -t SyN[0.1,3.0] --metric CC[b0_crop.nii.gz,wmn_crop.nii.gz,1,4] --convergence [100x50x20,1e-6,10] -f 4x2x1 -s 2x1x0vox -v

#antsApplyTransforms -d 3 -i wmn_crop.nii.gz -r b0_crop.nii.gz -o [wmn_to_b0_combined_warp.nii.gz,1] -t wmn_to_b0_nonlinear1Warp.nii.gz -t wmn_to_b0_nonlinear0GenericAffine.mat -n NearestNeighbor -v

#antsApplyTransforms -d 3 -i t1_crop.nii.gz -r b0_crop.nii.gz -o [t1_to_b0_combined_warp.nii.gz,1] -t wmn_to_b0_combined_warp.nii.gz -t t1_to_wmn_combined_warp.nii.gz -n NearestNeighbor -v

#antsRegistration -d 3 --float 0 --output [wmn_to_template_nonlinear,wmn_to_template_nonlinear.nii.gz] --initial-moving-transform [cropTemplate.nii.gz,wmn_crop.nii.gz,1] -t Rigid[0.1] --metric MI[cropTemplate.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -v -f 8x4x2x1 -s 3x2x1x0vox -t Affine[0.1] --metric MI[cropTemplate.nii.gz,wmn_crop.nii.gz,1,32,Regular,0.25] --convergence [1000x500x250x100,1e-6,10] -f 8x4x2x1 -s 3x2x1x0vox -t SyN[0.1,3.0] --metric CC[cropTemplate.nii.gz,wmn_crop.nii.gz,1,4] --convergence [100x50x20,1e-6,10] -f 4x2x1 -s 2x1x0vox -v

#antsApplyTransforms -d 3 -i wmn_crop.nii.gz -r cropTemplate.nii.gz -o [wmn_to_template_combined_warp.nii.gz,1] -t wmn_to_template_nonlinear1Warp.nii.gz -t wmn_to_template_nonlinear0GenericAffine.mat -n NearestNeighbor -v

antsApplyTransforms -d 3 -i b0_crop.nii.gz -r wmn_crop.nii.gz -o [b0_to_wmn_combined_warp.nii.gz,1] -t [wmn_to_b0_nonlinear0GenericAffine.mat,1] -t wmn_to_b0_nonlinear1InverseWarp.nii.gz -n NearestNeighbor -v

antsApplyTransforms -d 3 -i b0_crop.nii.gz -r cropTemplate.nii.gz -o [b0_to_template_combined_warp.nii.gz,1] -t wmn_to_template_combined_warp.nii.gz -t b0_to_wmn_combined_warp.nii.gz -n NearestNeighbor -v

antsApplyTransforms -d 3 -i b0_crop.nii.gz -r t1_crop.nii.gz -o [b0_to_t1_combined_warp.nii.gz,1] -t b0_to_wmn_combined_warp.nii.gz -t wmn_to_t1_combined_warp.nii.gz -n NearestNeighbor -v

antsApplyTransforms -d 3 -i t1_crop.nii.gz -r cropTemplate.nii.gz -o [t1_to_template_combinedwarp.nii.gz,1] -t wmn_to_template_combined_warp.nii.gz -t t1_to_wmn_combined_warp.nii.gz -n NearestNeighbor -v
