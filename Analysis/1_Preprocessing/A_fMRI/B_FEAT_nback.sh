#!/bin/bash 
 
 
# !!!!! adjust path!!!! 
# Subject list 


#IDs: FEAT+ to create new reg files with updated BETs
SUBJECTS=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

BASEPATH='BASE'

cd ${BASEPATH}imaging_files/nback/designfiles/

# !! take care to adjust paths in designfile_nback.fsf before running !!

# create new designfile for each subject and run feat
for subject in $SUBJECTS; do 
 
	#create a designfile for each subject and adjust name and paths 
	cp ${BASEPATH}scripts/1-5_nback/designfile_nback.fsf ${BASEPATH}imaging_files/nback/designfiles/designfeat2_C${subject}.fsf

	# Adjust paths with IDs, parameters and standard image in each designfile
	sed 's/id_dummy/'$subject'/g' -i designfeat2_C${subject}.fsf
	sed 's/id_dummy/'$subject'/g' -i designfeat2_C${subject}.fsf

	feat ${BASEPATH}imaging_files/nback/designfiles/designfeat2_C${subject}.fsf

done 

 
