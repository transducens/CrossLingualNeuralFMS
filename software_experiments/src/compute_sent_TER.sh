#! /bin/bash

if [ "$#" -ne 2 ]; then
    echo "Please, provide a file with the reference and the hypothesis to be evaluated, and the language in which text is writen"
    exit -1
else
    textfile=$1
    lang=$2
    if [[ ! -f "$textfile" ]]; then
        echo "File $textfile does not exist"
        exit -1
    fi
fi

src_dir=$(realpath $(dirname $0))

ref=$(mktemp)
hyp=$(mktemp)

#cut -f 2 $textfile | egrep -n  "*" | sed 's/^\([0-9]*\):\(.*\)$/\2  (\1)/g' > $ref &
cut -f 2 $textfile | python $src_dir/norm_spaces.py |  egrep -n  "*" | sed 's/^\([0-9]*\):\(.*\)$/\2  (\1)/g' > $ref &
#cut -f 4 $textfile | egrep -n  "*" | sed 's/^\([0-9]*\):\(.*\)$/\2  (\1)/g' > $hyp
cut -f 4 $textfile | python $src_dir/norm_spaces.py | egrep -n  "*" | sed 's/^\([0-9]*\):\(.*\)$/\2  (\1)/g' > $hyp
wait

java -cp $src_dir/../multeval/lib/tercom-0.8.0.jar ter.TERtest -r $ref -h $hyp -n $textfile -o ter -s  | egrep "^baseline"| sed 's/baseline *//g' | cut -d ' ' -f 1 | tr ',' '.'
#java -cp $src_dir/../multeval/lib/tercom-0.8.0.jar ter.TERtest -r $ref -h $hyp -n $textfile -o ter -s 2> /dev/null  | egrep "^baseline"| sed 's/baseline *//g' | cut -d ' ' -f 1 | tr ',' '.'

#cat $textfile.ter > $textfile.ter.tmp
cat $textfile.ter | tail -n+3 > $textfile.ter.tmp
mv $textfile.ter.tmp $textfile.ter

rm $ref $hyp

