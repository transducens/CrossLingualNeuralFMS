#! /bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide a data dir"
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

splitdir=$(mktemp)
rm $splitdir
mkdir $splitdir

for langpair in "en-es" "en-de" "en-cs" "en-fi"; do
        slang=$(echo $langpair | cut -d '-' -f 1)
        tlang=$(echo $langpair | cut -d '-' -f 2)
	dataset=$data_dir/$langpair/ter_ranges_$(echo $langpair | tr -d "-").tsv
	gnuplot_script=$(mktemp)
   

        echo "set term postscript eps color blacktext \"Helvetica\" 24" > $gnuplot_script
        echo "set title \"${langpair^^}\" font \",20\"" >> $gnuplot_script
        echo "set output \"$data_dir/$langpair/ter_ranges_$(echo $langpair | tr -d "-").eps\"" >> $gnuplot_script
        echo "set style data histogram"  >> $gnuplot_script
        echo "set style histogram cluster gap 1" >> $gnuplot_script
        echo "set style fill solid border rgb \"black\"" >> $gnuplot_script
        echo "set auto x" >> $gnuplot_script
        echo "set yrange [0:38]" >> $gnuplot_script
        echo "plot \"$dataset\" using 2:xtic(1) title col, '' using 3:xtic(1) title col, '' using 4:xtic(1) title col, '' using 5:xtic(1) title col" >> $gnuplot_script

        gnuplot < $gnuplot_script
	rm $gnuplot_script
done
