#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(shinydashboard)

ui <- dashboardPage(
  skin = "red",
  dashboardHeader(title = "Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem(
        "Wisconsin Metro Areas", 
        tabName = "wi-metro", 
        icon = icon("city")
      ),
      menuItem(
        "Gundersen Health", 
        tabName = "gundersen", 
        icon = icon("hospital")
      ),
      menuItem(
        "Marshfield Clinic", 
        tabName = "marshfield", 
        icon = icon("hospital")
      ),
      menuItem(
        "Development Version", 
        tabName = "dev-ver", 
        icon = icon("file-code")
      )
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "wi-metro",
        fluidRow(
          tags$iframe(
            seamless = "seamless", 
            src = "https://data-viz.it.wisc.edu/wi-metro-growth-rate/", 
            height = 800, width = 1400
          )
        )
      ),
      tabItem(
        tabName = "gundersen",
        fluidRow(
          tags$iframe(
            seamless = "seamless", 
            src = "https://data-viz.it.wisc.edu/wi-metro-growth-gundersen/", 
            height = 800, width = 1400
          )
        )
      ),
      tabItem(
        tabName = "marshfield",
        fluidRow(
          tags$iframe(
            seamless = "seamless", 
            src = "https://data-viz.it.wisc.edu/wi-metro-growth-marshfield", 
            height = 800, width = 1400
          )
        )
      ),
      tabItem(
        tabName = "dev-ver",
        fluidRow(
          tags$iframe(
            seamless = "seamless", 
            src = "https://data-viz.it.wisc.edu/dev-ver", 
            height = 800, width = 1400
          )
        )
      )
    )
  )
)

server <- function(input, output) {}
shinyApp(ui, server)



