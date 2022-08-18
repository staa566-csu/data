rm(list=ls())
library(tidyverse)
library(tidycensus)

# download data
covid_county <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")

covid_county <- covid_county %>%
  arrange(state,county,date) %>%
  group_by(state,county) %>%
  mutate(cases_1day  = cases  - lag(cases,1),
         deaths_1day = deaths - lag(deaths,1),
         cases_7day  = zoo::rollmean(cases_1day, 7, fill=NA, align="right"),
         deaths_7day = zoo::rollmean(deaths_1day, 7, fill=NA, align="right"),
         cases_14day  = zoo::rollmean(cases_1day, 14, fill=NA, align="right"),
         deaths_14day = zoo::rollmean(deaths_1day, 14, fill=NA, align="right"))
head(covid_county, n=20)

# need to get and save api key first time using
# census_api_key("...", install=TRUE)

# Find available variables and codes
# View(sf1)
sf1 <- load_variables(2010, "sf1", cache = TRUE)

# get county population data
county_pop <- get_decennial(geography = "county", 
                           variables = "P001001", 
                           year = 2010)


# merge population data and COVID19 data and normalize
county_pop <- county_pop %>% select(fips=GEOID, pop2010=value)
county_pop

# normalize cases per 100000
covid_county <- covid_county %>% 
  left_join(county_pop, by="fips") %>%
  mutate(cases_1day_per100k = 100000*cases_1day/pop2010,
         deaths_1day_per100k = 100000*deaths_1day/pop2010,
         cases_7day_per100k = 100000*cases_7day/pop2010,
         deaths_7day_per100k = 100000*deaths_7day/pop2010,
         cases_14day_per100k = 100000*cases_14day/pop2010,
         deaths_14day_per100k = 100000*deaths_14day/pop2010)


save(covid_county, file="Lectures/Data/COVID19/covid_county.rda")


