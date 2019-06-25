library(shiny)
library(shinydashboard)

# ui
shinyUI(
  dashboardPage(
    
    # header
    dashboardHeader(title="Classification of Key word searches",titleWidth = 350),
    
    # sidebar
    dashboardSidebar(width = 350,
                     fileInput("file","Upload CSV files",multiple=TRUE,accept=("text/comma")),
                     
                     # sidebar menu
                     sidebarMenu(                  # option
                       menuItem(text = "Data", tabName="Data", icon=icon("table"), startExpanded = TRUE),
                       menuItem(text="Distribution of Clusters",tabName="Distribution of Clusters",  # input
                                selectInput(inputId = "cluster",
                                            label = h1("Predicted cluster labels"),
                                            choices="",
                                            selected=""),
                                
                                actionButton(inputId = "Go",label = "Go")),
                       
                       menuItem(text="Distribution of Keys by Month",tabName="Distribution of Keys by Month",
                                
                                actionButton(inputId = "Go",label = "Go")),
                       menuItem(text="Distribution of Keys in last 90 days",tabName="Distribution of Keys in last 90 days",
                                
                                actionButton(inputId = "Go",label = "Go")),
                       menuItem(text="Word cloud by clusters",tabName="Word cloud by clusters",   selectInput(inputId = "labels",
                                                                                                            label = h1("cluster labels"),
                                                                                                            choices="",
                                                                                                            selected=""),
                                
                                actionButton(inputId = "Go",label = "Go"))
                       ))
    ,
    
    # body
    dashboardBody(
      
      # tab 1: data
      tabItem(tabName="Data Set",
              tabsetPanel(id="Data Set",
                          tabPanel(
                            "Data Set",tableOutput("data.frame")),
                          tabPanel("Distribution of Clusters",
                                   fluidRow(
                                     box(title="Distribution of Key searches",status="primary",solidHeader=T,background="aqua",plotOutput("box"),width=12))),
                          tabPanel("Distribution of Keys by Month",
                          fluidRow(
                                  box(title="Distribution of Monthly searches",status="primary",solidHeader=T,background="aqua",plotOutput("monthly"),width=10))
                          
                          ),
                          tabPanel("Distribution of Keys in last 90 days",
                                   fluidRow(
                                     box(title="Distribution of key searches in last 90 days",status="primary",solidHeader=T,background="aqua",plotOutput("ninety"),width=10))),
                          tabPanel("Word cloud by clusters",
                                   fluidRow(
                                     box(title="Word cloud by clusters",status="primary",solidHeader=T,background="aqua",plotOutput("cloud"),width=20,height = 20)))
                                   
                          )
              )
      )
    )
)