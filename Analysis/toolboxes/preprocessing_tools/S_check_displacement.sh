## clean up
# remove all but pre trail data

SUBJECTS="102 103 108 109 110 111 112 114 115 116 117 118 119 121 122 123 124 125 126 128 129 131 132 133 134 201 203 204 205 206 209 211 213 215 216 217 218 220 221 222 223 224 225 226 229 230 231 232 233 235 236 237 238 239 240 241 242 245 246 247 248 249 250 251 252 253"

#SUBJECTS="103"

#create file with header
echo -e "ID \t abs_mean \t rel_mean" >> displacements.txt


for subject in $SUBJECTS; 
do

	for run in {1..2}
	do		
		#save absolute and relative displacement mean
		abs_mean=$(cat /Volumes/LNDG/Maike_Fitness/preproc/${subject}/run${run}/FEAT.feat/mc/prefiltered_func_data_mcf_abs_mean.rms)
		rel_mean=$(cat /Volumes/LNDG/Maike_Fitness/preproc/${subject}/run${run}/FEAT.feat/mc/prefiltered_func_data_mcf_rel_mean.rms)
		
		#write values to txt file
		echo -e "${subject}_${run} \t $abs_mean \t $rel_mean"	>> displacements.txt
		
	done
done
