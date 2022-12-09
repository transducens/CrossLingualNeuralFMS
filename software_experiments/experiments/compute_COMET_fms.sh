#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please, provide a data dir and the directory containing the COMET model"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    COMET_dir=$2
    if [[ -d "$data_dir" ]]; then
        echo "Computing scores"
    else
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi

to_be_removed=""
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
	tlang=$(echo $langpair | cut -d '-' -f 2)
	hyp=$(mktemp)
	src=$(mktemp)
	to_be_removed="$to_be_removed $hyp $src"
	cut -f 1 $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv > $src
	cut -f 4 $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv > $hyp
	sbatch -W --partition=urgent --gres=gpu:1 --cpus-per-task=2 $src_dir/compute_COMET_fms.sh $src $hyp $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv.cometfms $COMET_dir &

        hyp=$(mktemp)
	src=$(mktemp)
	to_be_removed="$to_be_removed $hyp $src"
	cut -f 1 $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv > $src
	cut -f 4 $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv > $hyp
	sbatch -W --partition=urgent --gres=gpu:1 --cpus-per-task=2 $src_dir/compute_COMET_fms.sh $src $hyp $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv.cometfms $COMET_dir &

        hyp=$(mktemp)
	src=$(mktemp)
	to_be_removed="$to_be_removed $hyp $src"
	cut -f 1 $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv > $src
	cut -f 4 $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv > $hyp
	sbatch -W --partition=urgent --gres=gpu:1 --cpus-per-task=2 $src_dir/compute_COMET_fms.sh $src $hyp $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv.cometfms $COMET_dir &


        hyp=$(mktemp)
        src=$(mktemp)
        to_be_removed="$to_be_removed $hyp $src"
        cut -f 1 $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv > $src
        cut -f 4 $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv > $hyp
        sbatch -W --partition=urgent --gres=gpu:1 --cpus-per-task=2 $src_dir/compute_COMET_fms.sh $src $hyp $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.cometfms $COMET_dir &

done   
wait
rm $to_be_removed

