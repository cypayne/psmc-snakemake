# psmc-snakemake

A pipeline that takes sample GVCFs and the reference genome, converts them into PSMC inputs, and runs them through [PSMC](https://github.com/lh3/psmc), to infer population size over time.

## Runs through the following steps
- Convert GVCF to pseudogenome fasta by swapping out variants in the reference genome
- Generate a PSMCFA input file
- Run PSMC
- Bootstrap PSMC 

## Inputs

Required:
- GVCF(s), one per sample 
- Reference genome (same one used to map/call variants)

## How To Use

1. This is a snakemake pipeline that uses Mamba/Conda environments. So, install Mamba if you haven't already, and 
create a conda environment with your snakemake specs (see the [Snakemake Installation guide](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)). 
I developed and tested this pipeline with snakemake v7.32.4 and python v3.11, so I'd recommend creating an environment with 
those versions! Proceed with a later version at your own risk!
```
mamba create -c conda-forge -c bioconda -n popgen-filters-snakemake snakemake-7.32.4
mamba install python=3.11
``` 

2. Git clone this repository into your working directory
```
git clone https://github.com/cypayne/popgen-filters-snakemake.git
```

3. Edit the provided config.yaml file to reflect your data and filtering needs.

4. If you are using a cluster with a job scheduler like Slurm, and would like to schedule the snakemake
jobs to take advantage of compute nodes, you can create a profile specifying the nodes, 
resource limits, etc specific to your cluster 
(you can use the provided hpcc-profiles/slurm/sedna profile as a guide - you may not need to change much).

5. Activate your snakemake Mamba environment 
```
mamba activate popgen-filters-snakemake
```

6. Run your pipeline!
On cluster with job scheduler, take advantage of compute nodes with:
```
snakemake -p --profile hpcc-profiles/slurm/cluster --configfile config.yaml 
```
On local machine:
```
snakemake -p --configfile config.yaml
```


## Configuration - config.yaml 
You can edit the provided config.yaml file to reflect your data and filtering needs.

### Sample list 
A list of samples is required
```
## in config.yaml
input_file: "inputs/gvcfs.txt"
```

The sample list has a header and two tab-delimited columns with sample name in the first column and the path to the GVCF in the second column. 
```
sample  infile_path
CH000001    data/gvcfs/CH000001.g.vcf.gz
CH000002    data/gvcfs/CH000002.g.vcf.gz
```

### Reference genome
A reference genome used for mapping to generate the GVCF is required
```
## in config.yaml
genome_path: "inputs/genome.fasta"
```

### Chromosome list
A list of chromosomes to be included is required
```
## in config.yaml
chrom_subset_file: "inputs/chromosomes.txt"
```

The chromosome list has one column of the names of chromosomes that should be included in the analysis. If all chromosomes should be included, then list all of them. There is no header. 
```
chrom1
chrom2
chrom3
```

### PSMC parameters
There are a few parameters that you should set for PSMC.

The PSMC atomic time interval parameters you use are important, as using inappropriate intervals can lead to overfitting. See the [PSMC repo](https://github.com/lh3/psmc) for some information on this. The default is 4+25\*2+4+6, which works for humans, however it doesn't seem to work for many systems. [Hilgers et al (2025)](https://www.cell.com/current-biology/pdf/S0960-9822(24)01239-9.pdf) recommends splitting the first window to remove sharp false Ne peaks in recent time (ex. 2+2+25\*2+4+6 or 1+1+1+1+25\*2+4+6). 

Set the number of bootstraps to run for the bootstrapping step.

Other parameters to set are mutation rate and generation time (years), which will be specific to your system.

```
## in config.yaml
# psmc parameters
psmc:
  intervals: "2+2+25*2+4+6"  # default: "4+25*2+4+6"
  mutation_rate: 2e-09       # value for -u
  generation_time: 4         # value for -g
  num_bootstraps: 100        # specify number of bootstraps
```


## Outputs
The pipeline will output the following:

PSMC and PSMC bootstrap files, one per sample 
```
results/psmc/{sample}.psmc
results/psmc_bootstrapped/{sample}.psmc
```

Formatted PSMC results for plotting, one per sample
```
results/psmc_plot/{sample}.0.txt
```
