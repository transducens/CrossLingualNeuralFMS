import sys
from mosestokenizer import *
import argparse


oparser = argparse.ArgumentParser(
    description="Script that takes two TSV files and sorts one of them follwing the seame order as the refference one. Sorting is done by taking into account the first two fields of the files")
oparser.add_argument("--l1", help="Lang 1", dest="lang1", required=True)
oparser.add_argument("--l2", help="Lang 2", dest="lang2", required=True)
oparser.add_argument("-r", "--ratio", help="Lenght ratio threshold", type=int, default=5)
options = oparser.parse_args()


stokenizer = MosesTokenizer(lang=options.lang1, escape_xml=False)
ttokenizer = MosesTokenizer(lang=options.lang2, escape_xml=False)

for line in sys.stdin:
    fields = line.strip().split("\t")
    toks_ref_s = float(len(stokenizer.tokenize(fields[0].lower())))
    toks_ref_t = float(len(ttokenizer.tokenize(fields[1].lower())))

    #if toks_ref_s > 1 and toks_ref_t > 1:
    if toks_ref_s >= 2:
        if max(toks_ref_s,toks_ref_t)/min(toks_ref_s,toks_ref_t) < options.ratio:
            sys.stdout.write(line)
#        else:
#            sys.stderr.write(line)
#    else:
#        sys.stderr.write(line)

