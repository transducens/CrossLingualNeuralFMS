import sys

for line in sys.stdin:
    fields = line.strip().split("\t")
    score1 = float(fields[0])
    score2 = float(fields[1])
    ter1 = float(fields[2].split()[3])
    ter2 = float(fields[3].split()[3])
    if ter1 < 0.4 or ter2 < 0.4:
        if ter1 < ter2:
            print(fields[2])
        else:
            print(fields[3])
