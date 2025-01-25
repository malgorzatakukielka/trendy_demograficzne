library(tidyverse)

# funkcja licząca zmiany rok do roku
calculate_yearly_change <- function(df) {
  df <- df[order(df$Rok), ]  # Sortowanie według roku
  df$Zakres_Lat <- c(NA, paste0(head(df$Rok, -1), "-", tail(df$Rok, -1)))  # Dodanie zakresu lat
  df$Zmiana_Roczna <- c(NA, diff(df$Wartosc) / head(df$Wartosc, -1) * 100)  # Zmiana procentowa
  return(df)
}

#wzrost/spadek liczebności w grupach wiekowych (w %)
zmiany_ludnosc <- ludnosc %>% 
  na.omit() %>% 
  group_by(Kod, Wiek, Płeć) %>% 
  group_split() %>%
  lapply(calculate_yearly_change) %>%
  bind_rows() %>% 
  select(-c(5, 6, 7)) %>% 
  na.omit()

#wskaźnik zależności demograficznej 
#(stosunek liczby osób starszych niż 65 lat do liczby osób w wieku produkcyjnym (15-64 lata))
wiek_produkcja <- ludnosc %>%
  filter(Wiek %in% c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49", "50-54", "55-59", "60-64")) %>%
  group_by(Rok) %>%
  summarise(wiek_produkcja = sum(Wartosc))

wiek_starsi <- ludnosc %>%
  filter(Wiek %in% c("65-69", "70 i więcej")) %>%
  group_by(Rok) %>%
  summarise(wiek_starsi = sum(Wartosc))

wskaźnik_zależności <- left_join(wiek_produkcja, wiek_starsi, by = "Rok") %>%
  mutate(wskaźnik_zależności = wiek_starsi / wiek_produkcja * 100)

#populacja w miastach/ na wsi - zmiana w %
wies_miasto_zmiana <- miasto_wies %>% 
  group_by(Kod, Lokalizacje, Płeć) %>% 
  group_split() %>%
  lapply(calculate_yearly_change) %>%
  bind_rows() %>% 
  select(-c(3, 6, 7, 8))  %>% 
  na.omit()

#urbanizacja - odsetek ludzi mieskzających w miastach w odniesieniu do ogółu populacji
ludnosc_calkowita <- ludnosc %>%
  group_by(Rok, Nazwa) %>%
  summarise(ludnosc_calkowita = sum(Wartosc, na.rm = TRUE))

miasto <- miasto_wies %>%
  filter(Lokalizacje == "w miastach") %>%
  group_by(Rok, Nazwa) %>%
  summarise(ludnosc_miasto = sum(Wartosc))

urbanizacja <- left_join(miasto, ludnosc_calkowita, by = c("Rok", "Nazwa")) %>%
  mutate(wskaznik_urbanizacji = (ludnosc_miasto / ludnosc_calkowita) * 100) 
  
  