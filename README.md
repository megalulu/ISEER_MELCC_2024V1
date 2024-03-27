# ISEER_MELCC_2024V1
Ce repertoir contient les scripts pour la mise en place des indices de fonctions ecologiques et l'ISEER global. Un tutoriel (avec donnees et resultats) est disponible pour expliquer le fonctionnement des scripts (contacter meghana.paranjape@usherbrooke.ca) : 

Le Script 'Script_MELCCFP' permet de calculer :
1. Indice de regulation de la productivite des ecosystemes riverains
2. Indice de creation et de maintien de l'habitat riverain
3. Indice global ISEER (Indice de suivi de l'etat des ecosystemes riverains)

Le script 'Metric_functions' contient les fonctions R permettant de calculer toutes les metriques necessaires pour les quatre indices de fonctions ecologiques (Indice de connectivite du paysage, indice creation et de maintien de l'habitat riverain, indice regulation de la productivite des ecosystemes riverains, indice de regulation de la temperature l'eau)

Le script 'Normalization_functions' contient les fonctions R permettant de normalisation (selon le max et le min) les valeurs des metrique dans les unites spatiales (ici UREC). Ce scripts contient aussi une fonction permettant d'inverser la valeur de certaines metriques afin de prendre en consideration leur apport negatif. 



