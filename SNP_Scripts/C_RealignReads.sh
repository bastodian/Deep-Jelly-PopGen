#!/bin/bash

# Prepare the virgin reference for picard:
# index using samtools and create sequence dictionary using picard
samtools faidx Halicreas_combined_normalized-scaffolds.1000.fa &&
java -jar ~/SNP/Tools/picard-tools-1.88/CreateSequenceDictionary.jar \
    R= Halicreas_combined_normalized-scaffolds.1000.fa \
    O=Halicreas_combined_normalized-scaffolds.1000.dict &&

# Create a list of targets for realignment
for i in ./Halicreas_*reduced.bam
do
java -Xmx30g -jar \
    -XX:ParallelGCThreads=16 \
    -Djava.io.tmpdir=/mnt/pond/SCRATCH \
    ~/SNP/Tools/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar \
    -T RealignerTargetCreator \
    -I $i \
    -R Halicreas_combined_normalized-scaffolds.1000.fa \
    -o $i.realigner.targets.intervals \
    -nt 16 \
    --read_buffer_size 15000000
done

# Run the realignment for each individual BAM file
for i in ./*Antarctica*reduced.bam
do
    java -Xmx30g -jar \
            -XX:ParallelGCThreads=16 \
            -Djava.io.tmpdir=/mnt/pond/SCRATCH \
            ~/SNP/Tools/GenomeAnalysisTK-2.4-9-g532efad/GenomeAnalysisTK.jar \
            -T IndelRealigner \
            -I $i \
            -R Halicreas_combined_normalized-scaffolds.1000.fa \
            -o $i.realigned \
            -targetIntervals $i.realigner.targets.intervals \
            --maxReadsInMemory 15000000 \
            --maxReadsForRealignment 1000000
done
