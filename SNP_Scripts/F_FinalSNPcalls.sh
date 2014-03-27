#!/bin/bash

# Call SNPs with FreeBayes
freebayes \
    --fasta-reference ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
	-b ./RECAL_Halicreas_Antarctica_DLSI167_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Antarctica_DLSI94_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Atl_DNA34b_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Atl_DNA61a_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Atl_DNA63c_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Atl_DNA68a_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Atl_DNA68c_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Cal_06Mont3.2_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Cal_06Mont6.3_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Cal_2584_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Cal_BB033_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Jap_DLSI267_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Jap_DLSI286_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Jap_DLSI366_interleaved.sorted.reduced.realigned.bam \
	-b ./RECAL_Halicreas_Jap_I060320A_interleaved.sorted.reduced.realigned.bam \
    --vcf FinalSNPsFREEBAYES.vcf \
    --no-indels \
    --no-mnps \
    --no-complex \
    --standard-filters

# Call SNPs with the GATK
/mnt/pond/MappingGATK2.7/GATK/jdk1.7.0_45/bin/java \
    -XX:ParallelGCThreads=16 \
    -Djava.io.tmpdir=/mnt/pond/SCRATCH \
    -jar /mnt/pond/MappingGATK2.7/GATK/GenomeAnalysisTK-2.7-4-g6f46d11/GenomeAnalysisTK.jar \
            -T UnifiedGenotyper \
            -R ../RealignedBAMs/Halicreas_combined_normalized-scaffolds.1000.fa \
			-I ./RECAL_Halicreas_Antarctica_DLSI167_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Antarctica_DLSI94_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Atl_DNA34b_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Atl_DNA61a_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Atl_DNA63c_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Atl_DNA68a_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Atl_DNA68c_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Cal_06Mont3.2_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Cal_06Mont6.3_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Cal_2584_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Cal_BB033_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Jap_DLSI025_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Jap_DLSI267_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Jap_DLSI286_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Jap_DLSI366_interleaved.sorted.reduced.realigned.bam \
			-I ./RECAL_Halicreas_Jap_I060320A_interleaved.sorted.reduced.realigned.bam \
            -o FinalSNPsGATK.vcf \
            -stand_emit_conf 10.0 \
            -stand_call_conf 30.0 \
            --genotype_likelihoods_model SNP \
            -rf BadCigar \
            -nt 16

# Retain consensus set of SNPs from FreeBayes and GATK
./Consensus.py FinalSNPsFREEBAYES.vcf FinalSNPsGATK.vcf > FinalSNPsConsensus.vcf
