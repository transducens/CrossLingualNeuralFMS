import sys

for line in sys.stdin:
    sys.stdout.write(" ".join(line.strip().split()))
    sys.stdout.write("\n")
