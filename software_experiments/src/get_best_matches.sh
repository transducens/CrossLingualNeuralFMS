#! /bin/bash

if [ "$#" -ne 4 ]; then
    echo "Please, provide a source code dir, source prefix, a target prefix, and the output path."
    exit -1
else
    src_dir=$1
    source_pref=$2
    target_pref=$3
    output=$4
fi

echo "Monolingual embeddings for $lang_pair"
python $src_dir/get_best_embedding_matches.py --gpu --src-embeddings $source_pref.embs --trg-embeddings $target_pref.embs $source_pref.sents $target_pref.sents --output $output --verbose

