library(tidyverse)
library(ggplot2)
library(plotly)
library(broom)
library(ggrepel)
library(eurostat)
library(sf)
library(scales)


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

#wykres wskaźnika urbanizacji
plot_with_weighted_avg(urbanizacja, 'wskaznik_urbanizacji') + 
  ggtitle("Wskaźnik urbanizacji")

warszawa %>% 
  ggplot(aes(x = Rok, y = Wartosc)) + geom_line() + theme_bw() + 
  ggtitle("Ludność powiatu miasta stołecznego Warszawa")


plot_with_weighted_avg(wskaznik_urodzen, 'wskaznik')

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

#wykres migracji wewnętrznych
saldo_migracji %>% 
  filter(Migracje == "saldo migracji wewnętrznych") %>% 
  plot_wo_weighted_avg('Wartosc') + geom_abline(slope = 0, size = 1)

#migracje wewnętrzne - mapa
migration_summary <- saldo_migracji %>%
  filter(Migracje == "saldo migracji wewnętrznych") %>%
  group_by(Nazwa) %>%
  summarise(total_migracja = sum(Wartosc, na.rm = TRUE))

polska <- get_eurostat_geospatial(resolution = 10, 
                                  nuts_level = 2, 
                                  country = "PL",
                                  year = 2006)

map_data_merged <- polska %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>%
  left_join(migration_summary, by = c("NUTS_NAME" = "Nazwa"))

polska_with_coords <- polska %>%
  st_transform(crs = 4326) %>%
  st_centroid() %>%
  cbind(st_coordinates(.)) %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>% 
  left_join(migration_summary, by = c("NUTS_NAME" = "Nazwa")) %>%
  mutate(label_x = X, label_y = Y, 
         label_color = ifelse(total_migracja < 0, "lightcoral", "lightgreen"))

ggplot(data = map_data_merged) +
  geom_sf(aes(fill = total_migracja)) +
  scale_fill_viridis_c(labels = label_number()) +
  theme_minimal() +
  ggtitle("Mapa Salda Migracji Wewnętrznych w Polsce") +
  theme(legend.position = "top",
        legend.text = element_text(size = 10), 
        legend.title = element_text(size = 12),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  geom_label_repel(data = polska_with_coords, 
                   aes(x = label_x, y = label_y, label = total_migracja, 
                       color = label_color), 
                   box.padding = 0.5, 
                   max.overlaps = 100, 
                   size = 3,
                   fontface = "bold",
                   show.legend = FALSE) + 
  guides(fill = guide_colorbar(title = "Saldo migracji", 
                               direction = "vertical",
                               position = "right",
                               label.hjust = 0.5, 
                               label.vjust = 0.5))

#wykres migracji zagranicznych
migracje_zagraniczne <-  saldo_migracji %>% 
  filter(Migracje == "saldo migracji zagranicznych") %>% 
  group_by(Nazwa) %>%
  summarise(total_migracja = sum(Wartosc, na.rm = TRUE))
  
saldo_migracji %>% 
  filter(Migracje == "saldo migracji zagranicznych") %>% 
  plot_wo_weighted_avg('Wartosc') + 
  geom_abline(slope = 0, size = 1) + 
  geom_line(data = migracje_zagraniczne, aes(x = Rok, y = total_migracja), color = "black", size = 1) +
  theme_bw() + scale_y_continuous(breaks = seq(-40000, max(migracje_zagraniczne$total_migracja), by = 5000))

#mapa migracji zagranicznych
map_data_merged <- polska %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>%
  left_join(migracje_zagraniczne, by = c("NUTS_NAME" = "Nazwa"))

polska_with_coords <- polska %>%
  st_transform(crs = 4326) %>%
  st_centroid() %>%
  cbind(st_coordinates(.)) %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>% 
  left_join(migracje_zagraniczne, by = c("NUTS_NAME" = "Nazwa")) %>%
  mutate(label_x = X, label_y = Y, 
         label_color = ifelse(total_migracja < 0, "lightcoral", "lightgreen"))

ggplot(data = map_data_merged) +
  geom_sf(aes(fill = total_migracja)) +
  scale_fill_viridis_c(labels = label_number()) +
  theme_minimal() +
  ggtitle("Mapa Salda Migracji Wewnętrznych w Polsce") +
  theme(legend.position = "top",
        legend.text = element_text(size = 10), 
        legend.title = element_text(size = 12),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank()) +
  geom_label_repel(data = polska_with_coords, 
                   aes(x = label_x, y = label_y, label = total_migracja, 
                       color = label_color), 
                   box.padding = 0.5, 
                   max.overlaps = 100, 
                   size = 3,
                   fontface = "bold",
                   show.legend = FALSE) + 
  guides(fill = guide_colorbar(title = "Saldo migracji", 
                               direction = "vertical",
                               position = "right",
                               label.hjust = 0.5, 
                               label.vjust = 0.5))


