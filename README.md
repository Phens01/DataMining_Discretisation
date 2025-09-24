# DataMining_Discretisation
# Application de Discrétisation des Données

## 📊 Vue d'ensemble

Cette application Shiny interactive permet d'explorer et d'appliquer différentes techniques de discrétisation sur des données numériques. Elle a été développée pour analyser le dataset de qualité du vin rouge, mais peut être utilisée avec d'autres jeux de données CSV.

## 🎯 Objectifs du Projet

- **Explorer** et analyser des données numériques continues
- **Appliquer** quatre techniques de discrétisation différentes
- **Visualiser** et interpréter les résultats de chaque méthode
- **Comparer** l'efficacité des différentes approches
- **Exporter** les résultats pour une utilisation ultérieure

## 🛠️ Fonctionnalités

### Navigation Intuitive
- **Accueil** : Présentation du projet et des objectifs
- **Données** : Import, visualisation et analyse des données
- **Discrétisation** : Application des techniques et analyse des résultats
- **À propos** : Informations sur l'application et l'auteur

### Techniques de Discrétisation Implémentées

1. **Largeur d'Intervalle Égale** 
   - Divise la plage en intervalles de même taille
   - Idéal pour des distributions uniformes
  
2. **Fréquence Égale** 
   - Crée des intervalles avec le même nombre d'observations
   - Assure une représentation équilibrée

3. **Basée sur l'Entropie** 
   - Maximise l'information préservée
   - Optimale pour l'apprentissage automatique

4. **Par Classification (K-means)** 
   - Identifie des groupes naturels dans les données
   - Découvre la structure intrinsèque des données

## 📋 Prérequis

### Logiciels Requis
- **R** (version ≥ 4.0.0)
- **RStudio** (recommandé)

### Packages R Nécessaires
```r
# Installation des packages requis
install.packages(c(
  "shiny",
  "shinythemes", 
  "DT",
  "dplyr",
  "ggplot2",
  "infotheo",
  "cluster",
  "caret"
))

# Package optionnel pour les matrices de corrélation
install.packages("corrplot")
```

## 🚀 Installation et Lancement

### 1. Clonage du Projet
```bash
git clone https://github.com/Phens01/DataMining_Discretisation.git
cd DataMining_Discretisation
```

### 2. Structure des Fichiers
```
DataMining_Discretisation/
├── app_.R                    # Application Shiny principale
├── winequality-red.csv      # Jeu de données par défaut
├── README.md               # Ce fichier
```

### 3. Lancement de l'Application
```r
# Dans R ou RStudio
library(shiny)
runApp("app_.R")
```

L'application s'ouvrira automatiquement dans votre navigateur par défaut ou une fenêtre popup de RStudio.

## 📊 Utilisation

### Import de Données
1. Naviguez vers l'onglet **"Données"**
2. Utilisez le bouton **"Choisir un fichier CSV"** pour importer vos données
3. Configurez les paramètres d'import (séparateur, en-têtes)
4. Consultez l'aperçu et le résumé statistique

### Application de la Discrétisation
1. Allez dans l'onglet **"Discrétisation"**
2. Sélectionnez la variable à discrétiser
3. Définissez le nombre d'intervalles souhaités (2-10)
4. Cliquez sur l'une des quatre techniques disponibles
5. Analysez les résultats et visualisations générées

### Export des Résultats
- Utilisez le bouton **"Exporter les résultats"** pour sauvegarder l'analyse
- Le fichier contient les statistiques, coupures et interprétations

## 📁 Jeu de Données Par Défaut

L'application utilise le **Wine Quality Dataset** de l'UCI Machine Learning Repository :

### Caractéristiques
- **Source** : UCI ML Repository
- **Observations** : 1,599 vins rouges
- **Variables** : 12 variables numériques
- **Variable cible** : `quality` (qualité du vin, échelle 3-8)

### Variables Disponibles
- `fixed.acidity` : Acidité fixe
- `volatile.acidity` : Acidité volatile
- `citric.acid` : Acide citrique
- `residual.sugar` : Sucre résiduel
- `chlorides` : Chlorures
- `free.sulfur.dioxide` : Dioxyde de soufre libre
- `total.sulfur.dioxide` : Dioxyde de soufre total
- `density` : Densité
- `pH` : Niveau de pH
- `sulphates` : Sulfates
- `alcohol` : Taux d'alcool
- `quality` : Qualité (variable cible)

## 🔧 Architecture Technique

### Technologies Utilisées
- **Framework** : R Shiny
- **Interface** : Bootstrap (theme Spacelab)
- **Visualisation** : ggplot2
- **Manipulation de données** : dplyr
- **Théorie de l'information** : infotheo
- **Clustering** : cluster, stats

### Structure de l'Application
```r
# Interface utilisateur (UI)
├── Sidebar Navigation
├── Main Panel
    ├── Dynamic UI based on navigation
    └── Reactive outputs

# Serveur (Server)
├── Data Management
├── Navigation Logic  
├── Discretization Functions
├── Visualization Outputs
└── Export Functionality
```

## 📈 Cas d'Usage

### Types de Données Compatibles
- Données numériques continues
- Fichiers CSV avec en-têtes
- Données avec ou sans valeurs manquantes
- Taille recommandée : 100-10,000 observations

## 📞 Support et Contact

### Auteur
**MVOGO Stéphane**
- Email : franck.mvogo@facsciences-uy1.cm


### Ressources Utiles
- [Documentation R Shiny](https://shiny.rstudio.com/)
- [Wine Quality Dataset](https://archive.ics.uci.edu/ml/datasets/Wine+Quality)
- [Théorie de la Discrétisation](https://en.wikipedia.org/wiki/Discretization)

---

**Date de développement** : 2025  
**Version** : 1.0.0  
**Statut** : Actif
