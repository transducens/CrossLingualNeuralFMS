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
	echo "Monolingual embeddings for $lang_pair"
	mkdir -p $data_dir/$lang_pair/matches/
	sbatch --wait --gres=gpu:1 --cpus-per-task=2 $src_dir/get_best_matches_combo.sh $src_dir $data_dir/$lang_pair/embeddings/test_source_multilingual $data_dir/$lang_pair/embeddings/tm_target_multilingual $data_dir/$lang_pair/embeddings/monodata_target_multilingual $data_dir/$lang_pair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv &
	sbatch --wait --gres=gpu:1 --cpus-per-task=2 $src_dir/get_best_matches.sh $src_dir $data_dir/$lang_pair/embeddings/test_source_multilingual $data_dir/$lang_pair/embeddings/tm_target_multilingual $data_dir/$lang_pair/matches/best_matches_multilingual_on_tm.tsv &
        sbatch --wait --gres=gpu:1 --cpus-per-task=2 $src_dir/get_best_matches.sh $src_dir $data_dir/$lang_pair/embeddings/test_source_multilingual $data_dir/$lang_pair/embeddings/monodata_target_multilingual $data_dir/$lang_pair/matches/best_matches_eurlex.cosine.tsv &
done
wait
