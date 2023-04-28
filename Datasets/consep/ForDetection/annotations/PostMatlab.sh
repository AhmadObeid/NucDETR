#!/bin/bash

# The blow lines are needed for post-processing of the json files after generating them with the # MATLAB script. We want to remove a comma ',' two lines before, and one line after the word
# annotation. Written by Ahmad Obeid

# To get the line where the word annotation appears:

fileTr=instances_train2017.json
fileTs=instances_val2017.json

line=$(sed -n '/anno/=' $fileTr)
lineBfr=$(($line - 2))
lineAft=$(($line + 1))
# Replace }, two lines before the above with only }:
sed -i "${lineBfr}s/.*/}/" $fileTr
sed -i "${lineAft}s/.*//" $fileTr

# check:
echo "For Training:"
echo "Line before is"
head -$lineBfr $fileTr | tail +$lineBfr
echo "Line after is"
head -$lineAft $fileTr | tail +$lineAft

line=$(sed -n '/anno/=' $fileTs)
lineBfr=$(($line - 2))
lineAft=$(($line + 1))
# Replace }, two lines before the above with only }:
sed -i "${lineBfr}s/.*/}/" $fileTs
sed -i "${lineAft}s/.*//" $fileTs

# check:
echo "For Testing:"
echo "Line before is"
head -$lineBfr $fileTs | tail +$lineBfr
echo "Line after is"
head -$lineAft $fileTs | tail +$lineAft
