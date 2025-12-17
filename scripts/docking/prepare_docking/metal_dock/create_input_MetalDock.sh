#! /usr/bin/bash

# Create .ini files required by MetalDock

RECEPTOR_NAMES=("hCOX-1" "hCOX-2" "5-hLOX" "5-hLOX_Alosterico")

for RECEPTOR_NAME in "${RECEPTOR_NAMES[@]}"
do
	echo "Receptor is ${RECEPTOR_NAME}"
	if [[ ${RECEPTOR_NAME} == "5-hLOX" ]]
	then
		X="-1.14"
		Y="4.15"
		Z="3.61"
		CLEAN_PDB="True"

	elif [[ ${RECEPTOR_NAME} == "5-hLOX_Alosterico" ]]
	then
		X="-0.47"
		Y="-31.76"
		Z="6.09"
		CLEAN_PDB="True"

	elif [[ ${RECEPTOR_NAME} == *"hCOX"* ]]
	then
	# Same coords for hCOX-1 and hCOX-2
		X="-29.78"
		Y="-41.65"
		Z="3.93"
		CLEAN_PDB="True"
	fi

	for MOL in ./raw_ligands/*.xyz
	do
		MOL=$(basename ${MOL} .xyz)
		echo "  Doing ${MOL}"
		if [[ ${MOL} == I_* || ${MOL} == *Re* ]]; then
			METAL="Re"
			CHARGE=0
			SPIN=0
		elif [[ ${MOL} == II_* || ${MOL} == *Fe* ]]; then
			METAL="Fe"
			CHARGE=0
			SPIN=0
		elif [[ ${MOL} == IV_* || ${MOL} == *Ru* ]]; then
			METAL="Ru"
			CHARGE=0
			SPIN=0
		elif [[ ${MOL} == V_* || ${MOL} == *Mn* ]]; then
			METAL="Mn"
			CHARGE=0
			SPIN=0
		fi

		echo "    Metal is ${METAL}"

		mkdir -p ./input_files_${RECEPTOR_NAME}/${MOL}/

		cp ./raw_structure/${RECEPTOR_NAME}.pdb ./input_files_${RECEPTOR_NAME}/${MOL}/
		
		cp ./raw_ligands/${MOL}.xyz ./input_files_${RECEPTOR_NAME}/${MOL}/

		ALREADY_OPT=0
		if [[ ${ALREADY_OPT} == 1 && ${RECEPTOR_NAME} != "hCOX-1" ]] # MetalDock succesful optimized compounds. Always hCOX-1 first.
		then
			mkdir -p ./input_files_${RECEPTOR_NAME}/${MOL}/output/QM/geom_opt/
			cp ./input_files_hCOX-1/${MOL}/output/QM/geom_opt/* ./input_files_${RECEPTOR_NAME}/${MOL}/output/QM/geom_opt/
		fi
		
		# Old box size are x,y,z=30,30,30,
		# New box size are x.y,z=22.5,20.625,22.5
		cat > ./input_files_${RECEPTOR_NAME}/${MOL}/${MOL}.ini <<-EOF
		[DEFAULT]
		metal_symbol = ${METAL}
		method = dock
		ncpu = 10
		memory = 5000

		[PROTEIN]
		pdb_file = ${RECEPTOR_NAME}.pdb 
		pH = 7.4 
		clean_pdb = ${CLEAN_PDB}

		[QM]
		engine = GAUSSIAN 
		basis_set = LANL2DZ 
		functional_type = Hybrid
		functional = B3LYP
		dispersion = GD3BJ

		[METAL_COMPLEX]
		geom_opt = True
		xyz_file = ${MOL}.xyz
		charge = ${CHARGE}
		spin = ${SPIN}
		vacant_site = False

		[DOCKING]
		rmsd = False
		box_size = 22.875,22.875,22.5
		random_pos = True
		num_poses = 100
		dock_x = ${X}
		dock_y = ${Y}
		dock_z = ${Z}
		ga_dock_num_evals = 2500000
	EOF
	done
done
