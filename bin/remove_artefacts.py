#!/usr/bin/env python3

import sys
import csv

## arg1 => concat combined + somatic csv file
## arg2 => artefact csv
## arg3 => final csv without artefact outfile
## arg4 => artefact variants outfile

HEADER = [
    "Chr","Start","End","Ref","Alt","Variant_Callers","FILTER",
    "SOMATIC_FLAG","VariantCaller_Count","REF_COUNT","ALT_COUNT","VAF",
    "Func.refGene","Gene.refGene","ExonicFunc.refGene","AAChange.refGene",
    "Gene_full_name.refGene","Function_description.refGene",
    "Disease_description.refGene","cosmic84","PopFreqMax","1000G_ALL",
    "ExAC_ALL","CG46","ESP6500siv2_ALL","InterVar_automated"
]

blackList = [] #artefact list
finalList = [] #without artefact final list

with open(sys.argv[1], 'r') as variantFile:
        variant_reader = csv.reader(variantFile)
        for variant in variant_reader:
                list1 = [variant]
                counter = 0
                with open(sys.argv[2], 'r') as artefactFile:
                        artefact_reader = csv.reader(artefactFile)
                        for artefact in artefact_reader:
                                list2 = [artefact]
                                if list1[0][0] == list2[0][0] and list1[0][1] == list2[0][1] and list1[0][4] == list2[0][3]:
                                        blackList.append(list1[0])
                                        counter = 1
                if counter == 0:
                        finalList.append(list1[0])

# writing lists to csv files
with open(sys.argv[3], 'w') as outfile_final:
        writer = csv.writer(outfile_final)
        writer.writerow(HEADER)
        writer.writerows(finalList)

with open(sys.argv[4], 'w') as outfile_artefacts:
        writer = csv.writer(outfile_artefacts)
        writer.writerow(HEADER)
        writer.writerows(blackList)

outfile_final.close()
outfile_artefacts.close()