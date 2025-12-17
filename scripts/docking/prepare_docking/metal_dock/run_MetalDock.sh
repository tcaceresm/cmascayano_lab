#! /usr/bin/bash

REC="5-hLOX"
export REC
parallel -j 6 '
    MOL=$(basename {})
    echo "Doing ${MOL}"
    cd ./input_files_${REC}/${MOL}
    INPUT_FILE=./${MOL}.ini
    ~/Documents/GitHubRepos/MetalDock/metaldock -i "${INPUT_FILE}" -m dock
' ::: ./input_files_${REC}/*fenilo*/
