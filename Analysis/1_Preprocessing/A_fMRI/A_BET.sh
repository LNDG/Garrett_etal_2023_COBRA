#!/bin/bash

## Brain Extraction (BET). Create brain extracted images using desired parameters.

# We use various parameters in the lab, mainly the following:
	# -f; fractional intensity threshold: This determines the volume within the skull that actually encompasses the brain.; default= 0.5; smaller values give larger brain outline estimates
	# -g; vertical gradient in fractional intensity threshold (-1->1); Normally we use a negative value to remove non-brain structures from the base of the image.; default= 0; positive values give larger brain outline at bottom, smaller at top
	# -R; "robust" brain centre estimation. This option interatively resets the 'centre-of-gravity' as it performs the brain estimation, so as to achieve a more accurate fit of the image. 

# It's recommended to try various paramenters with a few subjects from your study in order to verify which are more appropriate for your particular dataset. Before we have decided which image to use for the participant, we create a series of BET images with different paramenters and the naming of these files corresponds to the parameters used in their creation. For example a BET image which was created using the -f parameter with a value of 0.3 and a -g parameter of -.25 we would name the image as 'ANATOMICAL_IMAGE' and append the suffix '_brainf03g025'. After we decide which parameter(s) are appropriate for the subject, we rename the file using the standard naming: 'ANATOMICAL_IMAGE' and the suffix '_brain.nii.gz'

# When deciding which parameters to use for the participant, always choose to be more liberal. That is to say, choose to include voxels which aren't brain matter if it's necessary to capture the totality of the brain structures one is interested in analyzing.

# Keep record of the final paremeters used for each participant.

WorkingDirectory="DIR"


## Try different parameters for all subjects ##
###############################################

SubjectID=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

for SUB in ${SubjectID} ; do
	# Verifies if the anatomical image exists. If it doesn't, the for loop stops here and continues with the next item.
	#if [ ! -f ${WorkingDirectory}/RAW/T1/COBRA_${SUB}.nii.gz ]; then
	#	echo "No mprage: ${SUB} cannot be processed"
	#	continue
	#fi
	AnatFolder="${WorkingDirectory}/imaging_files/nback/preproc/C${SUB}/anat"
	
	
	mkdir ${AnatFolder}								
	cd ${WorkingDirectory}/RAW/T1					
	cp COBRA_${SUB}.nii.gz ${WorkingDirectory}/imaging_files/nback/preproc/C${SUB}/anat/COBRA_${SUB}.nii.gz
	cd ${AnatFolder}
		
	# try all different parameters
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf5 -f 0.5		
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf1r55 -f 0.1 -r 55	
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf1r560 -f 0.1 -r 560
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf1 -f 0.1
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf2 -f 0.2
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf3 -f 0.3
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf1R -f 0.1 -R
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf2R -f 0.2 -R
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf3R -f 0.3 -R
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf15 -f 0.15
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf25 -f 0.25
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf15R -f 0.15 -R
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf25R -f 0.25 -R
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf1g25 -f 0.1 -g -0.25
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf3g25 -f 0.3 -g -0.25
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf15g25 -f 0.15 -g -0.25 
	bet COBRA_${SUB}.nii.gz COBRA_${SUB}_brainf25g25 -f 0.25 -g -0.25
	
	## check final parameters used for each subject in .csv-file!

done



