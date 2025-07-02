
# genotype gvcf with gatk
rule genotype_gvcf:
    input:
        gvcf=get_inputs,
        genome="reference/genome.fasta",
        fai="reference/genome.fasta.fai",
        dict="reference/genome.dict",
    output:
        vcf="results/genotyped/{sample}.vcf",
    log:
        "results/logs/genotyped/{sample}.log",
    benchmark:
        "results/benchmarks/genotyped/{sample}.bmk",
    params:
        java_opts="-Xmx4g",  
        gatk_opts="--sample-ploidy 2 --max-alternate-alleles 4 --standard-min-confidence-threshold-for-calling 30",
    resources:
        cpus = 4,
        time = "4:00:00"
    conda:
        "../envs/gatk4.2.6.1.yaml"
    shell:
        " gatk --java-options {params.java_opts} GenotypeGVCFs "
        "-R {input.genome} -V {input.gvcf} "
        " {params.gatk_opts} "
        " -O {output.vcf}.gz > {log} 2> {log} ; "
        "bgzip -d {output.vcf}.gz "


# generate insnp file
rule create_insnp:
    input:
        vcf="results/genotyped/{sample}.vcf",
    output:
        insnp="results/insnp/{sample}.vcf.insnp",
    log:
        "results/logs/insnp/{sample}.log",
    params:
        insnp_opts="20 10 40 10 10 4 -12.5 -8.0 5",
    resources:
        cpus = 4,
        time = "4:00:00"
    conda:
        "../envs/python.yaml"
    shell:
        "python3 workflow/scripts/insnp_v9_gatk3.4_gvcf.py {input.vcf} "
        "{output.insnp} {params.insnp_opts} > {log} 2> {log} "
 
# generate pseudogenome from insnp file
rule create_fasta:
    input:
        insnp="results/insnp/{sample}.vcf.insnp",            
        genome="reference/genome.fasta",
    output:
        fasta="results/gvcf2fasta/{sample}.fasta",
    log:
        "results/logs/gvcf2fasta/{sample}.log",
    conda:
        "../envs/seqtk.yaml"
    shell:
        "seqtk mutfa {input.genome} {input.insnp} "
        "> {output.fasta} 2> {log} "

