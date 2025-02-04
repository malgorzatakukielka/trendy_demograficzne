
library(shiny)
library(shinydashboard)
library(plotly)
library(sf)
library(giscoR)
library(eurostat)
library(leaflet)
library(shinyWidgets)

dashboardPage(
  dashboardHeader(title = "Trendy Demograficzne",
                  titleWidth = 310),
  dashboardSidebar(width = 310,
                   sidebarMenu(
                     h4("Menu"),
                     menuItem("Strona Główna", tabName = "home", icon = icon("house")),
                     menuItem("Strona 2", tabName = "tab2"), #stylizowanie do zrobienia
                     h4("Wybór:"),
                     h5("Wybór województw do analizy:")
                   ),
                   # Dodanie mapy do sidebaru
                   box(leafletOutput("mapa", height = "215px"), width = 12),
                   tags$div(
                     h5("Wybór lat:", class = "custom-h5"),  # Zastosowanie klasy CSS
                     sliderInput("lata", 
                                 label = NULL, 
                                 min = 2000, 
                                 max = 2023, 
                                 step = 1, 
                                 value = c(2000, 2023), 
                                 sep = "")
                   )
                   
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "style.css")
    ),
    tabItems(
      tabItem(
        tabName = "home",
        fluidRow(
          box(title = "Placeholder na opis projektu")
        )
      ),
      tabItem(
        tabName = "tab2",
        fluidRow(
          box(title = "Treść strony 2", width = 12)
        )
      )
    )
  )
)