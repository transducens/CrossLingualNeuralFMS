#! /bin/bash

splits=96

cur_dir=$(realpath $(dirname $0))
data_dir=$cur_dir/../data
verts_dir=/home/user/EurLex/verts
COMET_model_dir=/home/user/NeuralFuzzyMatches/COMET/FMS_prediction/

#Downloading DGT TM data and procesing it
bash $cur_dir/download_data.sh $cur_dir/.. $splits
#MANUAL STEP!
#Downoad the EurLex prevertical files by requesting them to ; thenrun the script:
bash $cur_dir/build_Eurlex_sents.sh $data_dir $verts_dir
#Building LaBSE embeddings
bash $cur_dir/build_embeddings.sh $data_dir
#Obtaining the best matches for the test set using embeddings on: the TM, the Eurlex monolingual corpus, the combination of both resources
bash $cur_dir/get_best_matches_embeddings.sh $data_dir
#Obrtaining the best matches for the test set using FMS on the TM
bash $cur_dir/run_FMS.sh $data_dir
bash $cur_dir/sort_FMS_matches.sh $data_dir

#Computing sentence-TER for all possible matches using both FMS and NeuroFMS and TM, Eurlex, and TM+Eurlex
bash $cur_dir/compute_sentence_TER.sh $data_dir
##Computing FMS on the source side of matches both for FMS and NeuroFMS only on TM
bash $cur_dir/compute_sfms.sh $data_dir
##Producing Table 2
bash $cur_dir/print_table_portion_useful_proposals.sh $data_dir

##Producing Figure 1
bash $cur_dir/prepare_TER_bars.sh $data_dir
bash $cur_dir/plot_TER_ranges.sh $data_dir

#Computing neuroFMS
bash $cur_dir/compute_COMET_fms.sh $data_dir $COMET_model_dir
#Correlation LaBSE vs COMETFMS
bash $cur_dir/get_correl_labse_vs_cometfms.sh $data_dir
#Combination of neuroFMS and FMS using neuroFMS
bash $cur_dir/get_total_TER_when_combining_with_neurofms.sh $data_dir
