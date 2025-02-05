# ŁADOWANIE PAKIETÓW I USTALENIE ZMIENNYCH POBIERANIA DANYCH Z API ####
library(tidyverse)
library(bdl)

lvl = 2 #dane dla województw
wiek <- c("0-14", "15-19", "20-24", "25-29", "30-34", "35-39", 
          "40-44", "45-49", "50-54", "55-59", "60-64", "65-69", "70 i więcej")

# LUDNOŚĆ ####

## Pobranie danych ####
dane <- get_data_by_variable(varId = get_variables("P2137") %>% 
                               filter(n1 %in% wiek, n2 != "ogółem") %>% 
                               pull(id), unitLevel = lvl)

## Pobranie mapowania id na Wiek i Płeć ####
id_mapping <- get_variables("P2137") %>%
  filter(n1 %in% wiek, n2 != "ogółem") %>%
  select(id, Wiek = n1, Płeć = n2, `Jednostka miary` = measureUnitName)

## Zmiana nazwy kolumny id, aby uniknąć konfliktów ####
dane <- dane %>%
  rename(Kod = id)

## Przekształcenie na długi format ####
ludnosc <- dane %>%
  pivot_longer(cols = starts_with("val_"), 
               names_to = "id_temp", 
               names_prefix = "val_", 
               values_to = "Wartosc") %>%
  mutate(id_temp = as.integer(id_temp)) %>%  # Konwersja id_temp na integer
  left_join(id_mapping, by = c("id_temp" = "id")) %>%
  rename(Nazwa = name, Rok = year) %>%
  select(Kod, Nazwa, Wiek, Płeć, Rok, Wartosc, `Jednostka miary`)

rm(dane, id_mapping) #usunięcie tabel technicznych

# WYNAGRODZENIA ####

## Pobieranie danych ####
wynagrodzenia <- get_data_by_variable(64428, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         `Jednostka miary` = measureName)
