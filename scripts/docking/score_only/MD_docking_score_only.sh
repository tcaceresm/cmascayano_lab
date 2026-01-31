#!/usr/bin/bash

# Global variables are always UPPERCASE.
# Local are used with local keyword and lowercase.
# If some function requires too much arguments,
# try using global variables directly, however, this is harder to
# read and debug.

#set -x 
# parallel --joblog MD_docking_score_only.log -j 8 bash MD_docking_score_only.sh -d . --ligand ligands/{1} --equi 0 --prod 1 --start_frame 10000 --end_frame 10000 -n 1 ::: ligands/*.mol2

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

Requirements:
  -> MetalDock package (with score_only option).
  -> An unsolvated protein-ligand topology and trajectory.
  -> ligand in PDBQT format.
  -> A folder structure and topologies obtained with setup_MD.sh is required.
  -> Trajectories obtained with run_MD.sh and processed with process_MD.sh are required.
  -> A folder named ligand_pdbqt inside working directory will be used to search the corresponding ligand PDBQT file.


Required options:
-d, --work_dir     <DIR>        Working directory. Inside this directory, a folder named setupMD should exist, containing all topologies and MD files.
-l, --ligand       <PATH>       Ligand to perform score only.
Optional:
-h, --help                      Show this help.
--equi             <0|1>        (default=1) Use trajectory from equilibration phase (noWAT_traj.nc)
--prod             <0|1>        (default=1) Use trajectory from production phase (noWAT_traj.nc).
--parameter_file   <PATH>
--start_frame
--end_frame
--interval         <integer>    (default=1) The offset from which to choose frames from each trajectory file.
-n, --replicas     <integer>    (default=3) Number of replicas or repetitions.
--start_replica    <integer>    (default=1) Run from --start_replica to --replicas.
--parallel         <0|1>        (default=0) Use GNU parallel to run parallel calculations.
--cores            <integer>    (default=4) Number of cores to parallelize, if --parallel is set to 1.
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
START_FRAME=1
END_FRAME=9999999
INTERVAL=1
START_REPLICA=1
REPLICAS=3
PARALLEL=0
CORES=4
INPUT_FILE="mm_pbsa.in"
PARAMETER_FILE="metal_dock.dat"
METALDOCK_EXE="/home/tcaceres/Documents/GitHubRepos/MetalDockFork/metaldock"


# CLI option parser
while [[ $# -gt 0 ]]; do
  case "$1" in
  '-d' | '--work_dir'        ) shift ; WDDIR=$1 ;;
  '-l' | '--ligand'          ) shift ; LIGAND_PATH=$1 ;;
  '--equi'                   ) shift ; RUN_EQUI=$1 ;;
  '--prod'                   ) shift ; RUN_PROD=$1 ;;
  '--parameter_file'         ) shift ; PARAMETER_FILE=$1 ;;
  '--start_frame'            ) shift ; START_FRAME=$1 ;;
  '--end_frame'              ) shift ; END_FRAME=$1 ;;
  '--interval'               ) shift ; INTERVAL=$1 ;;
  '-n' | '--replicas'        ) shift ; REPLICAS=$1 ;;
  '--start_replica'          ) shift ; START_REPLICA=$1 ;;
  '--parallel'               ) shift ; PARALLEL=$1 ;;
  '--cores'                  ) shift ; CORES=$1 ;;
  '--help' | '-h'            ) Help ; exit 0 ;;
  *                          ) echo "Unrecognized command line option: $1" >> /dev/stderr ; exit 1 ;;
  esac
  shift
done

function CheckProgram() {
  # Check if command is available
  for COMMAND in "$@"; do
	if ! command -v ${1} >/dev/null 2>&1; then
	  echo "Error: ${1} program not available, exiting."
	  exit 1
	fi
  done
}

function CheckFiles() {
  # Check existence of files
  for ARG in "$@"; do
	if [[ ! -f ${ARG} ]]; then
	  echo "Error: <${ARG}> file doesn't exist."
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

  if [[ -z "${lig}" ]]; then
	echo "Error in ParseDirectories(): lig variable is required."
	exit 1
  fi

  # Topologies
  # VAC_COM_TOPO=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/topo/${lig}_vac_com.parm7
  # VAC_REC_TOPO=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/topo/${lig}_vac_rec.parm7
  # VAC_LIG_TOPO=${WDDIR}/setupMD/${RECEPTOR_NAME}/proteinLigandMD/${lig}/topo/${lig}_vac_lig.parm7
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
trajin ${traj} ${START_FRAME} ${END_FRAME} ${INTERVAL}
vector center :${TOTALRES} out lig_com.dat
strip :${TOTALRES}
trajout conformations/${RECEPTOR_NAME}.pdb pdb multi keepext
run
strip !(:${TOTALRES})
trajout conformations/${LIGAND_NAME}.pdb pdb multi keepext
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

function mv_conformation_files() {
  local file=$1
  local conf=${file%.*}
  conf=${conf#*.}

  local dir="conformation_number_${conf}"
  mkdir -p "$dir"

  mv ${RECEPTOR_NAME}.${conf}.pdb \
     ${LIGAND_NAME}.${conf}.pdb \
     "$dir"

  echo "$conf"
}

function convert_ligand_to_xyz() {
  local lig=$1
  CheckProgram obabel

  obabel -i pdb "${lig}.pdb" -o xyz -O "${lig}.xyz"
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

function write_MetalDock_ini_file() {
  local conf=$1
  local comx=$2
  local comy=$3
  local comz=$4

  cat > "${LIGAND_NAME}.${conf}.ini" <<EOF
[DEFAULT]
metal_symbol = Fe
method = dock
ncpu = 1
memory = 1000

[PROTEIN]
pdb_file = ${RECEPTOR_NAME}.${conf}.pdb
pH = 7.4
clean_pdb = True

[QM]
engine = GAUSSIAN
basis_set = LANL2DZ
functional_type = Hybrid
functional = B3LYP
dispersion = GD3BJ

[METAL_COMPLEX]
geom_opt = False
xyz_file = ${LIGAND_NAME}.${conf}.xyz
charge = 0
spin = 1
vacant_site = False

[DOCKING]
rmsd = False
box_size = 22.875,22.875,22.5
dock_x = ${comx}
dock_y = ${comy}
dock_z = ${comz}
ga_dock = False
sa_dock = False
score_only = True
EOF
}

function copy_qm_files() {
  # Copy QM output files
  local ligand=$1
  local path=$2

  LIGAND_QM=${WDDIR}/ligand_qm/${ligand}/

  mkdir -p ${path}
  ln -s ${LIGAND_QM}/* ${path}
}

function clean_pdb() {
  # Clean PDB from non-standard resnames 
  local pdb=$1
  awk '$4 !~ /^(HM1|HD1|FE1)$/' ${pdb} > tmp.pdb && mv tmp.pdb ${pdb}
}

function gather_results() {
  # obtain energy value from one conformation
  local dlg_file=$1
  local conf_number=$2
  local energy
  
  declare -n results=$3
  
  energy=$(grep 'Estimated Free Energy of Binding' ${dlg_file} \
         | awk -F'= *| *kcal/mol' '{print $2}')

  results["conformation_${conf_number}"]=${energy}
}

function output_results() {
  declare -n results=$1
  for key in "${!RESULTS[@]}"; do
    echo "$key ${RESULTS[$key]}" >> results.data
  done
}

process() {
  local traj=$1
  local cpptraj_in="get_rec_conformations.in"

  declare -A RESULTS # Array to store score of all conformations

  mkdir -p conformations
  split_conformation_files "$traj" "$cpptraj_in"
  # generate_cpptraj_input "$traj" "$cpptraj_in"
  # run_cpptraj "$cpptraj_in"

  pushd conformations >/dev/null || exit 1

  for conformations in *${LIGAND_NAME}*.pdb; do
    conf=$(mv_conformation_files "$conformations")

    pushd "conformation_number_${conf}" >/dev/null || exit 1

    convert_ligand_to_xyz "${LIGAND_NAME}.${conf}"

    declare -A COM
    read COM[x] COM[y] COM[z] < <(
      get_com_for_conformation "$conf" "../../lig_com.dat"
    )
    clean_pdb ${RECEPTOR_NAME}.${conf}.pdb

    write_MetalDock_ini_file "$conf" "${COM[x]}" "${COM[y]}" "${COM[z]}"
    copy_qm_files ${LIGAND_NAME} "./output/QM/single_point/"
    ${METALDOCK_EXE} -i "${LIGAND_NAME}.${conf}.ini" -m dock
    gather_results "./output/docking/${LIGAND_NAME}.${conf}_${RECEPTOR_NAME}.${conf}.dlg" \
                    "$conf" RESULTS

    popd >/dev/null

  done

  output_results RESULTS
  popd >/dev/null
}


############################################################
# Main
############################################################

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

