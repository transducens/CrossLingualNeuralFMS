#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir and a tercom installation"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    if [[ -d "$data_dir" ]]; then
            echo "Building table"
    else
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi

for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
	tlang=$(echo $langpair | cut -d '-' -f 2)
	bash $src_dir/compute_sent_TER.sh $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv $tlang &
	bash $src_dir/compute_sent_TER.sh $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv $tlang &
	bash $src_dir/compute_sent_TER.sh $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv $tlang $tercom_installation &
        bash $src_dir/compute_sent_TER.sh $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv $tlang $tercom_installation &
done   
wait
