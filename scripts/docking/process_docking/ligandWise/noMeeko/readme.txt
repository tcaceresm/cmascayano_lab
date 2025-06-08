This folder contains scripts related to processing of docking output.
It relies in ChemmineR and dplyr R packages. In contrast to other scripts, these scripts don't require Meeko package

Main script:

	process_output_parallel.sh

Run bash process_output_parallel.sh -h for help.

Under the hood, it calls three diferent scripts:

	1) process_dlg.sh:
	    
		requires:
		1.1) OpenBabel
		

	2) rmsd_matrix.sh

		requires:
		2.1) obrms from OpenBabel not provided here.

	3) run_clustering.sh

		requires:
		3.1) clustering.R provided here.

This three scripts can be run indepently if you want. Check -h flag for more help in each script.