#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

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
