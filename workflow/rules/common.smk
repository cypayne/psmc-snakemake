## import modules
import os
import warnings
import pandas as pd
from snakemake.utils import validate
import csv
from collections import defaultdict
import glob
import numpy as np

## prepare inputs
# read in inputs file
input_file = pd.read_table(config["input_file"]).set_index("sample", drop=False)

# grab samples
sample_list = list(input_file['sample'])
print(sample_list)

# grab input type
input_type=config["input_type"]
print(input_type)

# get list of bootstrap rounds 
boot_round_list = list(map(str, range(1, int(config["psmc"]["num_bootstraps"]) + 1)))


## wildcard constraints
wildcard_constraints:
    sample="|".join(sample_list),
    round="|".join(boot_round_list),


#### DEFINITIONS ####

def get_inputs(wildcards):
    ins = input_file.loc[(wildcards.sample),"infile_path"]
    return ins 

def get_fastas(wildcards):
    if input_type=="bam":
        return [f"results/bam2fasta/{wildcards.sample}.fasta"]
    elif input_type=="gvcf":
        return [f"results/gvcf2fasta/{wildcards.sample}.fasta"]
    else:   
        raise(ValueError("Oops! Input type should be bam or gvcf")) 

