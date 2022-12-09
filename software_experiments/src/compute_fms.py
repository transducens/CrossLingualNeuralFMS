import distance
from mosestokenizer import *
import argparse
import sys


oparser = argparse.ArgumentParser(
    description="Script that takes two TSV files and sorts one of them follwing the seame order as the refference one. Sorting is done by taking into account the first two fields of the files")
oparser.add_argument("-l", "--lang", help="Language code", dest="lang", required=True)
options = oparser.parse_args()

stokenizer = MosesTokenizer(lang=options.lang, escape_xml=False)

for line in sys.stdin:
    fields = line.strip().split("\t")
    toks_ref = stokenizer.tokenize(fields[0])
    toks_ref = [x.lower() for x in toks_ref]
    toks_hyp = stokenizer.tokenize(fields[1])
    toks_hyp = [x.lower() for x in toks_hyp]
    print(1.0-distance.levenshtein(toks_ref,toks_hyp)/float(max(len(toks_ref),len(toks_hyp))))

