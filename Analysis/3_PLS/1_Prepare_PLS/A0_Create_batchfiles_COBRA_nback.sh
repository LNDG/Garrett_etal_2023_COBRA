#!/bin/bash

WD="BASE"
PLSDir="${WD}/PLS"


# ID
subjectID=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)

if [ ! -d ${PLSDir}/mean_data ]; then
	mkdir ${PLSDir}/mean_data
fi

for SID in $subjectID; do
	
	cd ${PLSDir}

	cp ${PLSDir}/A_1_COBRA_PLS_nback_2mm_template_batch_file.txt ${PLSDir}/mean_data/C${SID}_2mm_PLS_batchfile.txt
	
	old_1="dummyID"
	new_1="C${SID}"
	
	sed -i '' "s|${old_1}|${new_1}|g" ${PLSDir}/mean_data/C${SID}_2mm_PLS_batchfile.txt
	
	old_2="BASEDIR"
	new_2="${WD}"
		sed -i '' "s|${old_2}|${new_2}|g" ${PLSDir}/mean_data/C${SID}_2mm_PLS_batchfile.txt

done