#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please, provide a data dir and the directory where EurLex verts can be found"
    exit -1
else
    src_dir=$(realpath $(dirname $0)/../src)
    data_dir=$1
    verts=$2
    if [[ -d "$data_dir" ]]; then
        echo "Creating sents from verts"
    else
        echo "The data directory provided $data_dir does not exist"
        exit -1
    fi
fi

xzcat $verts/SPA.vert.xz | python $src_dir/vert_to_sents.py | grep -v '^\s*$' | gzip > $data_dir/en-es/es.sents.gz &
xzcat $verts/DEU.vert.xz | python $src_dir/vert_to_sents.py | grep -v '^\s*$' | gzip > $data_dir/en-de/de.sents.gz &
xzcat $verts/FIN.vert.xz | python $src_dir/vert_to_sents.py | grep -v '^\s*$' | gzip > $data_dir/en-fi/fi.sents.gz &
xzcat $verts/CES.vert.xz | python $src_dir/vert_to_sents.py | grep -v '^\s*$' | gzip > $data_dir/en-cs/cs.sents.gz &
wait
