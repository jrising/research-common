#!/bin/bash

cd "$(dirname "$0")"
python ../splice_grid.py subjects/bio-2.nc4 ../bio-2b.nc4
