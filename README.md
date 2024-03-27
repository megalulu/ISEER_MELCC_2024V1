# ISEER_MELCC_2024V1
Ce répertoire contient les scripts pour la mise en place des indices de fonctions écologiques et l'ISEER global. Un tutoriel (avec données et résultats) est disponible pour expliquer le fonctionnement des scripts (contacter meghana.paranjape@usherbrooke.ca) : 

Le Script 'Script_MELCCFP' permet de calculer :
1. Indice de régulation de la productivité des écosystèmes riverains
2. Indice de création et de maintien de l'habitat riverain
3. Indice global ISEER (Indice de suivi de l'état des écosystèmes riverains)

Le script 'Metric_functions' contient les fonctions R permettant de calculer toutes les métriques nécessaires pour les quatre indices de fonctions écologiques (Indice de connectivite du paysage, indice création et de maintien de l'habitat riverain, indice régulation de la productivité des écosystèmes riverains, indice de régulation de la température l'eau)

Le script 'Normalization_functions' contient les fonctions R permettant de normalisation (selon le max et le min) les valeurs des métriques dans les unités spatiales (ici UREC). Ce script contient aussi une fonction permettant d'inverser la valeur de certaines métriques afin de prendre en considération leur apport négatif. 



