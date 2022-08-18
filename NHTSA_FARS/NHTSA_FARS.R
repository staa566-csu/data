rm(list=ls())
library(tidyverse)

start_year <- 2000
end_year <- 2020


# load first year
# other years will be appended to this
# download zip as a temparary file
temp <- tempfile()
download.file(paste0("https://static.nhtsa.gov/nhtsa/downloads/FARS/",start_year,"/National/FARS",start_year,"NationalCSV.zip"),temp)
# find the accident.csv file. this is done because there is irregular capitalization in the file name.
contents <- unzip(temp, list=TRUE)
filename <- contents$Name[which(toupper(contents$Name)=="ACCIDENT.CSV")]
# read the accident.csv file
fars <- read_csv(unz(temp, filename))
colnames(fars) <- tolower(colnames(fars))
fars <- fars %>% mutate_at(c("longitud","latitude"), as.numeric)
# remove temporary file and some R objects
unlink(temp)
rm(list=c("contents","filename"))


# repeat and load subsequent years
for(year in (start_year+1):end_year){
  temp <- tempfile()
  download.file(paste0("https://static.nhtsa.gov/nhtsa/downloads/FARS/",year,"/National/FARS",year,"NationalCSV.zip"),temp)
  contents <- unzip(temp, list=TRUE)
  filename <- contents$Name[which(toupper(contents$Name)=="ACCIDENT.CSV")]
  fars_year <- read_csv(unz(temp, filename))
  colnames(fars_year) <- tolower(colnames(fars_year))
  fars_year <- fars_year %>% mutate_at(c("longitud","latitude"), as.numeric)
  fars <- bind_rows(fars,fars_year)
  
  
  
  unlink(temp)
  rm(list=c("contents","filename"))
}


save(fars, file=paste0("Lectures/Data/NHTSA_FARS/fars_",start_year,"_",end_year,".rda"))



