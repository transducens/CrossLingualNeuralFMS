import sys
import argparse


oparser = argparse.ArgumentParser(
    description="Script that takes two TSV files and sorts one of them follwing the seame order as the refference one. Sorting is done by taking into account the first two fields of the files")
oparser.add_argument("-f", "--file-to-sort",
                     help="File to be sorted",
                     dest="ftosort", required=True)
oparser.add_argument("-r", "--refference",
                     help="Refference file",
                     dest="fref", required=True)
options = oparser.parse_args()

tobesorted = options.ftosort
refference = options.fref

to_be_sorted_map={}
with open(tobesorted, "r") as tosortreader:
    for line in tosortreader:
        fields = line.rstrip('\n').split('\t')
        to_be_sorted_map[fields[0]+"\t"+fields[1]] = line

with open(refference, "r") as refreader:
    for line in refreader:
        fields = line.rstrip('\n').split('\t')
        sys.stdout.write(to_be_sorted_map[fields[0]+"\t"+fields[1]])
