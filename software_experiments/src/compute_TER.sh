#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please, provide a file with the reference and the hypothesis to be evaluated, and the language in which text is writen"
    exit -1
else
    textdir=$1
    lang=$2
    if [[ ! -f "$textdir" ]]; then
        echo "File $textdir does not exist"
        exit -1
    fi
fi

src_dir=$(realpath $(dirname $0)/..)

ref=$(mktemp)
hyp=$(mktemp)

cut -f 2 $1 | python $src_dir/norm_spaces.py | $src_dir/moses-scripts/scripts/tokenizer/tokenizer.perl -l $2 > $ref &
cut -f 4 $1 | python $src_dir/norm_spaces.py | $src_dir/moses-scripts/scripts/tokenizer/tokenizer.perl -l $2 > $hyp
wait

cur_dir=$PWD
cd $src_dir/multeval
#$src_dir/multevalnew/multeval.sh eval --metrics ter --refs $ref --hyps-baseline $hyp --boot-samples 0 2> /dev/null  | egrep "^baseline"| sed 's/baseline *//g' | cut -d ' ' -f 1 | tr ',' '.'
$src_dir/multevalnew/multeval.sh eval --metrics ter --refs $ref --hyps-baseline $hyp --boot-samples 0 | egrep "^baseline"| sed 's/baseline *//g' | cut -d ' ' -f 1 | tr ',' '.'
cd $cur_dir	
rm $ref $hyp

