#!/bin/env python3

import pandas as pd
import numpy as np
import os
import sys
import subprocess
import re

args = sys.argv
bed = args[1]
multi_anno_file = args[2]
outfile = args[3]

# Read and fix NTLEN — write to temp
with open(multi_anno_file, "r") as file:
	content = file.read()

content = re.sub(r'NTLEN=(\d+),(\d+)', r'NTLEN=\1;\2', content)

tmp_multianno = multi_anno_file + ".fixed.tmp"
with open(tmp_multianno, "w") as file:
	file.write(content)

# Load BED file
df = pd.read_csv(bed, header=None, sep="\t")

if os.stat(tmp_multianno).st_size != 0:
	df.columns = ["A", "B", "C", "D", "E"]
	df1 = pd.read_csv(tmp_multianno)
	
	df1.insert(loc=5, column='AF', value=0.000)
	df1.insert(loc=6, column='VAF', value=0.000)
	df1.insert(loc=7, column='AR', value=0.000)
	df1.insert(loc=8, column='Ref_Count', value=0.0)
	df1.insert(loc=9, column='Alt_Count', value=0.0)

	for i in range(len(df1)):
		df1.at[i, "Alt_Count"] = str(df1["Otherinfo"][i]).split(",")[1]

	df1["Alt_Count"] = pd.to_numeric(df1["Alt_Count"], errors='coerce')
	df1["Ref_Count"] = pd.to_numeric(df1["Ref_Count"], errors='coerce')

	for i in range(len(df)):
		for j in range(len(df1)):
			if (df1["Start"][j] in range(df["B"][i], df["C"][i])) and df1["Chr"][j] == df["A"][i]:
				df1.at[j, "Ref_Count"] = df["E"][i] + 0.0
				df1.at[j, 'AF'] = df1['Alt_Count'][j] / df1['Ref_Count'][j]
				df1.at[j, "AR"] = df1['AF'][j] / (1 - df1['AF'][j])
				df1.at[j, 'VAF'] = df1['Alt_Count'][j] / df1['Ref_Count'][j] * 100

	df1.to_csv(outfile, index=False)
else:
	subprocess.run(['touch', outfile], stdout=subprocess.DEVNULL)
