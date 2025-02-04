#wydatki w przeliczeniu na mieszkańca
plot_with_weighted_avg(wydatki_budzwoj_1_miesz, 'Wartosc')

#wydatki administracyjne
plot_with_weighted_avg(wydatki_administracja, 'Wartosc') +
  scale_y_continuous(labels = label_number())

#wydatki 801
plot_with_weighted_avg(wydatki_edukacja_wychowanie, 'Wartosc') +
  scale_y_continuous(labels = label_number())

#wydatki 700
plot_with_weighted_avg_labels(wydatki_gosp_mieszkaniowa, 'Wartosc') +
  scale_y_continuous(labels = label_number())

#wydatki 851
plot_with_weighted_avg_labels(wydatki_ochrona_zdrowia, 'Wartosc') +
  scale_y_continuous(labels = label_number())

#przeciętne wynagrodzenia
plot_with_weighted_avg_labels(wynagrodzenia, 'Wartosc')

polska <- get_eurostat_geospatial(resolution = 10, nuts_level = 2, country = "PL", year = 2006)

#mapa
wynagrodzenia_avg <- wynagrodzenia %>%
  filter(Rok >= 2014 & Rok <= 2023) %>%
  group_by(Nazwa) %>%
  summarise(avg_wynagrodzenie = mean(Wartosc, na.rm = TRUE))

srednia_krajowa <- mean(wynagrodzenia_avg$avg_wynagrodzenie, na.rm = TRUE)

wynagrodzenia_avg <- wynagrodzenia_avg %>%
  mutate(label_color = ifelse(avg_wynagrodzenie >= srednia_krajowa, "red", "green"))

map_data_merged <- polska %>%
  mutate(NUTS_NAME = str_to_upper(NUTS_NAME)) %>%
  left_join(wynagrodzenia_avg, by = c("NUTS_NAME" = "Nazwa"))

coords <- st_centroid(map_data_merged) %>% st_coordinates()
map_data_merged <- map_data_merged %>%
  mutate(label_x = coords[,1], label_y = coords[,2])

ggplot(data = map_data_merged) +
  geom_sf(aes(fill = avg_wynagrodzenie), color = "black") +
  scale_fill_viridis_c( name = "Śr. Wynagrodzenie", labels = label_number(big.mark = " ")) +
  theme_minimal() +
  ggtitle("Średnie wynagrodzenie w Polsce (2014-2023)") +
  theme(legend.position = "top", axis.title = element_blank(), axis.text = element_blank()) +
  geom_label_repel(aes(x = label_x, y = label_y, label = round(avg_wynagrodzenie, 0), color = label_color), 
                   size = 4, fontface = "bold", show.legend = FALSE)

