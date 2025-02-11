library(shiny)

function(input, output, session) {
  
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
    # graficzne oznaczenie wybranych do reactiveValues województw 
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
}