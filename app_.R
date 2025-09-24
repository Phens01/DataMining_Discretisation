# Charger les bibliothèques nécessaires
library(shiny)
library(shinythemes)
library(DT)
library(dplyr)
library(ggplot2)
library(infotheo)
library(cluster)
library(caret)

# Interface utilisateur
ui <- fluidPage(
  theme = shinytheme("united"),
  titlePanel("Application de Discretisation des Données"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      tags$div(
        style = "margin-bottom: 20px;",
        h4("Navigation")
      ),
      actionButton("accueil", "Accueil", width = "100%", style = "margin-bottom: 10px;"),
      actionButton("donnees", "Données", width = "100%", style = "margin-bottom: 10px;"),
      actionButton("discretisation", "Discretisation", width = "100%", style = "margin-bottom: 10px;"),
      actionButton("apropos", "À propos", width = "100%", style = "margin-bottom: 10px;")
    ),
    
    mainPanel(
      width = 9,
      uiOutput("contenu_principal")
    )
  )
)

# Serveur
server <- function(input, output, session) {
  
  # Données par défaut
  donnees_defaut <- reactive({
    # Lecture des données fournies
    df <- read.csv("winequality-red.csv", sep = ";")
    return(df)
  })
  
  # Données importées par l'utilisateur
  donnees_importees <- reactive({
    req(input$fichier_importe)
    tryCatch({
      df <- read.csv(input$fichier_importe$datapath, 
                     sep = input$separateur,
                     header = input$header)
      return(df)
    }, error = function(e) {
      showNotification("Erreur lors de l'importation du fichier", type = "error")
      return(NULL)
    })
  })
  
  # Données actives (importées ou par défaut)
  donnees_actives <- reactive({
    if (!is.null(donnees_importees())) {
      return(donnees_importees())
    } else {
      return(donnees_defaut())
    }
  })
  
  # Variable pour suivre l'onglet actif
  onglet_actif <- reactiveVal("accueil")
  
  # Observers pour les boutons de navigation
  observeEvent(input$accueil, { onglet_actif("accueil") })
  observeEvent(input$donnees, { onglet_actif("donnees") })
  observeEvent(input$discretisation, { onglet_actif("discretisation") })
  observeEvent(input$apropos, { onglet_actif("apropos") })
  
  # Contenu principal basé sur l'onglet actif
  output$contenu_principal <- renderUI({
    switch(onglet_actif(),
           "accueil" = ui_accueil(),
           "donnees" = ui_donnees(),
           "discretisation" = ui_discretisation(),
           "apropos" = ui_apropos()
    )
  })
  
  # UI pour l'onglet Accueil
  ui_accueil <- function() {
    tagList(
      h2("Bienvenue dans l'Application de Discretisation des Données"),
      p("Cette application permet d'appliquer différentes techniques de discretisation sur le jeu de données de qualité du vin rouge."),
      br(),
      h3("Objectifs du projet :"),
      tags$ul(
        tags$li("Explorer et analyser le jeu de données sur la qualité du vin"),
        tags$li("Appliquer quatre techniques de discretisation différentes"),
        tags$li("Visualiser et interpréter les résultats"),
        tags$li("Exporter les résultats pour une utilisation ultérieure")
      ),
      br(),
      h3("Techniques de discretisation disponibles :"),
      tags$ol(
        tags$li("Largeur d'intervalle égale (Equal Interval Width)"),
        tags$li("Fréquence égale (Equal Frequency)"),
        tags$li("Basée sur l'entropie (Entropy-based)"),
        tags$li("Par classification (Clustering)")
      ),
      br(),
      p("Utilisez les boutons de navigation sur la gauche pour explorer l'application.")
    )
  }
  
  # UI pour l'onglet Données
  ui_donnees <- function() {
    tagList(
      h2("Gestion des Données"),
      
      # Section d'importation
      wellPanel(
        h4("Importation des données"),
        fileInput("fichier_importe", "Choisir un fichier CSV",
                  accept = c(".csv")),
        fluidRow(
          column(6,
                 checkboxInput("header", "En-tête", TRUE)
          ),
          column(6,
                 selectInput("separateur", "Séparateur",
                             choices = c("Virgule" = ",", "Point-virgule" = ";", "Tabulation" = "\t"),
                             selected = ";")
          )
        )
      ),
      
      # Affichage des données
      h4("Aperçu des données"),
      DTOutput("tableau_donnees"),
      
      # Résumé des données
      h4("Résumé statistique"),
      verbatimTextOutput("resume_donnees"),
      
      # Analyse sans prétraitement
      h4("Analyse sans prétraitement"),
      actionButton("analyser_sans_pretraitement", "Afficher l'analyse", 
                   class = "btn btn-primary"),
      uiOutput("analyse_sans_pretraitement")
    )
  }
  
  # UI pour l'onglet Discretisation
  ui_discretisation <- function() {
    tagList(
      h2("Techniques de Discretisation"),
      p("Sélectionnez une technique de discretisation à appliquer :"),
      
      fluidRow(
        column(3,
               actionButton("btn_egale_largeur", "Largeur égale", 
                            class = "btn btn-primary", width = "100%",
                            style = "margin-bottom: 10px;")
        ),
        column(3,
               actionButton("btn_egale_freq", "Fréquence égale", 
                            class = "btn btn-primary", width = "100%",
                            style = "margin-bottom: 10px;")
        ),
        column(3,
               actionButton("btn_entropie", "Basée sur l'entropie", 
                            class = "btn btn-primary", width = "100%",
                            style = "margin-bottom: 10px;")
        ),
        column(3,
               actionButton("btn_clustering", "Par classification", 
                            class = "btn btn-primary", width = "100%",
                            style = "margin-bottom: 10px;")
        )
      ),
      
      # Sélection de la variable
      wellPanel(
        h4("Paramètres de discretisation"),
        selectInput("variable_discretisation", "Variable à discretiser :",
                    choices = "quality", selected = "quality"),  # Valeur par défaut
        numericInput("nb_intervalles", "Nombre d'intervalles :", 
                     value = 3, min = 2, max = 10)
      ),
      
      # Résultats
      uiOutput("resultats_discretisation"),
      
      # Bouton d'exportation
      downloadButton("exporter_resultats", "Exporter les résultats",
                     class = "btn btn-success")
    )
  }
  
  # UI pour l'onglet À propos
  ui_apropos <- function() {
    tagList(
      h2("À propos de l'application"),
      p("Cette application a été développée dans le cadre d'un projet de data science."),
      br(),
      h3("Informations techniques :"),
      tags$ul(
        tags$li("Développée avec RShiny"),
        tags$li("Packages utilisés : shiny, dplyr, ggplot2, infotheo, cluster, caret"),
        tags$li("Techniques de discretisation implémentées : 4 méthodes différentes")
      ),
      br(),
      h3("Auteur :"),
      p("MVOGO Stéphane"),
      br(),
      h3("Liens utiles :"),
      tags$ul(
        tags$li(tags$a(href = "https://github.com/votre-username/votre-repo", 
                       "Code source sur GitHub")),
        tags$li(tags$a(href = "https://archive.ics.uci.edu/ml/datasets/Wine+Quality", 
                       "Jeu de données Wine Quality"))
      ),
      br(),
      p("Date de développement : ", Sys.Date())
    )
  }
  
  # Mise à jour des choix de variables pour la discretisation
  observe({
    donnees <- donnees_actives()
    if (!is.null(donnees)) {
      vars_numeriques <- names(donnees)[sapply(donnees, is.numeric)]
      # Mettre à jour la liste déroulante avec les variables numériques
      # Conserver la sélection actuelle si elle existe toujours
      current_selection <- input$variable_discretisation
      if (is.null(current_selection) || !(current_selection %in% vars_numeriques)) {
        current_selection <- "quality"  # Valeur par défaut
      }
      
      updateSelectInput(session, "variable_discretisation",
                        choices = vars_numeriques,
                        selected = current_selection)
    }
  })
  
  # Affichage des données
  output$tableau_donnees <- renderDT({
    donnees <- donnees_actives()
    if (!is.null(donnees)) {
      datatable(donnees, options = list(scrollX = TRUE, pageLength = 5))
    }
  })
  
  # Résumé des données
  output$resume_donnees <- renderPrint({
    donnees <- donnees_actives()
    if (!is.null(donnees)) {
      summary(donnees)
    }
  })
  
  # Analyse sans prétraitement
  observeEvent(input$analyser_sans_pretraitement, {
    output$analyse_sans_pretraitement <- renderUI({
      donnees <- donnees_actives()
      if (!is.null(donnees)) {
        tagList(
          h5("Distribution de la qualité du vin :"),
          plotOutput("hist_qualite"),
          h5("Matrice de corrélation :"),
          plotOutput("correlation_plot")
        )
      }
    })
  })
  
  # Histogramme de la qualité
  output$hist_qualite <- renderPlot({
    donnees <- donnees_actives()
    if (!is.null(donnees) && "quality" %in% names(donnees)) {
      ggplot(donnees, aes(x = quality)) +
        geom_histogram(binwidth = 0.5, fill = "skyblue", color = "black") +
        labs(title = "Distribution de la qualité du vin",
             x = "Qualité", y = "Fréquence") +
        theme_minimal()
    }
  })
  
  # Matrice de corrélation
  output$correlation_plot <- renderPlot({
    donnees <- donnees_actives()
    if (!is.null(donnees)) {
      donnees_numeriques <- donnees[, sapply(donnees, is.numeric)]
      cor_matrix <- cor(donnees_numeriques, use = "complete.obs")
      
      # Vérifier si corrplot est disponible
      if (requireNamespace("corrplot", quietly = TRUE)) {
        corrplot::corrplot(cor_matrix, method = "color", type = "upper", 
                           order = "hclust", tl.cex = 0.8, tl.col = "black")
      } else {
        # Alternative si corrplot n'est pas disponible
        heatmap(cor_matrix, main = "Matrice de corrélation")
      }
    }
  })
  
  # Fonctions de discretisation
  
  # 1. Largeur d'intervalle égale
  discretisation_egale_largeur <- function(variable, n_intervalles) {
    min_val <- min(variable, na.rm = TRUE)
    max_val <- max(variable, na.rm = TRUE)
    largeur <- (max_val - min_val) / n_intervalles
    
    coupures <- seq(min_val, max_val, length.out = n_intervalles + 1)
    intervalles <- cut(variable, breaks = coupures, include.lowest = TRUE)
    
    return(list(
      intervalles = intervalles,
      coupures = coupures,
      methode = "Largeur d'intervalle égale"
    ))
  }
  
  # 2. Fréquence égale
  discretisation_egale_freq <- function(variable, n_intervalles) {
    quantiles <- quantile(variable, probs = seq(0, 1, length.out = n_intervalles + 1), 
                          na.rm = TRUE)
    intervalles <- cut(variable, breaks = quantiles, include.lowest = TRUE)
    
    return(list(
      intervalles = intervalles,
      coupures = quantiles,
      methode = "Fréquence égale"
    ))
  }
  
  # 3. Basée sur l'entropie - VERSION CORRIGÉE
  discretisation_entropie <- function(variable, n_intervalles) {
    # Utilisation de la discrétisation par entropie avec une approche robuste
    tryCatch({
      # Méthode MDL (Minimum Description Length) pour la discrétisation par entropie
      resultat <- infotheo::discretize(variable, nbins = n_intervalles)
      
      # Calcul des coupures basées sur les points de coupure réels
      unique_vals <- unique(variable)
      if (length(unique_vals) > n_intervalles) {
        # Approche par quantiles pour obtenir des coupures significatives
        quantiles <- quantile(variable, probs = seq(0, 1, length.out = n_intervalles + 1), na.rm = TRUE)
        coupures <- quantiles
      } else {
        # Si pas assez de valeurs uniques, utiliser les valeurs uniques
        coupures <- sort(unique_vals)
      }
      
      return(list(
        intervalles = resultat,
        coupures = coupures,
        methode = "Basée sur l'entropie (MDL)"
      ))
    }, error = function(e) {
      # Fallback vers la méthode des fréquences égales en cas d'erreur
      showNotification("Méthode entropie a échoué, utilisation de la méthode fréquence égale", type = "warning")
      return(discretisation_egale_freq(variable, n_intervalles))
    })
  }
  
  # 4. Par classification (clustering)
  discretisation_clustering <- function(variable, n_intervalles) {
    # K-means clustering
    set.seed(123)
    clusters <- kmeans(matrix(variable, ncol = 1), centers = n_intervalles)
    
    # Trier les centres pour créer des intervalles ordonnés
    centres_ordonnes <- sort(clusters$centers[,1])
    coupures <- c(-Inf, (centres_ordonnes[-1] + centres_ordonnes[-n_intervalles])/2, Inf)
    
    intervalles <- cut(variable, breaks = coupures)
    
    return(list(
      intervalles = intervalles,
      coupures = coupures,
      methode = "Par classification (K-means)"
    ))
  }
  
  # Gestion des boutons de discretisation
  observeEvent(input$btn_egale_largeur, {
    appliquer_discretisation("egale_largeur")
  })
  
  observeEvent(input$btn_egale_freq, {
    appliquer_discretisation("egale_freq")
  })
  
  observeEvent(input$btn_entropie, {
    appliquer_discretisation("entropie")
  })
  
  observeEvent(input$btn_clustering, {
    appliquer_discretisation("clustering")
  })
  
  # Fonction pour appliquer la discretisation
  appliquer_discretisation <- function(methode) {
    donnees <- donnees_actives()
    variable <- input$variable_discretisation
    n_intervalles <- input$nb_intervalles
    
    if (is.null(donnees) || variable == "") {
      showNotification("Veuillez sélectionner une variable valide", type = "warning")
      return()
    }
    
    # Vérifier que la variable existe dans les données
    if (!variable %in% names(donnees)) {
      showNotification(paste("Variable", variable, "non trouvée dans les données"), type = "error")
      return()
    }
    
    # Vérifier que la variable est numérique
    if (!is.numeric(donnees[[variable]])) {
      showNotification(paste("La variable", variable, "n'est pas numérique"), type = "error")
      return()
    }
    
    # Application de la méthode sélectionnée
    resultat <- switch(methode,
                       "egale_largeur" = discretisation_egale_largeur(donnees[[variable]], n_intervalles),
                       "egale_freq" = discretisation_egale_freq(donnees[[variable]], n_intervalles),
                       "entropie" = discretisation_entropie(donnees[[variable]], n_intervalles),
                       "clustering" = discretisation_clustering(donnees[[variable]], n_intervalles))
    
    # Stocker le résultat
    resultat_discretisation(resultat)
    
    # Afficher les résultats
    output$resultats_discretisation <- renderUI({
      tagList(
        h4(paste("Résultats -", resultat$methode)),
        h5("Statistiques descriptives :"),
        verbatimTextOutput("stats_discretisation"),
        h5("Distribution des intervalles :"),
        plotOutput("plot_discretisation"),
        h5("Interprétation :"),
        uiOutput("interpretation_discretisation")
      )
    })
    
    # Statistiques
    output$stats_discretisation <- renderPrint({
      table(resultat$intervalles)
    })
    
    # Graphique
    output$plot_discretisation <- renderPlot({
      df_plot <- data.frame(
        variable = donnees[[variable]],
        intervalle = resultat$intervalles
      )
      
      ggplot(df_plot, aes(x = intervalle, fill = intervalle)) +
        geom_bar() +
        labs(title = paste("Distribution après discretisation -", resultat$methode),
             x = "Intervalles", y = "Fréquence") +
        theme_minimal() +
        theme(axis.text.x = element_text(angle = 45, hjust = 1))
    })
    
    # Interprétation
    output$interpretation_discretisation <- renderUI({
      tagList(
        p(paste("La méthode", resultat$methode, "a créé", n_intervalles, "intervalles.")),
        p("Les coupures utilisées sont :"),
        verbatimTextOutput("coupures_details"),
        p("Cette méthode est particulièrement utile pour :"),
        tags$ul(
          if(methode == "egale_largeur") tags$li("Comparer des magnitudes similaires entre variables"),
          if(methode == "egale_freq") tags$li("Assurer une représentation équilibrée des données"),
          if(methode == "entropie") tags$li("Maximiser l'information préservée"),
          if(methode == "clustering") tags$li("Identifier des groupes naturels dans les données")
        )
      )
    })
    
    output$coupures_details <- renderPrint({
      if (is.numeric(resultat$coupures)) {
        round(resultat$coupures, 4)
      } else {
        resultat$coupures
      }
    })
  }
  
  # Variable réactive pour stocker les résultats de discretisation
  resultat_discretisation <- reactiveVal(NULL)
  
  # Exportation des résultats
  output$exporter_resultats <- downloadHandler(
    filename = function() {
      paste("resultats_discretisation_", Sys.Date(), ".txt", sep = "")
    },
    content = function(file) {
      resultat <- resultat_discretisation()
      if (!is.null(resultat)) {
        # Préparer le contenu du fichier
        contenu <- c(
          paste("Résultats de discretisation -", resultat$methode),
          paste("Date :", Sys.Date()),
          paste("Variable :", input$variable_discretisation),
          paste("Nombre d'intervalles :", input$nb_intervalles),
          "\n=== STATISTIQUES ===",
          capture.output(table(resultat$intervalles)),
          "\n=== COUPURES ===",
          capture.output(if (is.numeric(resultat$coupures)) round(resultat$coupures, 4) else resultat$coupures),
          "\n=== INTERPRÉTATION ===",
          "La discretisation permet de transformer une variable continue en variable catégorielle.",
          "Cette transformation peut améliorer la performance de certains algorithmes d'apprentissage automatique.",
          "Elle facilite également l'interprétation des résultats."
        )
        
        writeLines(contenu, file)
      }
    }
  )
}

# Lancer l'application
shinyApp(ui = ui, server = server)