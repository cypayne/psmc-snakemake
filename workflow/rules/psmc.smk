
# run psmc
rule psmc:
    input:
        psmcfa="results/psmcfa/{sample}.psmcfa",
    output:
        psmc="results/psmc/{sample}.psmc",
    log:
        "results/logs/psmc/{sample}.log",
    params:
        psmc=config["psmc"]["intervals"],
    conda:
        "../envs/psmc.yaml"
    shell:
        "psmc -p {params.psmc} -o {output.psmc} {input.psmcfa} 2>{log}"

# split psmcfa for bootstrapping 
rule split_psmcfa:
    input:
        psmcfa="results/psmcfa/{sample}.psmcfa",
    output:
        split="results/psmcfa/{sample}.split.psmcfa",
    conda:
        "../envs/psmc.yaml"
    shell:
        "splitfa {input.psmcfa} > {output.split} "

# run bootstraps 
rule bootstrap:
    input:
        psmcfa="results/psmcfa/{sample}.split.psmcfa",
    output:
        bootstrap="results/bootstraps/{sample}/{sample}.{round}.psmc",
    conda:
        "../envs/psmc.yaml"
    params:
        psmc=config["psmc"]["intervals"],
    shell:
        "psmc -b -p {params.psmc} -o {output.bootstrap} {input.psmcfa} "

# combine psmc and boostraps
rule combine_psmc_bootstraps:
    input:
        bootstrap=expand("results/bootstraps/{sample}/{sample}.{round}.psmc",
                         sample=sample_list,round=boot_round_list),
        psmc="results/psmc/{sample}.psmc",
    output:
        psmc="results/psmc_bootstrapped/{sample}.psmc",
    conda:
        "../envs/psmc.yaml"
    shell:
        "cat {input.psmc} results/bootstraps/{wildcards.sample}/{wildcards.sample}.*.psmc > {output.psmc} "

# run psmc_plot.pl to generate txt output and plot 
rule psmc_plot:
    input:
        psmc="results/psmc_bootstrapped/{sample}.psmc",
    output:
        plot_input="results/plot_inputs/{sample}.0.txt",
    log:
        "results/logs/plot_input/{sample}.log",
    params:
        mutation=config["psmc"]["mutation_rate"],
        gentime=config["psmc"]["generation_time"],
        prefix="{sample}"
    conda:
        "../envs/psmc.yaml"
    shell:
        "~/miniforge3/envs/psmc/bin/psmc_plot.pl -R -u {params.mutation} "
        "-g {params.gentime} results/plot_inputs/{params.prefix} {input.psmc} 2>{log} "




