library(bdl)
subjects <- get_subjects()
print(search_variables("ludność"), n = 675)
variables <- search_variables("ludność", subjectId = "P2137")

get_variables("P2137", level = 2)
options(bdl.api_private_key = "5b507565-9b85-440b-6777-08dd335c83c8")


get_data_by_variable("2137", unitlevel = 2)
get_levels()
woj<-as.data.frame(get_units(level=2))
