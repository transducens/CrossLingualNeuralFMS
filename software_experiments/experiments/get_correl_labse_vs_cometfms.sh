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

for l in es de fi cs; do
        tmpfile=$(mktemp)
        f1=$(mktemp)
        f2=$(mktemp)

        paste $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv $data_dir/en-$l/matches/best_matches_multilingual_on_tm.tsv.fms $data_dir/en-$l/matches/best_matches_multilingual_on_tm.tsv | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 en --l2 $l > $tmpfile
        cut -f 6 $tmpfile > $f1
        cut -f 11 $tmpfile > $f2
        echo -n "Kendall/Pearson correl FMS vs neuroFMS en-$l: "
        python $src_dir/compute_correlation_between_scores.py -t $f1 -f $f2
        rm $tmpfile $f1 $f2
done

for l in es de fi cs; do
	tmpfile=$(mktemp)
	f1=$(mktemp)
	f2=$(mktemp)
	
	paste $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv.fms $data_dir/en-$l/matches/best_matches_FMS.sorted.tsv.cometfms | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 en --l2 $l > $tmpfile
	cut -f 6 $tmpfile > $f1
	cut -f 7 $tmpfile > $f2
	echo -n "Kendall/Pearson correl FMS vs neuroFMS en-$l: "
	python $src_dir/compute_correlation_between_scores.py -t $f1 -f $f2
       	rm $tmpfile $f1 $f2
done
