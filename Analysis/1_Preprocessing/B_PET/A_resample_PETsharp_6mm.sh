#!/bin/bash

#Change all .nii in directory to 6mmREG
# and save in 6mmREG subdirctory


cd BASEPAH

#IDs - all RAW niftis
IDs==$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

#cd ..
#mkdir -p 6mmMNI/
cd /imaging_files/PETSharp/

for id in $IDs; do
	
	echo "processing ${id}"
	#register to 6mm SDBold image
	#flirt -in 2mm/${id} -ref 2mm/${id} -o 6mm/${id} -applyisoxfm 6
	flirt -in RAW/C${id}_y00_GM2016_mBP02T184swrc_fPT_rPETsh.nii -ref RAW/C${id}_y00_GM2016_mBP02T184swrc_fPT_rPETsh.nii -o 6mm/C${id}_y00_GM2016_mBP02T184swrc_fPT_6mm_rPETsh.nii -applyisoxfm 6
	gunzip 6mm/C${id}_y00_GM2016_mBP02T184swrc_fPT_6mm_rPETsh.nii.gz
	cp 6mm/C${id}_y00_GM2016_mBP02T184swrc_fPT_6mm_rPETsh.nii /imaging_files/PETSharp/6mm/C${id}_y00_GM2016_mBP02T184swrc_fPT_6mm_rPETsh.nii
	 
	#manually rename to 6mmMNI
done

cd PETPATH
chgrp -R lip-lndg . 
chmod -R 770 .