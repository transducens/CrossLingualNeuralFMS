#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    if [[ -d "$data_dir" ]]; then
        echo "Creating embeddings"
    else
        echo "The data directory provided $data_dir does not exist"
	exit -1
    fi
fi
for lang_pair in "en-de" "en-es" "en-cs" "en-fi"; do
    l1=$(echo $lang_pair | cut -d "-" -f 1)
    l2=$(echo $lang_pair | cut -d "-" -f 2)
    mkdir -p $data_dir/$lang_pair/embeddings
    sbatch --wait --gres=gpu:1 --cpus-per-task=4 $src_dir/get_embeddings.py -s $l1 -t $l2 -o $data_dir/$lang_pair/embeddings/test_source_multilingual -d $data_dir/$lang_pair/to_translate/splits/ -m -p $src_dir &
 
    sbatch --wait --gres=gpu:1 --cpus-per-task=3 $src_dir/get_embeddings.py -s $l1 -t $l2 -o $data_dir/$lang_pair/embeddings/tm_target_multilingual -d $data_dir/tm/ --embed-target -m -p $src_dir &
    sbatch --wait --partition=urgent --gres=gpu:1 --mem-per-cpu=10140 --cpus-per-task=2 $src_dir/get_embeddings.py -s $l1 -t $l2 -o $data_dir/$lang_pair/embeddings/monodata_target_multilingual -g $data_dir/$lang_pair/$l2.sents.gz --embed-target -m -p $src_dir &
done
wait
