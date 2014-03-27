#!/usr/bin/env python

'''
    Find consensus SNPs among two VCF files and print
    the SNPs from the second file
'''

import sys

FreeBayes_VCF = sys.argv[1]
GATK_VCF = sys.argv[2]

def SeqDict(line):
        if line[0:2] == '##':
            return 'NONE'
        elif line[0] == '#':
            return line
        elif line[0:2] != '##':
            #Record contig and position of SNP for indexing
            ContigPosition = '-'.join(line.split()[0:2])
            #Create list of possible residues at position
            Residues = line.split()[4].split(',')
            Residues.append(line.split()[3])
            return ContigPosition, Residues

with open(FreeBayes_VCF, 'r') as FreeBayes:
    FreeSeqs = {}
    for Free in FreeBayes:
        if SeqDict(Free) != 'NONE':
            try:
                if SeqDict(Free)[0] == '#':
                    #print '\t'.join((SeqDict(Free).split()))
                    continue
                else:
                    Key = SeqDict(Free)[0]
                    Value = SeqDict(Free)[1]
                    FreeSeqs[Key] = Value
            except Exception:
                continue

with open(GATK_VCF, 'r') as GATKcalls:
    GATKSeqs = {}
    for GATK in GATKcalls:
        if GATK[0] == '#':
            sys.stdout.write('%s' % GATK)
        if SeqDict(GATK) != 'NONE' and SeqDict(GATK)[0] != '#':
            try:
                Key = SeqDict(GATK)[0]
                Value = SeqDict(GATK)[1]
                GATKSeqs[Key] = Value
                if set(FreeSeqs[Key]) == set(GATKSeqs[Key]):
                    sys.stdout.write('%s' % GATK)
                    continue
            except KeyError:
                continue
