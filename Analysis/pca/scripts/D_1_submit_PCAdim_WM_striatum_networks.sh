#!/bin/bash 

#N162
#SUBJECTS="001 003 006 007 008 009 010 013 014 015 016 017 018 019 021 022 024 025 027 028 029 030 032 034 035 036 038 040 041 043 045 046 049 050 051 052 053 056 057 058 059 060 061 063 064 065 066 067 068 069 071 072 073 074 075 076 079 080 081 082 084 085 087 090 091 092 093 094 095 097 099 104 105 106 107 108 109 110 112 113 114 116 117 118 119 120 121 122 123 126 127 130 131 133 134 135 136 137 138 139 140 143 144 146 148 149 150 152 153 154 155 156 158 159 160 161 162 163 164 165 168 169 170 172 173 174 176 177 178 180 181 183 184 185 186 187 188 190 191 192 193 194 195 196 197 198 199 200 201 203 204 206 208 210 211 212 213 214 216 217 219 220"

SUBJECTS="217"
modality="spat"
#modality="temp"
WD="DIR"
#create and submit job to grid 
for ID in ${SUBJECTS}; do
	
	echo "#PBS -N PCAdim_${modality}_Vincent_networks_WM_striatum_${ID}"									>> jobfile 			# job name
	echo "#PBS -l walltime=3:0:0" 											>> jobfile			# time until job is killed
	echo "#PBS -l mem=8gb"	 												>> jobfile			# books 4gb RAM for the job
	#echo "#PBS -m ae" 														>> jobfile			# email notification on abort/end   -n no notification
	echo "#PBS -o /home/mpib/LNDG/COBRA/logs/" 								>> jobfile			# write (error) log to log folder
	echo "#PBS -e /home/mpib/LNDG/COBRA/logs/" 								>> jobfile
    
	echo "if [ -f ${WD}/preproc_nback/preproc/C${ID}/C${ID}_nback_FEAT_detrend_filt_FIX_MNI2mm.nii.gz ]; then  " >> jobfile 	

	echo "gunzip ${WD}/preproc_nbackpreproc/C${ID}/C${ID}_nback_FEAT_detrend_filt_FIX_MNI2mm.nii.gz; fi" >> jobfile 	
	
	echo "cd ${WD}/B_analyses/Paper1_2018/Dimensionality_nback/scripts/" 				>> jobfile

	echo "umask 0007"												 		>> jobfile 			# set permissions
    
	echo "./run_D_${modality}PCAdim_WM_striatum_networks.sh /opt/matlab/R2016b/ ${ID}" 			>> jobfile
	
	echo "if [ -f ${WD}/preproc_nback/preproc/C${ID}/C${ID}_nback_FEAT_detrend_filt_FIX_MNI2mm.nii ]; then" 	>> jobfile
	
	echo "gzip ${WD}/preproc_nback/preproc/C${ID}/C${ID}_nback_FEAT_detrend_filt_FIX_MNI2mm.nii; fi" 	>> jobfile
	
	    
	# submit job
	qsub jobfile  
	rm jobfile # clean up temporary file 
	
done