#!/bin/bash
# This script tests the decision accuracy for the training set

#Set the base directory: local or grid

BD=WORKDIR

# Set the working directory for the current project
WD=${BD}/imaging_files/nback/preproc


## initialize FIX
module load fsl_fix
source /etc/fsl/5.0/fsl.sh

DIR="${WD}"
DIR2="FEAT.feat"
#training set
TrainingSetCOBRA=SPECIFYTESTIDs

fix -C ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43 $TrainingSetCOBRA

#output: txt-file (Training_COBRA_n43_evaluation_results.txt) evaluation results