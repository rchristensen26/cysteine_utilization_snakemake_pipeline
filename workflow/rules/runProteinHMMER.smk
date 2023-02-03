#Run tnaA HMM search
rule run_tnaA_HMMER:
    input: join(config["proteinGenomeDir"], "{strain}.faa")
    output:
        hmmOut=join(config["tnaA_protein_outputDir"], "{strain}_tnaA.hmm.out"),
        domOut=join(config["tnaA_protein_outputDir"], "{strain}_tnaA.domtblout"),
        msa=join(config["tnaA_protein_outputDir"], "{strain}_tnaA.sto")
    params:
        hmm_profile=config["tnaA_profileHMM"]
    conda:
        config["hmmerEnv"]
    shell:
        """
        hmmsearch -o {output.hmmOut} --domtblout {output.domOut} -A {output.msa} {params.hmm_profile} {input} 
        """
