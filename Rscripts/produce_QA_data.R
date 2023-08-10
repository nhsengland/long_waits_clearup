## This setup is outside the markdown so that I can link to the warehouse when knitting
## but if I need to reknit for any reason once the data has been extracted,
## it means that don't need to run the whole extraction again

## Load libraries
source('Rscripts\\libraries.R')

#make connection
#note that you will get a little window you need to put your password into BUT
#it doesn't force itself to the top so you might need to check your taskbar
source('Rscripts\\connection.R')

## Import data
source('Rscripts\\data_import.R')

## create calendar and working days calendar
source('Rscripts\\calendar_builder.R')

## all to lower
source('Rscripts\\all_to_lower.R')

## load locally defined functions
source('Rscripts\\local_functions.R')

#### deadline - this sets when we want to aim to clear the list by
deadline <- as.Date('2024-03-31')

#### WLMDS data is submitted at the end of a week, 
#### the below finds the closest Sunday to the deadline entered above

deadline_week_ending <- fn_eoweek(deadline)
number_of_weeks_for_average <- 16

## create the data frames
source('Rscripts\\create_data_frames.R')


write_xlsx(current_position,'outputs/qa_cp.xlsx')
write_xlsx(full_long_wait_data,'outputs/qa_flwd.xlsx')