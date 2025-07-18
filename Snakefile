#Welcome to MitSorter
#Written by Sharon Natasha Cox and Angelo Sante Varvara

configfile: "config.yaml"

sample = config['samples']

rule all:
    input:
    	expand("results/modBAM+m_stats_{sample}.txt", sample = config["samples"]),
    	expand("results/modBAM-m_stats_{sample}.txt", sample = config["samples"])

rule basecalling:
	input:
		pod5="data/{sample}/pod5/",
		ref="data/chrM.fa",
		model="data/dna_r10.4.1_e8.2_400bps_sup@v5.0.0",
		modelC="data/dna_r10.4.1_e8.2_400bps_sup@v5.0.0_5mCG_5hmCG@v1"
	output:
		temp("mapped_reads/calls_{sample}.bam")
	log:
		"logs/basecalling/{sample}.log"
	message: "MitSorter is running! Basecalling on going..."
	shell:
		"dorado basecaller {input.model} {input.pod5} --min-qscore 9 -Y --recursive --modified-bases-models {input.modelC} --reference {input.ref} > {output}"

rule sorting:
	input:
		"mapped_reads/calls_{sample}.bam"
	output:
		bam=temp("sorted_reads/calls_sorted_{sample}.bam"),
		index="sorted_reads/calls_sorted_{sample}.bam.bai"
	threads: 16
	message: "Basecalling complete. Now sorting and indexing to produce raw modBAM file..."
	shell:
		"samtools sort -@ {threads} --write-index {input} -o {output.bam}##idx##{output.index}"

rule removeunmapped:
	input:
		"sorted_reads/calls_sorted_{sample}.bam"
	output:
		"sorted_reads/calls_sorted_no_unmapped_{sample}.bam"
	threads: 16
	message: "Removing unmapped reads from raw modBAM file..."
	shell:
		"samtools view -@ {threads} -bF4 {input} -o {output}"

rule modadjust:
	input:
		"sorted_reads/calls_sorted_no_unmapped_{sample}.bam"
	output:
		temp("sorted_reads/calls_sorted_no_unmapped_only_5mC_{sample}.bam")
	log:
		"logs/modkit_adjust/{sample}.log"
	message: "Keeping only 5mC tags to produce an intermediate modBAM..."
	shell:
		"modkit adjust-mods {input} {output} --ignore h"

rule script:
	input:
		"sorted_reads/calls_sorted_no_unmapped_only_5mC_{sample}.bam"
	output:
		"sorted_reads/INF_15_{sample}.txt"
	message: "Analyzing intermediate modBAM file to create a list of reads with CpG methylation levels below 15%..."
	shell:
		"sorted_reads/CpG_methyl_screen.sh {input} {output}"

rule discriminatemetbam:
	input:
		bam="sorted_reads/calls_sorted_no_unmapped_only_5mC_{sample}.bam",
		text="sorted_reads/INF_15_{sample}.txt"
	output:
		nomet="sorted_reads/modBAM-m_{sample}.bam",
		met="sorted_reads/modBAM+m_{sample}.bam"
	threads: 8
	message: "Splitting intermediate modBAM into two BAM files with methylated and not methylated reads..."
	shell:
		"samtools view -@ {threads} -b -o {output.nomet} -U {output.met} -N {input.text} {input.bam}"

rule modsummary1:
	input:
		"sorted_reads/modBAM+m_{sample}.bam"
	output:
		"results/modBAM+m_stats_{sample}.txt"
	message: "Last steps starting now! Calculating stats for modBAM+m..."
	shell:
		"modkit summary {input} --no-sampling --tsv > {output}"

rule modsummary2:
	input:
		"sorted_reads/modBAM-m_{sample}.bam"
	output:
		"results/modBAM-m_stats_{sample}.txt"
	message: "Calculating stats for modBAM-m..."
	shell:
		"modkit summary {input} --no-sampling --tsv > {output}"
