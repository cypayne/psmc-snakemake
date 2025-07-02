rule get_genome:
    output:
        "reference/genome.fasta",
    params:
        genome=config["genome_path"],
    shell:
        "cp {params.genome} {output} "

rule genome_faidx:
    input:
        "reference/genome.fasta",
    output:
        "reference/genome.fasta.fai",
    log:
        "results/logs/reference/genome_faidx.log",
    benchmark:
        "results/reference/genome_faidx.bmk",
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools faidx {input}"


rule genome_dict:
    input:
        "reference/genome.fasta",
    output:
        "reference/genome.dict",
    log:
        "results/logs/reference/genome_dict.log",
    benchmark:
        "results/reference/genome_dict.bmk"
    conda:
        "../envs/samtools.yaml"
    shell:
        "samtools dict {input} > {output} 2> {log} "
