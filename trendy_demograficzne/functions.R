# Funkcja do generowania wykresów plotly - aby uniknąć redundancji w kodzie
plotly_generate <- function(data, y_var, wojewodztwa) {
  
  # Check if wojewodztwa$wybrane is empty
  if (length(wojewodztwa$wybrane) == 0) {
    
    avg_data <- data %>%
      group_by(Rok) %>%
      summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) %>%
      ungroup()
    
    year_breaks <- sort(unique(data$Rok))
    
    p <- ggplot(avg_data, aes(x = Rok, y = weighted_avg)) +
      geom_line(color = "black", size = 2) +
      theme_bw() +
      ylab(y_var) +
      scale_x_continuous(breaks = year_breaks) +
      theme(legend.position = "top")
    
  } else {
    
    # Filtrowanie danych na podstawie mapy
    filtered_data <- data %>% 
      filter(Nazwa %in% toupper(wojewodztwa$wybrane))
    
    # Obliczanie średniej ważonej
    avg_data <- data %>%
      group_by(Rok) %>%
      summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) %>%
      ungroup()
    
    year_breaks <- sort(unique(data$Rok))
    
    # Wykres ggplot
    p <- ggplot(filtered_data, aes(x = Rok, y = !!sym(y_var), color = Nazwa)) +
      geom_line() +
      geom_line(data = avg_data, aes(x = Rok, y = weighted_avg), color = "black", size = 2) +
      theme_bw() +
      ylab(y_var) +
      scale_x_continuous(breaks = year_breaks) +
      theme(legend.position = "top")
  }
  # Transformacja na plotly
  ggplotly(p)
}