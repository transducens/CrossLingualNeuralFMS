#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please, provide the directory where the Autodesk *.bz2 files are stored"
    exit -1
else
    data_dir=$1
    if [[ -d "$data_dir" ]]; then
            echo "Computing"
    else
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi


bzcat $data_dir/esp.tm.bz2 | sed -r 's/+/\t/g' | cut -f 1,2,8 | python -c 'import sys
for line in sys.stdin:
    fields=line.strip().split("\t")
    fields[2]=str(float(fields[2])/100.0)
    print("\t".join(fields))' | sed 's/^/"/g' | sed 's/$/"/g' | sed 's/\t/","/g' > COMET_data.tsv

bzcat $data_dir/deu.tm.bz2 | sed -r 's/+/\t/g' | cut -f 1,2,8 | python -c 'import sys
for line in sys.stdin:
    fields=line.strip().split("\t")
    fields[2]=str(float(fields[2])/100.0)
    print("\t".join(fields))' | sed 's/^/"/g' | sed 's/$/"/g' | sed 's/\t/","/g' >> COMET_data.tsv

bzcat $data_dir/csy.tm.bz2 | sed -r 's/+/\t/g' | cut -f 1,2,8 | python -c 'import sys
for line in sys.stdin:
    fields=line.strip().split("\t")
    fields[2]=str(float(fields[2])/100.0)
    print("\t".join(fields))' | sed 's/^/"/g' | sed 's/$/"/g' | sed 's/\t/","/g' >> COMET_data.tsv

cat COMET_data.tsv | shuf > COMET_data.shuf.tsv
