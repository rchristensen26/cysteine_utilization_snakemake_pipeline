# download strain genomes
rule retrieveStrainGenomes:
    output:
        "config/strain_genomes/{strain}.fa"
    conda:
        "edirect"
    shell:
        """
        esearch -db assembly -query "{wildcards.strain} [ORGN] AND representative [PROP]" \
        | elink -target nuccore -name assembly_nuccore_refseq \
        | efetch -format fasta > {output}
        """

# build profile HMM
rule makeMSA:
    input:
        "config/referenceGeneFiles/{gene}.faa"
    output:
        "config/referenceGeneMSA/{gene}_msa.faa"
    shell:
        """
        /usr/local/bin/mafft {input} > {output}
        """

rule buildProfileHMM:
    input:
        "config/referenceGeneMSA/{gene}_msa.faa"
    output:
        "config/profileHMMs/{gene}.HMM"
    conda:
        config["hmmerEnv"]
    shell:
        """
        hmmbuild {output} {input}
        """

#Translate to NT to AA with PRODIGAL
rule runProdigal:
    input:
        join(config["ntGenomeDir"], "{strain}.fa")
    output:
        proteinSeqs=join(config["proteinSeqDir"], "{strain}_prodigal.faa")
    conda:
        config["prodigalEnv"]
    shell:
        """
        prodigal -i {input} -a {output.proteinSeqs}
        """

# run HMMER search on all genes
rule runHMMER:
    input:
        join(config["proteinSeqDir"], "{strain}_prodigal.faa")
    output:
        hmmOut="workflow/out/{gene}/hmmer_output/{strain}_{gene}.hmm.out",
        domOut="workflow/out/{gene}/hmmer_output/{strain}_{gene}.domtblout",
        msa="workflow/out/{gene}/hmmer_output/{strain}_{gene}.sto"
    params:
        hmm_profile="config/profileHMMs/{gene}.HMM"
    conda:
        config["hmmerEnv"]
    shell:
        """
        hmmsearch -o {output.hmmOut} --domtblout {output.domOut} -A {output.msa} {params.hmm_profile} {input} 
        """

rule parseHMMER:
    input:
        "workflow/out/{gene}/hmmer_output/{strain}_{gene}.domtblout"
    output:
        "workflow/out/{gene}/csv_summary/{strain}_{gene}_hits.csv"
    shell:
        """
        python3 workflow/scripts/parse_hmmer_domtable.py {input} {output}
        """

rule combineCSV:
    input:
        expand("workflow/out/{gene}/csv_summary/{strain}_{gene}_hits.csv",strain=STRAINS, gene=GENES)
    output:
        "workflow/out/summary_all/csv_summary/compiled_{gene}_hits.csv"
    params:
        input_dir="workflow/out/{gene}/csv_summary"
    shell:
        """
        for f in {params.input_dir}/*_hits.csv ; do cat $f ; done > {output}
        """

# convert the HMMER output MSA from stockholm format (.sto) to fasta (.faa)
rule convertMSA_toFASTA:
    input:
        "workflow/out/{gene}/hmmer_output/{strain}_{gene}.sto"
    output:
        "workflow/out/{gene}/faa_summary/{strain}_{gene}_hits.faa"
    shell:
        """
        python3 workflow/scripts/convertFASTA.py {input} {output}
        """

rule combineMSA:
    input:
        expand("workflow/out/{gene}/faa_summary/{strain}_{gene}_hits.faa",strain=STRAINS, gene=GENES)
    output:
        "workflow/out/summary_all/faa_summary/compiled_{gene}_hits.faa"
    params:
        input_dir="workflow/out/{gene}/faa_summary"
    shell:
        """
        for f in {params.input_dir}/*.faa ; do cat $f ; done > {output}
        """

# compile hits

rule combineAllCSV:
    input:
        expand("workflow/out/summary_all/csv_summary/compiled_{gene}_hits.csv",gene=GENES)
    output:
        "workflow/out/summary_all/compiled_hits_08092022.csv"
    shell:
        """
        for f in {input} ; do cat $f ; done > {output}
        """

rule compileHitInfo:
    input:
        "workflow/out/summary_all/compiled_hits_08092022.csv"
    output:
        "workflow/out/summary_all/maxHitScoreDF_08092022.csv"
    shell:
        """
        python3 workflow/scripts/compileHitInfo.py {input} {output}
        """

