
#get the data
raw_data <- DBI::dbGetQuery(conn = con_udal, 
                            statement = readr::read_file("SQL/lw_and_full_ptl.sql")) 
raw_data <- raw_data %>% 
  mutate(Activity_Date = as.Date(Activity_Date))

DBI::dbDisconnect(con_udal)

#raw_data <- read_csv("data/data_2023_06_23.csv",
#                     col_types = cols(Activity_Date = col_date(format = "%d/%m/%Y"), 
#                                      ACTIVITY_TREATMENT_FUNCTION_CODE = col_character()))

tfc_list <- read_csv("lookups/tfc_list.csv", 
                     col_types = cols(tfc = col_character()))

local_names <- read_csv("lookups/provider_short_names.csv",
                        show_col_types = FALSE)
