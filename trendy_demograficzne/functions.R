# Funkcja do generowania wykresów plotly - aby uniknąć redundancji w kodzie
plotly_generate <- function(data, y_var, wojewodztwa, y_label) {
  
  # Check if wojewodztwa$wybrane is empty
  if (length(wojewodztwa$wybrane) == 0) {
    
    avg_data <- data %>%
      group_by(Rok) %>%
      summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) %>%
      ungroup()
    
    year_breaks <- sort(unique(data$Rok))
    
    p <- ggplot(avg_data, aes(x = Rok, y = weighted_avg)) +
      geom_line(color = "black", size = 1.5) +
      geom_point(aes(text = paste0(
        "Średnia ważona: ", round(weighted_avg, 2), "%", "\n",
        "Rok: ", Rok
      )), color = "black", alpha = 0) +
      theme_bw() +
      ylab(y_label) +
      theme(legend.position = "top") +
      labs(color = "Województwo")
    
  } else {
    
    # Filtrowanie danych na podstawie mapy
    filtered_data <- data %>% 
      filter(Nazwa %in% toupper(wojewodztwa$wybrane)) %>% 
      mutate(Nazwa = str_to_title(Nazwa))
    
    # Obliczanie średniej ważonej
    avg_data <- data %>%
      group_by(Rok) %>%
      summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) %>%
      ungroup()
    
    # Wykres ggplot
    p <- ggplot(filtered_data, aes(x = Rok, y = !!sym(y_var), color = Nazwa)) +
      geom_line() +
      geom_point(aes(text = paste0(
        "Wartość: ", round(!!sym(y_var), 2), "%", "\n",
        "Województwo: ", str_to_title(Nazwa), "\n",
        "Rok: ", Rok
      )), alpha = 0) +
      geom_line(data = avg_data, aes(x = Rok, y = weighted_avg), color = "black", size = 1.5) +
      geom_point(data = avg_data, aes(x = Rok, y = weighted_avg, text = paste0(
        "Średnia ważona: ", round(weighted_avg, 2), "%", "\n",
        "Rok: ", Rok
      )), color = "black", alpha = 0) +
      theme_bw() +
      ylab(y_label) +
      theme(legend.position = "top") + 
      labs(color = "Województwo")
  }
  # Transformacja na plotly
  ggplotly(p, tooltip = "text")
}


generate_map <- function(data, y_var, selected_year) {
  
  #ustalenie obiektu polska - kontury
  polska <- get_eurostat_geospatial(resolution = 10, 
                                    nuts_level = 2, 
                                    country = "PL",
                                    year = 2006)
  # transformacja na wielkie litery, aby można było połączyć dane po nazwie województwa
  polska$NAME_LATN_UPPER <- toupper(polska$NAME_LATN)
  data$Nazwa <- toupper(data$Nazwa)
  
  #łączenie tabel
  polska_data <- polska %>%
    left_join(data, by = c("NAME_LATN_UPPER" = "Nazwa")) %>% 
    #filtrowanie danych po wartościach ze slidera
    filter(Rok == selected_year)
  
  
  # stworzenie obiektu leaflet
  leaflet(polska_data, 
          options = leafletOptions(
            zoomControl = FALSE,
            dragging = FALSE,
            doubleClickZoom = FALSE,
            minZoom = 5.8,
            maxZoom = 5.8
          )) %>%
    addPolygons(
      layerId = ~NAME_LATN,
      label = ~paste(NAME_LATN,":", round(polska_data[[y_var]], 2), "%"),
      color = "#9ca0a3",
      fillColor = ~colorBin(palette = "Blues", domain = polska_data[[y_var]], bins = 5)(polska_data[[y_var]]),
      weight = 2,
      fillOpacity = 0.7,
      highlight = highlightOptions(
        fillOpacity = 1,
        bringToFront = TRUE
      )
    )
  
  
}
