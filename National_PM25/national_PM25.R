library(tidyverse)

# function to download one year of data
download1year <- function(year,poll){
  # download and read data
  temp <- tempfile()
  filename <- paste0("daily_",poll,"_",year)
  download.file(paste0("https://aqs.epa.gov/aqsweb/airdata/",filename,".zip"), temp )
  datain <- read_csv(unz(temp, paste0(filename,".csv")))
  
  # filter to Larimer County Colorado
  datain <- datain %>% 
    select(Latitude, Longitude, site=`Site Num`, state=`State Code`, pm=`Arithmetic Mean`,
           name=`Local Site Name`, city=`City Name`, statename=`State Name`,
           date=`Date Local`) %>%
    filter(!(state %in% c("02","15","72","78"))) %>%
  drop_na()
  
  return(datain)
}

# loop through and download all years
pm2020 <- NULL
for(year in 2020){
  pm2020 <- bind_rows(pm2020, download1year(year,poll=88101))
}



# save files
save(pm2020, file="national_PM25/pm.rda")
