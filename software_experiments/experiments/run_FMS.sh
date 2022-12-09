#! /bin/bash

src_dir=$(realpath $(dirname $0)/../src)
splits=$1

for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
    slang=$(echo $langpair | cut -d '-' -f 1)
    tlang=$(echo $langpair | cut -d '-' -f 2)

    for i in {0..$splits}; do
        sbatch --wait $src_dir/get_best_matches.distance.py -s $slang -t $tlang --tm_dir $data_dir/data/tm/ --file_to_translate $data_dir/data/to_translate/splits/tm_split.$i.tmx > $data_dir/data/to_translate/splits/tm_split.$i.candidates.tsv &
    done
done
wait
