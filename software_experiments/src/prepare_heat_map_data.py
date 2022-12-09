import sys
import math

len_fms_counter={}
for line in sys.stdin:
    fields = line.strip().split("\t")
    fms = float(fields[4])
    length = int(fields[5])
    if length < 100:
        fms_floor=math.floor(fms*10.0)/10.0
        if fms_floor == 1.0:
            fms_floor = 0.9
        length_floor=(1+length//5)*5
        if fms_floor not in len_fms_counter:
            len_fms_counter[fms_floor] = {}
        if length_floor not in len_fms_counter[fms_floor]:
            len_fms_counter[fms_floor][length_floor] = 0
        
        len_fms_counter[fms_floor][length_floor] += 1

for fms_pos in range(0,10,1):
    fms_pos = fms_pos/10.0
    total = 0
    for len_pos in range(5,105,5):
        if len_pos in len_fms_counter[fms_pos]:
            total += len_fms_counter[fms_pos][len_pos]
    for len_pos in range(5,105,5):
        if len_pos in len_fms_counter[fms_pos]:
            print(str(fms_pos*100)+"\t"+str(len_pos)+"\t"+str(float(len_fms_counter[fms_pos][len_pos])*100.0/float(total)))
        else:
            print(str(fms_pos*100)+"\t"+str(len_pos)+"\t0")

    print()

    
