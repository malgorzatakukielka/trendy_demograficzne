
library(shiny)
library(shinydashboard)
library(plotly)
library(sf)
library(giscoR)
library(eurostat)
library(leaflet)

dashboardPage(
  dashboardHeader(title = "Trendy Demograficzne",
                  titleWidth = "300px"),
  dashboardSidebar(),
  dashboardBody(
    # Dodanie CSS - tło mapy
    tags$style(HTML("
      .leaflet-container {
        background-color: white !important;
      }
    ")),
    fluidRow(
      box(leafletOutput("mapa", height = 450, width = "100%"),
          width = 4)
    )
  )
)
