## This setup is outside the markdown so that I can link to the warehouse when knitting
## but if I need to reknit for any reason once the data has been extracted,
## it means that don't need to run the whole extraction again
 

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

rmarkdown::render(input = 'parent_main.Rmd',
                  output_file = 'long_wait_test.html',
                  output_dir = 'outputs')
