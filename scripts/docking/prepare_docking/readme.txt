
Meeko package tutorial available at https://meeko.readthedocs.io/en/release-doc/

Steps to prepare ligands:
    1) Get SMILES of each ligand.
        CMPD1.smi
        CMPD2.smi
        ...
    2) Protonate and compute partial charges. In MOE:
        2.1) Create a new database.
             all_H_ESP.mdb
        2.2) Protonate at desired pH.
        2.3) Calculate partial charges.
        2.4) Save as a single MOL2 file.
             In this case, I call it all_H_ESP.mol2
    4) Prepare PDBQT files using Meeko package.
        4.1) Install the develop branch of Meeko
             https://github.com/forlilab/Meeko/tree/develop
        4.2) Process .mol2 with mk_prepare_ligand.py, keeping partial charges computed in 2.3
             mk_prepare_ligand.py -i all.mol2 \
             --multimol_outdir test_pdbqt \
             --charge_model read \ # this is why we need develop branch             
    5) Perform sanity checks
        5.1) Check if pdbqt name match real name.
        5.2) Compare partial charges of .mol2 file and .pdbqt file.

Steps to prepare the protein:
    1) Get PDB file from Protein Data Bank (https://www.rcsb.org/)
    2) In MOE
        2.1) Protonate 3D
        2.2) Minimize using MM forcefield
        2.3) Check protonation states of important residues.
    3) Prepare PDBQT file using Meeko package
        4.1) If not installed, follow instructions https://meeko.readthedocs.io/en/release-doc/
        4.2) mk_prepare_receptor -i protein.pdb --write_pdbqt protein_prepared.pdbqt

Steps to compute grid maps files
    1) Check for prepare_gpf4.py script and pythonsh from MGLTools or ADFRsuite
        1.1) https://ccsb.scripps.edu/mgltools/
        1.2) https://ccsb.scripps.edu/adfr/downloads/
    2) Check Grid box size and center coordinates.
    3) Check all ligands atom types:
        3.1) awk '{print $12}' *.pdbqt | sort | uniq
    3) Get grid parameter file (GPF):
       pythonsh prepare_gpf4.py -l any_ligand.pdbqt \ 
       -r receptor.pdbqt \
       -p npts='X,Y,Z' \ # Size of GridBox
       -p gridcenter='X,Y,Z' \ # Coordinates of center of GridBox
       -p ligand_types='A,C,HD,OA' # Ligand AtomTypes. Can edit as needed
    4) Run:
       autogrid4 -p receptor.gpf -l receptor.glg

Steps to use classic AutoDock4 (NO GPU)
In adition to above steps, follow this only if you want to use AutoDock4. The steps mentioned above are enough to use AutoDock4-GPU.
    1) Obtain DPF file:
       pythonsh prepare_dpf42.py -l ligand.pdbqt -r receptor.pdbqt -p ga_run=100

