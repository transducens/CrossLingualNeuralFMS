import sys

total_errors = 0
total_lines = 0
for line in sys.stdin:
    fields = line.strip().split()
    total_errors += float(fields[-3])
    total_lines += float(fields[-2])

print(float(total_errors)/float(total_lines))
