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

echo " & \\multicolumn{1}{c}{\\textbf{EN-ES}} & \\multicolumn{1}{c}{\\textbf{EN-DE}} & \\multicolumn{1}{c}{\\textbf{EN-CS}} & \\multicolumn{1}{c}{\\textbf{EN-FI}} \\\\"
echo -n "FMS (TM)"
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
        slang=$(echo $langpair | cut -d '-' -f 1)
        tlang=$(echo $langpair | cut -d '-' -f 2)
	result=$(paste $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv $data_dir/$langpair/matches/best_matches_FMS.sorted.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max 0.4)
        echo -n " & $result "
done
echo " \\\\"

echo " & \\multicolumn{2}{c}{\\textbf{EN-ES}} & \\multicolumn{2}{c}{\\textbf{EN-DE}} & \\multicolumn{2}{c}{\\textbf{EN-CS}} & \\multicolumn{2}{c}{\\textbf{EN-FI}} \\\\"
echo "\\textbf{Method} & \\textbf{BLEU} \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} \\\\"
echo -n "NeuroFMS (TM)"
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
        slang=$(echo $langpair | cut -d '-' -f 1)
        tlang=$(echo $langpair | cut -d '-' -f 2)
        result=$(paste $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv $data_dir/$langpair/matches/best_matches_multilingual_on_tm.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max 0.4)
        echo -n " & $result "
done    
echo " \\\\"


echo " & \\multicolumn{2}{c}{\\textbf{EN-ES}} & \\multicolumn{2}{c}{\\textbf{EN-DE}} & \\multicolumn{2}{c}{\\textbf{EN-CS}} & \\multicolumn{2}{c}{\\textbf{EN-FI}} \\\\"
echo "\\textbf{Method} & \\textbf{BLEU} \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} \\\\"
echo -n "NeuroFMS (EurLex)"
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
        slang=$(echo $langpair | cut -d '-' -f 1)
        tlang=$(echo $langpair | cut -d '-' -f 2)
        result=$(paste $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv $data_dir/$langpair/matches/best_matches_eurlex.cosine.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max 0.4)
        echo -n " & $result "
done    
echo " \\\\"

echo " & \\multicolumn{2}{c}{\\textbf{EN-ES}} & \\multicolumn{2}{c}{\\textbf{EN-DE}} & \\multicolumn{2}{c}{\\textbf{EN-CS}} & \\multicolumn{2}{c}{\\textbf{EN-FI}} \\\\"
echo "\\textbf{Method} & \\textbf{BLEU} \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} & \\textbf{BLEU} & \\textbf{TER} \\\\"
echo -n "NeuroFMS (TM+EurLex)"
for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
        slang=$(echo $langpair | cut -d '-' -f 1)
        tlang=$(echo $langpair | cut -d '-' -f 2)
        result=$(paste $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv $data_dir/$langpair/matches/best_matches_multilingual_on_tm_plus_eurlex.tsv.ter | python $src_dir/remove_dups.py | python $src_dir/remove_length_outlayers.py --l1 $slang --l2 $tlang | python $src_dir/compute_ratio_ter_in_range.py --max 0.4)
        echo -n " & $result "
done    
echo " \\\\"
