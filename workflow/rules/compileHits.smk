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