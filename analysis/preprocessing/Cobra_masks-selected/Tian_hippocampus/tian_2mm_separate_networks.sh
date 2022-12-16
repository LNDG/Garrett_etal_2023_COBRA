#!/bin/bash
# 
#separate all parcellations

mri_vol2vol --mov Tian_Subcortex_S1_3T_1mm.nii.gz  --targ $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz --regheader --o net/Tian_Subcortex_S1_3T_2mm.nii --no-save-reg --interp nearest --precision uchar 


mkdir -p net
for f in Tian_Subcortex_S1_3T_2mm.nii.gz; do
    b=`basename $f`
    let i=1
    max=`fslstats $f -R | awk '{printf("%d", $2)}'`
    while [ $i -le $max ]; do
        mkdir -p net/$i
        f2=net/$i/net${i}_${b}
        fslmaths $f -thr $i -uthr $i $f2 
        let i=$i+1
    done
done

fslmerge -t Tian_Subcortex_S1_3T_2mm_combined.nii.gz `ls net/*/*.nii.gz`
flirt -in Tian_Subcortex_S1_3T_2mm_combined.nii.gz -ref Tian_Subcortex_S1_3T_2mm_combined.nii.gz -out Tian_Subcortex_S1_3T_2mm_combinednii.gz -applyxfm