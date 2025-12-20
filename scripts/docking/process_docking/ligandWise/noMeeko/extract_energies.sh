#!/usr/bin/bash

############################################################
# Help
############################################################
Help() {
    echo "Syntax: extract_energies.sh [-h|d|f|o]"
    echo "Requires an already processed DLG file (process_dlg.sh)."
    echo "  The processed directory must be the same than "Processed DLG output directory" used by process_dlg.sh (-o flag)."
    echo "  Also, requires the output of sort_pdb.sh (docking_energies.txt)."
    echo "Options:"
    echo "h     Print help"
    echo "d     DLG file."
    echo "o     Processed ligands' directory."
}

while getopts ":hd:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            LIGAND_NAME=$OPTARG;;
        o)  # Output directory
            PROCESSED_DIRECTORY=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

LIGAND_NAME=$(basename ${LIGAND_NAME} .dlg)
LIGAND_PDB_PATH=${PROCESSED_DIRECTORY}/${LIGAND_NAME}/pdb/

ENERGY_FILE="$LIGAND_PDB_PATH/docking_energies.txt"

if [[ ! -f ${ENERGY_FILE} ]]
then
    echo "${ENERGY_FILE} not found."
    echo "Did you run sort_pdb.sh?"
    exit 1
fi

# Energies of single ligand
awk -v ligand_name=${LIGAND_NAME} '{print $0 ";" ligand_name}' ${ENERGY_FILE} > "${PROCESSED_DIRECTORY}/${LIGAND_NAME}/docking_scores.csv"
