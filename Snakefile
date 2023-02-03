from os.path import join
import os

configfile: "config/config.yml"

with open("config/strain_list.txt", 'r') as f:
    strains = f.read()
    STRAINS = strains.split()

with open("config/gene_list.txt", 'r') as f:
    genes = f.read()
    GENES = genes.split()


rule all:
    input:
        expand("config/strain_genomes/{strain}.fa",strain=STRAINS),
        # expand("config/referenceGeneMSA/{gene}_msa.faa", gene=GENES),
        expand("config/profileHMMs/{gene}.HMM", gene=GENES),
        expand(join(config["proteinSeqDir"],"{strain}_prodigal.faa"), strain=STRAINS),
        expand("workflow/out/{gene}/hmmer_output/{strain}_{gene}.hmm.out",strain=STRAINS,gene=GENES),
        expand("workflow/out/{gene}/hmmer_output/{strain}_{gene}.domtblout",strain=STRAINS,gene=GENES),
        expand("workflow/out/{gene}/hmmer_output/{strain}_{gene}.sto",strain=STRAINS,gene=GENES),
        expand("workflow/out/{gene}/csv_summary/{strain}_{gene}_hits.csv",strain=STRAINS,gene=GENES),
        expand("workflow/out/{gene}/faa_summary/{strain}_{gene}_hits.faa",strain=STRAINS,gene=GENES),
        expand("workflow/out/summary_all/csv_summary/compiled_{gene}_hits.csv", gene=GENES),
        expand("workflow/out/summary_all/faa_summary/compiled_{gene}_hits.faa", gene=GENES),
        "workflow/out/summary_all/compiled_hits_08092022.csv",
        "workflow/out/summary_all/maxHitScoreDF_08092022.csv"


include:
    # "workflow/rules/downloadStrainGenomes.smk"
    # "workflow/rules/makeProfileHMM.smk",
    # "workflow/rules/runHMMER.smk"
    "workflow/rules/doItAll.smk"
