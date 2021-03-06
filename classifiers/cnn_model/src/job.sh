#!/bin/bash
#
# This shell script does the following
# 1) Saves randomly generated partion of data
# 2) Trains model on data
# 3) Tests model on testing subset of data
# 4) Prints error analysis results


module load tensorflow/0.12.1
source ~/tensorflow/bin/activate

PROJ_DIR=../../../

# Download glove vectors
if [ ! -f "${PROJ_DIR}/data/glove.42B.300d.txt"];
then
wget http://nlp.stanford.edu/data/glove.42B.300d.zip
unzip glove.42B.300d.zip
mv glove.42B.300d.txt ../../../data/
rm glove.42B.300d.zip
# stanford_pe.tsv file also needs to be downloaded into data folder
fi

func ()
{
local task_num=1
local arch=cnn_word
local partition="task${task_num}_human"
local name=${arch}_${partition}

<<COMMENT
#python create_partition.py --partition $partition

python classifier.py \
    --task_num $task_num \
    --runtype train \
    --arch $arch \
    --partition $partition \
    --name $name

python classifier.py \
    --task_num $task_num \
    --runtype test \
    --arch $arch \
    --partition $partition \
    --name $name \
#    -error_analysis
COMMENT
python prediction.py \
    --task_num $task_num \
    --arch $arch \
    --name $name \
    --input_path "${PROJ_DIR}/data/stanford_pe.tsv" \
    --output_path "${PROJ_DIR}/data/task${task_num}_pred_file.csv"

}
func
