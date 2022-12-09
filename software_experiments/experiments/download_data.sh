#! /bin/bash

if [ "$#" -ne 2 ]; then
	echo "Please, provide two arguments: the work directory (this directory must exist) and the number of splits"
    exit -1
else
    work_dir=$(realpath $1)
    num_splits=$2
    if [[ -d "$work_dir" ]]; then
        echo "Creating data directories"
    else
        echo "The work directory provided $work_dir does not exist"
	exit -1
    fi
fi
mkdir -p $work_dir/data

mkdir -p $work_dir/data/tm
mkdir -p $work_dir/data/to_translate

curdir=$(pwd)

#Downloading TMs from 2019 to emulate a TM
cd $work_dir/data/tm
wget http://wt-public.emm4u.eu/Resources/DGT-TM-2019/Vol_2018_1.zip
wget http://wt-public.emm4u.eu/Resources/DGT-TM-2019/Vol_2018_2.zip
wget http://wt-public.emm4u.eu/Resources/DGT-TM-2019/Vol_2018_3.zip
for f in $(ls *.zip); do
        unzip -o $f
done

#Downloading TMs from 2020 to create the test set
cd $work_dir/data/to_translate
wget http://wt-public.emm4u.eu/Resources/DGT-TM-2020/Vol_2019_1.zip
wget http://wt-public.emm4u.eu/Resources/DGT-TM-2020/Vol_2019_2.zip
for f in $(ls *.zip); do
        unzip -o $f
done

#Splitting the test TMX into same size N TMXs, in order to enable parallelisation of processing
mkdir -p $work_dir/data/en-es/to_translate/splits
mkdir -p $work_dir/data/en-fi/to_translate/splits
mkdir -p $work_dir/data/en-cs/to_translate/splits
mkdir -p $work_dir/data/en-de/to_translate/splits
python $curdir/../src/merge_and_split_TMX.py -s EN -t ES --splits $num_splits --tm_dir $work_dir/data/to_translate -o $work_dir/data/en-es/to_translate/splits/tm_split -p $curdir/../src
python $curdir/../src/merge_and_split_TMX.py -s EN -t FI --splits $num_splits --tm_dir $work_dir/data/to_translate -o $work_dir/data/en-fi/to_translate/splits/tm_split -p $curdir/../src
python $curdir/../src/merge_and_split_TMX.py -s EN -t CS --splits $num_splits --tm_dir $work_dir/data/to_translate -o $work_dir/data/en-cs/to_translate/splits/tm_split -p $curdir/../src
python $curdir/../src/merge_and_split_TMX.py -s EN -t DE --splits $num_splits --tm_dir $work_dir/data/to_translate -o $work_dir/data/en-de/to_translate/splits/tm_split -p $curdir/../src

cd $curdir
