
# convert fasta to fastq 
rule fasta_to_fastq:
    input:
        fasta=get_fastas,
    output:
        fastq="results/fastq/{sample}.fastq",
    log:
        "results/logs/fastq/{sample}.log",
    conda:
        "../envs/seqtk.yaml"
    shell:
        "seqtk seq -F 'I' {input.fasta} > {output.fastq} "

# subset major chromosomes
rule subset_chroms:
    input:
        fastq="results/fastq/{sample}.fastq",
    output:
        fastq="results/fastq/{sample}.chrom-subset.fastq",
    log:
        "results/logs/fastq/{sample}_subset.log",
    params:
        subset_file=config['chrom_subset_file'],  
    conda:
        "../envs/seqtk.yaml"
    shell:
        "seqtk subseq {input.fastq} {params.subset_file} > {output.fastq} "

# generate psmc formatted input file
rule create_psmcfa:
    input:
        fastq="results/fastq/{sample}.chrom-subset.fastq",
    output:
        psmcfa="results/psmcfa/{sample}.psmcfa",
    log:
        "results/logs/psmcfa/{sample}.log",
    conda:
        "../envs/psmc.yaml"
    shell:
        "fq2psmcfa -q20 {input.fastq} > {output.psmcfa} "

