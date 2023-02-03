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
