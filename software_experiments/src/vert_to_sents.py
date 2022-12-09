import sys

prev_nontok = False

for line in sys.stdin:
    line = line.strip()
    if line == "</p>" or line == "</s>":
        print()
        prev_nontok = False
    elif line == "<g/>":
        prev_nontok = True
    elif line == "<s>" or line == "<p>":
        prev_nontok = True
    elif line[0] == "<":
        continue
    else:
        tok = line.split("\t")[0]
        if not prev_nontok:
            sys.stdout.write(" ")
        sys.stdout.write(tok)
        prev_nontok = False

