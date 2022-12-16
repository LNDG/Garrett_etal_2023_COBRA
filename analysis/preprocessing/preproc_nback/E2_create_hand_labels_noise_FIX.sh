#!/bin/bash

# C${SUB}_nback_rejComps.txt for all the training subjects were created by hand - look through the ICAs and decide which components are artifacts


workingDIR=WORKDIR
mkdir -p ${workingDIR}/scripts/1-5_nback/6_FIX/rejcomps
cd ${workingDIR}/scripts/1-5_nback/6_FIX/rejcomps

#N45
subjID="003 006 007 009 010 011 013 014 015 016 017 018 019 021 022 023 024 025 026 027 028 029 030 031 032 033 035 036 037 038 039 040 041 043 044 045 046 047 049 050 051 052 053 054"

for subj in $subjID; do
		
	#place brackets at beginning and ending
	echo  "processing: C${subj}_nback_rejComps.txt"
	#echo -n "]" >> C${subj}_nback_rejComps.txt
	#sed -i  '1s/^/[\n/' C${subj}_nback_rejComps.txt
	#sed -i  's/n//g' C${subj}_nback_rejComps.txt
	
	## copy the manually created files to their respective subject directory
	cp C${subj}_nback_rejComps.txt ${workingDIR}/imaging_files/nback/preproc/C${subj}/FEAT.feat/hand_labels_noise.txt
		
done
