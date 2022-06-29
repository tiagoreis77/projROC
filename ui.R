
library(shiny)
library(ROCR)

shinyUI(fluidPage(
  
  # Choose Theme for app
  theme = bslib::bs_theme(bootswatch = "superhero"),
  
  # App Title
  titlePanel("ROC SHINY APP"),
  
  # Lateral Menu
  navlistPanel(id = "tabset", widths = c(2,9), "File Upload",
               tabPanel("Upload your file", icon = icon("file-csv"),
                        
                        # Sidebar layout with input and output definitions
                        sidebarLayout(
                          
                          # Sidebar panel for inputs
                          sidebarPanel(
                            
                            # Input: Select a file
                            fileInput("file1", "Choose Your CSV File",
                                      multiple = FALSE,
                                      accept = c("text/csv",
                                                 "text/comma-separated-values,text/plain",
                                                 ".csv")),
                            
                            # Horizontal line
                            tags$hr(),
                            
                            # Input: Checkbox if file has header
                            checkboxInput("header", "Header", TRUE),
                            
                            # Horizontal line
                            tags$hr(),
                            
                            # Input: Select separator
                            radioButtons("sep", "Separator",
                                         choices = c(Comma = ",",
                                                     Semicolon = ";",
                                                     Tab = "\t"),
                                         selected = ";")
                          ),
                          
                          # Main panel for displaying outputs
                          mainPanel(
                            
                            # Output: Data file
                            tableOutput("contents")
                            
                          )
                          
                        )),
               
               "ROC Curve",
               tabPanel("ROCR", icon = icon("chart-line"),
                        
                        sidebarLayout(
                          
                          sidebarPanel(
                            
                            # Input: select predictor
                            selectInput("prediction", "Prediction", ""),
                            
                            # Horizontal line ----
                            tags$hr(),
                            
                            # Input: select response
                            selectInput("response", "Response", "", selected = ""),
                            
                            # Horizontal line ----
                            tags$hr(),
                            
                            # Input: option to add a new curve
                            checkboxInput("add", "Add a new curve"),
                            
                            # Input: add predictor
                            selectInput("addprediction", "Add Prediction", ""),
                            
                            # Horizontal line ----
                            tags$hr(),
                            
                            # Input: select response
                            selectInput("addresponse", "Add Response", "", selected = "")
                            
                          ),
                          
                          mainPanel(
                            # Output: ROC Curve and AUC
                            verbatimTextOutput("AUC"),
                            tags$hr(),
                            plotOutput("MyCurve", click = "plot_click"), 
                            tags$hr(),
                            verbatimTextOutput("plot_clickinfo")
                          )
                          
                        )
               )
  )
))