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
wynagrodzenia <- get_data_by_variable(64428, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         `Jednostka miary` = measureName)

# MIASTO-WIEŚ ####

## Pobranie danych ####
dane <- get_data_by_variable(varId = get_variables("P2462") %>%
                               filter(n1 == "rok", n2 != "ogółem", n3 != "ogółem") %>% 
                               pull(id), unitLevel = lvl)

## Pobranie mapowania id na n1-n3 ####
id_mapping <- get_variables("P2462") %>%
  filter(n1 == "rok", n2 != "ogółem", n3 != "ogółem") %>%
  select(id, Okresy = n1, Lokalizacje = n2, Płeć = n3, `Jednostka miary` = measureUnitName)

## Zmiana nazwy kolumny id, aby uniknąć konfliktów ####
dane <- dane %>%
  rename(Kod = id)

## Przekształcenie na długi format ####
miasto_wies <- dane %>%
  pivot_longer(cols = starts_with("val_"), 
               names_to = "id_temp", 
               names_prefix = "val_", 
               values_to = "Wartosc") %>%
  mutate(id_temp = as.integer(id_temp)) %>%  # Konwersja id_temp na integer
  left_join(id_mapping, by = c("id_temp" = "id")) %>%
  rename(Nazwa = name, Rok = year) %>%
  select(Kod, Nazwa, Okresy, Lokalizacje, Płeć, Rok, Wartosc, `Jednostka miary`)

rm(dane, id_mapping) #usunięcie tabel technicznych


# WYDATKI BUDŻETÓW WOJEWÓDZTW NA 1 MIESZKAŃCA - OGÓŁEM ####
wydatki_budzwoj_1_miesz <- get_data_by_variable(60518, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)

# WYDATKI NA OCHRONĘ ZDROWIA - OGÓŁEM ####
wydatki_ochrona_zdrowia <- get_data_by_variable(6507, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)

# WYDATKI NA EDUKACJĘ I WYCHOWANIE  - OGÓŁEM ####
wydatki_edukacja_wychowanie <- get_data_by_variable(6499, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)

# WYDATKI NA TRANSPORT I ŁĄCZNOŚĆ - OGÓŁEM ####
wydatki_transport_lacznosc <- get_data_by_variable(8458, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)

# WYDATKI NA ADMINISTARCJĘ - OGÓŁEM ####
wydatki_administracja <- get_data_by_variable(8473, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)

# WYDATKI NA GOSPODARKĘ MIESZKANIOWĄ - OGÓŁEM ####
wydatki_gosp_mieszkaniowa <- get_data_by_variable(8462, unitLevel = lvl) %>% 
  select(Kod = id,
         Nazwa = name,
         Rok = year,
         Wartosc = val,
         'Jednostka Miary' = measureName)
