import sys
import argparse


parser = argparse.ArgumentParser(description='LASER: Mine bitext')
parser.add_argument('--max', required=True, type=float,
        help='Maximum value that TER can take to take the match into account')
parser.add_argument('--min', default=0.0, type=float,
        help='Minimum value that TER can take to take the match into account')

args = parser.parse_args()


valid=0
total=0
for line in sys.stdin:
    ter=float(line.strip().split()[-1])
    if ter<args.max and ter>=args.min:
        valid+=1
    total+=1
print("{:.1f}".format(100*(float(valid)/total)))
