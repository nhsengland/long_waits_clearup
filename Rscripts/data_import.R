#make connection
#note that you will get a little window you need to put your password into BUT
#it doesn't force itself to the top so you might need to check your taskbar
source('scripts/connection.R')


#get the data
raw_date <- DBI::dbGetQuery(conn = con_udal, 
                            statement = readr::read_file("SQL/lw_and_full_ptl.sql"))

DBI::dbDisconnect(con_udal)

#raw_data <- read_csv("data/data_2023_06_23.csv",
#                     col_types = cols(Activity_Date = col_date(format = "%d/%m/%Y"), 
#                                      ACTIVITY_TREATMENT_FUNCTION_CODE = col_character()))

tfc_list <- read_csv("lookups/tfc_list.csv", 
                     col_types = cols(tfc = col_character()))

local_names <- read_csv("lookups/provider_short_names.csv",
                        show_col_types = FALSE)


