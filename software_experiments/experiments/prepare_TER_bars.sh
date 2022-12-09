#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    if [[ ! -d "$data_dir" ]]; then
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi


for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
	echo "Lang pair $langpair"
	echo -e "Approach\t<0.4\t<0.3\t<0.2\t<0.1" > $data_dir/$langpair/ter_ranges_$(echo $langpair | tr -d '-').tsv

	tec2="neuroMatch"
        for range in "0.4-0.3" "0.3-0.2" "0.2-0.1" "0.1-0.0"; do
                echo "Neuro RANGE: $range"

                slang=$(echo $langpair | cut -d '-' -f 1)
                tlang=$(echo $langpair | cut -d '-' -f 2)
                min=$(echo $range | cut -d '-' -f 2)
                max=$(echo $range | cut -d '-' -f 1)

                tec2="$tec2\t$(paste $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max $max)"
                #tec2="$tec2\t$(paste $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max $max --min $min)"
        done
        echo -e $tec2 >> $data_dir/$langpair/ter_ranges_$(echo $langpair | tr -d '-').tsv

        tec1="FMS"
	for range in "0.4-0.3" "0.3-0.2" "0.2-0.1" "0.1-0.0"; do
		echo "FMS RANGE: $range"
	        slang=$(echo $langpair | cut -d '-' -f 1)
                tlang=$(echo $langpair | cut -d '-' -f 2)
                min=$(echo $range | cut -d '-' -f 2)
                max=$(echo $range | cut -d '-' -f 1)

		tec1="$tec1\t$(paste $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max $max)"
	done
	echo -e $tec1 >> $data_dir/$langpair/ter_ranges_$(echo $langpair | tr -d '-').tsv
done
