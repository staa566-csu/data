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
    filter(`State Name`=="Colorado" & `County Code`=="069") %>%
    select(`State Name`, `County Name`, `Site Num`, `Date Local`, `Arithmetic Mean`, `City Name`, `Local Site Name`, `Address`) %>%
    drop_na()
  
  return(datain)
}

# loop through and download all years
lp_temp <- NULL
for(year in 1980:2022){
  lp_temp <- bind_rows(lp_temp, download1year(year,poll="TEMP"))
}

# rename without spaces in column names
colnames(lp_temp) <- c("State","County","SiteNum","Date","Temp","City","SiteName","Address")

# save files
save(lp_temp, file="Lectures/Data/LongsPeakTemperature/LongsPeakTemperature.rda")
