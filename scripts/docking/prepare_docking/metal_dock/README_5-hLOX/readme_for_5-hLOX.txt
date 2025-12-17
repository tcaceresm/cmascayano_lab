En 5-hLOX, el hierro es relevante, pero metaldock limpia los cofactores.
Lo que hago es que ejecuto metaldock hasta que empieza a correr autodock4 y calcula los maps usando el receptor sin hierro.
cancelo el run. En la carpeta output/docking estan los archivos para autodock4.
Aquí reemplazo 5-hLOX.pdbqt por:
	-file_prep/5-hLOX.pdb 
	-de este archivo obtengo el pdbqt
	-cálculo de maps para que incluya al hierro con prepare_gpf4 y autogrid4

Utilizar recompute_5-hLOX.sh leyendo los comentarios dentro del script.
