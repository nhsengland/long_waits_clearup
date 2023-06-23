

lm_data <- modelling_data %>% 
  filter(metricname=='RTT_65ww_at_date') %>% 
  select(activity_date,organisation_name,metricvalue) %>% 
  group_by(activity_date, organisation_name) %>% 
  summarise(activity = sum(metricvalue))


lm_data %>% 
  ggplot(aes(x=activity_date, 
             y=activity))+
  geom_point()+
  geom_smooth(method = 'lm', se=FALSE)+
  facet_wrap(~organisation_name, scales='free')



