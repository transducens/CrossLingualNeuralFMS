#! /bin/bash

if [ "$#" -ne 2 ] & [ "$#" -ne 3 ]; then
    echo "Please, provide a file with the reference and the hypothesis to be evaluated, and the language in which text is writen"
    exit -1
else
    textdir=$1
    lang=$2
    output=$3
    if [[ -f "$textdir" ]]; then
        echo "Computing BLEU"
    else
        echo "File $textdir does not exist"
        exit -1
    fi
fi

src_dir=$(realpath $(dirname $0))

src=$(mktemp)


cut -f 3 $textdir | $src_dir/../moses-scripts/scripts/tokenizer/tokenizer.perl -l $2 > $src

python $src_dir/split_matches_into_length.py --tokenized_source $src --matches-file $textdir -o  $output

rm $src

