#!/bin/bash
# this script assumes we're running from the SUBJECT_DIR

# this script assumes MASKDIR has been set by neuropipe's globals function
source globals.sh

old_dir=$(pwd)
#cd ${DATADIR}


#TODO: Add smarter detection of correct .feat output directory to use (i.e. sometimes we have ALL_RUNS.feat+++ instead of ALL_RUNS.feat) this could be easily done by piping ls'ing ALL_RUNS* and grabbing the last one created
img_names=("ALL_RUNS" "IMG_LOCALIZERS" "WORD_LOCALIZERS" "WORDLISTS")
for img in ${img_names[@]}
do
	# change to the appropriate feat output folder
	cd "${FIRSTLEVEL_DIR}/$img.feat"

	# compute the transform
	flirt -in $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -ref mean_func.nii.gz -omat MNI2mm2func.transform

	# apply the transform to the mask
	flirt -in ${MASKDIR}/temporal_occipital_mask.nii.gz -ref mean_func.nii.gz -applyxfm -init MNI2mm2func.transform -out temporal_occipital_mask_transformed

	# threshold the mask at 0.5
	fslmaths temporal_occipital_mask_transformed -thr 0.5 temporal_occipital_mask_transformed

	# binarize the mask
	fslmaths temporal_occipital_mask_transformed.nii.gz -bin temporal_occipital_mask_transformed

	# de-compress the mask
	gunzip temporal_occipital_mask_transformed.nii.gz

	# check your mask
	#fslview&

	cd ${old_dir}
done
