from os import listdir
from os.path import isfile, join
import sys
from pathlib import Path
import math
import argparse


oparser = argparse.ArgumentParser(
    description="Script that reads all the TMX files in a directory, and produces N new files containing a similar number of TUs.")
oparser.add_argument("-s", "--source-lang",
                     help="Source language code (two characters)",
                     dest="sl", required=True)
oparser.add_argument("-t", "--target-lang",
                     help="Target language code (two characters)",
                     dest="tl", required=True)
oparser.add_argument("--splits", help="Number of output TMX",
                     dest="splits", type=int, required=True)
oparser.add_argument("--tm_dir", help="Dir that contains the translation memories",
                     dest="tm_dir", required=True)
oparser.add_argument("-o", "--output-pref", help="Prefix to the output files",
                     dest="o_pref", required=True)
oparser.add_argument('-p', '--src-path', default=None,
                      help='Path to find the tmx library; defining this is useful if using SLURM')
options = oparser.parse_args()

if options.src_path != None:
    import os
    sys.path.append(options.src_path)
from tmx import TMXFile


sl=options.sl
tl=options.tl

splits=options.splits

tm_files_dir=options.tm_dir

output_pref=options.o_pref

tm_files = [f for f in listdir(tm_files_dir) if isfile(join(tm_files_dir, f))]
tmx = TMXFile(sl, tl)
for f in tm_files:
    if f[-4:].lower() == ".tmx":
        #sys.stderr.write(str(f)+"\n")
        tmx.read_file(tm_files_dir+"/"+f)

num_tus = len(tmx.slorigsegs)
split_size = math.ceil(float(num_tus)/float(splits))

for s in range(0, splits):
    init_range = s*split_size
    end_range = init_range+split_size
    if end_range > num_tus:
        end_range = num_tus
    ouput_path = output_pref+"."+str(s)+".tmx"
    with open(ouput_path, "w") as ofile:
        tmx.write(ofile, (init_range, end_range))
