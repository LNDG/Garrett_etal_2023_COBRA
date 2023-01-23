#!/bin/bash

# C${SUB}_nback_rejComps.txt for all the training subjects were created by hand - look through the ICAs and decide which components are artifacts


workingDIR=WORKDIR
mkdir -p ${workingDIR}/scripts/1-5_nback/6_FIX/rejcomps
cd ${workingDIR}/scripts/1-5_nback/6_FIX/rejcomps

#IDs
subjID=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

for subj in $subjID; do
		
	#place brackets at beginning and ending
	echo  "processing: C${subj}_nback_rejComps.txt"
	#echo -n "]" >> C${subj}_nback_rejComps.txt
	#sed -i  '1s/^/[\n/' C${subj}_nback_rejComps.txt
	#sed -i  's/n//g' C${subj}_nback_rejComps.txt
	
	## copy the manually created files to their respective subject directory
	cp C${subj}_nback_rejComps.txt ${workingDIR}/imaging_files/nback/preproc/C${subj}/FEAT.feat/hand_labels_noise.txt
		
done
