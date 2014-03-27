#!/bin/bash

# Call SNPs using FreeBayes
freebayes \
    --fasta-reference Halicreas_combined_normalized-scaffolds.1000.fa \
    -b ./Halicreas_Antarctica_DLSI167_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Antarctica_DLSI94_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Atl_DNA34b_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Atl_DNA61a_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Atl_DNA63c_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Atl_DNA68a_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Atl_DNA68c_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Cal_06Mont3.2_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Cal_06Mont6.3_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Cal_2584_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Cal_BB033_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Jap_DLSI267_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Jap_DLSI286_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Jap_DLSI366_interleaved.sorted.reduced.realigned.bam \
    -b ./Halicreas_Jap_I060320A_interleaved.sorted.reduced.realigned.bam \
    --vcf InitialSNPsFREEBAYES.vcf \
    --no-indels \
    --no-mnps \
    --no-complex \
    --standard-filters

# Call SNPs using GATK Unified Genotyper
/mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
    -XX:ParallelGCThreads=16 \
    -Djava.io.tmpdir=/mnt/pond/SCRATCH \
    -jar /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
            -T UnifiedGenotyper \
            -R Halicreas_combined_normalized-scaffolds.1000.fa \
            -I ./Halicreas_Antarctica_DLSI167_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Antarctica_DLSI94_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Atl_DNA34b_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Atl_DNA61a_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Atl_DNA63c_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Atl_DNA68a_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Atl_DNA68c_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Cal_06Mont3.2_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Cal_06Mont6.3_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Cal_2584_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Cal_BB033_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Jap_DLSI267_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Jap_DLSI286_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Jap_DLSI366_interleaved.sorted.reduced.realigned.bam \
            -I ./Halicreas_Jap_I060320A_interleaved.sorted.reduced.realigned.bam \
            -o InitialSNPsGATK.vcf \
            -stand_emit_conf 30.0 \
            -stand_call_conf 30.0 \
            --genotype_likelihoods_model SNP \
            -rf BadCigar \
            -nt 16

# Retain the intersecting set between GATK and FreeBayes SNPs
./ConsensusSNPs.py InitialSNPsFreeBayes.vcf InitialSNPsGATK.vcf > InitialSNPsConsensus.vcf
