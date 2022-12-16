#!/bin/bash
#usage: sh maskcreation.sh roilist
#input:
## roilist - text file with X,Y,Z MNI coords (separated by " ")

roilist=$1

rm imgvoxrois.txt

while read line

do

X=$(echo $line | cut -d " " -f 1)
Y=$(echo $line | cut -d " " -f 2)
Z=$(echo $line | cut -d " " -f 3)

echo $X $Y $Z | std2imgcoord -img $FSLDIR/data/standard/MNI152_T1_2mm -std $FSLDIR/data/standard/MNI152_T1_2mm -vox - >> imgvoxrois.txt

done < $roilist

linecount=0

while read line

do

Ximg=$(echo $line | cut -d " " -f 1)
Yimg=$(echo $line | cut -d " " -f 2)
Zimg=$(echo $line | cut -d " " -f 3)

linecount=`expr $linecount + 1`

fslmaths $FSLDIR/data/standard/MNI152_T1_2mm -mul 0 -add 1 -roi $Ximg 1 $Yimg 1 $Zimg 1 0 1 ${linecount}_point.nii.gz -odt float
fslmaths ${linecount}_point.nii.gz -kernel sphere 8 -fmean ${linecount}_sphere.nii.gz -odt float
fslmaths ${linecount}_sphere.nii.gz -bin ${linecount}_mask.nii.gz

done < imgvoxrois.txt


