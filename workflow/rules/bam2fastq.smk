
# convert bam to fasta with angsd 
rule bam_to_fasta:
    input:
        bam=get_inputs,
    output:
        fasta="results/bam2fasta/{sample}.fasta",
    log:
        "results/logs/bam2fasta/{sample}.log",
    benchmark:
        "results/benchmarks/bam2fasta/{sample}.bmk",
    resources:
        cpus = 4,
        time = "4:00:00"
    conda:
        "../envs/angsd.yaml"
    shell:
        "angsd -i {input.bam} -doFasta 2 -doCounts 1 -out {output.fasta} 2> {log} ; "
        "mv {output.fasta}.fa.gz {output.fasta}.gz ; "
        "bgzip -d {output.fasta}.gz ; "


