library(shiny)

function(input, output, session) {

  # Renderowanie mapy
  polska <- get_eurostat_geospatial(resolution = 10, 
                                    nuts_level = 2, 
                                    country = "PL",
                                    year = 2006)
  
  output$mapafiltr <- renderLeaflet({
<<<<<<< HEAD
=======
    
>>>>>>> 59bfc83ee55c70af0e2f7cbe4b5eae048d217a8c
    
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
  wojewodztwa <- reactiveValues(wybrane = NULL)
  
  observeEvent(input$mapafiltr_shape_click, { 
    click <- input$mapafiltr_shape_click
<<<<<<< HEAD
    print(click) #debug
    print(wojewodztwa$wybrane) #debug
    
  # kliknięcie poowduje dodanie województwa do reactiveValues
=======
    print(click)
    print(wojewodztwa$wybrane)
  
>>>>>>> 59bfc83ee55c70af0e2f7cbe4b5eae048d217a8c
  if (click$id %in% wojewodztwa$wybrane) {
    wojewodztwa$wybrane <- 
      wojewodztwa$wybrane[wojewodztwa$wybrane != click$id]
    
  } else if(click$id == "selected"){ 
<<<<<<< HEAD
    # ponowne kliknięcie poowduje uzunięcie województwa z reactiveValues
    wojewodztwa$wybrane <- 
      wojewodztwa$wybrane[wojewodztwa$wybrane !=
                             tail(wojewodztwa$wybrane, n = 1)]
  }else {
    wojewodztwa$wybrane <- c(wojewodztwa$wybrane, click$id)
    
  }
  # graficzne oznaczenie wybranych do reactiveValues województw 
=======
    # when a county is clicked again it is removed
    wojewodztwa$wybrane <- 
      wojewodztwa$wybrane[wojewodztwa$wybrane !=
                             tail(wojewodztwa$wybrane, n = 1)]
  }else { # If not selected, add it
    wojewodztwa$wybrane <- c(wojewodztwa$wybrane, click$id)
    
  }
  
>>>>>>> 59bfc83ee55c70af0e2f7cbe4b5eae048d217a8c
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