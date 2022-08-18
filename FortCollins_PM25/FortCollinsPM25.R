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
fc_pm <- NULL
for(year in 2000:2022){
  fc_pm <- bind_rows(fc_pm, download1year(year,poll=88101))
}

# rename without spaces in column names
colnames(fc_pm) <- c("State","County","SiteNum","Date","PM","City","SiteName","Address")


# save files
save(fc_pm, file="Lectures/Data/FortCollins_PM25/fc_pm.rda")
