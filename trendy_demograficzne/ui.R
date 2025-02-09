library(readr)
library(shiny)
library(shinydashboard)
library(plotly)
library(sf)
library(giscoR)
library(eurostat)
library(leaflet)
library(shinyWidgets)
library(ggrepel)

ludnosc <- read_csv2("~/trendy_demograficzne/data/LUDN_2137_CREL_20250113221303.csv")
ludnosc <- ludnosc %>% select(1:7)

wiek_produkcja <- ludnosc %>%
  filter(Wiek %in% c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64")) %>%
  group_by(Rok, Nazwa) %>%
  summarise(wiek_produkcja = sum(Wartosc))

wiek_starsi <- ludnosc %>%
  filter(Wiek %in% c("65-69", "70 i więcej")) %>%
  group_by(Rok, Nazwa) %>%
  summarise(wiek_starsi = sum(Wartosc))

wskaźnik_zależności <- left_join(wiek_produkcja, wiek_starsi, by = c("Rok", "Nazwa")) %>%
  mutate(wskaźnik_zależności = wiek_starsi / wiek_produkcja * 100)


dashboardPage(

  dashboardHeader(title = "Trendy Demograficzne",
                  titleWidth = 310),
  dashboardSidebar(width = 310,
                   sidebarMenu(
                     id = "tabs", # zmienna techniczna, przekazuje wartość do conditionalpanel
                     
                     h4("Menu"),
                     menuItem("Strona Główna", tabName = "home", icon = icon("house")),
                     menuItem("Analiza Demografii", tabName = "tab2", icon = icon("person"),
                              menuSubItem("Wskaźnik obciążenia demograficznego", 
                                          tabName = "tab2_1", icon = icon("chevron-right"))
                     ),
                   conditionalPanel(
                     condition = "input.tabs !== 'home'",  # Widoczność na stronach poza home
                     h4("Wybór:"),
                     h5("Wybór województw do analizy:"),
                     tags$div(class = "box", 
                              tags$div(class = "box-body", 
                                       leafletOutput("mapafiltr", height = "215px")
                              )),
                     tags$div(class = "slider-container",
                       h5("Wybór lat:", class = "custom-h5"),  # Zastosowanie klasy CSS
                       sliderInput("lata", 
                                   label = NULL, 
                                   min = 2000, 
                                   max = 2023, 
                                   step = 1, 
                                   value = c(2000, 2023), 
                                   sep = "")
                     ))
                   )
                   
  ),
  dashboardBody(
    tags$head( #pobranie czcionki z google fonts, ponieważ Source Sans Pro w shinydashboard nie obsługuuje części polskich znaków
      tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=Source+Sans+Pro&display=swap"),
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
        ),
      ),
      tabItem(
        tabName = "tab2_1",
        fluidRow(
          box(title = "Wykres obciążenia demograficznego", 
              width = 12, height = "500px",
              plotlyOutput("plot1"),
              textOutput("no_selection_msg")
              )
        ),
        fluidRow(
          box(title = "Placeholder na opis wykresu", width = 12)
        ),
      )
    )
  )
)