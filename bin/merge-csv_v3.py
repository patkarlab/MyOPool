#!/usr/bin/env python3

import pandas as pd
import os, sys
import re

args = sys.argv
sample = args[1]
filepath = args[2]
outfile = args[3]
cava_path = args[4]
coverview_path = args[5]
pindel_path = args[6]
cnvkit_path = args[7]
pharma_marker_path = args[8]
pindel_ubtf_path = args[9]
fit3_itd_ext_path = args[10]
append_final_concat = args[11]
filt3r = args[12]

#csvfilenames=[filepath+sample+'.final.concat.csv',cava_path+sample+'.cava.csv',pindel_path,coverview_path,filepath+sample+'.artefacts.csv',cnvkit_path,pharma_marker_path]
csvfilenames=[cava_path+sample+'.cava.csv',pindel_path,coverview_path,filepath+sample+'.artefacts.csv',cnvkit_path,pharma_marker_path,pindel_ubtf_path,fit3_itd_ext_path,append_final_concat,filt3r]

writer = pd.ExcelWriter(outfile)
for csvfilename in csvfilenames:
	if os.path.getsize(csvfilename) != 0:
		sheetname=os.path.split(csvfilename)[1]
		if csvfilename.endswith(".tsv"):
			df = pd.read_csv(csvfilename, sep="\t")
		else:
			df = pd.read_csv(csvfilename, sep=",")
		print('process file:', csvfilename, 'shape:', df.shape)
		new_sheet_name = os.path.splitext(sheetname)[0]
		new_sheet_name = re.sub (sample,"", new_sheet_name, flags = re.IGNORECASE).strip("._")
		df.to_excel(writer,sheet_name=new_sheet_name, index=False)
writer.close()
