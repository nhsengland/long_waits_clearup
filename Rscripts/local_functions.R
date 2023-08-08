#### This function finds the end of a week from a date.
#### If your date is a Sunday, it returns that date.
#### Otherwise it returns the closest Sunday after the date provided


fn_eoweek <- function(x){
  as.Date(x)
  if (wday(x) > 1) {
    x+(8-wday(x))
  } else{
    x
  }
}

fn_projections_dt <- function(df) {
x <-  datatable(df,
                class = 'cell-border stripe',
                colnames = c('Treatment Function',
                             'Current PTL',
                             'Current Long Waits',
                             'Est. Position At Deadline',
                             'Avg. weekly change',
                             'Change Trend'),
                rownames = FALSE,
                options = list(
                  dom = 't',
                  paging = FALSE,
                  columnDefs = list(list(targets = c('change_trend'), visible = FALSE))
                )) %>% 
    formatStyle(5,6,
                backgroundColor = styleEqual(c('growing','no change','reducing'),
                                             c(table_red,highlight,table_green)),
                color = 'white') %>% 
  formatRound('mean_change_lw',2)


 return(x) 
}



fn_lw_trend <- function(df, wt) {
  
  lw_trend <- df %>% 
  filter(wait_type == wt) %>% 
  select(week_ending,
         long_waits_cleaned) %>% 
  group_by(week_ending) %>% 
  mutate(long_waits = sum(long_waits_cleaned)) %>% 
  ungroup()

  lw_trend <- ggplot(lw_trend, aes(x=week_ending,y=long_waits))+
    geom_point()+
    expand_limits(y=0)+
    scale_x_date(
      date_breaks = '1 week',
      date_labels = '%d-%b-%Y'
    )+
    theme(axis.text.x = element_text(angle = 30),
          axis.title.x = element_blank(),
          axis.title.y = element_blank())

return(lw_trend)
}

