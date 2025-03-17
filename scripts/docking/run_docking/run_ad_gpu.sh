#!/usr/bin/bash

############################################################
# Script to run AD-GPU. It's just a for loop over all 
# ligands. For large virtual screening projects, check 
# batch flag  of ad-gpu.                                                   
############################################################

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help

   echo "Syntax: [-hrlco]"
   echo "To save a log file and also print the status, run: bash prepare_odbqt.sh -d \$DIRECTORY | tee -a \$LOGFILE"
   echo "Options:"
   echo "h     Print help"
   echo "b     AD-gpu executable file"
   echo "r     Receptor map file (fld) directory"
   echo "l     Ligands PDBQT"
   echo "o     Output directory"
   echo "n     N runs"
   echo "k     (default=1). If a ligand docking fail, keep docking the rest of ligands."
   
}

############################################################
# Process the input options. Add options as needed.        #
############################################################
# Get the options

while getopts ":hr:b:l:o:n:k:" option; do
   case $option in
      h) # Print this help
         Help
         exit;;
      b) # binary file
         EXECUTABLE=$OPTARG;;
      r) # Receptor FLD directory
         RECEPTOR_FLD=$OPTARG;;
      l) # Enter the Ligands PDBQT path
         LIGANDS_PDBQT_PATH=$OPTARG;;
      o) # Output path
         OUTPUT_PATH=$OPTARG;;
      n) # NRuns
         NRUNS=$OPTARG;;
      k) # Keep docking if a ligand fails.
         KEEP_DOCKING=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

# Default values

KEEP_DOCKING=1

LIGANDS_PDBQT=(${LIGANDS_PDBQT_PATH}/*.pdbqt)

mkdir -p ${OUTPUT_PATH}

for LIGAND_NAME in "${LIGANDS_PDBQT[@]}"
do
   LIGAND_NAME=$(basename ${LIGAND_NAME} .pdbqt)
   echo "Docking ${LIGAND_NAME}"
   ${EXECUTABLE} -L ${LIGANDS_PDBQT_PATH}/${LIGAND_NAME}.pdbqt \
                                    -M ${RECEPTOR_FLD}/*.maps.fld \
                                    --nrun ${NRUNS} \
                                    --resnam ${OUTPUT_PATH}/${LIGAND_NAME} >> ${OUTPUT_PATH}/run_ad_gpu.log
   
   # Check if docking finished correctly.
   if [[ -f "${OUTPUT_PATH}/${LIGAND_NAME}.dlg" ]]
   then
      echo "Docking ${LIGAND_NAME} was a success!"
   elif [[ ${KEEP_DOCKING} -eq 1 ]]
   then
      echo "Docking ${LIGAND_NAME} failed. Continue." > ${OUTPUT_PATH}/${LIGAND_NAME}_failed.log
   else
      echo "Docking ${LIGAND_NAME} failed. Exiting." > ${OUTPUT_PATH}/${LIGAND_NAME}_failed.log
   fi

done

echo "Done!"
