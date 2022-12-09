#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    if [[ -d "$data_dir" ]]; then
        echo "Comparing embeddings"
    else
        echo "The data directory provided $data_dir does not exist"
	exit -1
    fi
fi
for lang_pair in "en-de" "en-es" "en-cs" "en-fi"; do
	echo "Sorting best matches for FMS in lang. $lang_pair"
	python $src_dir/sort_tsv_as_refference.py -f $data_dir/$lang_pair/matches/best_matches_FMS.tsv -r $data_dir/$lang_pair/matches/best_matches_multilingual_on_tm.tsv > $data_dir/$lang_pair/matches/best_matches_FMS.sorted.tsv
done
