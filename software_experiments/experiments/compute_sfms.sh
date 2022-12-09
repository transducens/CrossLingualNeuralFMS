#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    if [[ -d "$data_dir" ]]; then
        echo "Computing scores"
    else
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi

to_be_removed=""
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
	slang=$(echo $langpair | cut -d '-' -f 1)
	tlang=$(echo $langpair | cut -d '-' -f 2)
	echo $langpair
        cut -f 1,3 $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv | python $src_dir/compute_fms.py -l $slang | cut -f 3 > $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv.fms &
        cut -f 1,3 $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv | python $src_dir/compute_fms.py -l $slang | cut -f 3 > $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv.fms &
        cut -f 1,3 $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv | python $src_dir/compute_fms.py -l $slang | cut -f 3 > $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurex.tsv.fms &
done  
wait
#rm $to_be_removed

