#!/bin/bash

# Script to annotate BAM file,
# mark duplicate reaads
#
# Set ulimit -n SOMETHING large prior to running!

# Convert SAM to BAM
for file in ./*sam
do
    samtools import Halicreas_combined_normalized-scaffolds.1000.fai $file ${file/sam/bam}
done

# Replace Read Group headers for downstream analyses with GATK;
# Mark duplicate reads; index BAM file
for file in ./*bam
do
    ID=${file/\.\/Halicreas_/}
    newID=`echo ${file/\.\/Halicreas_/} | awk -F '.' '{ print $1}'`
    SORTEDFILE=$file.sorted
    REDUCEDFILE=$SORTEDFILE.reduced
    METRICSFILE=${file/bam/duplicates}
    java \
        -XX:MaxPermSize=4g \
        -XX:PermSize=1g \
        -XX:ParallelGCThreads=16 \
        -Xms1g \
        -Xmx30g \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar /home/bastodian/SNP/Tools/picard-tools-1.88/AddOrReplaceReadGroups.jar \
        I=$file \
        O=$SORTEDFILE \
        SORT_ORDER=coordinate \
        ID=$newID \
        LB=$newID \
        PL=illumina \
        PU=$newID \
        SM=$newID \
        MAX_RECORDS_IN_RAM=15000000 \
    && \
    java \
        -XX:MaxPermSize=4g \
        -XX:PermSize=1g \
        -XX:ParallelGCThreads=16 \
        -Xms1g \
        -Xmx30g \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
        -jar /home/bastodian/SNP/Tools/picard-tools-1.88/MarkDuplicates.jar \
        I=$SORTEDFILE \
        O=$REDUCEDFILE \
        MAX_RECORDS_IN_RAM=15000000 \
        REMOVE_DUPLICATES=false \
        METRICS_FILE=$METRICSFILE \
    && \
    java \
        -Djava.io.tmpdir=/mnt/pond/SCRATCH \
	-jar /home/bastodian/SNP/Tools/picard-tools-1.88/BuildBamIndex.jar \
        I=$REDUCEDFILE
done
