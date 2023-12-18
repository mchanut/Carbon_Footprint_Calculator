library(shiny)
library(shinythemes)
library(shiny.i18n)
library(readxl)
library(ggplot2)
library(readr)
library(shinyjs)
library(shinyscreenshot)
library(markdown)



#load data files
data_dm <- read.csv("data.csv", sep = ';')
data_country <- read.csv("Country.csv", sep = ';')
i18n <- Translator$new(translation_json_path = "lang.json")
constantes <- read.csv("constantes.csv", sep = ";")


#CONSTANTES=======================================================================================================================================================================================================================================


quantite_eau_ster <- 200
quantite_eau_laveur <- 100
quantite_detergent <- 0.2
nb_cycles_ster <- 13290
nb_cycles_laveur <- 20526


#INTERFACE=======================================================================================================================================================================================================================================

ui <- fluidPage(

                shinyFeedback::useShinyFeedback(),               # to use warning messages
                useShinyjs(),                                    # active shinyjs
                usei18n(i18n),                                   # translation tool
                
          
                
                
                navbarPage(theme = shinytheme("readable"),
                           windowTitle="Ecovamed",
                           title = tags$img(src = "logo1.jpg", width = "230px", height = "40px"),
                           
                           
                           id = "inTabset",
                           
                           
                                 
                                
                           tabPanel(i18n$t("Formulaire"),
                                    value = "panel1",
                                    h2(i18n$t("Comparateur d'empreinte carbone entre un dispositif médical à usage unique et un dispositif réutilisable, avec stérilisation à la vapeur"), align = "center"),
                                    br(),
                                    br(),
                                    column(12, align = "center", h5(i18n$t("Nom du Dispositif Médical (DM)")),
                                           
                                           # to center align the name of the MD
                                           tags$head(
                                             tags$script("
                                              $(document).ready(function() {
                                                $('#name_dm').on('input', function() {
                                                  var input = $(this);
                                                  input.css('text-align', 'center');
                                                });
                                              });
                                            ")
                                           ),
                                           
                                           textInput("name_dm",NULL, value = ""),
                                           br(),
                                           br()),
                                    sidebarPanel(width = 6,
                                                 h4(i18n$t("Données du dispositif Réutilisable"), align = "center"),
                                                 
                                                 br(),
                                                 
                                                 selectInput("reusable_mat", 
                                                              label = i18n$t("Matière principale"),
                                                              choices = c("Plastique",
                                                                             "Métal",
                                                                             "Verre",
                                                                             "Multi-matériaux"),
                                                              selected = "Multi-matériaux"),
                                                  
                                                 numericInput("reusable_weight", label = i18n$t("Masse du dispositif médical (kg)"), value = NULL, min = 0, max = 20),
                                                  
                                                 selectInput("fabr_zone_reusable", i18n$t("Origine de fabrication"), choices = c("Europe de l'Ouest", 
                                                                                                                              "Europe de l'Est", 
                                                                                                                              "Asie", 
                                                                                                                              "Amérique", 
                                                                                                                              "Reste du monde", 
                                                                                                                              "Inconnu"), 
                                                             selected = "Europe de l'Ouest"),
                                                 
                                                 numericInput("reusable_price", i18n$t("Prix unitaire (€ HT)"), value = NULL, min = 0, max = 20000),
                                                 
                                                 br(),
                                                 
                                                 h5(i18n$t("Procédures pour réutilisation :"), align = "left"),
                                                 
                                                 br(),
                                                 
                                                 selectInput("reusable_country", i18n$t("Pays où le lavage/stérilisation est réalisé"), 
                                                             choices = unique(data_country$Pays), selected = "France"),
                                                 
                                                 selectInput("passage_predesinfection", i18n$t("Pré-désinfection après utilisation"), choices = c("Oui", "Non"), selected = "Oui"),
                                                 
                                                 numericInput("desinfectant_quant_par_dm", label = i18n$t("Si pré-désinfection par trempage, quantité de solution désinfectante par DM (Litre)"), 
                                                              value = 0, min = 0, max = 50),
                                                 
                                                 helpText(i18n$t("Remarque : indiquer une moyenne par DM, en divisant le volume total du bain de pré-désinfection par le nombre de DM qui y sont trempés.")),
                                                 
                                                 numericInput("lingette_quant_par_dm", label = i18n$t("Si pré-désinfection avec lingette, nombre de lingette(s) utilisée(s) par DM"), 
                                                              value = 0, min = 0, max = 50),
                                                 
                                                 selectInput("passage_laveur", i18n$t("Passage en laveur/désinfecteur"), choices = c("Oui", "Non"), selected = "Oui"),
                                                 
                                                 numericInput("num_dm", label = i18n$t("Nombre de DM maximal qui peuvent etre stérilisés en meme temps dans une panière normalisée de 30x60x30 cm"), 
                                                              value = NULL, min = 0, max = 5000000),      
                                                 
                                                 helpText(i18n$t("Remarque : multiplier par deux si vous utilisez une panière moins haute, de 30x60x15 cm")),
                                                 
                                                 selectInput("emballage", 
                                                             label = i18n$t("Emballage de stérilisation"),
                                                             choices = c("Sachet",
                                                                            "Pliage",
                                                                            "Boîte réutilisable"),
                                                             selected = "Sachet"),
                                                 
                                                 numericInput("poids_emballage", label = i18n$t("Si sachet ou pliage, poids de l'emballage (mettre 15% du poids du DM si inconnu) (kg)"), 
                                                              value = NULL, min = 0, max = 50000),
                                                 
                                                 numericInput("remplissage", i18n$t("Taux de remplissage moyen du stérilisateur (%)"), value = NULL, min = 0, max = 100),
                                                 
                                    ),
                                    
                                    
                                    
                                    
                                    
                                    sidebarPanel(width = 6,
                                                 h4(i18n$t("Données du dispositif à Usage Unique"), align = "center"),
                                                
                                                 br(),
                                                 
                                                 selectInput("unique_mat", 
                                                             label = i18n$t("Matière principale"),
                                                             choices = c("Plastique",
                                                                            "Métal",
                                                                            "Verre",
                                                                            "Multi-matériaux"),
                                                             selected = "Plastique"),
                                                 
                                                 numericInput("unique_weight", label = i18n$t("Masse du dispositif médical (kg)"), value = NULL, min = 0, max = 20),
                                                 
                                                 selectInput("fabr_zone_unique", i18n$t("Origine de fabrication"), choices = c("Europe de l'Ouest", 
                                                                                                                                 "Europe de l'Est", 
                                                                                                                                 "Asie", 
                                                                                                                                 "Amérique", 
                                                                                                                                 "Reste du monde", 
                                                                                                                                 "Inconnu"), 
                                                             selected = "Europe de l'Ouest"),
                                                 
                                                 numericInput("unique_price", i18n$t("Prix unitaire (€ HT)"), value = NULL, min = 0, max = 20000),
                                                 
                                                 selectInput("end_life_unique", i18n$t("Fin de vie (gestion du déchet)"), choices = c("Incinération avec récupération d'énergie", 
                                                                                                                               "Incinération sans récupération d'énergie", 
                                                                                                                               "Mise en décharge", 
                                                                                                                               "Inconnue"), 
                                                             selected = "Incinération avec récupération d'énergie"),
                                    ),
                                                  
                                    
                                    column(12, actionButton("go", i18n$t("Calculer"), width = "400px", class="btn btn-info" ), align = "center",
                                    br(),
                                    br(),
                                    br(),
                                    br(),
                                    ),
                                    
                                    column(12, 
                                           align = "center",
                                           htmlOutput("unique_cons"),
                                           br(),
                                           htmlOutput("reusable_cons"),
                                           br(),
                                           htmlOutput("reusable_lavage_cons"),
                                           br(),
                                           htmlOutput("intersectionText"),
                                           br(),
                                           br()
                                    ),
                                    
                                    column(1),
                                    column(5,
                                           align = "center",
                                           plotOutput("plot1"),
                                           br(),
                                           br(),
                                    ),
                                    column(5,
                                           align = "center",
                                           plotOutput("plot2"),
                                           br(),
                                           br()
                                    ),
                                    column(1),
                                    
                                    column(12, br(),
                                            br()
                                           ),
                                    
                                    column(4),
                                    column(2,
                                           align = "center",
                                           numericInput("nombre_reutil", label = i18n$t("Veuillez rentrer un nombre de réutilisation pour le DM réutilisable"), value = 100, min = 0, max = 50000),  
                                           ),
                                    column(2,
                                           align = "center",
                                           checkboxInput("showPercentages", i18n$t("Montrer les pourcentages"), value = FALSE),
                                           
                                           ),
                                    column(4),
                                    
                                    column(12),
                                    
                                    column(2),
                                    column(8, 
                                           align = "center",
                                           plotOutput("plot3"),
                                           br(),
                                           br(),
                                           br(),
                                           actionButton("generate", i18n$t("Génerer une capture d'écran")),
                                           br(),
                                           br(),
                                           br(),
                                           tags$a(href = "https://www.ecovamed.com/#contactus", i18n$t("Nous contacter")),
                                           br(),
                                           br(),
                                           br(),
                                           br(),
                                           br()
                                           
                                    ),
                                    column(2),
                                    
                           ),
                           
                           
                           
                           tabPanel(i18n$t("Méthodologie"),
                                    value = "panel3",
                                    h2(i18n$t("Comparateur d'empreinte carbone entre un dispositif médical à usage unique et un dispositif réutilisable, avec stérilisation à la vapeur"), align = "center"),
                                    br(),
                                    br(),
                                    uiOutput("markdownOutput")
                           ),
                           
                           tabPanel(i18n$t("CGU"),
                                    
                                    includeMarkdown("CGU.md")
                           ),
                           
                           navbarMenu("Language",
                                      tabPanel("English",
                                               value = "panel4",
                                               ),
                                      tabPanel("Français",
                                               value = "panel5"),
                           )
                )
)
  

server <- function(input, output, session) {
  
  #decide which markdown file to include
  reactiveString <- reactiveVal("fr")
  markdownContent <- reactive({
    if (reactiveString() == "eng") {
      "Methodo_eng.md"
    } else {
      "Methodo.md"
    }
    
  })
  output$markdownOutput <- renderUI({
    includeMarkdown(markdownContent())
  })
  
  
  
  
  # grise les sections au besoin
  observe({
    
    if (input$passage_predesinfection == "Non" | input$passage_predesinfection == "No") {
      shinyjs::disable("desinfectant_quant_par_dm")
      shinyjs::disable("lingette_quant_par_dm")
    } else {
      shinyjs::enable("desinfectant_quant_par_dm")
      shinyjs::enable("lingette_quant_par_dm") 
    }
    
    if (input$emballage == "Boîte réutilisable" | input$emballage == "Reusable box") {
      shinyjs::disable("poids_emballage")
    } else {
      shinyjs::enable("poids_emballage")
    }
    
  })
  
  
  observeEvent(input$generate, {
    screenshot()
  })
  


#REUSABLE SECTION====================================================================================================================================================================================================================================

  
  
  # Get factor of electricity of country on ecoinvent csv data set
  filteredDataCountry <- reactive(subset(data_country, Pays == input$reusable_country))
  filteredDataZoneReusable <- reactive(subset(data_dm, Zone == input$fabr_zone_reusable))
  
  fe_electricite <- reactive(filteredDataCountry()$FE)
  
  remplissage <- reactive(input$remplissage * 0.01)                   # modifie le pourcentage en décimal 
  
  prix_massique_reusable <- reactive(input$reusable_price/input$reusable_weight)
 
  
  ef_cradle_to_hospital_reusable <- reactive(
    if (prix_massique_reusable() <= 10) {
      filteredDataZoneReusable()$EF10
    } else if (prix_massique_reusable() >= 1000) {
      filteredDataZoneReusable()$EF1000
    }else {
      as.numeric(filteredDataZoneReusable()$a) / prix_massique_reusable() + as.numeric(filteredDataZoneReusable()$b)
    }
    
  )
  
  
  
  #UNIQUE SECTION====================================================================================================================================================================================================================================
  


  filteredDataZoneUnique <- reactive(subset(data_dm, Zone == input$fabr_zone_unique))
  
  prix_massique_unique <- reactive(input$unique_price/input$unique_weight)
  
  ef_cradle_to_hospital_unique <- reactive(
    if (prix_massique_unique() <= 10) {
      filteredDataZoneUnique()$EF10
    } else if (prix_massique_unique() >= 1000) {
      filteredDataZoneUnique()$EF1000
    }else {
      as.numeric(filteredDataZoneUnique()$a) / prix_massique_unique() + as.numeric(filteredDataZoneUnique()$b)
    }
    
  )
  
  
  ef_fin_de_vie_par_methode <- reactive(
    switch(input$end_life_unique,
           "Incinération avec récupération d'énergie" = constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"],
           "Incinération sans récupération d'énergie" = constantes$valeur[constantes$nom == "Fin de vie incinération sans récup d'énergie"],
           "Mise en décharge" =  constantes$valeur[constantes$nom == "Fin de vie mise en décharge"],
           "Inconnue" = constantes$valeur[constantes$nom == "Fin de vie inconnue"],
          
           "Incineration with energy recovery" = constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"],
           "Incineration without energy recovery" = constantes$valeur[constantes$nom == "Fin de vie incinération sans récup d'énergie"],
           "Landfill of waste" = constantes$valeur[constantes$nom == "Fin de vie mise en décharge"],
           "Unknown" = constantes$valeur[constantes$nom == "Fin de vie inconnue"]
    )
  )
  
    
                                        
  ef_fin_de_vie_unique <- reactive(
    switch(input$unique_mat,
           "Plastique" = ef_fin_de_vie_par_methode(),
           "Multi-matériaux" = 0.5 * ef_fin_de_vie_par_methode(),
           "Verre" = constantes$valeur[constantes$nom == "Fin de vie mise en décharge"],
           "Métal" = constantes$valeur[constantes$nom == "Fin de vie mise en décharge"],
           
           "Plastic" = ef_fin_de_vie_par_methode(),
           "Multi-material" = 0.5 * ef_fin_de_vie_par_methode(),
           "Glass" = constantes$valeur[constantes$nom == "Fin de vie mise en décharge"],
           "Metal" = constantes$valeur[constantes$nom == "Fin de vie mise en décharge"]
    )
  )
           
 
 #LAVAGE/STERILISATION SECTION====================================================================================================================================================================================================================================

           
  
  ef_pre_desinfect <- reactive(
    if (input$passage_predesinfection == "Oui" |  input$passage_predesinfection == "Yes") {
      constantes$valeur[constantes$nom == "Désinfectant"] * input$desinfectant_quant_par_dm + constantes$valeur[constantes$nom == "Lingette"] * input$lingette_quant_par_dm
    } else {
      0
    }
  )
  
  num_cycles <- reactive({if (input$emballage == "Boîte réutilisable" | input$emballage == "Reusable box") {
    2
  } else {
    1
  }})
  
  emiss_elec_lav <- reactive(constantes$valeur[constantes$nom == "Energie par cycle laveur"] * num_cycles() * fe_electricite())
  
  emiss_hors_elec_lav <- reactive(constantes$valeur[constantes$nom == "1 cycle laveur-desinfecteur hors électricité"] * num_cycles())
  
  ef_lavage <- reactive(
    if (input$passage_laveur == "Oui" | input$passage_laveur == "Yes") {
      (emiss_hors_elec_lav() + emiss_elec_lav() / constantes$valeur[constantes$nom == "Taux de remplissage laveur"]) / (input$num_dm * 8)
   
    } else {
      0
    }
  )
  
  emiss_elec_ste <- reactive(1.2 * constantes$valeur[constantes$nom == "Energie par cycle stérilisateur"] * fe_electricite() / remplissage())
  
  emiss_hors_elec_ste <- reactive(constantes$valeur[constantes$nom == "1 cycle stérilisateur hors électricité et emballage"] / remplissage())
  
  emiss_emballage <- reactive(switch(input$emballage,
                            "Sachet" = input$poids_emballage * (constantes$valeur[constantes$nom == "Emballage stérilisation"] + 0.5 * constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"]),
                            "Pliage" = input$poids_emballage * (constantes$valeur[constantes$nom == "Emballage stérilisation"] + constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"]),
                            "Boîte réutilisable" = 0,
                            
                            "Bag" = input$poids_emballage * (constantes$valeur[constantes$nom == "Emballage stérilisation"] + 0.5 * constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"]),
                            "Folding" = input$poids_emballage * (constantes$valeur[constantes$nom == "Emballage stérilisation"] + constantes$valeur[constantes$nom == "Fin de vie incinération avec récup d'énergie"]),
                            "Reusable box" = 0))
  
  
  ef_sterilisation <- reactive(
    (emiss_elec_ste() + emiss_hors_elec_ste()) / (input$num_dm * 8) + emiss_emballage()
 )
  
  
  
  
#RESULTS SECTION===========================================================================================================================================
  
  
  
  
  observeEvent(input$go, {
    

    
    #Make sure that user inputed values
    exists <- (!(is.na(input$reusable_weight)) & (input$reusable_weight >= 0))
    exists2 <- (!(is.na(input$reusable_price)) & (input$reusable_price >= 0))
    exists3 <- (!(is.na(input$num_dm)) & (input$num_dm >= 0))
    exists4 <- (!(is.na(input$remplissage)) & (input$remplissage >= 0) & (input$remplissage <= 100))
    exists5 <- (!(is.na(input$unique_weight)) & (input$unique_weight >= 0))
    exists6 <- (!(is.na(input$unique_price)) & (input$unique_price >= 0))
    exists7 <- 
    if (input$passage_predesinfection == "Oui" | input$passage_predesinfection == "Yes") {
      (!(is.na(input$desinfectant_quant_par_dm)) & (input$desinfectant_quant_par_dm >= 0))
    } else {
      TRUE
    }
    exists8 <- 
      if (input$passage_predesinfection == "Oui" | input$passage_predesinfection == "Yes") {
        (!(is.na(input$lingette_quant_par_dm)) & (input$lingette_quant_par_dm >= 0))
      } else {
        TRUE
      }
    exists9 <- 
      if (input$emballage != "Boîte réutilisable" & input$emballage != "Reusable box") {
        (!(is.na(input$poids_emballage)) & (input$poids_emballage >= 0))
      } else {
        TRUE
      }
    
    if ((!exists) | (!exists2) | (!exists5) | (!exists6)) {
      jsCode <- "$('html, body').animate({scrollTop: 0}, 'slow');"
      runjs(jsCode)
    } else if ((!exists4) | (!exists7) | (!exists8) | (!exists9) | (!exists3)) {
      jsCode <- "$('html, body').animate({scrollTop: $('#reusable_price').offset().top}, 'slow');"
      runjs(jsCode)
    }
    
    
    #Warning messages
    shinyFeedback::feedbackDanger("reusable_weight", !exists, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("reusable_price", !exists2, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("num_dm", !exists3, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("remplissage", !exists4, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("unique_weight", !exists5, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("unique_price", !exists6, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("desinfectant_quant_par_dm", !exists7, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("lingette_quant_par_dm", !exists8, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    shinyFeedback::feedbackDanger("poids_emballage", !exists9, i18n$t("Veuillez rentrer une valeur supérieure ou égale à 0"))
    
    #Cancel output if missing values
    req(exists, cancelOutput = TRUE)
    req(exists2, cancelOutput = TRUE)
    req(exists3, cancelOutput = TRUE)
    req(exists4, cancelOutput = TRUE)
    req(exists5, cancelOutput = TRUE)
    req(exists6, cancelOutput = TRUE)
    req(exists7, cancelOutput = TRUE)
    req(exists8, cancelOutput = TRUE)
    req(exists9, cancelOutput = TRUE)
    
    
    
    ef_dm_reusable <-  ef_cradle_to_hospital_reusable() * input$reusable_price
    ef_dm_unique <- ef_cradle_to_hospital_unique() * input$unique_price + ef_fin_de_vie_unique() * input$unique_weight
    ef_lavage_ster_tot <- ef_pre_desinfect() + ef_lavage() + ef_sterilisation()
    
    # Update the textOutput with the results
    output$reusable_cons <- renderPrint({
      HTML(paste0(i18n$t("Empreinte carbone du DM réutilisable neuf : "), strong(round(ef_dm_reusable, digits = 1)), HTML(" <strong>kgCO<sub>2</sub></strong>"), strong(i18n$t("eq/dispositif"))))
    })
    
    
    output$unique_cons <- renderPrint({
      HTML(paste0(i18n$t("Empreinte carbone du DM à usage unique : "), strong(round(ef_dm_unique, digits = 1)), HTML(" <strong>kgCO<sub>2</sub></strong>"), strong(i18n$t("eq/dispositif"))))
    })
    
    
    output$reusable_lavage_cons <- renderPrint({
      HTML(paste0(i18n$t("Empreinte carbone d'un lavage/stérilisation du DM réutilisable : "), strong(round(ef_lavage_ster_tot, digits = 1)), HTML(" <strong>kgCO<sub>2</sub></strong>"), strong(i18n$t("eq/dispositif"))))
    })
    
    output$plot1 <- renderPlot({
      
      intersect <- 
        if ((ef_dm_reusable / (ef_dm_unique - ef_lavage_ster_tot)) > 0) {
          ceiling((ef_dm_reusable / (ef_dm_unique - ef_lavage_ster_tot)) * 4)
        } else {
          25
        }
      
      x <- seq(0, intersect, length.out = 100)
      y1 <- ef_dm_unique * x
      y2 <- ef_lavage_ster_tot * x + ef_dm_reusable
      
      
      
      df <- data.frame(x, y1, y2)
      
     
        ggplot(df, aes(x)) +
          geom_line(aes(y = y1, color = "Usage unique")) +
          geom_line(aes(y = y2, color = "Réutilisable")) +
          labs(x = i18n$t("Nombre d'utilisations"), y = i18n$t("Emissions (kgCO2eq)"), title = i18n$t("Emissions cumulées")) +
          scale_color_manual(values = c("Usage unique" = "blue", "Réutilisable" = "red"), guide = guide_legend(title = "Légende")) + 
          theme_minimal() +
          scale_x_continuous(limits = c(0, intersect)) +
          theme(legend.position = "bottom") +
          theme(legend.text = element_text(size = 15)) +
          theme(legend.title=element_blank()) +
          theme(plot.title = element_text(size = 16, hjust = 0.5)) +
          theme(axis.text.x = element_text(size = 14)) +
          theme(axis.text.y=element_text(size=14)) + 
          theme(axis.title.y=element_text(size=15, margin = margin(r = 12, unit = "pt"))) +
          theme(axis.title.x = element_text(size = 15, margin = margin(t = 15, unit = "pt")))
        
      
    })
    
    
    output$intersectionText <- renderPrint({
      x_intersect <- (ef_dm_reusable / (ef_dm_unique - ef_lavage_ster_tot))
      y_intersect <- ef_dm_unique * x_intersect
      
      if (ceiling(x_intersect > 0)) {
        HTML(paste0(i18n$t("Après: "), strong(ceiling(x_intersect)), i18n$t(" utilisation(s), l'empreinte carbone du DM réutilisable est plus faible que celle de l'usage unique")))
      } else {
        HTML(paste0(i18n$t("Le DM à usage unique a une empreinte carbone plus faible que celle du DM réutilisable, quelque soit le nombre de réutilisations" )))
      }
    })
    
    output$plot2 <- renderPlot({
      
      intersect <- 
        if ((ef_dm_reusable / (ef_dm_unique - ef_lavage_ster_tot)) > 0) {
          ceiling((ef_dm_reusable / (ef_dm_unique - ef_lavage_ster_tot)) * 4)
        } else {
          25
        }
      
      x <- seq(1, intersect, length.out = 100)
      y1 <- ef_dm_unique 
      y2 <- (ef_lavage_ster_tot * x + ef_dm_reusable) / x
      
      df <- data.frame(x, y1, y2)
      
      
      
        ggplot(df, aes(x)) +
          geom_line(aes(y = y1, color = "Usage unique")) +
          geom_line(aes(y = y2, color = "Réutilisable")) +
          labs(x = i18n$t("Nombre d'utilisations"), y = i18n$t("Emissions (kgCO2eq)"), title = i18n$t("Emissions des DM par utilisation")) +
          scale_color_manual(values = c("Usage unique" = "blue", "Réutilisable" = "red"), guide = guide_legend(title = "Légende")) + 
          theme_minimal() +
          scale_x_continuous(limits = c(0, intersect)) +
          theme(legend.position = "bottom") +
          theme(legend.text = element_text(size = 15)) +
          theme(legend.title=element_blank()) +
          theme(plot.title = element_text(size = 16, hjust = 0.5)) +
          theme(axis.text.x=element_text(size=14)) +
          theme(axis.text.y=element_text(size=14)) + 
          theme(axis.title.y=element_text(size=15, margin = margin(r = 12, unit = "pt"))) +
          theme(axis.title.x = element_text(size = 15, margin = margin(t = 15, unit = "pt")))
      
    })
    
    graph_reus_prod_dm <- ef_dm_reusable
    graph_reus_fin_vie <- 0
    graph_reus_pre_desinf <- ef_pre_desinfect()
    graph_reus_elec_eau <- (emiss_elec_ste() + emiss_elec_lav() + constantes$valeur[constantes$nom == "Eau osmosée"] * quantite_eau_laveur/0.9 + constantes$valeur[constantes$nom == "Eau osmosée"] * quantite_eau_ster/remplissage()) / (input$num_dm * 8)
    graph_reus_achat_machine <- ((constantes$valeur[constantes$nom == "Fabrication et transport stérilisateur"]/nb_cycles_ster)/remplissage() + (constantes$valeur[constantes$nom == "Fabrication et transport laveur"]/nb_cycles_laveur)/0.9) / (input$num_dm * 8)
    graph_reus_consommables_deterg <- (constantes$valeur[constantes$nom == "Consommables stérilisateur"]/remplissage() + constantes$valeur[constantes$nom == "Consommables laveur"]/0.9 + quantite_detergent*constantes$valeur[constantes$nom == "Détergent"]/0.9) / (input$num_dm * 8)
    graph_reus_emballage <- emiss_emballage()
    graph_reus_trajet <- (constantes$valeur[constantes$nom == "Trajet domicile-travail"]*2/remplissage() + constantes$valeur[constantes$nom == "Trajet domicile-travail"]/0.9) / (input$num_dm * 8)
    graph_unique_prod_dm <- ef_cradle_to_hospital_unique() * input$unique_price
    graph_unique_fin_vie <- ef_fin_de_vie_unique() * input$unique_weight
    
    output$plot3 <- renderPlot({
      
      req(!is.na(input$nombre_reutil), cancelOutput = TRUE)
    # Data for the first bar
      graph_reus_tot <- graph_reus_prod_dm + (graph_reus_pre_desinf + graph_reus_elec_eau + graph_reus_achat_machine + graph_reus_consommables_deterg + graph_reus_emballage + graph_reus_trajet) * input$nombre_reutil
      graph_unique_tot = (graph_unique_prod_dm + graph_unique_fin_vie) * input$nombre_reutil
      
    values1 <- c(graph_reus_prod_dm * 100 / graph_reus_tot,
                 graph_reus_fin_vie,
                 graph_reus_pre_desinf * input$nombre_reutil * 100 / graph_reus_tot,
                 graph_reus_elec_eau * input$nombre_reutil * 100 / graph_reus_tot,
                 graph_reus_achat_machine * input$nombre_reutil * 100 / graph_reus_tot,
                 graph_reus_consommables_deterg * input$nombre_reutil * 100 / graph_reus_tot,
                 graph_reus_emballage * input$nombre_reutil * 100 / graph_reus_tot,
                 graph_reus_trajet * input$nombre_reutil * 100 / graph_reus_tot)
    
    # Data for the second bar
    values2 <- c(graph_unique_prod_dm * input$nombre_reutil * 100 / graph_unique_tot,
                 graph_unique_fin_vie * input$nombre_reutil * 100 / graph_unique_tot,
                 0,
                 0,
                 0,
                 0,
                 0,
                 0)
    
    
    # Combine the data into a data frame
    df <- data.frame(
      Category = factor(c(i18n$t("Production du DM"),
                          i18n$t("Fin de vie du DM"),
                          i18n$t("Pré-désinfection"),
                          i18n$t("Electricité et eau (lavage et stérilisation)"),
                          i18n$t("Achat des machines (laveur et stérilisateur)"),
                          i18n$t("Consommables et détergent (lavage et stérilisation)"),
                          i18n$t("Emballage de stérilisation"),
                          i18n$t("Trajets domicile-travail (lavage et stérilisation)")), 
                        levels = c(i18n$t("Production du DM"),
                                   i18n$t("Fin de vie du DM"),
                                   i18n$t("Pré-désinfection"),
                                   i18n$t("Electricité et eau (lavage et stérilisation)"),
                                   i18n$t("Achat des machines (laveur et stérilisateur)"),
                                   i18n$t("Consommables et détergent (lavage et stérilisation)"),
                                   i18n$t("Emballage de stérilisation"),
                                   i18n$t("Trajets domicile-travail (lavage et stérilisation)"))), 
      Bar = rep(c(i18n$t("DM réutilisable"), i18n$t("DM usage-unique")), c(length(values1), length(values2))),
      Value = c(values1, values2)
    )
    
    if (input$showPercentages == TRUE) {
      ggplot(df, aes(x = Bar, y = Value, fill = Category)) +
        geom_bar(stat = "identity", position = "stack") +
        geom_text(aes(label = paste0(round(Value, digits = 0), "%"), group = Category), 
                  position = position_stack(vjust = 0.5), color = "black", size = 5) +
        labs(x = i18n$t("Dispositif"), y = i18n$t("Pourcentage (%)"), title = i18n$t("Pourcentage d'émissions de CO2 par catégories et par dispositif")) +
        scale_fill_manual(values = c("#FFA500", "darkgoldenrod4", "brown3","#2E8B57",  "#00FF00", "#0000FF", "#1E90FF", "#800080"), limits = c(i18n$t("Production du DM"),
                                                                                                                                               i18n$t("Fin de vie du DM"),
                                                                                                                                               i18n$t("Pré-désinfection"),
                                                                                                                                               i18n$t("Electricité et eau (lavage et stérilisation)"),
                                                                                                                                               i18n$t("Achat des machines (laveur et stérilisateur)"),
                                                                                                                                               i18n$t("Consommables et détergent (lavage et stérilisation)"),
                                                                                                                                               i18n$t("Emballage de stérilisation"),
                                                                                                                                               i18n$t("Trajets domicile-travail (lavage et stérilisation)"))) +
        theme_minimal() +
        theme(legend.position = "bottom") +
        theme(legend.text = element_text(size = 14, face = "bold")) +
        theme(legend.title=element_blank()) +
        theme(plot.title = element_text(size = 16, hjust = 0.5)) +
        theme(axis.text.x=element_text(size=14)) +
        theme(axis.text.y=element_text(size=14)) +
        theme(axis.title.y=element_text(size=15)) +
        theme(axis.title.x=element_text(size=15)) +
        guides(fill = guide_legend(nrow = 3))
    }else {
      
    
    # Create a stacked bar chart using ggplot2
    ggplot(df, aes(x = Bar, y = Value, fill = Category)) +
      geom_bar(stat = "identity", position = "stack") +
      
      labs(x = i18n$t("Dispositif"), y = i18n$t("Pourcentage (%)"), title = i18n$t("Pourcentage d'émissions de CO2 par catégories et par dispositif")) +
      scale_fill_manual(values = c("#FFA500", "darkgoldenrod4", "brown3","#2E8B57",  "#00FF00", "#0000FF", "#1E90FF", "#800080"), limits = c(i18n$t("Production du DM"),
                                                                                                                                             i18n$t("Fin de vie du DM"),
                                                                                                                                             i18n$t("Pré-désinfection"),
                                                                                                                                             i18n$t("Electricité et eau (lavage et stérilisation)"),
                                                                                                                                             i18n$t("Achat des machines (laveur et stérilisateur)"),
                                                                                                                                             i18n$t("Consommables et détergent (lavage et stérilisation)"),
                                                                                                                                             i18n$t("Emballage de stérilisation"),
                                                                                                                                             i18n$t("Trajets domicile-travail (lavage et stérilisation)"))) +
      theme_minimal() +
      theme(legend.position = "bottom") +
      theme(legend.text = element_text(size = 14, face = "bold")) +
      theme(legend.title=element_blank()) +
      theme(plot.title = element_text(size = 16, hjust = 0.5)) +
      theme(axis.text.x=element_text(size=14)) +
      theme(axis.text.y=element_text(size=14)) +
      theme(axis.title.y=element_text(size=15)) +
      theme(axis.title.x=element_text(size=15)) +
      guides(fill = guide_legend(nrow = 3))
    }
    
    
  })
    
  })
    
 

  
#LANGUAGE SECTION===============================================================================================================================================
  
  

  
  i18n_r <- reactive({
    i18n
  })

  
  observe({
    
    current_lang <- i18n$get_translation_language()
    
    if (input$inTabset == "panel4") {                 # if english is clicked
      updateTabsetPanel(session, "inTabset",          # go to home tab
                        selected = "panel1")          
      update_lang("en")                               # update lang to english
      reactiveString("eng")
    
      # update language of widget options

      updateSelectInput(session, "reusable_mat", label = i18n$t("Matière principale"),
                        choices = i18n_r()$t(c("Plastique",
                                               "Métal",
                                               "Verre",
                                               "Multi-matériaux")))
      
      updateSelectInput(session, "fabr_zone_reusable", i18n$t("Origine de fabrication"), choices = i18n_r()$t(c("Europe de l'Ouest", 
                                                                                                     "Europe de l'Est", 
                                                                                                     "Asie", 
                                                                                                     "Amérique", 
                                                                                                     "Reste du monde", 
                                                                                                     "Inconnu")))
      
      updateSelectInput(session, "passage_predesinfection", i18n$t("Pré-désinfection après utilisation"), choices = i18n_r()$t(c("Oui", "Non")))
      
      updateSelectInput(session, "passage_laveur", i18n$t("Passage en laveur/désinfecteur"), choices = i18n_r()$t(c("Oui", "Non")))
      
      updateSelectInput(session, "emballage", 
                        label = i18n$t("Emballage de stérilisation"),
                        choices = i18n_r()$t(c("Sachet",
                                       "Pliage",
                                       "Boîte réutilisable")))
      
      updateSelectInput(session, "unique_mat", label = i18n$t("Matière principale"),
                        choices = i18n_r()$t(c("Plastique",
                                               "Métal",
                                               "Verre",
                                               "Multi-matériaux")))
      
      updateSelectInput(session, "fabr_zone_unique", i18n$t("Origine de fabrication"), choices = i18n_r()$t(c("Europe de l'Ouest", 
                                                                                                                "Europe de l'Est", 
                                                                                                                "Asie", 
                                                                                                                "Amérique", 
                                                                                                                "Reste du monde", 
                                                                                                                "Inconnu")))
      
      updateSelectInput(session, "end_life_unique", i18n$t("Fin de vie (gestion du déchet)"), choices = i18n_r()$t(c("Incinération avec récupération d'énergie", 
                                                                                                          "Incinération sans récupération d'énergie", 
                                                                                                          "Mise en décharge", 
                                                                                                          "Inconnue")))
    }
    
    if (input$inTabset == "panel5") {                 # if français is clicked
      updateTabsetPanel(session, "inTabset",          # go to home tab
                        selected = "panel1")          
      update_lang("fr")                               # update lang to french
      reactiveString("fr")
      
      # update language of widget options

      updateSelectInput(session, "reusable_mat", label = i18n$t("Matière principale"),
                        choices = i18n_r()$t(c("Plastique",
                                               "Métal",
                                               "Verre",
                                               "Multi-matériaux")))
      
      updateSelectInput(session, "fabr_zone_reusable", i18n$t("Origine de fabrication"), choices = i18n_r()$t(c("Europe de l'Ouest", 
                                                                                                                "Europe de l'Est", 
                                                                                                                "Asie", 
                                                                                                                "Amérique", 
                                                                                                                "Reste du monde", 
                                                                                                                "Inconnu")))
      
      updateSelectInput(session, "passage_predesinfection", i18n$t("Pré-désinfection après utilisation"), choices = i18n_r()$t(c("Oui", "Non")))
      
      updateSelectInput(session, "passage_laveur", i18n$t("Passage en laveur/désinfecteur"), choices = i18n_r()$t(c("Oui", "Non")))
      
      updateSelectInput(session, "emballage", 
                        label = i18n$t("Emballage de stérilisation"),
                        choices = i18n_r()$t(c("Sachet",
                                               "Pliage",
                                               "Boîte réutilisable")))
      
      updateSelectInput(session, "unique_mat", label = i18n$t("Matière principale"),
                        choices = i18n_r()$t(c("Plastique",
                                               "Métal",
                                               "Verre",
                                               "Multi-matériaux")))
      
      updateSelectInput(session, "fabr_zone_unique", i18n$t("Origine de fabrication"), choices = i18n_r()$t(c("Europe de l'Ouest", 
                                                                                                              "Europe de l'Est", 
                                                                                                              "Asie", 
                                                                                                              "Amérique", 
                                                                                                              "Reste du monde", 
                                                                                                              "Inconnu")))
      
      updateSelectInput(session, "end_life_unique", i18n$t("Fin de vie (gestion du déchet)"), choices = i18n_r()$t(c("Incinération avec récupération d'énergie", 
                                                                                                                     "Incinération sans récupération d'énergie", 
                                                                                                                     "Mise en décharge", 
                                                                                                                     "Inconnue")))
    }
  })
}
  

shinyApp(ui, server)