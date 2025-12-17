#! /usr/bin/bash

# Run after process dlg files
# Read all compound directories and append all docking scores and cluster to a common file
# for further processing.
for COMPOUND in ./*/
do
    COMPOUND=$(basename ${COMPOUND})
    cat ./${COMPOUND}/docking_scores.csv >> all_docking_scores.csv
    tail -n +2 ./${COMPOUND}/sdf/cluster/2.0/${COMPOUND}.csv >> all_clusters.csv
done
