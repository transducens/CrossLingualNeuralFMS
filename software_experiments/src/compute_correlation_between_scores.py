import sys
from scipy import stats
import numpy as np
import sys
import difflib
import argparse


oparser = argparse.ArgumentParser(
    description="Script that computes the correlation between the scores obtained when using two different matching methods. It takes to TSV as input, in which scores are placed in the 5th field, and computes Pearson's correlation.")
oparser.add_argument("-f", "--ranking_file",
                     help="File with the results to be compared to TER",
                     dest="scoresfile", required=True)
oparser.add_argument("-t", "--TERfile",
                     help="File with the TER scores",
                     dest="terscoresfile", required=True)
options = oparser.parse_args()


scores = []
ters = []
with open(options.scoresfile, "r") as f1reader, open(options.terscoresfile, "r") as f2reader:
    for f1line,f2line in zip(f1reader, f2reader):
        score=f1line.strip("\n")
        ter=f2line.split()[-1].strip("\n")
        scores.append(float(score))
        ters.append(float(ter))

rcorrel = stats.pearsonr(scores, ters)
kcorrel = stats.kendalltau(scores, ters)
print(str(kcorrel[0])+"/"+str(rcorrel[0]))
