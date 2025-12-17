#! /usr/bin/bash

# Esto es para recalcular los grid maps incluyendo la carga del Fe en 5-hLOX
# Hay que asegurarse que el pdbqt del receptor incluya al Fe y con la carga que queramos
# Copiar 5-hLOX.pdb y preparar con Meeko y obtener 5-hLOX.pdbqt.
# Hay que ejecutar 1 vez MetalDock con clean pdb true y luego pegar 5-hLOX.pdbqt a la carpeta, y re ejecutar los maps

# 1. Activar entorno MeekoDevelop 
# source ~/apps/venvs/MeekoDevelop/bin/activate

#mk_prepare_receptor.py --read_pdb ./5-hLOX.pdb --write_pdbqt ./5-hLOX.pdbqt

# 2. Modificar carga del Fe (3+ a 1.154 ) !

# 3. Copiar 5-hLOX.pdbqt a las carpetas output/docking/

# COMPOUNDS=("Fe_fenilo_H" "Re_fenilo_H" "Ru_fenilo_H" "Fe_tiazolina_H" "Re_tiazolina_H" "Ru_tiazolina_H")
# #for COMPOUND in ../input_files_5-hLOX/*_*_*_*_*
# for COMPOUND in ${COMPOUNDS[@]}
#     do
#  #       MOL=$(basename ${COMPOUND})
#  #       echo "Copying 5-hLOX.pdbqt with Fe to ../${COMPOUND}/output/docking"
#  #       cp ./5-hLOX.pdbqt ../${COMPOUND}/output/docking
#          echo "Copying 5-hLOX.pdbqt with Fe to ../input_files_5-hLOX/${COMPOUND}/output/docking/"
#          cp ./5-hLOX.pdbqt ../input_files_5-hLOX_Alosterico/${COMPOUND}/output/docking/
#     done

# 4. Modificar gpf para incluir Fe en receptor_types


# find . -name "*.gpf" -exec sh -c '
#   for file do
#     awk '\''$1 == "receptor_types" { $2 = "Fe " $2 } { print }'\'' "$file" > "$file.tmp" && mv "$file.tmp" "$file"
#   done
# ' sh {} +


# 5. Recalcular maps
export RECEPTOR="5-hLOX"

#export AUTOGRID=/home/pc-usach-cm/Documentos/autodocksuite-4.2.6-x86_64Linux2/x86_64Linux2/autogrid4
# export AUTOGRID=/home/tcaceres/apps/autodock4/autogrid4

# parallel -j 6 '
#    MOL=$(basename {});
#    cd {}/output/docking/;
#    $AUTOGRID -p ${MOL}_${RECEPTOR}.gpf -l ${MOL}_${RECEPTOR}.glg
# ' ::: ../input_files_${RECEPTOR}/*fenilo*

# 6. Hacer docking

#export AUTODOCK=/home/pc-usach-cm/Documentos/autodocksuite-4.2.6-x86_64Linux2/x86_64Linux2/autodock4
export AUTODOCK=/home/tcaceres/apps/autodock4/autodock4
parallel -j 3 '
    MOL=$(basename {});
    cd {}/output/docking/;
    $AUTODOCK -p ${MOL}_${RECEPTOR}.dpf -l ${MOL}_${RECEPTOR}.dlg
' ::: ../input_files_${RECEPTOR}/*
