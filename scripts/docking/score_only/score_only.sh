#!/usr/bin/bash

# Global variables are always UPPERCASE.
# Local are used with local keyword and lowercase.
# If some function requires too much arguments,
# try using global variables directly, however, this is harder to
# read and debug.

#set -x
set -euo pipefail
# parallel --joblog MD_metal_docking_score_only.log -j 8 bash MD_docking_score_only.sh -d . --ligand ligands/{1} --equi 0 --prod 1 --start_frame 10000 --end_frame 10000 -n 1 ::: ligands/*.mol2

function ScriptInfo() {
  DATE="2025"
  VERSION="0.0.1"
  GH_URL="https://github.com/tcaceresm/cmascayano_lab"
  LAB="http://schuellerlab.org/"

  cat <<EOF
###################################################
Welcome to MD_docking_score_only version ${VERSION} ${DATE}   
Author: Tomás Cáceres <caceres.tomas@uc.cl>    
Laboratory of Computational simulation & drug design        
GitHub <${GH_URL}>                             
Powered by high fat food and procrastination   
###################################################
EOF
}

Help() {
  cat <<EOF
  
$(ScriptInfo)
  
Usage: 
	
	Under construction.

Computes ligand affinity scores using AD4 forcefield and MD conformations.
Calculations are paralelized using GNU parallel package.

Requirements:
  -> A folder structure and topologies obtained with setup_MD.sh script.
  -> Trajectories obtained with run_MD.sh and processed with process_MD.sh.

Required options:
-d, --work_dir     <DIR>        Working directory. Inside this directory, a folder named setupMD should exist, containing all topologies and MD files.
-l, --ligand       <FilePath>       Ligand to perform score only.
Optional:
-h, --help                      Show this help.
--equi             <0|1>        (default=1) Use trajectory from equilibration phase (noWAT_traj.nc)
--prod             <0|1>        (default=1) Use trajectory from production phase (noWAT_traj.nc).
--npts             <"x,y,z">    (default="61,60,60") Size of docking box.
--only_process     <0|1>        (default=0) Process existing results.
--start_frame      <int>        (default=1) Frame to begin reading at.
--end_frame        <int|"last"> (default="last") Frame to stop reading at; if not specified or "last" specified, end of trajectory.
--interval         <int>        (default=1) Offset for reading in trajectory frames.
-n, --replicas     <int>        (default=3) Number of replicas or repetitions.
--start_replica    <int>        (default=1) Run from --start_replica to --replicas.
--cores            <int>        (default=4) Cores to use for calculations.
EOF
}


# Check arguments
if [[ "$#" == 0 ]]; then
  echo "No options provided."
  echo "Use --help option to check available options."
  exit 1
fi

# Default values

RUN_EQUI=1
RUN_PROD=1
NPTS="61,60,60"
START_FRAME=1
END_FRAME="last"
OFFSET=1
START_REPLICA=1
REPLICAS=3
PYTHONSH="/home/tcaceres/apps/mgltools_x86_64Linux2_1.5.7/bin/pythonsh"
CORES=4

# CLI option parser
while [[ $# -gt 0 ]]; do
  case "$1" in
  '-d' | '--work_dir'        ) shift ; WDDIR=$1 ;;
  '-l' | '--ligand'          ) shift ; LIGAND_PATH=$1 ;;
  '--equi'                   ) shift ; RUN_EQUI=$1 ;;
  '--prod'                   ) shift ; RUN_PROD=$1 ;;
  '--npts'                   ) shift ; NPTS=$1 ;;
  '--start_frame'            ) shift ; START_FRAME=$1 ;;
  '--end_frame'              ) shift ; END_FRAME=$1 ;;
  '--offset'                 ) shift ; OFFSET=$1 ;;
  '-n' | '--replicas'        ) shift ; REPLICAS=$1 ;;
  '--start_replica'          ) shift ; START_REPLICA=$1 ;;
  '--cores'                  ) shift ; CORES=$1 ;;
  '--help' | '-h'            ) Help ; exit 0 ;;
  *                          ) echo "Unrecognized command line option: $1" >> /dev/stderr ; exit 1 ;;
  esac
  shift
done

function CheckProgram() {
  # Check if command is available
  for PROGRAM in "$@"; do
    if ! command -v ${PROGRAM} >/dev/null 2>&1; then
      echo "Error: <${PROGRAM}> program not available, exiting."
      exit 1
    fi
  done
}

function CheckFiles() {
  # Check existence of files
  for FILE in "$@"; do
    if [[ ! -f ${FILE} ]]; then
      echo "Error: <${FILE}> file doesn't exist."
      exit 1
    fi
  done
}

function ParseDirectory() {
  local mode=$1
  local lig=$2
  local rep=$3

  DOCK_SCORE_ONLY_DIR=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/MD/rep${rep}/${mode}/npt/dock_score_only
  mkdir -p ${DOCK_SCORE_ONLY_DIR}

}

function ParseFiles() {
  # Set topologies and trajectories files.

  local mode=$1
  local lig=$2
  local rep=$3

  # Topologies
  VAC_COM_TOPO="../../../../../topo/${lig}_vac_com.parm7"
  VAC_REC_TOPO="../../../../../topo/${lig}_vac_rec.parm7"
  VAC_LIG_TOPO="../../../../../topo/${lig}_vac_lig.parm7"

  CheckFiles ${VAC_COM_TOPO} ${VAC_REC_TOPO} ${VAC_LIG_TOPO}

  # Trajectories
  if [[ "${mode}" == "equi" ]]; then
    # EQUI_TRAJ=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/MD/rep${rep}/${mode}/npt/noWAT_traj.nc
    EQUI_TRAJ="../noWAT_traj.nc"
    CheckFiles ${EQUI_TRAJ}
  fi

  if [[ "${mode}" == "prod" ]]; then
    # PROD_TRAJ=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/MD/rep${rep}/${mode}/npt/noWAT_traj.nc
    PROD_TRAJ="../noWAT_traj.nc"
    CheckFiles ${PROD_TRAJ}
  fi

  # Ligands' PDBQT files
  # LIGAND_PDBQT=${WDDIR}/ligand_pdbqt/${lig}/${lig}.pdbqt
  # CheckFiles ${LIGAND_PDBQT}
}

function TotalResWrapper() {
  # Obtain total residue of solute, using dry topology.
  local com_topo=$1

  CheckFiles ${com_topo}

  TOTALRES=$(cpptraj -p ${com_topo} --resmask \* | tail -n 1 | awk '{print $1}')
}

function generate_cpptraj_input() {
  local traj=$1
  local outfile=$2

  cat > "$outfile" <<EOF
parm ${VAC_COM_TOPO}
trajin ${traj} ${START_FRAME} ${END_FRAME} ${OFFSET}
vector center :${TOTALRES} out lig_com.dat
strip :${TOTALRES}
trajout conformations/${RECEPTOR_NAME}.pdb pdb multi keepext
run
strip !(:${TOTALRES})
trajout conformations/${LIGAND_NAME}.mol2 mol2 multi sybyltype keepext
EOF
}

function run_cpptraj() {
  local input=$1
  CheckProgram cpptraj
  cpptraj -i "$input"
}

function split_conformation_files() {
  local traj=$1
  local cpptraj_in=$2

  generate_cpptraj_input "$traj" "$cpptraj_in"
  run_cpptraj "$cpptraj_in"
  
}

function get_conf_number() {
  local file=$1
  local conf=${file%.*}
  conf=${conf#*.}
  
  echo "$conf"
}

function mv_conformation_files() {
  local file=$1
  local conf=$2

  local dir="conformation_number_${conf}"
  mkdir -p "$dir"

  mv ${RECEPTOR_NAME}.${conf}.pdb \
     ${LIGAND_NAME}.${conf}.mol2 \
     "$dir"
}

function convert_ligand_to_pdbqt() {
  local lig=$1
  CheckProgram obabel

  obabel -i mol2 "${lig}.mol2" -o pdbqt -O "${lig}.pdbqt"
}

function get_com_for_conformation() {
  local conf=$1
  local com_file=$2

  awk -v conf="$conf" '
    $1 == conf {
      print $2, $3, $4
      exit
    }
  ' "$com_file"
}

function clean_pdb() {
  # Clean PDB from non-standard resnames 
  local pdb=$1
  awk '$4 !~ /^(HM1|HD1|FE1)$/' ${pdb} > tmp.pdb && mv tmp.pdb ${pdb}
}

function prepare_receptor() {
  local pdb=$1

  CheckProgram ${PYTHONSH}
  ${PYTHONSH} ${SCRIPT_PATH}/prepare_receptor4.py -r "${pdb}"
}

function prepare_maps() {
  local lig_pdbqt=$1
  local rec_pdbqt=$2
  local npts=$3

  local rec_name=${rec_pdbqt%.*}

  CheckProgram ${PYTHONSH}  
  #-y flag center grid box on ligand
  ${PYTHONSH} ${SCRIPT_PATH}/prepare_gpf4.py -l ${lig_pdbqt} -r ${rec_pdbqt} -o ${rec_name}.gpf -y -p npts="${npts}"

  /home/tcaceres/apps/autodock4/autogrid4 -p ${rec_name}.gpf -l ${rec_name}.glg

}

function prepare_dpf() {
  local lig_pdbqt=$1
  local rec_pdbqt=$2

  CheckProgram ${PYTHONSH}
  ${PYTHONSH} ${SCRIPT_PATH}/prepare_dpf42.py -e -l ${lig_pdbqt} -r ${rec_pdbqt} 

}
function run_docking() {
  local dpf=$1
  local output=$2
  /home/tcaceres/apps/autodock4/autodock4 -p ${dpf} -l ${output}
}

function gather_results() {
  # obtain energy value from one conformation
  local dlg_file=$1
  local conf_number=$2
  local energy
  
  declare -n results=$3
  
  energy=$(grep 'epdb: USER    Estimated Free Energy of Binding' ${dlg_file} \
         | awk -F'= *| *kcal/mol' '{print $2}')

  results["conformation_${conf_number}"]=${energy}
}

function output_results() {
  declare -n results=$1
  : > results.data
  for key in "${!results[@]}"; do
    echo "$key ${results[$key]}" >> results.data
  done
}

function process_one_conformation() {
  local mol2file=$1

  conf=$(get_conf_number "${mol2file}")
  mv_conformation_files "${mol2file}" "${conf}"

  pushd "conformation_number_${conf}" >/dev/null || exit 1

  convert_ligand_to_pdbqt "${LIGAND_NAME}.${conf}"

  clean_pdb ${RECEPTOR_NAME}.${conf}.pdb
  prepare_receptor ${RECEPTOR_NAME}.${conf}.pdb

  prepare_maps \
    ${LIGAND_NAME}.${conf}.pdbqt \
    ${RECEPTOR_NAME}.${conf}.pdbqt \
    ${NPTS}

  prepare_dpf \
    ${LIGAND_NAME}.${conf}.pdbqt \
    ${RECEPTOR_NAME}.${conf}.pdbqt

  run_docking \
    ${LIGAND_NAME}_${RECEPTOR_NAME}.dpf \
    ${LIGAND_NAME}.${conf}_${RECEPTOR_NAME}.${conf}.dlg

  popd >/dev/null
}

process() {
  local traj=$1
  local cpptraj_in="get_rec_conformations.in"

  mkdir -p conformations
  split_conformation_files "$traj" "$cpptraj_in"

  pushd conformations >/dev/null || exit 1
  . env_parallel.bash
  env_parallel --joblog score_only.log -j ${CORES} process_one_conformation {} ::: *"${LIGAND_NAME}"*.mol2

  declare -A RESULTS
  for dlg in conformation_number_*/${LIGAND_NAME}.*_${RECEPTOR_NAME}.*.dlg; do
    conf=${dlg%.*}
    conf=${conf##*.}
    gather_results "$dlg" "$conf" RESULTS
  done

  output_results RESULTS
  popd >/dev/null
}

# export -f parallel_worker

# export LIGAND_NAME RECEPTOR_NAME NPTS PYTHONSH SCRIPT_PATH

############################################################
# Main
############################################################

SCRIPT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WDDIR=$(realpath "$WDDIR")
RECEPTOR_NAME=$(basename "${WDDIR}/receptor/"*.pdb .pdb)

for REP in $(seq ${START_REPLICA} ${REPLICAS}); do

  #for LIGAND_PATH in ${LIGANDS_PATH[@]}; do

  LIGAND_NAME=${LIGAND_PATH%.*}
  LIGAND_NAME=${LIGAND_NAME##*/}

  if [[ ${RUN_EQUI} -eq 1 ]]; then
    ParseDirectory "equi" ${LIGAND_NAME} ${REP}
    cd ${DOCK_SCORE_ONLY_DIR}
    
    ParseFiles "equi" ${LIGAND_NAME} ${REP}
    TotalResWrapper ${VAC_COM_TOPO}
    ExtractConformations ${EQUI_TRAJ}
  fi

  if [[ ${RUN_PROD} -eq 1 ]]; then
    ParseDirectory "prod" ${LIGAND_NAME} ${REP}
    cd ${DOCK_SCORE_ONLY_DIR}

    ParseFiles "prod" ${LIGAND_NAME} ${REP}
    TotalResWrapper ${VAC_COM_TOPO}
    process ${PROD_TRAJ}
  fi

  #done

done

