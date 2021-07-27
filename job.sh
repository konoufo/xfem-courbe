#!/bin/bash
## *****************************************************
## IMPORTANT: Il faut faire "module load MEFPP" *avant* de lancer sbatch avec ce fichier
##            car on y injecte des paramètres via les modules...
## Notez que deux ## indique un commentaire, alors que #SBATCH est une commande pour l'ordonnanceur.
## *****************************************************

## **NE PAS MODIFIER** ces 2 lignes:
#SBATCH --constraint="*** Chargez le module MEFPP avant de lancer sbatch ***" ## Ne pas modifier: Ça assure qu'on a bien chargé le module *avant* de lancer sbatch...
#SBATCH --exclusive                                                           ## Ne pas modifier: Nous assure de ne pas partager un noeud de calcul!

## *****************************************************
## Section de choses à **MODIFIER** selon votre calcul:
## *****************************************************
#SBATCH --job-name=recherche-sphere-valide  ## Le "nom" de la job... détermine aussi le nom de fichier de sortie
#SBATCH --nodes=2                      ## Le nb total de noeuds désirés
#SBATCH --time=06:00:00                ## Durée max (hh:mm:ss)
#SBATCH --account=rrg-deteix           ## Numéro de l'allocation 2020-2021 de Jean Deteix
#SBATCH --mem=12G                        ## Demande toute la mémoire des noeuds, sans limite blocante par processus.  Ici, on peut demander des noeuds de 186 Go si on écrit 186G.
#SBATCH --mail-user=konoufo@hotmail.fr       ## La liste des personnes à avertir par courriel
#SBATCH --mail-type=BEGIN,END,FAIL     ## Notifications par courriel pour événements: NONE, BEGIN, END, FAIL, REQUEUE, ALL
#SBATCH -o %x-%j.out.txt               ## On redirigera les sorties (stdout/stderr) vers ces fichier (nb: %x désigne le nom de la job et %j le job_id)
#SBATCH -e %x-%j.err.txt

# **CHANGER** Le nb de processus désirés par "noeud":
#    - Spécial: Pour demander 1 processus par coeur mettre:
#               export nb_processus_par_noeud=0
#
#    - Génial : Pour demander la moitié des coeurs de chaque noeud:
#               export nb_processus_par_noeud=$(( SLURM_CPUS_ON_NODE / 2))
#
#    - Normal : Pour demander 16 coeurs par noeuds:
#               export nb_processus_par_noeud=16
#
export nb_processus_par_noeud=$(( SLURM_CPUS_ON_NODE / 2))
#export nb_processus_par_noeud=1

# **Important**: Il faut que la ligne suivante apparaissent après avoir renseigné la variable nb_processus_par_noeud:
module load MEFPP; eval "${MEFPP_ENVMPI}"

# La variable $MPIEXEC_MEFPP contient tous les "bons" paramètres pour lancer MEF++ avec le bon nombre de processus, bindings, etc...
# Le binaire lancé est celui contenu dans variable $MEFPP_BINAIRE qui est MEF++.opt par défaut.
# **Ajouter** les arguments:
#MPIEXEC_MEFPP_DEV="$( echo ${MPIEXEC_MEFPP} | sed 's/MEF++\.opt/MEF++\.dev/' )"
./recherche_sphere_valide.sh decoupagelevelset ../cube64-h "$MPIEXEC_MEFPP"

