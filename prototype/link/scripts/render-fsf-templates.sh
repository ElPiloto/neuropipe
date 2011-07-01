#!/bin/bash
#
# render-fsf-templates.sh fills in templated fsf files so FEAT can use them
# original author: mason simon (mgsimon@princeton.edu)
# this script was provided by NeuroPipe. modify it to suit your needs

set -e

source globals.sh

 
function render_firstlevel {
  fsf_template=$1
  output_dir=$2
  standard_brain=$3
  data_file_prefix=$4
  initial_highres_file=$5
  highres_file=$6
  ev_dir=$7
  design_dir=$8

  subject_dir=$(pwd)

  # note: the following replacements put absolute paths into the fsf file. this
  #       is necessary because FEAT changes directories internally
  cat $fsf_template \
    | sed "s:<?= \$OUTPUT_DIR ?>:$subject_dir/$output_dir:g" \
    | sed "s:<?= \$STANDARD_BRAIN ?>:$standard_brain:g" \
    | sed "s:<?= \$DATA_FILE_PREFIX ?>:$subject_dir/$data_file_prefix:g" \
    | sed "s:<?= \$INITIAL_HIGHRES_FILE ?>:$subject_dir/$initial_highres_file:g" \
    | sed "s:<?= \$HIGHRES_FILE ?>:$subject_dir/$highres_file:g" \
    | sed "s:<?= \$EV_DIR ?>:$subject_dir/$ev_dir:g"
    | sed "s:<?= \$DESIGN_DIR ?>:$subject_dir/$design_dir:g"

}

