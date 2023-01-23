#!/bin/bash 

#Register preprocessed data to MNI space and downsample to 6mm
#Subject list 

#!!!!! adjust path!!!! 
#IDs
SUBJECTS==$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

BASEPATH='BASE'

#create and submit job to grid 
for subject in $SUBJECTS; 		
	do
		FuncPath="${BASEPATH}imaging_files/nback/preproc/C${subject}"
		FuncImage="C${subject}_nback_FEAT_detrend_filt_FIX"
		AnatPath="${FuncPath}/anat"
		AnatImage="COBRA_${subject}"
		
		VoxelSize="2"
		
		cd ${BASEPATH}/imaging_files/nback/preproc/C${subject}/
																	
		Preproc="${FuncPath}/${FuncImage}.nii.gz"										#Preprocessed data image
		Registered="${FuncPath}/${FuncImage}_MNI${VoxelSize}mm.nii.gz"				#Registered image
		BET="${AnatPath}/${AnatImage}_brain.nii.gz"										#Brain extracted anatomical image
		MNI="/home/mpib/LNDG/COBRA/scripts/1-5_nback/MNI152_T1_${VoxelSize}mm_brain.nii.gz"					#Standard MNI image
		Preproc_to_BET="${FuncPath}/FEAT.feat/reg/${FuncImage}_preproc_to_BET.mat"		    #Lowres registration matrix
		BET_to_MNI="${FuncPath}/FEAT.feat/reg/${FuncImage}_BET_to_MNI.mat"				    #Highres registration matrix
		Preproc_to_MNI="${FuncPath}/FEAT.feat/reg/${FuncImage}_preproc_to_MNI.mat"		    #Final registration matrix

		Resized="${FuncPath}/${FuncImage}_MNI6mm.nii.gz"								#6mm reslution image

		
		##Run FLIRT commands
	
		#Create lowres registration matrix. Register preprocessed data to BET image and create preproc_to_BET matrix (A_to_B)
		flirt -in ${Preproc} -ref ${BET} -omat ${Preproc_to_BET}
		#Create highres registration matrix. Register BET image to MNI space and create BET_to_MNI matrix (B_to_C)
		flirt -in ${BET} -ref ${MNI} -omat ${BET_to_MNI}
		#Create final registration matrix. Combine previously created matrices into preproc_to_MNI (A_to_C). This will be used for creating the registered images.
		#omat = name of concatenated matrices (A_to_C), 
		#concat = two matrices to be concatenated (B_to_C A_to_B)
		convert_xfm -omat ${Preproc_to_MNI} -concat ${BET_to_MNI} ${Preproc_to_BET}
		#Register preprocessed data to MNI space using MNI image and combined matrices
		flirt -in ${Preproc} -ref ${MNI} -out ${Registered} -applyxfm -init ${Preproc_to_MNI}
		
		#Change resolution of registered image to 6mm
		flirt -in ${Registered} -ref ${Registered} -o ${Resized} -applyisoxfm 6
		

done
