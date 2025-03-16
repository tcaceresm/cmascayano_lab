#!/bin/bash

###################################################
# Procesamiento del output de docking             #
# 1) dlg -> sdf                                   #         
# 2) sort docking conformations based on affinity #
# 3) Obtain docking scores                        #
#    Step 1 to 3 run with ChemmineR in R
# 4) RMSD matrix (OpenBabel)                      #
# 5) Clustering basado en RMSD -> in R            #
###################################################

############################################################
# Help
############################################################
Help() {
    echo "Script used to process AD output"
    echo "Syntax: process_output.sh [-h|d|o|c]"
    echo "Options:"
    echo "h     Print help."
    echo "d     DLG files path."
    echo "o     Processed output directory."
    echo "c     Clustering cutoff"
    echo "n     Threads (for parallel run)"
}

while getopts ":hd:o:c:n:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            IPATH=$OPTARG;;
        o)  # Output directory
            OPATH=$OPTARG;;
        c)  # Clustering cutoff
            CUTOFF=$OPTARG;;
        n)  # Cores
            THREADS=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Export necessary variables for parallel jobs
export SCRIPT_PATH
export OPATH
export CUTOFF

# Parallel processing for each .dlg file
parallel --jobs ${THREADS} '
    LIGAND_DLG={1}
    
    echo "
    ########################
    # Processing dlg file #
    ########################
    "
    ${SCRIPT_PATH}/process_dlg_new.sh -d ${LIGAND_DLG} -o ${OPATH}

    echo "Done processing dlg file!"

    echo "
    ###########################
    # Calculating RMSD matrix #
    ###########################
    "
    #${SCRIPT_PATH}/rmsd_matrix.sh -d ${LIGAND_DLG} -i ${OPATH}

    echo "Done calculating RMSD matrix"

    echo "
    #######################################
    # Performing clustering based on RMSD #
    #######################################	
    "
    #${SCRIPT_PATH}/run_clustering.sh -d ${LIGAND_DLG} -i ${OPATH} -c ${CUTOFF}
' ::: ${IPATH}/*.dlg
