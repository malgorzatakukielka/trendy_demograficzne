library(shiny)

function(input, output, session) {
  
  #ładowanie funkcji z pliku functions.R
  source("functions.R")
  
  # Renderowanie mapy
  polska <- get_eurostat_geospatial(resolution = 10, 
                                    nuts_level = 2, 
                                    country = "PL",
                                    year = 2006)
  
  output$mapafiltr <- renderLeaflet({
    
    leaflet(polska, 
            options = leafletOptions(
              zoomControl = FALSE,
              dragging = FALSE,
              doubleClickZoom = FALSE,
              minZoom = 5,
              maxZoom = 5
            )) %>%  
      addPolygons(layerId = ~NAME_LATN,
                  label = ~NAME_LATN,
                  color = "#9ca0a3",
                  fillColor = "#408cbc",
                  weight = 2,
                  fillOpacity = 0.1,
                  highlight = highlightOptions(
                    fillOpacity = 1,
                    bringToFront = TRUE
                  ))
  })
  
  #logika filtrowania mapą:
  wojewodztwa <- reactiveValues(wybrane = character(0))
  
  observeEvent(input$mapafiltr_shape_click, { 
    click <- input$mapafiltr_shape_click
    
    # Pobranie aktualnej listy wybranych województw
    wybrane <- wojewodztwa$wybrane
    
    # Dodanie lub usunięcie województwa z listy wybranych
    if (click$id %in% wybrane) {
      wybrane <- wybrane[wybrane != click$id]
    } else {
      wybrane <- c(wybrane, click$id)
    }
    
    # Aktualizacja wartości w reactiveValues
    wojewodztwa$wybrane <- wybrane
    print(wojewodztwa$wybrane)
  })
    # Obsługa resetu województw
    observeEvent(input$reset, {
      wojewodztwa$wybrane <- character(0)  # Wyczyszczenie wyboru
    })
    
    # graficzne oznaczenie wybranych do reactiveValues województw 
    observe({
      leafletProxy("mapafiltr", session) %>% 
        addPolygons(data = polska,
                  layerId = ~NAME_LATN,
                  label = ~NAME_LATN,
                  color = "#9ca0a3",
                  fillColor = ifelse(polska$NAME_LATN %in% wojewodztwa$wybrane, "#2a6f97", "#408cbc"),
                  weight = 2,
                  fillOpacity = ifelse(polska$NAME_LATN %in% wojewodztwa$wybrane, 1, 0.1),
                  highlight = highlightOptions(
                    fillOpacity = 0.5,  # Zmniejszona przezroczystość dla hovera
                    bringToFront = TRUE
                  ))
  })
  # Resetowanie mapy i suwaka
  observeEvent(input$reset, {
    wojewodztwa$wybrane <- character(0)
    updateSliderInput(session, "lata", 
                      label = NULL,
                      value = 2000,
                      min = 2000, 
                      max = 2023, 
                      step = 1)
    
    print(wojewodztwa$wybrane) #debug
  })
  
  
  
  output$plot1 <- renderPlotly({
    
    plotly_generate(wskaźnik_zależności, "wskaźnik_zależności", wojewodztwa,  "Wskaźnik obciążenia demograficznego")
    
  })
  
  output$no_selection_msg <- renderText({
    if (length(wojewodztwa$wybrane) == 0) {
      return("⚠️ Dodaj województwa do analizy, aby zobaczyć szczegóły.")
    }
    return("")
  })
  
  output$map1 <- renderLeaflet({
    selected_year <- input$lata
    generate_map(wskaźnik_zależności, "wskaźnik_zależności", selected_year)
  })
  
  
}
