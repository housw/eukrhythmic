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
SCRATCHDIR = config["scratch"]
#INPUTFILES = [[os.path.join(curr,f) for f in os.listdir(os.path.join(INPUTDIR, curr)) if isfile(join(os.path.join(INPUTDIR, curr), f))] for curr in INPUTDIRs.split(",")];
#INPUTFILES = [item for sublist in INPUTFILES for item in sublist]

SAMPLEINFO = pd.read_csv(DATAFILE, sep = "\t")
samplenames = list(SAMPLEINFO.SampleID);
fastqnames = list(SAMPLEINFO.FastqFile);
print(fastqnames)
for currfile in fastqnames:
    if isfile(os.path.join(INPUTDIR, currfile + "_R1_001.fastq.gz")):
        print("yo")
    else:
        print(os.path.join(INPUTDIR, currfile + "_R1_001.fastq.gz"))
filenames = [currfile for currfile in fastqnames if isfile(os.path.join(INPUTDIR, currfile + "_R1_001.fastq.gz"))]

print(filenames)

if config["separategroups"] == 1:
    assemblygroups = list(set(SAMPLEINFO.AssemblyGroup))
else:
    assemblygroups = [1] * len(INPUTFILES)

include: "modules/fastqc-snake"
include: "modules/trimmomatic-snake"
include: "modules/fastqc-trimmed-snake"
include: "modules/trinity-snake"
include: "modules/velvet-snake"

rule all:
    input:
        # FASTQC OUTPUTS
        fastqc1 = expand(["{base}/qc/fastqc/{sample}_{num}.html", "{base}/qc/fastqc/{sample}_{num}.zip"], zip, base = OUTPUTDIR, sample = filenames, num = [1,2]),
        # TRIMMOMATIC OUTPUTS
        trimmed = expand(["{base}/firsttrim/{sample}_1.trimmed.fastq.gz", "{base}/firsttrim/{sample}_2.trimmed.fastq.gz"], zip, base = OUTPUTDIR, sample = filenames),
        # FASTQC 2 OUTPUTS (trimmed)
        fastqc2 = expand(["{base}/qc/fastqc_trimmed/{sample}_{num}.trimmed.html", "{base}/qc/fastqc_trimmed/{sample}_{num}.trimmed.zip"], zip, base = OUTPUTDIR, sample = filenames, num = [1,2]),
        # TRINITY OUTPUTS
        trinity = expand("{base}/trinity_results_assembly_{assembly}/Trinity.fasta", base = OUTPUTDIR, assembly = assemblygroups)
