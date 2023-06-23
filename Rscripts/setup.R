## Load libraries
source('Rscripts\\libraries.R')

## Import data
source('Rscripts\\data_import.R')

## create calendar and working days calendar
source('Rscripts\\calendar_builder.R')

## all to lower
source('Rscripts\\all_to_lower.R')

## load locally defined functions
source('Rscripts\\local_functions.R')

## load locally defined functions
source('Rscripts\\local_colours.R')

#### deadline - this sets when we want to aim to clear the list by
deadline <- as.Date('2024-03-31')

#### WLMDS data is submitted at the end of a week, 
#### the below finds the closest Sunday to the deadline entered above

deadline_week_ending <- fn_eoweek(deadline)
number_of_weeks_for_average <- 16

## create the data frames
source('Rscripts\\create_data_frames.R')


icb_list <- current_position %>% 
  select(stp_name) %>% 
  distinct() %>% 
  pull(stp_name)

##### set the region name
#region_name  <- 'the South East region'
#icb_list <- c(icb_list,region_name)
#
#for(icb in icb_list) {
#  paramicb <- icb
#  rmarkdown::render('RScripts\\long_wait_report.Rmd', 
#                    output_file = paste0("long_wait_report_",paramicb, "_", format(Sys.Date(),'%d%m%Y')),
#                    output_dir = "Output", 
#                    params = list(icb = paramicb))
#}

rmarkdown::render('RScripts\\long_wait_report.Rmd', 
                  output_file = paste0("long_wait_report_test"),
                  output_dir = "Output")
