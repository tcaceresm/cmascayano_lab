#! /usr/bin/bash

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for COMPOUND in ./*/
do
    COMPOUND=$(basename ${COMPOUND})
    echo $COMPOUND
    cat ./${COMPOUND}/docking_scores.csv >> all_docking_scores.csv
    tail -n +2 ./${COMPOUND}/sdf/cluster/2.0/${COMPOUND}.csv >> all_clusters.csv
done
