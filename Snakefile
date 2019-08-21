configfile: "config.yaml"

import io
import os
from os import listdir
from os.path import isfile, join
import pandas as pd
import numpy as np
import pathlib
from snakemake.exceptions import print_exception, WorkflowError

DATAFILE = config["metaT_sample"]
INPUTDIR = config["inputDIR"]
OUTPUTDIR = config["outputDIR"]
ASSEMBLYFILE = config["assembly"]
SCRATCHDIR = config["scratch"]
INPUTFILES = [f for f in os.listdir(INPUTDIR) if isfile(join(INPUTDIR, f))];

samplenames = list(pd.read_csv(DATAFILE, sep = "\t").SampleID);

sample_barcodes = dict();
sample_codes = dict();

# create a dictionary that contains a list with the relevant
# information about each sample: the barcode and the L code
def get_base_names():
    for i in INPUTFILES:
        split_i = i.split("_")
        if (split_i[0] in samplenames) & (split_i[0] != "SH265"):
            sample_barcodes[split_i[0]] = split_i[1]
            sample_codes[split_i[0]] = split_i[2]

notatest = True # if false, this is a test

filenames = []
if notatest:
    get_base_names()
    #print(sample_barcodes.values())

    filenames = []
    name1 = list(sample_barcodes.keys())
    name2 = list(sample_barcodes.values())
    name3 = list(sample_codes.values())

if notatest:
    for i in range(0, len(name1)-1):
        filenames.append(str(name1[i]) + "_" + str(name2[i]) + "_" + str(name3[i]))
else:
    for i in range(0, len(samplenames)):
        filenames.append(str(samplenames[i] + "_test"))

assemblygroups = list(set(pd.read_csv(ASSEMBLYFILE, sep = "\t").AssemblyGroup))

include: "modules/fastqc-snake"
include: "modules/trimmomatic-snake"
include: "modules/fastqc-trimmed-snake"
include: "modules/trinity-snake"

print(assemblygroups)

rule all:
    input:
        # FASTQC OUTPUTS
        fastqc1 = expand("{base}/qc/fastqc/{file}.{ext}", base = OUTPUTDIR, file = filenames, ext = ["zip", "html"]),
        # TRIMMOMATIC OUTPUTS
        trimmed = expand("{base}/firsttrim/{id_name}_{num}.trimmed.fastq.gz", base = OUTPUTDIR, id_name = filenames, num = [1,2]),
        # FASTQC 2 OUTPUTS (trimmed)
        fastqc2 = expand("{base}/qc/fastqc_trimmed/{file}_{num}.trimmed.{ext}", base = OUTPUTDIR, file = filenames, num = [1,2], ext = ["zip", "html"]),
        # TRINITY OUTPUTS
        trinity = expand("{base}/trinity_results_assembly_{assembly}/Trinity.fasta", base = OUTPUTDIR, assembly = assemblygroups)
