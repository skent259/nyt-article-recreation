#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(readxl)
library(tidyverse)

us_counties <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-counties.csv")
us_states <- read_csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/us-states.csv")

county_population <- 
  read_csv("https://www2.census.gov/programs-surveys/popest/datasets/2010-2019/counties/totals/co-est2019-alldata.csv") %>% 
  filter(SUMLEV == "050") %>% 
  mutate(CTYNAME = str_remove(CTYNAME, " County"),
         CTYNAME = str_remove(CTYNAME, " Parish")) %>% 
  rename(state = STNAME,
         county = CTYNAME,
         population = POPESTIMATE2019) %>% 
  select(state, county, population)

temp <- tempfile(fileext = ".xls")
url <- "https://www2.census.gov/programs-surveys/metro-micro/geographies/reference-files/2018/delineation-files/list1_Sep_2018.xls"
download.file(url, destfile = temp, mode = "wb")

metro <- 
  read_xls(temp, skip = 2) %>% 
  mutate(`County/County Equivalent` = str_remove(`County/County Equivalent`, " County"),
         `County/County Equivalent` = str_remove(`County/County Equivalent`, " Parish")) %>% 
  rename(state = `State Name`,
         county = `County/County Equivalent`,
         metro = `CBSA Title`) %>% 
  select(state, county, metro)

us_metro <- 
  us_counties %>% 
  left_join(metro, by = c("state", "county")) %>% 
  left_join(county_population, by = c("state", "county")) %>% 
  filter(!is.na(metro)) %>% 
  group_by(metro, date) %>%
  summarize(cases = sum(cases, na.rm = TRUE),
            deaths = sum(deaths, na.rm = TRUE),
            population = sum(population, na.rm = TRUE)) %>% 
  ungroup() %>%
  group_by(metro) %>% 
  # filter(max(deaths)>=3) %>% 
  ungroup()

vec_metro <- us_metro %>% 
  distinct(metro) %>% 
  pull()



# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Coronavirus in the U.S.: How Fast It's Growing"),
   
   # Sidebar with a slider input for number of bins 
   selectInput(
     "metro",
     label = "Select Metropolitan Area:",
     vec_metro,
     selected = "Madison, WI"
   ),
    
   textOutput("sum_par")

)

# Define server logic required to draw a histogram
server <- function(input, output) {
   
   output$sum_par <- renderText({
     df.1 <- us_metro %>% 
       filter(!is.na(metro)) %>% 
       group_by(metro) %>% 
       mutate(lag.cases = cases - lag(cases, n = 7),
              lag.deaths = deaths - lag(deaths, n = 7)) %>%
       ungroup() %>% 
       filter(date == max(date)) %>% 
       mutate(rank.total.cases = min_rank(desc(cases)),
              rank.total.deaths = min_rank(desc(deaths)),
              rank.new.cases = min_rank(desc(lag.cases)),
              rank.new.deaths = min_rank(desc(lag.deaths)),
              rank.total.cases = ifelse(cases == 0, NA, rank.total.cases),
              rank.total.deaths = ifelse(deaths == 0, NA, rank.total.deaths),
              rank.new.cases = ifelse(cases == 0, NA, rank.new.cases),
              rank.new.deaths = ifelse(deaths == 0, NA, rank.new.deaths)) %>% 
       filter(metro == input$metro)
     
     df.2 <- us_metro %>%
       filter(metro == input$metro) %>%
       arrange(date) %>%
       mutate(lag.cases = cases - lag(cases, n = 7),
              lag.deaths = deaths - lag(deaths, n = 7),
              growth.rate = (cases / lag(cases, n = 7))^(1 / 7) - 1) %>%
       summarize(total.cases = last(cases),
                 total.deaths = last(deaths),
                 new.cases = last(lag.cases),
                 new.deaths = last(lag.deaths),
                 doubling.time.cases = max(date) - last(date, last(cases)/cases >= 2),
                 doubling.time.deaths = max(date) - last(date, last(deaths)/deaths >= 2),
                 cases.per.1000 = round(last(cases)/(last(population)/1000),3),
                 deaths.per.1000 = round(last(deaths)/(last(population)/1000),3),
                 daily.change = round(last(growth.rate),3))
     
     print(paste0("For the metropolitan area of ", input$metro, ", there are ", df.2$total.cases, 
                  " confirmed cases (ranked ", df.1$rank.total.cases, " out of " , length(vec_metro), 
                  " metropolitan areas) and ", df.2$total.deaths, " confirmed deaths (ranked ", 
                  df.1$rank.total.deaths, " out of " , length(vec_metro), 
                  " metropolitan areas) caused by coronavirus. ", "There are ", df.2$new.cases, 
                  " new cases (ranked ", df.1$rank.new.cases, " out of " , length(vec_metro), 
                  " metropolitan areas) and ", df.2$new.deaths, " new deaths (ranked ", df.1$rank.new.deaths, 
                  " out of " , length(vec_metro), " metropolitan areas). ", 
                  "The doubling time for confirmed cases is ", format(df.2$doubling.time.cases), 
                  " and the doubling time for deaths is ", format(df.2$doubling.time.deaths), ". ", 
                  "Per capita, there are ", df.2$cases.per.1000, " cases per 1,000 people and ", 
                  df.2$deaths.per.1000, " deaths per 1,000 people. ", 
                  "The average daily change by the number of cases is ", df.2$daily.change, 
                  " over the last 7 days. "))
   })
}

# Run the application 
shinyApp(ui = ui, server = server)

