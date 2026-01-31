#!/usr/bin/bash

MD_DIRECTORY="/home/tcaceres/Documents/USACH/cmascayano/work/MD/cMD/MD/"
RUN_SETUPMD=0
POSE=3
LIGAND="Imina_A_2_Fe_hCOX-2"
CLUSTERID=4
for DLG in ${LIGAND}.dlg; do
  if [[ ${RUN_SETUPMD} == 0 ]]; then

  LIG=$(basename ${DLG} .dlg)
  echo "Doing ${LIG}"

  LIGNAME="${LIG%_*}"
  
  RECEPTOR="${DLG##*_}"     # remove everything until the last "_": 5-hLOX.dlg
  RECEPTOR="${RECEPTOR%%.*}"      # quita desde el primer "." hacia adelante: 5-hLOX

  BIGGER_CLUSTERID=$(cat "processed_output/${LIG}/sdf/cluster/2.0/clusterID.txt")
  BIGGER_CLUSTERID=${CLUSTERID}
  BEST_POSE_OF_CLUSTER=$(grep -oP 'Run = \K\d+' processed_output/${LIG}/sdf/cluster/2.0/*cluster${BIGGER_CLUSTERID}_* | head -n 1)
  #BEST_POSE_OF_CLUSTER=$(grep -oP 'Run = \K\d+' processed_output/${LIG}/sdf/cluster/2.0/*_outliers_* | head -n 1)

  awk '/MODEL[[:space:]]+'"$BEST_POSE_OF_CLUSTER"'/ {f=1} f && /ENDMDL/ {print; exit} f' "processed_output/${LIG}/pdb/${LIG}_withMetal.pdb" > \
  "processed_output/${LIG}/pdb/${LIG}_withMetal_forMD.pdb"

  MODEL=$(grep 'Run =' "processed_output/${LIG}/pdb/${LIG}_withMetal_forMD.pdb" | awk '{print $4}')

  echo "clusterid is: ${BIGGER_CLUSTERID}, best pose of this clusterid is: ${BEST_POSE_OF_CLUSTER} and model is: ${MODEL}"

  if [[ ${BEST_POSE_OF_CLUSTER} != ${MODEL} ]]; then
    echo "Error: Model and BIGGER_CLUSTERID don't match. Exiting..."; exit 1
  fi

#  cp "processed_output/${LIG}/pdb/${LIG}_withMetal_forMD.pdb" "${MD_DIRECTORY}/${RECEPTOR}/ligands/${LIG}.pdb"

  cp "processed_output/${LIG}/pdb/${LIG}_withMetal_forMD.pdb" "${MD_DIRECTORY}/${RECEPTOR}/from_docking/${LIGNAME}_${POSE}_${RECEPTOR}_docked.pdb"

  obabel -i pdb "${MD_DIRECTORY}/${RECEPTOR}/from_docking/${LIGNAME}_${POSE}_${RECEPTOR}_docked.pdb" \
         -o mol2 -O "${MD_DIRECTORY}/${RECEPTOR}/ligands/${LIGNAME}_${POSE}.mol2"

  rm "processed_output/${LIG}/pdb/${LIG}_withMetal_forMD.pdb" # "${MD_DIRECTORY}/${RECEPTOR}/ligands/${LIG}.pdb"

  fi

  # Run setup_MD, then

done
