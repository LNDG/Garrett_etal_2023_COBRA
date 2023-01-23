#!/bin/bash 

# Subject list 

# !!!!! adjust path!!!! 
# IDs
SUBJECTS=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)


BASEPATH='BASDIR'

#create and submit job to grid 
for subject in $SUBJECTS; 		
	do
		DATAPATH="${BASEPATH}imaging_files/nback/preproc/C${subject}/"

		cd ${BASEPATH}/imaging_files/nback/preproc/C${subject}/		# job output dir
		
		Input="${DATAPATH}C${subject}_nback_FEAT_detrend_filt.nii.gz"
		Output="${DATAPATH}C${subject}_nback_FEAT_detrend_filt_FIX.nii.gz"
		Melodic="${DATAPATH}FEAT.feat/filtered_func_data.ica/melodic_mix"
		FIXfile="${DATAPATH}FEAT.feat/fix4melview_Training_COBRA_n43_070417_thr60.txt"
		HANDfile="${DATAPATH}FEAT.feat/hand_labels_noise.txt"
		
		if [ -f $FIXfile ]; then
			
			cat ${DATAPATH}FEAT.feat/fix4melview_Training_COBRA_n43_070417_thr60.txt | tail -1  > tmp${subject}
			Rejected=$(cat tmp${subject})
			rm tmp${subject}
			
		elif [ -f $HANDfile ]; then
			
			Rejected=$(cat ${DATAPATH}FEAT.feat/hand_labels_noise.txt)
		
		else echo "reject comps txt not found: C${subject}"
		fi
		
															
   	  	fsl_regfilt -i ${Input} -o ${Output} -d ${Melodic} -f \"${Rejected}\"
		

done
