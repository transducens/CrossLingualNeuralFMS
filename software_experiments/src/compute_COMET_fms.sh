#! /bin/bash

src=$1
hyp=$2
out=$3
model_dir=$4

comet-score -s $src -t $hyp --model "$model_dir/checkpoints/model.ckpt"  | egrep "Segment.*score:" | sed 's/.* //g' > $out
#comet-score -s $src -t $hyp --model "wmt20-comet-qe-da" | egrep "Segment.*score:" | sed 's/.* //g' > $out
