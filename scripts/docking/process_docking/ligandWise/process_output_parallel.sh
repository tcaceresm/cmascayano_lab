#!/bin/bash

###################################################
# Docking output processing     
# 1) Processing of DLG requires:
    # Meeko Package (https://github.com/forlilab/Meeko)
    # ChemmineR Package
# 2) RMSD matrix requires OpenBabel package
# 3) Clustering requires dplyr, ChemmineR and jsonlite
###################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to process AD output"
    echo "Options:"
    echo "h     Print help."
    echo "d     DLG files path."
    echo "f     DLG files."
    echo "o     Processed output directory."
    echo "c     Clustering cutoff"
    echo "n     Threads (for parallel run)"
    echo "p     Process DLG?"
    echo "r     Compute RMSD matrix?"
    echo "t     Compute clustering?"
}

while getopts ":hd:f:o:c:n:p:r:t:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        f)  # DLG files
            DLG_FILES=($OPTARG);;
        o)  # Output directory
            OPATH=$OPTARG;;
        c)  # Clustering cutoff
            CUTOFF=$OPTARG;;
        n)  # Cores
            THREADS=$OPTARG;;
        p)  # Process DLG
            PROCESS_DLG=$OPTARG;;
        r)  # Calculate RMSD matrix
            RMSD_MATRIX=$OPTARG;;
        t)  # Cluster
            CLUSTERING=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

if [[ -z "${IPATH}" || -z "${OPATH}" || -z "${CUTOFF}" || -z "${THREADS}" ]]
then
    echo "Missing arguments. Exiting."
fi

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# Export necessary variables for parallel jobs
export SCRIPT_PATH
export IPATH
export OPATH
export CUTOFF
export PROCESS_DLG
export RMSD_MATRIX
export CLUSTERING
export DLG_FILES

if ! compgen -G "${IPATH}/*.dlg" > /dev/null
then
    echo "Can't find DLG files"
    echo "Exiting."
    exit 1
fi

# Parallel processing for each .dlg file
parallel --halt soon,fail=1 --jobs ${THREADS} '
    #set -e 
    
    LIGAND_DLG={1}

    if [[ ${PROCESS_DLG} -eq 1 ]]
    then
        ${SCRIPT_PATH}/process_dlg.sh -d ${LIGAND_DLG} -o ${OPATH}
    fi
    
    if [[ ${RMSD_MATRIX} -eq 1 ]]
    then
        ${SCRIPT_PATH}/rmsd_matrix.sh -d ${LIGAND_DLG} -o ${OPATH}
    fi
    
    if [[ ${CLUSTERING} -eq 1 ]]
    then
        ${SCRIPT_PATH}/run_clustering.sh -d ${LIGAND_DLG} -o ${OPATH} -c ${CUTOFF}
    fi
' ::: ${x[@]}
