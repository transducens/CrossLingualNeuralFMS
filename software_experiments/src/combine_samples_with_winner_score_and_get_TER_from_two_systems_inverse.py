import sys

for line in sys.stdin:
    fields = line.strip().split("\t")
    score1 = float(fields[-4])
    #score1 = round(float(fields[-4]),2)
    score2 = float(fields[-3])
    #score2 = round(float(fields[-3]),2)
    ter1 = float(fields[-2].split()[-1])
    ter2 = float(fields[-1].split()[-1])
    if (ter1 < 0.4 or ter2 < 0.4):
        #and (abs(score1-score2)>0.001):
        #sys.stderr.write(str(score1)+"\t"+str(score2)+"\t"+str(ter1)+"\t"+str(ter2)+"\n")
        if score1 < score2:
            print(str(score2)+"\t"+fields[-1])
        else:
            print(str(score1)+"\t"+fields[-2])
