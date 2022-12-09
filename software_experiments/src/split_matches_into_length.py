import sys
import argparse


oparser = argparse.ArgumentParser(
    description="Script that reads all a matches file, a TSV file with five fields, the last being the score assigned to a TM match, and splits into four pieces correspoinding to the quartiles of the scores.")
oparser.add_argument("--tokenized_source", help="File containing the source segment tokenized", dest="tok_source", required=True)
oparser.add_argument("--matches-file", help="File to be split", dest="split_file", required=True)
oparser.add_argument("-o", "--output-prefix", help="Prefix of the output file", dest="out_pref", required=True)
options = oparser.parse_args()

len_map={}

with open(options.tok_source,"r") as tok_source_reader, open(options.split_file,"r") as split_file_reader:
    for splits,matches_line in zip(tok_source_reader,split_file_reader):
        splits = splits.strip()

        ntoks = len(splits.split())
        if ntoks < 120:
            key = (1+ntoks // 5)*5
            if key not in len_map:
                len_map[key] = []
            len_map[key].append(matches_line.strip())

for length,samplelist in len_map.items():
    with open(options.out_pref+"."+str(length), "w") as writer:
        writer.write("\n".join(samplelist))
