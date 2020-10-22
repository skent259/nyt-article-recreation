library(shiny)
library(shinydashboard)
library(scales)

#' TODO: list
#' - Numerical ranges for input parameters
#' - Have exogenous shock variables included only when exogenous shock = "Yes"
#' - Format some of the input variables (see here: https://stackoverflow.com/questions/51791983/how-to-format-r-shiny-numericinput)
#' 


header <- dashboardHeader(
    title = "Paltiel COVID-19 Screening for College"
)

sidebar <- dashboardSidebar(
    sidebarMenu(
        id = "sidebar",
        menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("Source code", icon = icon("file-code-o"), 
                 href = "https://github.com/rstudio/shinydashboard/"),
        menuItem("Orignal Spreasheet", icon = icon("file-code-o"), 
                 href = "https://docs.google.com/spreadsheets/d/1otD4h-DpmAmh4dUAM4favTjbsly3t5z-OXOtFSbF1lY/edit#gid=1783644071")
    )#,
    # numericInput("initial_susceptible", "Initial susceptible", value = 1001),
    # numericInput("initial_infected", "Initial infected", value = 10),
    # numericInput("R0", "R0", value = 2.5),
    # radioButtons("exogenous_shocks", "Exogenous shocks?", choices = c("Yes", "No"), selected = "Yes"),
    # numericInput("shocks_frequency", "Frequency of exogenous shocks (every x days)", value = 7),
    # numericInput("new_infections_per_shock", "Number of new infections per shock", value = 10)
)

body <- dashboardBody(
    tags$style("@import url(https://use.fontawesome.com/releases/v5.14.0/css/all.css);"),

    ## INPUTS ------------------------------------------------------------------
    column(width = 2,
           ## Population
           box(title = "Population", width = NULL, solidHeader = TRUE, status = "primary",
               collapsible = TRUE, collapsed = FALSE,
               numericInput("initial_susceptible", "Initial susceptible", value = 1001),
               numericInput("initial_infected", "Initial infected", value = 10)
           ),
           ## Epidemiology
           box(title = "Epidemiology", width = NULL, solidHeader = TRUE, status = "primary",
               collapsible = TRUE, collapsed = FALSE,
               numericInput("R0", "R0", value = 2.5),
               radioButtons("exogenous_shocks", "Exogenous shocks?", choices = c("Yes", "No"), selected = "Yes"),
               numericInput("shocks_frequency", "Frequency of exogenous shocks (every x days)", value = 7),
               numericInput("new_infections_per_shock", "Number of new infections per shock", value = 10),
           ),
    ),
    column(width = 2,
           ## Clinical history
           box(title = "Clinical history", width = NULL, solidHeader = TRUE, status = "primary",
               collapsible = TRUE, collapsed = TRUE,
               numericInput("days_to_incubation", "Days to Incubation", value = 3),
               numericInput("time_to_recovery", "Time to recovery (days)", value = 14),
               numericInput("pct_advancing_to_symptoms", "% asymptomatics advancing to symptoms", value = 0.3),
               numericInput("symptom_case_fatality_ratio", "Symptom Case Fatality Ratio", value = 0.0005),
           ),
           ## Testing
           box(title = "Testing", width = NULL, solidHeader = TRUE, status = "primary",
               collapsible = TRUE, collapsed = FALSE,
               selectizeInput("freqency_of_screening", "Frequency of screening",
                              choices = c("Symptoms Only",
                                          "Every 4 weeks",
                                          "Every 3 weeks",
                                          "Every 2 weeks",
                                          "Weekly",
                                          "Every 3 days",
                                          "Every 2 days",
                                          "Daily"),
                              selected = "Every 2 weeks"),
               numericInput("test_sensitivity", "Test sensitivity", value = 0.7),
               numericInput("test_specificity", "Test specificity", value = 0.98),
               numericInput("test_cost", "Test cost ($)", value = 25),
               numericInput("isolation_return_time", "Time to return FPs from Isolation (days)", value = 3),
               numericInput("confirmatory_test_cost", "Confirmatory Test Cost", value = 100),
           ),
    ),
    
    ## OUTPUT: plot and metrics
    column(width = 8, 
           fluidRow(
               valueBoxOutput("testing_cost_box", width = 4), 
               valueBoxOutput("number_tested_box", width = 4), 
               valueBoxOutput("number_confirmatory_tests_box", width = 4), 
           ),
           fluidRow(
               valueBoxOutput("infections_box", width = 4), 
               valueBoxOutput("average_iu_census_box", width = 4), 
               # valueBoxOutput("average_pct_isolated_box", width = 4), 
               infoBoxOutput("average_pct_isolated_ibox", width = 4),
           ),
           # fluidRow(plotOutput("plot1")),
           plotOutput("plot1")
           
           
    )
    
)



ui <- dashboardPage(header, sidebar, body)

server <- function(input, output) {
    
    
    output$plot1 <- renderPlot({
        ggplot2::qplot(rnorm(100))
    })
    
    ## Expected outputs
    number_tested <- 12388
    number_confirmatory_tests <- 679
    average_iu_census <- 42
    average_pct_isolated <- 0.44
    testing_cost <- 642272
    infections <- 359
    
    ## Value Boxes 
    output$number_tested_box <- renderValueBox({
        valueBox(scales::comma(number_tested), "Total Tests",
                 icon = icon("vials", class = "fad"), 
                 color = "yellow")
    })
    
    output$number_confirmatory_tests_box <- renderValueBox({
        valueBox(scales::comma(number_confirmatory_tests), "Confirmatory Tests",
                 icon = icon("vial"), 
                 color = "yellow")
    })
    
    output$average_iu_census_box <- renderValueBox({
        valueBox(scales::comma(average_iu_census), "Isolation Unit Census (Avg.)",
                 color = "yellow")
    })
    
    output$average_pct_isolated_box <- renderValueBox({
        valueBox(scales::percent(average_pct_isolated), "Percentage in Isolation (Avg.)",
                 color = "yellow")
    })
    
    output$testing_cost_box <- renderValueBox({
        valueBox(scales::dollar(testing_cost), "Cost of Testing",
                 # icon = icon("money-bill-wave"),
                 icon = icon("dollar-sign"),
                 color = "yellow")
    })
    
    output$infections_box <- renderValueBox({
        valueBox(scales::comma(infections), "Total Infections",
                 icon = icon("viruses"),
                 color = "yellow")
    })
    
    
    output$average_pct_isolated_ibox <- renderInfoBox({
        infoBox(NULL, scales::percent(average_pct_isolated),
                subtitle = "Percentage in Isolation (Avg.)",
                 color = "yellow")
    })
    # output$approvalBox <- renderInfoBox({
    #     infoBox(
    #         "Approval", "80%", icon = icon("thumbs-up", lib = "glyphicon"),
    #         color = "yellow"
    #     )
    # })
    # 
    # 
    # INPUTS			
    # 
    # Population			
    #   Initial susceptible	1,001	
    #   Initial infected	10	
    # Epidemiology			
    #   R0	2.5	
    #   Exogenous shocks? 	Yes	
    #   Frequency of exogenous shocks (every x days)	7	
    #   Number of new infections per shock	10	
    # Clinical history			
    #   Days to Incubation (Exposed-Asympt)	3	
    #   Time to recovery (days)	14	
    #   % asymptomatics advancing to symptoms	30%	
    #   Symptom Case Fatality Ratio	0.0005	
    # Testing			
    #   Frequency of screening	Symptoms Only	
    #   Test sensitivity	70%	
    #   Test cost	 $25 	
    #   Test specificity	98.0%	
    #   Time to return FPs from Isolation (days)	1/3	
    #   Confirmatory Test Cost	 $100 	
    # 
    
    
}

shinyApp(ui, server)








##Old code below -----------------------------------

# # input style 1 - within larger input box ------------------------------------------------------------------
# column(width = 4,
#        # fluidRow(box(width = NULL, background = "black", "Inputs")),
#        box(width = NULL, solidHeader = FALSE, status = "primary", title = "Inputs",
#            column(width = 6,
#                   ## Population
#                   box(title = "Population", width = NULL, #solidHeader = TRUE, status = "primary",
#                       background = "light-blue", 
#                       collapsible = TRUE, collapsed = TRUE,
#                       numericInput("initial_susceptible", "Initial susceptible", value = 1001),
#                       numericInput("initial_infected", "Initial infected", value = 10)
#                   ), 
#                   ## Epidemiology
#                   box(title = "Epidemiology", width = NULL, #solidHeader = TRUE, status = "primary",
#                       background = "light-blue", 
#                       collapsible = TRUE, collapsed = FALSE,
#                       numericInput("R0", "R0", value = 2.5),
#                       radioButtons("exogenous_shocks", "Exogenous shocks?", choices = c("Yes", "No"), selected = "Yes"),
#                       numericInput("shocks_frequency", "Frequency of exogenous shocks (every x days)", value = 7),
#                       numericInput("new_infections_per_shock", "Number of new infections per shock", value = 10)
#                   )
#            ),
#            column(width = 6,
#                   ## Clinical history
#                   box(title = "Clinical history", width = NULL, #solidHeader = TRUE, status = "primary",
#                       background = "light-blue", 
#                       collapsible = TRUE, collapsed = TRUE,
#                       numericInput("days_to_incubation", "Days to Incubation", value = 3),
#                       numericInput("time_to_recovery", "Time to recovery (days)", value = 14),
#                       numericInput("pct_advancing_to_symptoms", "% asymptomatics advancing to symptoms", value = 0.3),
#                       numericInput("symptom_case_fatality_ratio", "Symptom Case Fatality Ratio", value = 0.0005)
#                   ),
#                   ## Testing
#                   box(title = "Testing", width = NULL, #solidHeader = TRUE, status = "primary",
#                       background = "light-blue", 
#                       collapsible = TRUE, collapsed = FALSE,
#                       selectizeInput("freqency_of_screening", "Frequency of screening",
#                                      choices = c("Symptoms Only", 
#                                                  "Every 4 weeks",
#                                                  "Every 3 weeks",
#                                                  "Every 2 weeks",
#                                                  "Weekly",
#                                                  "Every 3 days",
#                                                  "Every 2 days",
#                                                  "Daily"),
#                                      selected = "Every 2 weeks"),
#                       numericInput("test_sensitivity", "Test sensitivity", value = 0.7),
#                       numericInput("test_specificity", "Test specificity", value = 0.98),
#                       numericInput("test_cost", "Test cost ($)", value = 25),
#                       numericInput("isolation_return_time", "Time to return FPs from Isolation (days)", value = 3),
#                       numericInput("confirmatory_test_cost", "Confirmatory Test Cost", value = 100)
#                   )
#            )
#        ),
# ),


# 
# # input style 2 - input header ------------------------------------------------------------------
# column(width = 4,
#        # fluidRow(box(width = NULL, background = "light-blue", "Inputs")),
#        box(width = NULL, background = "light-blue", "INPUTS"),
#        fluidRow(
#            column(width = 6,
#                   ## Population
#                   box(title = "Population", width = NULL, solidHeader = TRUE, status = "primary",
#                       collapsible = TRUE, collapsed = TRUE,
#                       numericInput("initial_susceptible", "Initial susceptible", value = 1001),
#                       numericInput("initial_infected", "Initial infected", value = 10)
#                   ),
#                   ## Epidemiology
#                   box(title = "Epidemiology", width = NULL, solidHeader = TRUE, status = "primary",
#                       collapsible = TRUE, collapsed = FALSE,
#                       numericInput("R0", "R0", value = 2.5),
#                       radioButtons("exogenous_shocks", "Exogenous shocks?", choices = c("Yes", "No"), selected = "Yes"),
#                       numericInput("shocks_frequency", "Frequency of exogenous shocks (every x days)", value = 7),
#                       numericInput("new_infections_per_shock", "Number of new infections per shock", value = 10)
#                   )
#            ),
#            column(width = 6,
#                   ## Clinical history
#                   box(title = "Clinical history", width = NULL, solidHeader = TRUE, status = "primary",
#                       collapsible = TRUE, collapsed = TRUE,
#                       numericInput("days_to_incubation", "Days to Incubation", value = 3),
#                       numericInput("time_to_recovery", "Time to recovery (days)", value = 14),
#                       numericInput("pct_advancing_to_symptoms", "% asymptomatics advancing to symptoms", value = 0.3),
#                       numericInput("symptom_case_fatality_ratio", "Symptom Case Fatality Ratio", value = 0.0005)
#                   ),
#                   ## Testing
#                   box(title = "Testing", width = NULL, solidHeader = TRUE, status = "primary",
#                       collapsible = TRUE, collapsed = FALSE,
#                       selectizeInput("freqency_of_screening", "Frequency of screening",
#                                      choices = c("Symptoms Only", 
#                                                  "Every 4 weeks",
#                                                  "Every 3 weeks",
#                                                  "Every 2 weeks",
#                                                  "Weekly",
#                                                  "Every 3 days",
#                                                  "Every 2 days",
#                                                  "Daily"),
#                                      selected = "Every 2 weeks"),
#                       numericInput("test_sensitivity", "Test sensitivity", value = 0.7),
#                       numericInput("test_specificity", "Test specificity", value = 0.98),
#                       numericInput("test_cost", "Test cost ($)", value = 25),
#                       numericInput("isolation_return_time", "Time to return FPs from Isolation (days)", value = 3),
#                       numericInput("confirmatory_test_cost", "Confirmatory Test Cost", value = 100)
#                   )
#            )  
#        )
# ),