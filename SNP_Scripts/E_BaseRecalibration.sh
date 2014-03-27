#!/bin/bash

# Analyze patterns of covariation in the sequence dataset
#for BAM in ../RealignedBAMs/*realigned.bam 
for BAM in ../RealignedBAMs/Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam 
do
    /mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar \
        /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
        -T BaseRecalibrator \
        -I $BAM \
        -R ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
        -knownSites ../RealignedBAMs/InitialSNPsConsensusFreeBayesGATK_Phred30.vcf \
        -o ${BAM/\.\/RealignedBAMs/}.table \
        -rf BadCigar
done

# Do a second pass to analyze covariation remaining after recalibration
#for BAM in ../RealignedBAMs/*realigned.bam 
for BAM in ../RealignedBAMs/Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam 
do
    /mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar \
        /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
        -T BaseRecalibrator \
        -I $BAM \
        -R ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
        -knownSites ../RealignedBAMs/InitialSNPsConsensusFreeBayesGATK_Phred30.vcf \
        -BQSR ${BAM/\.\/RealignedBAMs/}.table \
        -o ${BAM/\.\/RealignedBAMs/}.post_table \
        -rf BadCigar
done

# Generate before/after plots
#for BAM in ../RealignedBAMs/*realigned.bam 
for BAM in ../RealignedBAMs/Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam 
do
    /mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar \
        /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
        -T AnalyzeCovariates \
        -R ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
        -before ${BAM/\.\/RealignedBAMs/}.table \
        -after ${BAM/\.\/RealignedBAMs/}.post_table \
        -plots ${BAM/\.\/RealignedBAMs/}.pdf \
        -rf BadCigar
done

# Apply the recalibration to your sequence data
#for BAM in ../RealignedBAMs/*realigned.bam 
for BAM in ../RealignedBAMs/Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam 
do
    /mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar \
        /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
        -T PrintReads \
        -I $BAM \
        -R ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
        -BQSR ${BAM/\.\/RealignedBAMs/}.table \
        -o ${BAM/\.\.\/RealignedBAMs\//\.\/RECAL_} \
        -rf BadCigar
done
