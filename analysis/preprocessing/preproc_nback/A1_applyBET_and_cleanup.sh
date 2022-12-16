#!/bin/bash

WorkingDirectory="DIR"

## Use only parameters that look best and delete the rest ##
############################################################

all_parameters="f1 f15 f15g25 f15R f1g25 f1R f2 f25 f25g25 f25R f2g25 f2R f3 f3g25 f3R f7g15"
f1="057 058 074 081 082 083 084 093 096 105 107 108 109 113 116 148 164 192"
f15="053 064 075 122 141 185 220"
f15g25="054 060 065 066 067 072 073 090 091 094 126 127 132 143 149 150 160 188 190"
f15R="121 133 156 165 168 177"
f1g25="068 092 120 131 158"
f1R="061 110 114 117 118 144 176 210 211 219"
f2="152"
f25="205 214"
f25g25="087 172"
f25R="138 208 216"
f2g25="063 079 080 099 104 119 130 137 139 153 154 161 169 173 178 179 180 181 183 187 193 198 203 212 217"
f2R="056 069 159 162"
f3="174 204 206 213"
f3g25="059 069 159 162 170 195 201"
f3R="197 202"
f7g15="155"


for PAR in ${all_parameters}; do
	for SUB in ${!PAR}; do
		                                                                          
		AnatPath="${WorkingDirectory}/imaging_files/nback/preproc/C${SUB}/anat"
		cd ${AnatPath}
		
		rm -rf COBRA_${SUB}_brain.nii.gz																 
		mv COBRA_${SUB}_brain${PAR}.nii.gz COBRA_${SUB}_brain.nii.gz
		            
		all_images=`ls | grep "C*"`                                            
		mkdir ${AnatPath}/temp                                                 
		for image in ${all_images}; do                                           
			mv ${AnatPath}/${image} ${AnatPath}/temp                           
		done
		                                                                   
		mv ${AnatPath}/temp/COBRA_${SUB}_brain.nii.gz ${AnatPath}              
		mv ${AnatPath}/temp/COBRA_${SUB}.nii.gz ${AnatPath}                 
		rm -rf ${AnatPath}/temp                                                  
		
	done
done