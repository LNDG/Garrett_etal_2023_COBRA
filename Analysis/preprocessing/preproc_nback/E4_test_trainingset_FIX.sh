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
TrainingSetCOBRA="${DIR}/C003/${DIR2} ${DIR}/C006/${DIR2} ${DIR}/C007/${DIR2} ${DIR}/C009/${DIR2} ${DIR}/C010/${DIR2} ${DIR}/C011/${DIR2} ${DIR}/C013/${DIR2} ${DIR}/C014/${DIR2} ${DIR}/C015/${DIR2} ${DIR}/C016/${DIR2} ${DIR}/C017/${DIR2} ${DIR}/C018/${DIR2} ${DIR}/C019/${DIR2} ${DIR}/C021/${DIR2} ${DIR}/C022/${DIR2} ${DIR}/C023/${DIR2} ${DIR}/C024/${DIR2} ${DIR}/C025/${DIR2} ${DIR}/C026/${DIR2} ${DIR}/C027/${DIR2} ${DIR}/C028/${DIR2} ${DIR}/C029/${DIR2} ${DIR}/C030/${DIR2} ${DIR}/C031/${DIR2} ${DIR}/C032/${DIR2} ${DIR}/C033/${DIR2} ${DIR}/C035/${DIR2} ${DIR}/C036/${DIR2} ${DIR}/C037/${DIR2} ${DIR}/C038/${DIR2} ${DIR}/C039/${DIR2} ${DIR}/C040/${DIR2} ${DIR}/C041/${DIR2} ${DIR}/C043/${DIR2} ${DIR}/C045/${DIR2} ${DIR}/C046/${DIR2} ${DIR}/C047/${DIR2} ${DIR}/C049/${DIR2} ${DIR}/C050/${DIR2} ${DIR}/C051/${DIR2} ${DIR}/C052/${DIR2} ${DIR}/C053/${DIR2} ${DIR}/C054/${DIR2}"

fix -C ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43.RData ${BD}/scripts/1-5_nback/6_FIX/Training_COBRA_n43 $TrainingSetCOBRA

#output: txt-file (Training_COBRA_n43_evaluation_results.txt) evaluation results