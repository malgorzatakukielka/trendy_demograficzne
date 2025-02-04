library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {

  # Renderowanie mapy
  polska <- get_eurostat_geospatial(resolution = 10, 
                                    nuts_level = 2, 
                                    country = "PL",
                                    year = 2006)
  
  output$mapa <- renderLeaflet({
    
    
    leaflet(polska, 
            options = leafletOptions(
              zoomControl = FALSE,
              dragging = FALSE,
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
  
}