#!/bin/bash

workingDIR=WORKDIR

ID=$(awk -F "\"*,\"*" '{print $1}' ${WD}/SharableData/SharedData_Garrett_etal_Neuron_FINAL.csv)


DIR="${workingDIR}/imaging_files/nback/preproc"
DIR2="FEAT.feat"

TrainingSetCOBRA=SPECIFYTRAININGIDs

## initialize FIX
module load fsl_fix
source /etc/fsl/5.0/fsl.sh

cd ${workingDIR}/scripts/1-5_nback/6_FIX

fix -t Training_COBRA_n43 $TrainingSetCOBRA 

#output: Training_COBRA_n43.RData and folder Training_COBRA_n43/