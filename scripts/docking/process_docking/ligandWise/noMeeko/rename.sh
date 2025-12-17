# Rename Ligands name from A serie to standarize it. All ligand should be coded into 5-component name.
# This happens when I don't think seriously.
# Set 1
# # Serie A
# 4_A --> H_tiazolina_fenilo_H_H
sed -i 's/4_A/H_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"4_A/\"H_tiazolina_fenilo_H_H/g' all_clusters.csv

# I_A --> Re_tiazolina_fenilo_H_H
sed -i 's/;I_A/;Re_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"I_A/\"Re_tiazolina_fenilo_H_H/g' all_clusters.csv

# II_A --> Fe_tiazolina_fenilo_H_H
sed -i 's/;II_A/;Fe_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"II_A/\"Fe_tiazolina_fenilo_H_H/g' all_clusters.csv

# III_A --> Fenilo_tiazolina_fenilo_H_H
sed -i 's/;III_A/;fenilo_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"III_A/\"fenilo_tiazolina_fenilo_H_H/g' all_clusters.csv

# IV_A --> Ru_tiazolina_fenilo_H_H
sed -i 's/;IV_A/;Ru_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"IV_A/\"Ru_tiazolina_fenilo_H_H/g' all_clusters.csv

# V_A --> Mn_tiazolina_fenilo_H_H
sed -i 's/;V_A/;Mn_tiazolina_fenilo_H_H/g' all_docking_scores.csv
sed -i 's/\"V_A/\"Mn_tiazolina_fenilo_H_H/g' all_clusters.csv

# # Serie B
# 4_B --> H_tiazolina_fenilo_OH_OH
sed -i 's/4_B/H_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/4_B/H_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# I_B --> Re_tiazolina_fenilo_OH_OH
sed -i 's/;I_B/;Re_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/\"I_B/\"Re_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# II_B --> Fe_tiazolina_fenilo_OH_OH
sed -i 's/;II_B/;Fe_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/\"II_B/\"Fe_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# III_B --> Fenilo_tiazolina_fenilo_OH_OH
sed -i 's/;III_B/;fenilo_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/\"III_B/\"fenilo_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# IV_B --> Ru_tiazolina_fenilo_OH_OH
sed -i 's/;IV_B/;Ru_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/\"IV_B/\"Ru_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# V_B --> Mn_tiazolina_fenilo_OH_OH
sed -i 's/;V_B/;Mn_tiazolina_fenilo_OH_OH/g' all_docking_scores.csv
sed -i 's/\"V_B/\"Mn_tiazolina_fenilo_OH_OH/g' all_clusters.csv

# # Serie C
# 4_C --> H_tiazolina_fenilo_OH_OMe
sed -i 's/4_C/H_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/4_C/H_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# I_C --> Re_tiazolina_fenilo_OH_OMe
sed -i 's/;I_C/;Re_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/\"I_C/\"Re_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# II_C --> Fe_tiazolina_fenilo_OH_OMe
sed -i 's/;II_C/;Fe_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/\"II_C/\"Fe_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# III_C --> Fenilo_tiazolina_fenilo_OH_OMe
sed -i 's/;III_C/;fenilo_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/\"III_C/\"fenilo_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# IV_C --> Ru_tiazolina_fenilo_OH_OMe
sed -i 's/;IV_C/;Ru_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/\"IV_C/\"Ru_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# V_C --> Mn_tiazolina_fenilo_OH_OMe
sed -i 's/;V_C/;Mn_tiazolina_fenilo_OH_OMe/g' all_docking_scores.csv
sed -i 's/\"V_C/\"Mn_tiazolina_fenilo_OH_OMe/g' all_clusters.csv

# # Serie D
# 4_D --> H_tiazolina_fenilo_OH_H
sed -i 's/4_D/H_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/4_D/H_tiazolina_fenilo_OH_H/g' all_clusters.csv

# I_D --> Re_tiazolina_fenilo_OH_H
sed -i 's/;I_D/;Re_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/\"I_D/\"Re_tiazolina_fenilo_OH_H/g' all_clusters.csv

# II_D --> Fe_tiazolina_fenilo_OH_H
sed -i 's/;II_D/;Fe_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/\"II_D/\"Fe_tiazolina_fenilo_OH_H/g' all_clusters.csv

# III_D --> Fenilo_tiazolina_fenilo_OH_H
sed -i 's/;III_D/;fenilo_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/\"III_D/\"fenilo_tiazolina_fenilo_OH_H/g' all_clusters.csv

# IV_D --> Ru_tiazolina_fenilo_OH_H
sed -i 's/;IV_D/;Ru_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/\"IV_D/\"Ru_tiazolina_fenilo_OH_H/g' all_clusters.csv

# V_D --> Mn_tiazolina_fenilo_OH_H
sed -i 's/;V_D/;Mn_tiazolina_fenilo_OH_H/g' all_docking_scores.csv
sed -i 's/\"V_D/\"Mn_tiazolina_fenilo_OH_H/g' all_clusters.csv

# # Serie E
# 4_E --> H_tiazolina_fenilo_OMe_H
sed -i 's/4_E/H_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/4_E/H_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# I_E --> Re_tiazolina_fenilo_OMe_H
sed -i 's/;I_E/;Re_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/\"I_E/\"Re_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# II_E --> Fe_tiazolina_fenilo_OMe_H
sed -i 's/;II_E/;Fe_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/\"II_E/\"Fe_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# III_E --> Fenilo_tiazolina_fenilo_OMe_H
sed -i 's/;III_E/;fenilo_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/\"III_E/\"fenilo_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# IV_E --> Ru_tiazolina_fenilo_OMe_H
sed -i 's/;IV_E/;Ru_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/\"IV_E/\"Ru_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# V_E --> Mn_tiazolina_fenilo_OMe_H
sed -i 's/;V_E/;Mn_tiazolina_fenilo_OMe_H/g' all_docking_scores.csv
sed -i 's/\"V_E/\"Mn_tiazolina_fenilo_OMe_H/g' all_clusters.csv

# Set 3
# # fenilos
# Fe_fenilo_H --> Fe_fenilo_H_H_H
sed -i 's/Fe_fenilo_H/Fe_fenilo_H_H_H/g' all_docking_scores.csv
sed -i 's/Fe_fenilo_H/Fe_fenilo_H_H_H/g' all_clusters.csv

# Ru_fenilo_H --> Ru_fenilo_H_H_H
sed -i 's/Ru_fenilo_H/Ru_fenilo_H_H_H/g' all_docking_scores.csv
sed -i 's/Ru_fenilo_H/Ru_fenilo_H_H_H/g' all_clusters.csv

# Re_fenilo_H --> Re_fenilo_H_H_H
sed -i 's/Re_fenilo_H/Re_fenilo_H_H_H/g' all_docking_scores.csv
sed -i 's/Re_fenilo_H/Re_fenilo_H_H_H/g' all_clusters.csv

# fenilo_fenilo_H --> fenilo_fenilo_H_H_H
sed -i 's/fenilo_fenilo_H/fenilo_fenilo_H_H_H/g' all_docking_scores.csv
sed -i 's/fenilo_fenilo_H/fenilo_fenilo_H_H_H/g' all_clusters.csv

# # tiazolina
# Fe_tiazolina_H --> Fe_tiazolina_H_H_H
sed -i 's/Fe_tiazolina_H/Fe_tiazolina_H_H_H/g' all_docking_scores.csv
sed -i 's/Fe_tiazolina_H/Fe_tiazolina_H_H_H/g' all_clusters.csv

# Ru_tiazolina_H --> Ru_tiazolina_H_H_H
sed -i 's/Ru_tiazolina_H/Ru_tiazolina_H_H_H/g' all_docking_scores.csv
sed -i 's/Ru_tiazolina_H/Ru_tiazolina_H_H_H/g' all_clusters.csv

# Re_tiazolina_H --> Re_tiazolina_H_H_H
sed -i 's/Re_tiazolina_H/Re_tiazolina_H_H_H/g' all_docking_scores.csv
sed -i 's/Re_tiazolina_H/Re_tiazolina_H_H_H/g' all_clusters.csv

# fenilo_tiazolina_H --> fenilo_tiazolina_H_H_H
sed -i 's/fenilo_tiazolina_H/fenilo_tiazolina_H_H_H/g' all_docking_scores.csv
sed -i 's/fenilo_tiazolina_H/fenilo_tiazolina_H_H_H/g' all_clusters.csv
