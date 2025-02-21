#!/bin/bash

# Defining input file
bam_file=$1

# Controlla se il file esiste
if [ ! -f "$bam_file" ]; then
    echo "BAM file does not exist."
    exit 1
fi

# Inizializing output file
echo -e "Read\tTotal_C\tCpG\tHigh_Methyl\tPercent_Methylated_CpG\tTotal_Nucleotides" > "$2"
output_inf_15=$2

# Finding samtools
SAMTOOLS_PATH=$(which samtools)

if [ -z "$SAMTOOLS_PATH" ]; then
    echo "Error: samtools not found"
    exit 1
fi

# Analyzing BAM file
$SAMTOOLS_PATH view "$bam_file" | awk -v inf15="$output_inf_15" '
BEGIN { OFS="\t" }  
{
    total_C = 0;  
    CpG_count = 0;  
    seq = $10;  
    read_length = length(seq);  
    prob_methyl = "";  
    num_high_methyl = 0;  

    for (k = 11; k <= NF; k++) {
        if ($k ~ /^ML:B:C,/) {
            prob_methyl = $k;  
            break;             
        }
    }

    for (i = 1; i <= length(seq); i++) {
        base = substr(seq, i, 1);  
        if (base == "C") {
            total_C++;
            if (i < length(seq) && substr(seq, i+1, 1) == "G") {  
                CpG_count++;
            }
        }
    }

    if (prob_methyl != "") {  
        split(prob_methyl, methyl_scores, ",");  
        for (j = 2; j <= length(methyl_scores); j++) {  
            score = methyl_scores[j] + 0;  
            if (score > 128) {
                num_high_methyl++;
            }
        }
    }

    percent_methylated_CpG = (CpG_count > 0) ? (num_high_methyl / CpG_count) * 100 : 0;

    if (percent_methylated_CpG < 15) {
        printf "%s\t%d\t%d\t%d\t%.2f%%\t%d\n", $1, total_C, CpG_count, num_high_methyl, percent_methylated_CpG, read_length >> (inf15);
   }
}'
