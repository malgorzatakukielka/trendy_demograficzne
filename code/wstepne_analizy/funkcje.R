#customowa funkcja do generowania wykresów ze średnią ważoną
plot_with_weighted_avg <- function(data, y_var) {
  avg_data <- data %>%
    group_by(Rok) %>%
    summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) #dodanie średniej ważonej ogólnopolskiej
  
  trend_data <- data %>%
    group_by(Nazwa) %>%
    do(tidy(lm(!!sym(y_var) ~ Rok, data = .))) %>%
    filter(term == "Rok" & estimate > 0) %>%
    mutate(label = paste(Nazwa, "(rosnący)")) #dodanie adnotacji o dodatniej wartości współczynnika kirunkowego linii regresji
  
  label_positions <- data %>%
    filter(Nazwa %in% trend_data$Nazwa) %>%
    group_by(Nazwa) %>%
    slice_tail(n = 1) %>%
    mutate(label = paste(Nazwa, "(rosnący)")) 
  
  year_breaks <- sort(unique(data$Rok))
  
  #wykres
  ggplot(data, aes(x = Rok, y = !!sym(y_var), color = Nazwa)) +
    geom_line() +
    geom_line(data = avg_data, aes(x = Rok, y = weighted_avg), color = "black", size = 2) +
    theme_bw() +
    ylab(y_var) +
    scale_x_continuous(breaks = year_breaks) +
    theme(legend.position = "top") +
    geom_text_repel(data = label_positions, 
                    aes(x = Rok, y = !!sym(y_var), label = label, color = Nazwa), 
                    hjust = 1, vjust = -0.7, size = 3.5, fontface = "bold", 
                    direction = 'both', max.overlaps = Inf) 
}

#customowa funkcja bez średniej ważonej
plot_wo_weighted_avg <- function(data, y_var) {
  
  year_breaks <- sort(unique(data$Rok))
  
  label_positions <- data %>%
    group_by(Nazwa) %>%
    slice_tail(n = 1) %>%
    mutate(label = Nazwa)
  
  #wykres
  ggplot(data, aes(x = Rok, y = !!sym(y_var), color = Nazwa)) +
    geom_line() +
    theme_bw() +
    ylab(y_var) +
    scale_x_continuous(breaks = year_breaks) + 
    theme(legend.position = "top") +
    geom_text_repel(data = label_positions, 
                    aes(x = Rok, y = !!sym(y_var), label = label, color = Nazwa),
                    size = 3.5, fontface = "bold", direction = "both", 
                    box.padding = 0.5, point.padding = 0.2, force = 2, 
                    max.overlaps = Inf)
}

#funkcja ze średnią ważoną i etykietami województw:
plot_with_weighted_avg_labels <- function(data, y_var) {
  avg_data <- data %>%
    group_by(Rok) %>%
    summarise(weighted_avg = mean(!!sym(y_var), na.rm = TRUE)) #dodanie średniej ważonej ogólnopolskie
  
  label_positions <- data %>%
    group_by(Nazwa) %>%
    slice_tail(n = 1) %>%
    mutate(label = paste(Nazwa)) 
  
  year_breaks <- sort(unique(data$Rok))
  
  #wykres
  ggplot(data, aes(x = Rok, y = !!sym(y_var), color = Nazwa)) +
    geom_line() +
    geom_line(data = avg_data, aes(x = Rok, y = weighted_avg), color = "black", size = 2) +
    theme_bw() +
    ylab(y_var) +
    scale_x_continuous(breaks = year_breaks) +
    theme(legend.position = "top") +
    geom_text_repel(data = label_positions, 
                    aes(x = Rok, y = !!sym(y_var), label = label, color = Nazwa), 
                    hjust = 1, vjust = -0.7, size = 3.5, fontface = "bold", 
                    direction = 'both', max.overlaps = Inf) 
}