raw_data <- read_csv("data/data_2023_06_23.csv",
                     col_types = cols(Activity_Date = col_date(format = "%d/%m/%Y"), 
                                      ACTIVITY_TREATMENT_FUNCTION_CODE = col_character()))

tfc_list <- read_csv("lookups/tfc_list.csv", 
                     col_types = cols(tfc = col_character()))