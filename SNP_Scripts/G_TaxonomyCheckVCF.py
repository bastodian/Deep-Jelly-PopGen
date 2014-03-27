#!/usr/bin/env python

''' 

Reads a vcf file and tabular BLAST hits file. BLAST hits are compared to
NCBI's taxonomy and only those sequences that hit Cnidaria, Metazoa, or 
have no hit are retained. Writes three output files.

Requires VCF file as input and BLAST report

./TaxonomyCheckVCF MySNPs.vcf HalicreasVSnr_combined

'''

from Bio import Entrez 
import sys, time

SNPs = sys.argv[1]
BLAST = sys.argv[2]
MetazoaOut = SNPs.split('.')[-2] + '_Metazoa.vcf'
CnidariaOut = SNPs.split('.')[-2] + '_Cnidaria.vcf'
NoHitOut = SNPs.split('.')[-2] + '_NoHit.vcf'

#get the taxonomy ids for Metazoa and Cnidaria through ENTREZ
Entrez.email = "bentlage@umd.edu"
if not Entrez.email:
    print "you must add your email address"
    sys.exit(2)
# Retrieve Cnidrian ids
Cnidaria = '6073'
#6099 cnidarians in Genbank
handle = Entrez.esearch(db="taxonomy",term="txid%s[Subtree]" %Cnidaria,retmax=92000)
record = Entrez.read(handle)
CnidariaIDs = frozenset(record["IdList"])
# Retrieve Metazoan ids
Metazoa = '33208'
# Retrieve Metazoan ids
#400,000 metazoans in Genbank
handle = Entrez.esearch(db="taxonomy",term="txid%s[Subtree]" %Metazoa,retmax=400000)
record = Entrez.read(handle)
handle.close()
MetazoaIDs = frozenset(record["IdList"])

# Annotate contig ids for BLAST results using remote queries of NCBI
# 1: retrieve taxon ID for GI in BLAST hit
# 2: check taxon ID against Cnidaria and Metazoa IDs; keep if match
MetazoaContigs = []
CnidariaContigs = []
Contams = []
with open(BLAST, 'r') as NR:
    for Line in NR:
        if '#' not in Line:
            TEST = False
            while TEST == False:
                try:
                    GI = Line.split('|')[1]
                    Handle = Entrez.esummary(db="protein", id=GI)
                    Summary = Entrez.read(Handle)
                    Handle.close()
                    TaxId = str(Summary[0]["TaxId"])

                    if TaxId in MetazoaIDs and TaxId in CnidariaIDs:
                        MetazoaContigs.append(Line.split()[0])
                        print 'Metazoa'
                        CnidariaContigs.append(Line.split()[0])
                        print 'Cnidaria' + "\n"
                        TEST = True
                    elif TaxId in CnidariaIDs:
                        CnidariaContigs.append(Line.split()[0])
                        print 'Cnidaria' + "\n"
                        TEST = True
                    elif TaxId in MetazoaIDs:
                        MetazoaContigs.append(Line.split()[0])
                        print 'Metazoa' + "\n"
                        TEST = True
                    else:
                        Contams.append(Line.split()[0])
                        print 'Contam' + "\n"
                        TEST = True
                        time.sleep(1)
                except Exception as E:
                    sys.stdout.write('Exception: %s' % (E))
                    time.sleep(1)

print 'Retrieved all IDs from Genbank'

# Parse VCF file and retain only those contigs that represent Cnidaria or Metazoa
# Write two separate output VCF files
with open(SNPs, 'r') as Vars:
    with open(MetazoaOut, 'w') as Metazoa:
        with open(CnidariaOut, 'w') as Cnidaria:
            with open(NoHitOut, 'w') as NoHit:
                for Line in Vars:
                    if '#' in Line:
                        Metazoa.write(Line)
                        Cnidaria.write(Line)
                        NoHit.write(Line)
                    elif '#' not in Line:
                        Specimens = Line.split()[9:]
                        if Line.split()[0] in frozenset(CnidariaContigs) and Line.split()[0] in frozenset(MetazoaContigs):
                            Metazoa.write(Line)
                            Cnidaria.write(Line)
                        elif Line.split()[0] in frozenset(CnidariaContigs):
                            Cnidaria.write(Line)
                        elif Line.split()[0] in frozenset(MetazoaContigs):
                            Metazoa.write(Line)
                        elif Line.split()[0] not in frozenset(CnidariaContigs) and \
                                Line.split()[0] not in frozenset(MetazoaContigs) and \
                                Line.split()[0] not in frozenset(Contams):
                                NoHit.write(Line)
                    else:
                        continue
