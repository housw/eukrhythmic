import pandas as pd
import numpy as np
import os
import sys
import yaml 

with open("config.yaml", "r") as configfile:
    config = yaml.load(configfile)

indexfile = pd.read_csv(config["metaT_sample"], sep = "\t")
samplenames = list(indexfile.SampleID)
filenames = list(indexfile.FastqFile)

# The purpose of this script is to create a tab-delimited
# file containing the names of the data sources from
# the input table and assigning each to an 
# assembly group. 

# Later, this will be adapted to take into account
# sourmash comparisons (I don't yet know how to 
# incorporate this into the snakemake workflow, but
# I will get there!). 

assemblygroups = []
#assemblygroups.append(filenames) # this will be better later; for now every sample is in assembly group 1
assemblygroups.append(indexfile[indexfile.SampleName == "S2"].FastqFile) # group of those in the diel grouping
assemblygroups.append(indexfile[indexfile.SampleName != "S2"].FastqFile)

assemblyfile = pd.DataFrame({'AssemblyGroup': [], \
                             'SampleName': []})

for a in range(0,len(assemblygroups)):
    groupname = str(a+1)
    thisgroup = pd.DataFrame({'AssemblyGroup': [groupname] * len(assemblygroups[a]), \
                              'FastqFile': assemblygroups[a]})
    assemblyfile = assemblyfile.append(thisgroup)

assemblyfile.to_csv(path_or_buf = os.path.join("input", "assemblyfile.txt"), sep = "\t")
