library(tidyverse)
library(ggplot2)
library(plotly)
library(broom)

#wskażnik obciążenia demograficznego
wskaźnik_zależności_avg <- wskaźnik_zależności %>%
  group_by(Rok) %>%
  summarise(weighted_avg = mean(wskaźnik_zależności, na.rm = TRUE))

ggplotly(ggplot() +
  geom_line(data = wskaźnik_zależności, aes(x = Rok, y = wskaźnik_zależności, color = Nazwa), size = 1) +
  geom_line(data = wskaźnik_zależności_avg, aes(x = Rok, y = weighted_avg), color = "black", size = 2) +
  theme_bw() +
  ggtitle("Stosunek liczby osób starszych niż 65 lat do liczby osób w wieku produkcyjnym (15-64 lata)") +
  ylab("Wskaźnik zależności") +
  theme(legend.position = "top")
)

#customowa funkcja do generowania wykresów
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
    geom_text(data = label_positions, 
              aes(x = Rok, y = !!sym(y_var), label = label, color = Nazwa), 
              hjust = 1, vjust = -0.7, size = 3.5, fontface = "bold") 
}

#wykres wskaźnika urbanizacji
plot_with_weighted_avg(urbanizacja, 'wskaznik_urbanizacji') + 
  ggtitle("Wskaźnik urbanizacji")

warszawa %>% 
  ggplot(aes(x = Rok, y = Wartosc)) + geom_line() + theme_bw() + 
  ggtitle("Ludność powiatu miasta stołecznego Warszawa")


plot_with_weighted_avg(wskaznik_urodzen, 'wskaznik')



