#!/bin/bash

#apply cleanup with certain threshold on your new subjects; can be run locally (doesn't need much time)

#Set the base directory

BD=BASEDIR

# Set the working directory for the current project
WD=${BD}/imaging_files/nback/preproc



#IDs
subjectID=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

## initialize FIX
module load fsl_fix
source /etc/fsl/5.0/fsl.sh


for SID in $subjectID; do
	
	#test different thresholds
	fix -c ${WD}/C${SID}/FEAT.feat ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData 40
	fix -c ${WD}/C${SID}/FEAT.feat ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData 50
	fix -c ${WD}/C${SID}/FEAT.feat ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData 60
	fix -c ${WD}/C${SID}/FEAT.feat ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData 70
	
		
done

#output: txt-file (fix4melview_Training_thr50.txt) with names of noise components
