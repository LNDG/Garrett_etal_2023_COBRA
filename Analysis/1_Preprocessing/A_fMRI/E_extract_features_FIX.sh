#!/bin/bash
##Extract features for FIX: do this for all SIDects (training set & SID to be denoised)

#Set the base directory
BD=BASEDIR

# Set the working directory for the current project
WD=${BD}/COBRA
ICAD=${WD}/imaging_files/nback/preproc
#N183
subjectID==$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

for SID in $subjectID; do
		
		# Verifies if the session# exists. If it doesn't, the for loop ends this iteration and continues with the next one
		if [ ! -d ${ICAD}/C${SID}/FEAT.feat/filtered_func_data.ica ]; then
			continue
		fi
		
	
		# Extract features for FIX; FEAT directories with all required files and folders have to be provided
		cd ${ICAD}/C${SID}/
		fix -f ${ICAD}/C${SID}/FEAT.feat 

done
