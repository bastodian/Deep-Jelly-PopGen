#!/usr/bin/env python

import sys

VCF = sys.argv[1]

# VCF file containing all biallelic SNPs
VCFout1 = './%s_Biallelic.%s' % (VCF.split('/')[-1].split('.')[0], VCF.split('/')[-1].split('.')[-1])
print VCFout1
# VCF containing all transitions
VCFout2 = './%s_BiallelicTS.%s' % (VCF.split('/')[-1].split('.')[0], VCF.split('/')[-1].split('.')[-1])
# VCF containing all transversions
VCFout3 = './%s_BiallelicTV.%s' % (VCF.split('/')[-1].split('.')[0], VCF.split('/')[-1].split('.')[-1])

# Transitions
TS = ('AG', 'GA', 'CT', 'TC')
# Transversions
TV = ('AC', 'CA', 'AT', 'TA', 'GC', 'CG', 'GT', 'TG')

with open(VCF, 'r') as InVCF:
    with open(VCFout1, 'w') as Out1:
        with open(VCFout2, 'w') as Out2:
            with open(VCFout3, 'w') as Out3:
                for Line in InVCF:
                    if '#' in Line:
                        # Write header to all files
                        Out1.write('%s' % (Line))
                        Out2.write('%s' % (Line))
                        Out3.write('%s' % (Line))
                        continue
                    else:
                        Alleles = ''.join(Line.split()[3:5])
                        # Create a list with all genotypes in a line
                        GenotypesOnLine = list(set([x.split(':')[0] for x in Line.split()[9:]]))
                        # Find the Index of Missing data value and remove missing Genotype from List
                        try:
                            MissingGenotype = GenotypesOnLine.index('./.')
                            GenotypesOnLine.pop(MissingGenotype)
                        except ValueError:
                            pass
                        # If only one genotype present move on to next line in VCF file unless...
                        if len(GenotypesOnLine) == 1:
                            # If all alleles are homozygous non-reference then they are probably wrong since
                            # the reference Genome may be erroneous; so remove these loci from further 
                            # consideration
                            if len(set(GenotypesOnLine[0].split('/'))) == 1:
                                continue
                            else:
                                # retain biallelic loci
                                if len(Alleles) < 3:
                                    Out1.write('%s' % (Line))
                                    # Write transitions
                                    if ''.join(Line.split()[3:5]) in TS:
                                        Out2.write('%s' % (Line))
                                    # Write transversions
                                    elif ''.join(Line.split()[3:5]) in TV:
                                        Out3.write('%s' % (Line))
                        # If there is more variation continue parsing
                        else:
                            # retain biallelic loci
                            if len(Alleles) < 3:
                                Out1.write('%s' % (Line))
                                # Write transitions
                                if ''.join(Line.split()[3:5]) in TS:
                                    Out2.write('%s' % (Line))
                                # Write transversions
                                elif ''.join(Line.split()[3:5]) in TV:
                                    Out3.write('%s' % (Line))
