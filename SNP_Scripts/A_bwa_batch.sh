#!/bin/bash

# HALICREAS
for FASTQ in ./Halicreas_Reads/*fq
do
    echo $FASTQ
    ./bwa mem -t 16 -p -M ./Halicreas_combined_normalized-scaffolds.1000.fa $FASTQ > ${FASTQ/fq/sam}
done
