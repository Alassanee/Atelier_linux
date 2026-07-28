#!/bin/bash

# ============================================
# setup_project.sh
# Ce script sert a creer automatiquement un projet IA
# avec tous les dossiers, la config, les logiciels et le dataset
# ============================================

# on demande a l'utilisateur le nom du projet
# read sert a recuperer ce que l'utilisateur va taper au clavier
echo "=========================================="
read -p "Entrez le nom du projet : " NOM_PROJET

# petite securite : si l'utilisateur n'a rien tape, on arrete le script
if [ -z "$NOM_PROJET" ]; then
    echo "Erreur : tu dois donner un nom de projet !"
    exit 1
fi

 
# 1) Creation de l'arborescence du projet
# mkdir -p permet de creer tous les dossiers d'un coup
# meme si les dossiers parents n'existent pas encore
echo "Creation de l'arborescence..."

mkdir -p "$NOM_PROJET"/{api,Backup,config,datasets/brut,documentation,logs,models,scripts,shared}

# on verifie que ca a bien fonctionne (arborescence)
if [ -d "$NOM_PROJET" ]; then
    ARBORESCENCE="OK"
else
    ARBORESCENCE="ECHEC"
fi

# 2) Creation du fichier de configuration
# on cree deux fichiers de config comme demande dans l'arborescence
echo "Creation du fichier de configuration..."

cat > "$NOM_PROJET/config/settings.conf" << EOF
# fichier de configuration generale du projet
project_name=$NOM_PROJET
created_on=$(date)
EOF

cat > "$NOM_PROJET/config/model.conf" << EOF
# fichier de configuration du modele IA
model_type=default
version=1.0
EOF

# on verifie que les deux fichiers existent bien
if [ -f "$NOM_PROJET/config/settings.conf" ] && [ -f "$NOM_PROJET/config/model.conf" ]; then
    CONFIG="OK"
else
    CONFIG="ECHEC"
fi

# 3) Installation des logiciels necessaires
# on met a jour la liste des paquets avant d'installer
echo "Installation des logiciels (ca peut prendre un moment)..."

sudo apt update -y

# on installe tous les logiciels demandes en une seule commande
sudo apt install -y git curl wget htop tree python3 python3-pip unzip

# on verifie que les logiciels principaux sont bien installes
# command -v renvoie le chemin du programme s'il existe
if command -v git > /dev/null && command -v python3 > /dev/null && command -v wget > /dev/null; then
    LOGICIELS="OK"
else
    LOGICIELS="ECHEC"
fi

# 4) Telechargement du dataset
echo "Telechargement du dataset iris.csv..."

# url du dataset donne dans la consigne
URL_DATASET="https://raw.githubusercontent.com/mwaskom/seaborn-data/master/iris.csv"

# on telecharge le fichier directement dans le dossier datasets
wget -q "$URL_DATASET" -O "$NOM_PROJET/datasets/iris.csv"

# on verifie que le fichier a bien ete telecharge et qu'il n'est pas vide
if [ -s "$NOM_PROJET/datasets/iris.csv" ]; then
    DATASET="OK"
else
    DATASET="ECHEC"
fi

# 5) Compression du projet
echo "Compression du projet..."

# tar -czf cree une archive compressee (gzip) du dossier entier
tar -czf "$NOM_PROJET/Backup/${NOM_PROJET}.tar.gz" "$NOM_PROJET"

# on garde le chemin de l'archive pour l'afficher dans le resume
CHEMIN_ARCHIVE="$NOM_PROJET/Backup/${NOM_PROJET}.tar.gz"

# 6) Affichage du resume final
# echo permet juste d'afficher du texte dans le terminal
echo "============================"
echo "Projet cree"
echo "Nom : $NOM_PROJET"
echo "Arborescence : $ARBORESCENCE"
echo "Fichier de config : $CONFIG"
echo "Logiciels : $LOGICIELS"
echo "Datasets : $DATASET"
echo "Archive : $CHEMIN_ARCHIVE"
echo "Installation terminee."
