#### step 1 get the max and min dates from the data 
#### and the number of weeks left to the deadline

max_date <- max(raw_data$activity_date)
min_date <- min(raw_data$activity_date)
weeks_remaining <- as.numeric(difftime(deadline_week_ending,max_date,units = "weeks"))

#### when we change the SQL to be dynamic, we won't need this
#### for now it's here to allow for dynamic adjustment in the number of weeks used to get the average

start_date <- max_date-(number_of_weeks_for_average*7) 

#### step 2 get a list of all of the week ending dates between the beginning 
#### and the end of the RTT dataset
#### we are going to rename the column week_ending to better reflect its job

all_weeks_ending <- calendar %>% 
  filter(date >= start_date & 
           date <= max_date & 
           day_name == 'Sun') %>% 
  select(date) %>% 
  rename(week_ending = date)

rm(calendar, monthly_working_days)

#### step 3 not every trust started reporting at the same time, 
#### and in some cases we've got big lags between the earliest week for the dataset
#### and the earliest week for the trust itself. 
#### Therefore "week 1" needs to be individually determined

week_one_set <- raw_data %>% 
  filter(activity_date >= start_date) %>% 
  select(organisation_code,
         activity_date) %>% 
  group_by(organisation_code) %>% 
  mutate(trust_min_date = min(activity_date)) %>% 
  ungroup() %>% 
  select(organisation_code,
         trust_min_date) %>% 
  distinct()

#### step 4 now we create a table that gives all of the week ending dates for each trust
#### starting from their earliest reporting week in the data
#### in this step rowwise ensures we are looking at each trust individually (because there is 
#### only one row per organisation)
#### then we are creating a week ending column where the "cell" associated with that trust 
#### holds a list, instead of a single item.
#### we then unpack that list using unnest to get a row for every item in the list for that trust
#### finally we use select to get rid of the min_date column because we don't need it any more

weeks_by_trust <- week_one_set %>% 
  rowwise() %>% 
  mutate(week_ending = list(all_weeks_ending$week_ending[all_weeks_ending$week_ending >= trust_min_date])) %>% 
  unnest(week_ending) %>% 
  select(week_ending,
         organisation_code)

rm(week_one_set)

#### step 5 get the unique rows from the RTT data minus the activity and the dates
#### then bind the treatment function names to the TFC codes

org_specs <- raw_data %>% 
  filter(activity_date >= start_date) %>% 
  select(organisation_name,
         organisation_code,
         stp_name,
         activity_treatment_function_code,
         rtt_tfc_descriptor,
         wait_type) %>% 
  distinct()

tfc_list <- tfc_list %>% 
  select(tfc,
         tfc_name)

org_specs <- left_join(x=org_specs,
                       y=tfc_list, 
                       by=c('activity_treatment_function_code' = 'tfc'),
                       keep = FALSE) %>% 
  select(organisation_name,
         organisation_code,
         stp_name,
         activity_treatment_function_code,
         tfc_name,
         rtt_tfc_descriptor,
         wait_type)

#### step 6 merge the range of dates from step 4 with the data frame created in step 5
#### we now have a blank table with all of the dates where activity should have been reported
#### together with all of the inpatient and outpatient specialties
#### against which the trust reports wl activity

framework <- merge(x = weeks_by_trust,
                   y = org_specs,
                   by = 'organisation_code')
  
rm(org_specs,all_weeks_ending,weeks_by_trust,tfc_list)

#### step 7 now we add the activity back in from the raw data, missing weeks will show as NA 

full_long_wait_data <- left_join(x = framework,
                       y = raw_data,
                       by = c('week_ending'='activity_date',
                              'organisation_name',
                              'organisation_code',
                              'stp_name',
                              'activity_treatment_function_code',
                              'rtt_tfc_descriptor',
                              'wait_type'),
                       keep = FALSE)

rm(framework)

#### step 8 we need to replace the NAs with 0 values in order to get the running difference
#### we don't want to lose the NAs entirely though because we want the gaps for accurate charting
#### therefore we are going to create two new columns with the NAs replaced
#### one for long waits and one for full ptl
#### we are also going to rename the various activity columns so they're more meaningful

full_long_wait_data <- full_long_wait_data %>% 
  mutate(long_waits_cleaned = replace_na(long_waits,0),
         total_ptl_cleaned = replace_na(total_ptl,0)) %>% 
  rename(long_waits_raw = long_waits,
         total_ptl_raw = total_ptl)

#### step 9 now we need the running difference between each week of data grouped by
####  - organisation name
####  - tfc
####  - wait type

full_long_wait_data <- full_long_wait_data %>% 
  group_by(organisation_name,
           stp_name,
           activity_treatment_function_code,
           tfc_name,
           rtt_tfc_descriptor,
           wait_type) %>% 
  arrange(week_ending, .by_group = TRUE) %>% 
  mutate('running_difference_lw' = long_waits_cleaned - lag(long_waits_cleaned),
         'running_difference_ptl' = total_ptl_cleaned - lag(total_ptl_cleaned) ) %>% 
  ungroup() 

#### step 10 now we want to find the mean average of the running difference

mean_change <- full_long_wait_data %>% 
  select(-c(week_ending,
            long_waits_raw,
            total_ptl_raw,
            long_waits_cleaned,
            total_ptl_cleaned)) %>% 
  filter(!is.na(running_difference_lw)) %>% 
  group_by(across(-c(running_difference_lw,
                     running_difference_ptl))) %>%   
  summarise(mean_change_lw = mean(running_difference_lw),
            mean_change_ptl = mean(running_difference_ptl)) %>% 
  ungroup()

#### step 11 we need to get our current position, 
#### since we don't care about specialities with no long waits we can exclude those,
#### once we've done that both "_cleaned" fields will be redundant so we'll drop them,
#### running difference is a bad name for those fields with just one week in them,
#### but it may be useful later so we can just rename them.
#### As we are renaming things we will also rename the "_raw" fields 

current_position <- full_long_wait_data %>% 
  filter(week_ending == max_date &
         long_waits_cleaned > 0 ) %>% 
  select(-c('long_waits_cleaned',
            'total_ptl_cleaned')) %>% 
  rename(ptl_change_in_last_week = running_difference_ptl,
         lw_change_in_last_week = running_difference_lw,
         current_long_waits = long_waits_raw,
         current_ptl = total_ptl_raw)

#### step 12 now we will combine the mean change with the current position
#### this will allow us to figure out: 
#### > when we will clear the long waits
#### > how many long waits we will have in each specialty by the deadline

#### Currently positive values indicate growth and negative values indicate reduction
#### so we need to convert the current value to it's inverse by multiplying by -1
#### (ie growth of 20 a week needs to be treated as -20)

current_position <- left_join(x = current_position,
                              y = mean_change,
                              by = c('organisation_name',
                                     'organisation_code',
                                     'stp_name',
                                     'activity_treatment_function_code',
                                     'tfc_name',
                                     'rtt_tfc_descriptor',
                                     'wait_type'),
                              keep = FALSE) 

current_position <- current_position %>% 
  mutate(change_trend = case_when(mean_change_lw == 0 ~ 'no change',
                                    mean_change_lw < 0 ~ 'reducing',
                                    mean_change_lw > 0 ~ 'growing')) %>% 
  mutate(weeks_to_clear = case_when(change_trend == 'reducing' ~ current_long_waits/(mean_change_lw*-1))) %>% 
  mutate(est_position_at_deadline = 
           case_when(weeks_to_clear < weeks_remaining ~ 0,
                     weeks_to_clear >= weeks_remaining ~ ceiling(mean_change_lw*weeks_remaining+current_long_waits),
                     change_trend != 'reducing' ~ ceiling(mean_change_lw*weeks_remaining+current_long_waits)))


