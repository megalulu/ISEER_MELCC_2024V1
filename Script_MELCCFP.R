#Script de travail MELCCFP #

#Charger les fichier de fonctions (calcul de metrique et normalisation)
source('metric_functions.R')
source('normalization_functions.R')

#Mettre en place le dossier de travail 
setwd('C:/Meghana/TUTO_2024/')

#Charger les donnees necessaires pour tout le projet
#Charger UREC_merge : le shapefile avec la delimitation d'un sous-ensemble d'UREC (unites spatiales) 
UREC_merge = st_read(paste0(getwd(),'/data/UREC.shp'))
UREC_merge = st_make_valid(UREC_merge)#s'assurer que la geometrie de shapefile est valide
UEA_merge = st_read(paste0(getwd(),'/data/UEA.shp'))

QcLambProj = 'EPSG: 32198'#creer une variable pour la projection Quebec Lambert 

pente1 = raster(paste0(getwd(),'/data/pentes/Pentes_21L13SE.tif'))#Charger le raster de pente (faire un vrt si necessaire)
ut19_full= raster(paste0(getwd(),'/data/utilisation_territoire/ut19_mask.tif'))#Charger le raster d'utilisation du territoire (masker  sur les UREC pour reduire le temps de calcul)
csv__class_correspondence = read.csv2(paste0(getwd(),'/data/utilisation_territoire/UT_2019_10m.csv'))#Charger la table de correspondance entre les valeurs du raster d'utilisation du territoire et les categorie d'utilisation du territoire

CondHyd = terra::rast(paste0(getwd(),'/data/Conductivite_hydraulique/avr_HydraulicConductivity_mask.tif'))#Charger le raster de conductivite hydraulique masker pour les UREC. !Attention voir autre tuto pour creer ce raster!
mask_urbain_vect= st_read(paste0(getwd(),'/data/ut_urbain_vect.shp'))

MNT1 = terra::rast(paste0(getwd(),'/data/MNT/MNT_21L13SE.tif'))
MHC = terra::rast((paste0(getwd(),'/data/MHC/MHC_21L13SE.tif')))

UREC_indice_ombrage = st_read(paste0(getwd(),'/data/indicesFE/resultats_metrique_Norm_IndiceOmbrage.sqlite'))#Shapefile des resultats de l<indice d'ombrage (TUTO2022)
UREC_indiceConnectivite = st_read(paste0(getwd(),'/data/indicesFE/resultats_indice_Norm_IndiceConnectivitePaysage.sqlite'))#Shapefile des resultats de l'indice de connectivite du paysage (TUTO2022)

####################################################################################################

#Fonction de regulation de la productivite des ER
#########################
#Calculons les metriques necessaires : 
#Pente, la vegetation optimale, la vegetation, la conductivite hydraulique, hauteur emergee au pied de berge

#Charger les donnees necessaires pour tout le projet
#Charger UREC_merge : le shapefile avec la delimitation d'un sous-ensemble d'UREC (unites spatiales) 
UREC_merge = st_read(paste0(getwd(),'/data/UREC.shp'))
UREC_merge = st_make_valid(UREC_merge)#s'assurer que la geometrie de shapefile est valide

QcLambProj = 'EPSG: 32198'#creer une variable pour la projection Quebec Lambert 

pente1 = raster(paste0(getwd(),'/data/pentes/Pentes_21L13SE.tif'))#Charger le raster de pente (faire un vrt si necessaire)
ut19_full= raster(paste0(getwd(),'/data/utilisation_territoire/ut19_mask.tif'))#Charger le raster d'utilisation du territoire (masker  sur les UREC pour reduire le temps de calcul)
csv__class_correspondence = read.csv2(paste0(getwd(),'/data/utilisation_territoire/UT_2019_10m.csv'))#Charger la table de correspondance entre les valeurs du raster d'utilisation du territoire et les categorie d'utilisation du territoire

CondHyd = terra::rast(paste0(getwd(),'/data/Conductivite_hydraulique/avr_HydraulicConductivity_mask.tif'))#Charger le raster de conductivite hydraulique masker pour les UREC. !Attention voir autre tuto pour creer ce raster!
mask_urbain_vect= st_read(paste0(getwd(),'/data/ut_urbain_vect.shp'))

MNT1 = terra::rast(paste0(getwd(),'/data/MNT/MNT_21L13SE.tif'))

#Metrique pente moyenne : 
##########################################################
UREC_merge_pente1 = st_transform(UREC_merge, crs(pente1)) #Transformer la projection du fichier vectorielle a celle du raster 
UREC_merge_pente1 = vect(UREC_merge_pente1)#transformer l'objet sf en objet SpatVect pour etre compatible avec la fonction
UREC_merge_pente1 = AverageSlope(UREC_merge = UREC_merge_pente1, slope_raster = pente1) #Utiliser la fonction de pente pour calculer la metrique de pente
UREC_merge_pente1 = terra::project(UREC_merge_pente1, QcLambProj)#reprojetter le shapefile vers Quebec Lambert
writeVector(UREC_merge_pente1, paste0(getwd(),'/results/UREC_pentesMoyenne.shp'))
UREC_merge_pente2=st_as_sf(UREC_merge_pente1)#Convertir objet SpatVect a un objet sf
###
#Metrique surface de la vegetation optimale et de la vegetation
##########################################
UREC_merge_surface_class1 = UREC_merge #creer une variable de travail pour calculer les metriques de vegetation optimale et vegetation
UREC_merge_surface_class1 = SurfaceClass(UREC_merge = UREC_merge_surface_class1, csv_class_correspondence = csv__class_correspondence,
                                  raster_file = ut19_full)#extraire les surface de toutes les classes generales d'utilisation du territoire a l'aide de la fonction SurfaceClass
UREC_merge_surface_class1$vegopt = UREC_merge_surface_class1$Forestier+UREC_merge_surface_class1$Humide #La surface de la vegetation optimale inclue la surface de la foret et des milieu humide
UREC_merge_surface_class1$veg= UREC_merge_surface_class1$Forestier+UREC_merge_surface_class1$Humide+UREC_merge_surface_class1$Agricole #La surface de la vegetation optimale inclue la surface de la foret et des milieu humide et de l'agriculture
st_write(UREC_merge_surface_class1, paste0(getwd(),'/results/UREC_surfaces1.sqlite'))#Ecrire le shapefile dans les resultats and SQLITE pour ne pas changer le nom des colonne

###
#Metrique de conductivite hydraulique (CondHyd)
##########################################
mask_urbain_vect1=st_transform(mask_urbain_vect,crs(CondHyd))#s'assurer que le mask urbain et le raster de conductivite hydraulique sont dans la meme projection
UREC_merge_CondHy = UREC_merge
UREC_merge_CondHy = AverageHydraulicConductivity(raster_avrHc = CondHyd, UREC_merge = UREC_merge_CondHy,urban_vector = mask_urbain_vect1)
st_write(UREC_merge_CondHy, paste0(getwd(),'/results/UREC_CondHyd.sqlite'))#Ecrire le shapefile dans les resultats and SQLITE pour ne pas changer le nom des colonne

###
#Metrique de hauteur emergee au pied de berge (HepB)
##########################################
UREC_merge_HepB = st_transform(UREC_merge, crs(MNT1))#reprojetter le shapefile des urec vers la projection du MNT
mask_urbain_vect2 = st_transform(mask_urbain_vect, crs(MNT1))#transformer la projection du shapefile du mask urbain vers la projection du MNT
UREC_merge_HepB=AverageHepb(UREC_merge = UREC_merge_HepB, raster_mnt = MNT1, urban_mask_vect =mask_urbain_vect2 )#Extraire la HebP pour les unites spatiales
UREC_merge_HepB= st_transform(UREC_merge_HepB, crs(UREC_merge))#Retransformer le shapefile on projection quebec lambert
st_write(UREC_merge_HepB, paste0(getwd(),'/results/UREC_HepB.sqlite'))#Ecrire le fichier

##############################################################
#NORMALISATION et inversion des metriques
#############
#Drop geometry of sf objects we need to join
UREC_merge_surface_class1_dg= st_drop_geometry(UREC_merge_surface_class1)
UREC_merge_CondHy_dg= st_drop_geometry(UREC_merge_CondHy)
UREC_merge_HepB_dg= st_drop_geometry(UREC_merge_HepB)

# join sf objects with metric values based on id column
UREC_merge_prodER <- UREC_merge_pente2 %>%
  left_join(UREC_merge_surface_class1_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,avrSlope,vegopt, veg)

UREC_merge_prodER <- UREC_merge_prodER %>%
  left_join(UREC_merge_CondHy_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,avrSlope,vegopt, veg,HydCond)

UREC_merge_prodER <- UREC_merge_prodER %>%
  left_join(UREC_merge_HepB_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,avrSlope,vegopt, veg,HydCond,hepb)

st_write(UREC_merge_prodER, paste0(getwd(),'/results/UREC_ProdMetriques1.sqlite'))#Ecrire le shapegfile avec les metriques

#Faire la normalisation 
###############################
UREC_merge_prodER_nrm= Normalization_function(UREC_merge =UREC_merge_prodER)#Faire rouler la fonction de normalisation
#Faire l'inversion de la pente (plus la pente est elevee moins il y a capacite de captation du ruissellement de surface)
UREC_merge_prodER_nrm_inv = New_inverse_fun(UREC_norm = UREC_merge_prodER_nrm, col_names = c('avrSlope_nrm'))
st_write(UREC_merge_prodER, paste0(getwd(),'/results/UREC_ProdMetriques1_nrm_inv.sqlite'))#Ecrire le shapegfile avec les metriques normalise et inverse

#####################################################
#Mise en place de l'indice
UREC_merge_prodER_indice = UREC_merge_prodER_nrm
UREC_merge_prodER_indice$indiceProd = (UREC_merge_prodER_indice$avrSlope_nrm+
                                         UREC_merge_prodER_indice$vegopt_nrm+
                                         UREC_merge_prodER_indice$veg_nrm+
                                         UREC_merge_prodER_indice$HydCond_nrm+
                                         UREC_merge_prodER_indice$hepb_nrm)/5
st_write(UREC_merge_prodER_indice, paste0(getwd(),'/results/UREC_ProdIndice1.sqlite'))


##############################################################################################################################
##############################################################################################################################
# Fonction de creation et maintien de l'habitat riverain

###########################################
#Les metriques a calculer sont : la surface de la vegetation optimale, le nombre de differente classe de vegetation, la surface anthropique, la moyenne de la hauteur des arbres, la moyenne de la largeur de l'unite



#Metrique surface de la vegetation optimale et de la vegetation et surface anthropique 
########################################## (ces metriques ont deja etaientt calculees pour la fonction de regulation de la productivite des ERS)
UREC_merge_surface_class1

#Metrique nombre de classe de vegetation
UREC_merge_nrb_class = NumberClasses(UREC_merge = UREC_merge, raster_file = ut19_full)#Utiliser la fonction du nombre de classe pour obtenir la metriques
st_write(UREC_merge_nrb_class,paste0(getwd(),'/results/UREC_nbr_class.sqlite'))#Ecrire le shapefile

#Metrique hauteur moyenne des arbres
UREC_merge_hauteurA = st_transform(UREC_merge, crs(MHC))#transformer les shapefile UREC vers la projection du raster MHC
UREC_merge_hauteurA=vect(UREC_merge_hauteurA)#Transformer l'objet sf en spatvect
mask_urbain_vect3 = st_transform(mask_urbain_vect, crs(MHC))#transformer les shapefile du mask urbain vers la projection du raster MHC
mask_urbain_vect3=vect(mask_urbain_vect3)#transformer l'object sf en spatVector
EPSG = 'EPSG:2949'
UREC_merge_hauteurA= TreeStats(UREC_merge = UREC_merge_hauteurA,raster_file = MHC, EPSG = EPSG,urban_vector_mask = mask_urbain_vect3)
UREC_merge_hauteurA=st_as_sf(UREC_merge_hauteurA)#remettre le vecteur des URECs and objet sf
UREC_merge_hauteurA=st_transform(UREC_merge_hauteurA, crs(UREC_merge))#changer la project vers du Quebec lambert
st_write(UREC_merge_hauteurA,paste0(getwd(),'/results/UREC_treeStats.sqlite'))#Ecrire le shapefile

#Metrice moyenne de la largeur de l'unite
UREC_merge_largUnite= LateralWidthFunction(UREC_merge=UREC_merge, UEA_merge = UEA_merge)
st_write(UREC_merge_largUnite,paste0(getwd(),'/results/UREC_largeurUnite.sqlite'))#Ecrire le shapefile


##############################################################
#NORMALISATION et inversion des metriques
##########################################
#Drop geometry of sf objects we need to join (j'ai laisser UREC_merge_nbr_class avec la geomtry pour faire le join)
UREC_merge_surface_class1_dg= st_drop_geometry(UREC_merge_surface_class1)#memem que precedement
UREC_merge_hauteurA_dg= st_drop_geometry(UREC_merge_hauteurA)
UREC_merge_largUnite_dg = st_drop_geometry(UREC_merge_largUnite)

# join sf objects with metric values based on id column
UREC_merge_Habitat <-UREC_merge_nrb_class %>%
  left_join(UREC_merge_surface_class1_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,nbr_class,vegopt,Anthropique )

UREC_merge_Habitat <- UREC_merge_Habitat %>%
  left_join(UREC_merge_hauteurA_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,nbr_class,vegopt,Anthropique,meanHeight)

UREC_merge_Habitat <- UREC_merge_Habitat %>%
  left_join(UREC_merge_largUnite_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,nbr_class,vegopt,Anthropique,meanHeight,meanlenght)
st_write(UREC_merge_Habitat,paste0(getwd(),'/results/UREC_CreationMaintienHabitat_metriques.sqlite'))

#Do normalisation of data 
UREC_merge_Habitat_nrm = Normalization_function(UREC_merge_Habitat)
#Inverse metrique surface de l<anthropique pour prendre en consideration son effet negatif
UREC_merge_Habitat_nrm_inv = New_inverse_fun(UREC_norm = UREC_merge_Habitat_nrm, col_names = c('Anthropique_nrm'))
st_write(UREC_merge_Habitat_nrm_inv, paste0(getwd(),'/results/UREC_CreationMaintienHabitat_metriques_nrm_inv.sqlite'))


############################################################
#Creer l'indice de creation et de maintien de l'habitat riverain
UREC_merge_Habitat_indice = UREC_merge_Habitat_nrm_inv
UREC_merge_Habitat_indice$indiceHabitat = (UREC_merge_Habitat_indice$nbr_class_nrm+
                                             UREC_merge_Habitat_indice$vegopt_nrm+
                                             UREC_merge_Habitat_indice$Anthropique_nrm+
                                             UREC_merge_Habitat_indice$meanHeight_nrm+
                                             UREC_merge_Habitat_indice$meanlenght_nrm)/5

st_write(UREC_merge_Habitat_indice, paste0(getwd(),'/results/UREC_CreationMaintienHabitat_indice.sqlite'))




##########################################################################
##########################################################################
#Caculer l'ISEER : Les metriques a inclure sont : la surface de la vegetation , la moyenne de la pente, le taux de dispersion des parcelles de vegetation optimale (pd), la hauteur emergee au pied de berge (HepB),Surface de la canope en surplomb, la conductivite hydraulique (HydCond), la largeur de l<unite

#Mettre ensemble les metriques necessaires (utiliser les version normalise et inverse de chaque metrique)
UREC_merge_ISEER = UREC_merge

#Enlever la geometry des couches de metriques 
UREC_merge_indiceOmbrage_dg = st_drop_geometry(UREC_indice_ombrage)#indice ombrage
UREC_merge_indice_ConP_dg = st_drop_geometry(UREC_indiceConnectivite)#Indice connectivite du paysage
UREC_merge_prodER_indice_dg = st_drop_geometry(UREC_merge_prodER_indice)#indice de regulation de la productivite des ER
UREC_merge_Habitat_indice_dg = st_drop_geometry(UREC_merge_Habitat_indice)#Indice de creation et de maintien de l'habitat

#Joindre les tables necessaire  a UREC_merge_ISEER (Avec les bonnes metriques)
#Prendre les shapefile des indices (ici productivite de l'ER)
UREC_merge_ISEER <-UREC_merge %>%
  left_join(UREC_merge_prodER_indice_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,veg_nrm,avrSlope_nrm,hepb_nrm,HydCond_nrm)
UREC_merge_ISEER <-UREC_merge_ISEER %>%
  left_join(UREC_merge_Habitat_indice_dg, by = c("id", 'Id_UEA',"rive")) %>%
  select(id,Id_UEA,rive,veg_nrm,avrSlope_nrm,hepb_nrm,HydCond_nrm,meanlenght_nrm)
UREC_merge_ISEER <-UREC_merge_ISEER %>%
  left_join(UREC_merge_indiceOmbrage_dg, by = c("id","rive")) %>%
  select(id,Id_UEA,rive,veg_nrm,avrSlope_nrm,hepb_nrm,HydCond_nrm,meanlenght_nrm,canopyratio_nrm) #Attention l'argument 'by' a changer du au fait de la non concordance entre le nom de la colonne Id_UEA (une avec une majuscule vs sans)
UREC_merge_ISEER <-UREC_merge_ISEER %>%
  left_join(UREC_merge_indice_ConP_dg, by = c("id","rive")) %>%
  select(id,Id_UEA,rive,veg_nrm,avrSlope_nrm,hepb_nrm,HydCond_nrm,meanlenght_nrm,canopyratio_nrm,pd_vegetation_optimale_nrm)

#Mettre en place l'indice 
UREC_merge_ISEER$ISEER = (UREC_merge_ISEER$veg_nrm+
                            UREC_merge_ISEER$avrSlope_nrm+
                            UREC_merge_ISEER$hepb_nrm+
                            UREC_merge_ISEER$HydCond_nrm+
                            UREC_merge_ISEER$meanlenght_nrm+
                            UREC_merge_ISEER$canopyratio_nrm+
                            UREC_merge_ISEER$pd_vegetation_optimale_nrm)/7
st_write(UREC_merge_ISEER,paste0(getwd(),'/results/UREC_ISEER.sqlite') )#ecrire le fichier
