#!/bin/bash 

# Subject list 

# !!!!! adjust path!!!! 

#IDs
SUBJECTS=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

BASEPATH='BASE'

#create and submit job to grid 
for subject in $SUBJECTS; 		
	do

		d ${BASEPATH}/imaging_files/nback/preproc/C${subject}/		# job output dir
		
																
		# fsl command
		flirt -in anat/COBRA_${subject}_brain.nii.gz -ref ../../../../RAW/nback/COBRA_${subject}.nii.gz -out anat2func
		melodic -i filtered_func_data.nii.gz -o filtered_func_data.ica --dimest=mdl -v --nobet --bgthreshold=3 --tr=2.0 --report --guireport=/FEAT.feat/report.html -d 0 --mmthresh=0.5 --Ostats --bgimage=anat2func.nii.gz


done
