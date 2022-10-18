#!/bin/bash
#SBATCH --job-name DDMbias
#SBATCH --time 24:0:0
#SBATCH --cpus-per-task 1
#SBATCH --mem 32GB
#SBATCH --mail-type NONE
#SBATCH --workdir .

./COBRA_HDDM_123back_bias.py
