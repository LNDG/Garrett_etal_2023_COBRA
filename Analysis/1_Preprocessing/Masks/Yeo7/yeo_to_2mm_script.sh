#!/bin/bash 
# Convert Yeo files to 2mm
mri_vol2vol --mov Yeo2011_7Networks_MNI152_FreeSurferConformed1mm_LiberalMask.nii.gz --targ $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz --regheader --o Yeo2011_7Networks_MNI152_FreeSurferConformed2mm_LiberalMask.nii.gz --no-save-reg --interp nearest --precision uchar 

