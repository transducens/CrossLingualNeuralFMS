#! /bin/bash

src=$1
hyp=$2
out=$3
model=$4

comet-score -s $src -t $hyp --model $model | egrep "Segment.*score:" | sed 's/.* //g' > $out
