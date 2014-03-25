#!/bin/bash

## 3-step digital normalization protocol; hashsize table is calculated by N * x / 8 (here: 4 * 64/8 = 32GB/)

export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.6/dist-packages/khmer/python
normalize-by-median.py -C 20 -k 20 -N 4 -x 64e8 --savehash Halicreas_combined.fq.kh Halicreas_combined.fq

export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.6/dist-packages/khmer/python
filter-abund.py Halicreas_combined.fq.kh Halicreas_combined.fq.keep

export PYTHONPATH=$PYTHONPATH:/usr/local/lib/python2.6/dist-packages/khmer/python
normalize-by-median.py -C 5 -k 20 -N 4 -x 64e8 Halicreas_combined.fq.keep.abundfilt
