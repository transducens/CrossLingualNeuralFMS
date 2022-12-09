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

for l in es de cs fi; do
	fields=$(mktemp)
	paste $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv.cometfms $data_dir/en-$l/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.cometfms $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv.ter $data_dir/en-$l/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 en --l2 $l | cut -f 6- > $fields
        echo "en-$l"
	echo -en "\tOnly FMS: "
	cat $fields | python $src_dir/combine_samples_with_winner_score_and_get_TER_from_two_systems_force_first.py | python $src_dir/compute_TER_from_sTER.py
	echo -en "\tOnly neuroMatch: "
	cat $fields | python $src_dir/combine_samples_with_winner_score_and_get_TER_from_two_systems_force_second.py | python $src_dir/compute_TER_from_sTER.py
	echo -en "\tCombination FMS and neuroMatch: "
	cat $fields | python $src_dir/combine_samples_with_winner_score_and_get_TER_from_two_systems_inverse.py | python $src_dir/compute_TER_from_sTER.py
	echo -ne "\tOracle: "
	cat $fields | python $src_dir/combine_samples_with_winner_score_and_get_TER_from_two_systems_oracle.py | python $src_dir/compute_TER_from_sTER.py
	echo ""
done
