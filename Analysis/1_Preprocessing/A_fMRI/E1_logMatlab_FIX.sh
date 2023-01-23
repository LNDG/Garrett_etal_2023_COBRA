#!/bin/bash

# This script checks if FIX was run for all subjects

# FIX expects the ICA folders to be called 'filtered_func_data.ica'

# !!!!! adjust path!!!! 
workingDIR=WORKDIR
cd ${workingDIR}/imaging_files/nback/preproc

subjID=`ls | grep "C*"`

for subj in $subjID; do
		
	SUBDIR=${workingDIR}/imaging_files/nback/preproc/${subj}/FEAT.feat/fix
		
		if [ -d ${SUBDIR} ]; then
			echo fix
			cd $SUBDIR
		else
			echo ${subj}/FEAT.feat/fix does not exist
		fi
		
		#cat logMatlab.txt | tail -n 1
		if grep -q End "${SUBDIR}/logMatlab.txt"; then
			echo yes
		else
			echo ${subj} did not finish properly
		fi
	
done

