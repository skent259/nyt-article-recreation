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
          htmlOutput("frame1")
        )
      ),
      tabItem(
        tabName = "gundersen",
        fluidRow(
          htmlOutput("frame2")
        )
      ),
      tabItem(
        tabName = "marshfield",
        fluidRow(
          htmlOutput("frame3")
        )
      ),
      tabItem(
        tabName = "dev-ver",
        fluidRow(
          htmlOutput("frame4")
        )
      )
    )
  )
)

server <- function(input, output) {
  output$frame1 <- 
    renderUI({
      tags$iframe(
        seamless = "seamless", 
        src = "https://data-viz.it.wisc.edu/wi-metro-growth-rate/", 
        height = 800, width = 1400
      )
    })
  output$frame2 <- 
    renderUI({
      tags$iframe(
        seamless = "seamless", 
        src = "https://data-viz.it.wisc.edu/wi-metro-growth-gundersen/", 
        height = 800, width = 1400
      )
    })
  output$frame3 <- 
    renderUI({
      tags$iframe(
        seamless = "seamless", 
        src = "https://data-viz.it.wisc.edu/wi-metro-growth-marshfield/", 
        height = 800, width = 1400
      )
    })
  output$frame4 <- 
    renderUI({
      tags$iframe(
        seamless = "seamless", 
        src = "https://data-viz.it.wisc.edu/dev-ver/", 
        height = 800, width = 1400
      )
    })
}
shinyApp(ui, server)



