library(tidyverse)

#ludność wg wieku i płci
ludnosc <- read_csv2("~/trendy_demograficzne/data/LUDN_2137_CREL_20250113221303.csv")
ludnosc <- ludnosc %>% select(1:7)

#przeciętne wynagrodzenia
wynagrodzenia <- read_csv2("data/WYNA_2497_CREL_20250113223353.csv")
wynagrodzenia <- wynagrodzenia %>% select(1:6)

#ludność wg zamieszkania (wieś/miasto) z podziałem na płeć
miasto_wies <- read_csv2("data/LUDN_2462_CREL_20250113230153.csv")
miasto_wies <- miasto_wies %>% select(1:8)

#wydatki budżetów województw w przeliczeniu na 1 mieszkańca
wydatki_budzwoj_1_miesz <- read_csv2("data/FINA_2416_CREL_20250113230845.csv")
wydatki_budzwoj_1_miesz <- wydatki_budzwoj_1_miesz %>% select(1:6)

#aktywność ekonomiczna ludności w wieku 15-89 lat wg. BAEL
aktywnosc_ekonomiczna <- read_csv2("data/RYNE_4089_CREL_20250113231804.csv")
aktywnosc_ekonomiczna <- aktywnosc_ekonomiczna %>% select(1:8)

#wydatki budżetów województw na ochronę zdrowia
wydatki_ochrona_zdrowia <-  read_csv2("data/FINA_1586_CREL_20250113234937.csv")


#wydatki budżetów województw na edukację
wydatki_edukacja_wychowanie <- read.csv2("data/FINA_1582_CREL_20250113234730.csv")


#wydatki budżetów województw na transport i łączność
wydatki_transport_lacznosc <- read_csv2("data/FINA_1579_CREL_20250113235613.csv")

#wydatki budżetów województw na administrację publiczną
wydatki_administracja <- read_csv2("data/FINA_1590_CREL_20250113235801.csv")


#wydatki budżetów województw na gospodarkę mieszkaniową
wydatki_gosp_mieszkaniowa <- read_csv2("data/FINA_1581_CREL_20250113235923.csv")
