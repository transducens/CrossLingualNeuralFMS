#!/usr/bin/env python

from sentence_transformers import SentenceTransformer
from os import listdir
from os.path import isfile, join
from pathlib import Path
import sys
import gzip
import pickle
import argparse


def dump_model(prefix, scorpus_segs, tcorpus_segs):
    if args.multilingual:
        model = SentenceTransformer('LaBSE')
        #model = SentenceTransformer('paraphrase-multilingual-mpnet-base-v2')
    else:
        model = SentenceTransformer('paraphrase-mpnet-base-v2')
    
    if args.embed_target:
        sentence_embeddings = model.encode(tcorpus_segs)
    else:
        sentence_embeddings = model.encode(scorpus_segs)
    
    corpus = []
    
    for pair in zip(scorpus_segs, tcorpus_segs):
        corpus.append(pair)
    
    with open(prefix+".sents", 'wb') as output:
        pickle.dump(corpus, output)
    
    with open(prefix+".embs", 'wb') as output:
        sentence_embeddings.tofile(output)


parser = argparse.ArgumentParser(description='LASER: Mine bitext')
parser.add_argument('-s', '--src-lang', required=True,
        help='Source language code')
parser.add_argument('-t', '--trg-lang', required=True,
        help='Target language code')
parser.add_argument('-d', '--tm-dir', default=None,
        help='Directory containing the TMs to be processed')
parser.add_argument('-g', '--gzipped-sentlist', default=None,
        help="Instead of providing a directory with TMX, users can provide a .gz file with a list of segments to be processed")
parser.add_argument('-o', '--output-prefix', required=True,
        help='Prefix to the output files, with extensions .emb and .sents')
parser.add_argument('--embed-target', action='store_true',
        help='If enabled, target segment is embedded; otherwise, source target is embedded')
parser.add_argument('-m', '--multilingual', action='store_true',
        help='If enabled, multilingual embeddings are computed; otherwise monolingual embeddings are obtained')
parser.add_argument('-p', '--src-path', default=None,
        help='Path to find the tmx library; defining this is useful if using SLURM')
args = parser.parse_args()

if args.src_path != None:
    import os
    sys.path.append(args.src_path)
    print(sys.path)
from tmx import TMXFile

multilingual_string=""
if args.multilingual:
    multilingual_string="multilingual"
else:
    multilingual_string="monolingual"

target_string=""
if args.embed_target:
    target_string="target"
else:
    target_string="source"

sys.stderr.write("Running "+multilingual_string+" embeddings extraction on "+target_string+" side\n")

scorpus_segs = []
tcorpus_segs = []

NLINESREAD=100000
if args.tm_dir != None:
    tm_files = [f for f in listdir(args.tm_dir) if isfile(join(args.tm_dir, f)) and f.endswith(".tmx")]
    tmx = TMXFile(args.src_lang, args.trg_lang)
    for f in tm_files:
        tmx.read_file(args.tm_dir+"/"+f)
    
    sys.stderr.write("TM Read\n")
    
    for corpus_seg_pos in range(0,len(tmx.slsegs)):
        tcorpus_segs.append(tmx.tlorigsegs[corpus_seg_pos])
        scorpus_segs.append(tmx.slorigsegs[corpus_seg_pos])
    dump_model(args.output_prefix, scorpus_segs, tcorpus_segs)

elif args.gzipped_sentlist != None:
    counter = 0
    with gzip.open(args.gzipped_sentlist, mode='rt') as sentreader:
        for line in sentreader:
            counter += 1
            tcorpus_segs.append(line.strip())
            if counter % NLINESREAD == 0:
                scorpus_segs = tcorpus_segs
                dump_model(args.output_prefix+"."+str(int(counter / NLINESREAD)), scorpus_segs, tcorpus_segs)
                tcorpus_segs = []
                scorpus_segs = None
            #sys.stderr.write(line.strip()+"\n")
    scorpus_segs = tcorpus_segs
    dump_model(args.output_prefix+"."+str(int(counter / NLINESREAD)), scorpus_segs, tcorpus_segs)
else:
    sys.stderr.write("It is mandatory to either define argument -g (a gzipped file with the segments to be compressed) or -d (a directory containing a list of TMX files to be read).")
    sys.exit(-1)

dump_model(args.output_prefix, scorpus_segs, tcorpus_segs)
