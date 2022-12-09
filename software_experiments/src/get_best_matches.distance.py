from os import listdir
from os.path import isfile, join
from difflib import SequenceMatcher
import sys
from pathlib import Path
import distance
import argparse


def get_close_matches(seg, possibilities):
    result = (1.0,0)
    best_ratio = 1.0
    seglen=len(seg)
    for pos in range(0, len(possibilities)):
        x = possibilities[pos]
        xlen = len(x)
        normfactor = float(max(seglen,xlen))
        if abs(seglen - xlen)/normfactor < best_ratio:
            ratio = distance.levenshtein(seg,x)/normfactor
            if ratio < best_ratio:
                result = (ratio, pos)
                best_ratio = ratio

    return result


oparser = argparse.ArgumentParser(
    description="Script that reads all the TMX files in a directory, and produces N new files containing a similar number of TUs.")
oparser.add_argument("-s", "--source-lang", help="Source language code (two characters)", dest="sl", required=True)
oparser.add_argument("-t", "--target-lang", help="Target language code (two characters)", dest="tl", required=True)
oparser.add_argument("--tm_dir", help="Dir that contains the TMX files to be read", dest="tm_dir", required=True)
oparser.add_argument("--file_to_translate", help="TMX file to be readed", dest="tm_file_to_translate", default=None)
oparser.add_argument("-c", "--corpus-to-translate", help="Directory that contains a list of TMX files for which the source-side must be translated", dest="corpus_to_translate_dir", default=None)
oparser.add_argument("-o", "--output-file", help="Output file", dest="o_file", default=None)
options = parser.parse_args()

if args.src_path != None:
    import os
    sys.path.append(args.src_path)
    print(sys.path)
from tmx import TMXFile

sl=options.sl
tl=options.tl

if options.corpus_to_translate_dir != None:
    corpus_files_dir=options.corpus_to_translate_dir
    if options.tm_file_to_translate != None:
        sys.stderr.write("corpus_to_translate_dir and tm_file_to_translate cannot be defined simultaneously. Please, choose only one of these options.\n")
        exit(-1)
    else:
        corpus_files = [f for f in listdir(corpus_files_dir) if isfile(join(corpus_files_dir, f))]
        tmx_corpus_files = TMXFile(sl, tl)
        for f in corpus_files:
            if f[-4:].lower() == ".tmx":
                tmx_corpus_files.read_file(corpus_files_dir+"/"+f)

elif options.tm_file_to_translate != None:
    tmx_corpus_files = TMXFile(sl, tl)
    tmx_corpus_files.read_file(options.tm_file_to_translate)
else:
    sys.stderr.write("Either corpus_to_translate_dir and tm_file_to_translate options must be defined.\n")
    exit(-1)

tm_files_dir = options.tm_dir
tm_files = [f for f in listdir(tm_files_dir) if isfile(join(tm_files_dir, f))]
tmx = TMXFile(sl, tl)
for f in tm_files:
    if f[-4:].lower() == ".tmx":
        tmx.read_file(tm_files_dir+"/"+f)

sys.stderr.write("TM Read\n")

if options.o_file == None:
   for corpus_seg_pos in range(0,len(tmx_corpus_files.slsegs)):
        corpus_seg = tmx_corpus_files.slsegs[corpus_seg_pos]
        ratio, best_candidate_pos = get_close_matches(corpus_seg, tmx.slsegs)
        print(tmx_corpus_files.slorigsegs[corpus_seg_pos]+"\t"+tmx_corpus_files.tlorigsegs[corpus_seg_pos]+"\t"+tmx.slorigsegs[best_candidate_pos]+"\t"+tmx.tlorigsegs[best_candidate_pos]+"\t"+str(1.0-ratio))

else:
    with open(options.o_file, "w") as ofile:
        for corpus_seg_pos in range(0,len(tmx_corpus_files.slsegs)):
            corpus_seg = tmx_corpus_files.slsegs[corpus_seg_pos]
            ratio, best_candidate_pos = get_close_matches(corpus_seg, tmx.slsegs)
            sys.stderr.write("Best candidate found\n")
            best_candidate = tmx.slorigsegs[best_candidate_pos]
            #ofile.write(" ".join(tmx_corpus_files.stokenizer.tokenize(tmx_corpus_files.slorigsegs[corpus_seg_pos]))+"\t"+" ".join(tmx_corpus_files.stokenizer.tokenize(best_candidate))+"\t"+str(1.0-ratio)+"\n")
            ofile.write(tmx_corpus_files.slorigsegs[corpus_seg_pos]+"\t"+tmx_corpus_files.tlorigsegs[corpus_seg_pos]+"\t"+tmx.slorigsegs[best_candidate_pos]+"\t"+tmx.tlorigsegs[best_candidate_pos]+"\t"+str(1.0-ratio)+"\n")
