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