library(tidyverse)
library(ggplot2)
library(plotly)
library(broom)
library(ggrepel)
library(eurostat)
library(sf)
library(scales)
library(corrplot)


#wskażnik obciążenia demograficznego
plot_with_weighted_avg_labels(wskaźnik_zależności, "wskaźnik_zależności")

#wykres wskaźnika urbanizacji
plot_with_weighted_avg(urbanizacja, 'wskaznik_urbanizacji') + 
  ggtitle("Wskaźnik urbanizacji")

plot_with_weighted_avg_labels(urbanizacja, 'wskaznik_urbanizacji')

warszawa %>% 
  ggplot(aes(x = Rok, y = Wartosc)) + geom_line() + theme_bw() + 
  ggtitle("Ludność powiatu miasta stołecznego Warszawa")


plot_with_weighted_avg_labels(wskaznik_urodzen, 'wskaznik')

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

#gsopodarstwa domowe
ggplotly(plot_with_weighted_avg_labels(gosp_dom, "Wartosc"))

#gospodarstwa domowe - mapa
# Obliczenie średniej dla województw w latach 2014-2023
wojewodztwa_avg <- gosp_dom %>%
  filter(Rok >= 2014 & Rok <= 2023) %>%
  group_by(Nazwa) %>%
  summarise(avg_value = mean(Wartosc, na.rm = TRUE))

# Obliczenie ogólnopolskiej średniej
weighted_avg <- mean(wojewodztwa_avg$avg_value, na.rm = TRUE)

# Dodanie informacji, czy województwo jest powyżej/poniżej średniej
wojewodztwa_avg <- wojewodztwa_avg %>%
  mutate(category = ifelse(avg_value >= weighted_avg, "Powyżej średniej", "Poniżej średniej"))

# Pobranie mapy Polski na poziomie województw (NUTS 2)
polska <- get_eurostat_geospatial(resolution = 10, nuts_level = 2, country = "PL", year = 2006)

# Dopasowanie nazw województw
map_data_merged <- polska %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>%
  left_join(wojewodztwa_avg, by = c("NUTS_NAME" = "Nazwa"))

# Wyznaczenie centroidów dla etykiet
polska_with_coords <- map_data_merged %>%
  st_transform(crs = 4326) %>%
  st_centroid() %>%
  cbind(st_coordinates(.))

# Tworzenie mapy
ggplot(data = map_data_merged) +
  geom_sf(aes(fill = category), color = "black") +
  scale_fill_manual(values = c("Powyżej średniej" = "lightgreen", "Poniżej średniej" = "lightcoral")) +
  theme_minimal() +
  ggtitle("Średnia wartość dla gospodarstw domowych (2014-2023)") +
  theme(legend.position = "top", axis.title = element_blank()) +
  geom_label_repel(data = polska_with_coords, 
                   aes(x = X, y = Y, label = NUTS_NAME), 
                   size = 3, fontface = "bold")

#corrplot gospodarstwa domowe - urbanizacja
# Agregacja danych: średnie wartości dla województw (lata 2014-2023)
gosp_dom_avg <- gosp_dom %>%
  filter(Rok >= 2014 & Rok <= 2023) %>%
  group_by(Nazwa) %>%
  summarise(avg_gosp_dom = mean(Wartosc, na.rm = TRUE))

urbanizacja_avg <- urbanizacja %>%
  filter(Rok >= 2014 & Rok <= 2023) %>%
  group_by(Nazwa) %>%
  summarise(avg_urbanizacja = mean(wskaznik_urbanizacji, na.rm = TRUE))

# Połączenie zbiorów danych
data_merged <- gosp_dom_avg %>%
  inner_join(urbanizacja_avg, by = "Nazwa")

# Obliczenie macierzy korelacji
cor_matrix <- cor(data_merged %>% select(-Nazwa), use = "complete.obs")

# Wizualizacja macierzy korelacji
corrplot(cor_matrix, method = "color", addCoef.col = "black", tl.col = "black", tl.srt = 45)
