#!/bin/bash

##########################################################################
# Sort  ligands' conformations in a PDB file based on binding energy     #
##########################################################################

############################################################
# Help
############################################################
Help() {
    echo "Sort ligands' conformations in PDB file based on binding energy."
    echo "Syntax: sort_pdb.sh [-h|d|i]."
    echo "Requires an already processed DLG file (process_dlg.sh)."
    echo "  The processed directory must be the same than "Processed DLG output directory" used by process_dlg.sh (-o flag)"
    echo "Options:"
    echo "h     Print help."
    echo "d     DLG file."
    echo "o     Processed ligands' directory."
}

while getopts ":hd:o:" option; do
    case $option in
        h)  # Print this help
            Help
            exit;;
        d)  # Enter the input directory
            DLG_FILE=$OPTARG;;
        o)  # Output directory
            PROCESSED_DIRECTORY=$OPTARG;;
        \?) # Invalid option
            echo "Error: Invalid option"
            exit;;
    esac
done

# Verifica si Open Babel está instalado
if ! command -v obabel &> /dev/null
  then
    echo "Open Babel is not installed. Please install Open Babel and try again."
    exit 1
fi

LIGAND_NAME=$(basename ${DLG_FILE} .dlg)

echo "Doing for ${LIGAND_NAME}"    

# Archivo temporal para almacenar los valores de energía y los nombres de conformaciones
CONFORMATIONS_DIR="${PROCESSED_DIRECTORY}/${LIGAND_NAME}/pdb"
ENERGY_FILE="${PROCESSED_DIRECTORY}/${LIGAND_NAME}/pdb/docking_energies.txt"
PDB_FILE=${CONFORMATIONS_DIR}/$LIGAND_NAME.pdb
    
# Crear un directorio temporal para almacenar las conformaciones
mkdir -p ${CONFORMATIONS_DIR}

# Split pdb file, obtain energy values  

awk -v energy_file=${ENERGY_FILE} -v conformation_dir=${CONFORMATIONS_DIR} '
    /MODEL/ {
        molecule = ($0 "\n")
        run = $2
        out = (conformation_dir "/model_" run ".pdb")
    }
    /Estimated Free Energy of Binding/ {
        molecule = (molecule $0 "\n")
        split($0, fields, "=")
        split(fields[2], energy, " ")
        energia = sprintf("%.2f", energy[1])
        }
    /ENDMDL/ {
        molecule = molecule $0 "\n"
        print molecule > out
        close(out)
        print energia, run > energy_file
    }

    !(/MODEL/ || /Estimated Free Energy of Binding/ || /ENDMDL/) {
        molecule = molecule $0 "\n"
    }
    ' $PDB_FILE

if [[ ! -f "${ENERGY_FILE}" ]]; then
    echo "Energy File not generated!. Please check ${LIGAND_NAME}"
    exit 1
fi

# Ordenar las conformaciones por energía
sort -n ${ENERGY_FILE} -o ${ENERGY_FILE}

# Crear un archivo final con las conformaciones ordenadas
SORTED_FILE="${CONFORMATIONS_DIR}/${LIGAND_NAME}_sorted_conformations.pdb"
> ${SORTED_FILE}

# Leer solo la primera línea para el mejor pose
read -r _ MODEL_NUM _ < "${ENERGY_FILE}"
cat "${CONFORMATIONS_DIR}/model_${MODEL_NUM}.pdb" > "${CONFORMATIONS_DIR}/${LIGAND_NAME}_best_pose.pdb"

# Procesar todas las líneas para el archivo ordenado
while read -r _ MODEL_NUM _; do
    cat "${CONFORMATIONS_DIR}/model_${MODEL_NUM}.pdb" >> "${SORTED_FILE}"
done < "${ENERGY_FILE}"

sed -i 's/ /;/g' $ENERGY_FILE

echo "Sorted PDB!"

# Limpiar archivos temporales
rm -rf ${CONFORMATIONS_DIR}/model_*.pdb

# Obtener SDF con poses ordenadas

echo "Generating sorted SDF file based on sorted PDB"
obabel -ipdb "${CONFORMATIONS_DIR}/${LIGAND_NAME}_sorted_conformations.pdb" -osdf -O"${PROCESSED_DIRECTORY}/${LIGAND_NAME}/sdf/${LIGAND_NAME}_sorted_conformations.sdf"
obabel -ipdb "${CONFORMATIONS_DIR}/${LIGAND_NAME}_best_pose.pdb" -osdf -O"${PROCESSED_DIRECTORY}/${LIGAND_NAME}/sdf/${LIGAND_NAME}_best_pose.sdf"
