BASEPATH='BASE';
PLSPATH=([BASEPATH, '/3_PLS/']);
MASKPATH=([BASEPATH, '/1_Preprocessing_fMRI/Masks/']);
% load results
load([PLSPATH, 'BGHAT_Morel/behavPLS_COBRA_N162_change32SDBOLD_tempPCAdim_change32_BGHATMorel_1000P1000B_BfMRIresult.mat']),
BSR=abs(result.boot_result.compare_u);

mask=S_load_nii_2d([MASKPATH, 'BGHAT_Morel_combined.nii']);
nifti=load_nii([MASKPATH, 'BGHAT_Morel_combined.nii']);
coords=intersect(st_coords, find(mask));
mask_orig=zeros(length(mask), 1);
mask_orig(coords)=BSR;
nifti.img=mask_orig;
save_nii(nifti, [PLSPATH, 'SD_2mm/BGHAT_Morel/BSR_behavPLS_COBRA_N162_change32SDBOLD_tempPCAdim_change32_BGHATMorel.nii']);
