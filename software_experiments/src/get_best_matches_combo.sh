#! /bin/bash

if [ "$#" -ne 5 ]; then
    echo "Please, provide a source code dir, source prefix, a target prefix1, a target prefix2, and the output path."
    exit -1
else
    src_dir=$1
    source_pref=$2
    target_prefA=$3
    target_prefB=$4

    output=$5
fi

echo "Monolingual embeddings for $lang_pair"
python $src_dir/get_best_embedding_matches.py --gpu --src-embeddings $source_pref.embs --trg-embeddings $target_prefA.embs,$target_prefB.embs $source_pref.sents $target_prefA.sents,$target_prefB.sents --output $output --verbose

