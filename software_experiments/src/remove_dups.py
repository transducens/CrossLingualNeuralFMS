import sys

seen=set()

for line in sys.stdin:
    fields = line.strip().split("\t")[0:2]
    if fields[0] != fields[1]:
        key = "\t".join(line.strip().split("\t")[0:2])
        if key not in seen:
            sys.stdout.write(line)
            seen.add(key)
