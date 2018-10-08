library(shiny)
library(leaflet)
library(ggplot2)
library(tm)
library(SnowballC)
library(wordcloud)
library(RColorBrewer)
library(plotly)
library(shinythemes)
library(dplyr)
# Define UI for application 
shinyUI(navbarPage("AirBnB Visualization :Boston",theme = shinytheme("united"),tabPanel("Map the Listings",
                   
  sidebarLayout(
    sidebarPanel(h3("Listings in Boston"), width = "3",br(),
                 selectInput("Neighbourhood", "Select one NeighbourHood:",             # creating a drop down menu
                             c("Boston" = "Boston",
                               "Allston" = "Allston",
                               "Back Bay" = "Back Bay",
                               "Bay Village" = "Bay Village",
                               "Beacon Hill" = "Beacon Hill",
                               "Brighton" = "Brighton",
                               "Charlestown" = "Charlestown",
                               "Chinatown" = "Chinatown",
                               "Dorchester" = "Dorchester",
                               "Downtown" = "Downtown",
                               "East Boston" = "East Boston",
                               "Fenway" = "Fenway",
                               "Hyde Park" = "Hyde Park",
                               "Jamaica Plain" = "Jamaica Plain",
                               "Leather District" = "Leather District",
                               "Longwood Medical Area" = "Longwood Medical Area",
                               "Mattapan" = "Mattapan",
                               "Mission Hill" = "Mission Hill",
                               "North End" = "North End",
                               "Roslindale" = "Roslindale",
                               "Roxbury" = "Roxbury",
                               "South Boston" = "South Boston",
                               "South Boston Waterfront" = "South Boston Waterfront",
                               "South End" = "South End",
                               "West End" = "West End", 
                               "West Roxbury" = "West Roxbury")),  #select input finish
                 checkboxGroupInput("roomtype" , "Select Room Type :",           # creating checkbox inouts
                                    c("Entire home/apt" = "Entire home/apt",
                                      "Private room" = "Private room",
                                      "Shared room" = "Shared room"),
                                    selected = c("Entire home/apt","Private room","Shared room" )),
                 sliderInput("price","Select range for Price:",           # slidebar input
                             min = 1, max = 1500, value = c(0,1500)),
                 
                 sliderInput("rating","Score Rating:",                    # slidebar input
                             min = 0, max = 100, value = c(0,100)),
                 
                 sliderInput("noreviews","No. of Reviews:",                 # slidebar input
                             min = 0, max = 200, value = c(0,200))
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      leafletOutput("distPlot"),br(),br(),
      plotlyOutput("avgprice")
    ))
  ),
  
  ######Creating tab for Review by time######
  
  tabPanel("Review By time",
           sidebarLayout(
             sidebarPanel(h3("Number of reviews over time"), width = 3,
                          helpText(tags$b("This graph is totally interactive.As you move your mouse over the line, the number of reviews are displayed")),
                          #br(),
                          #helpText(h5("As you move your mouse over the line, the number of reviews are displayed")),
                          helpText(h5("To identify the trend you can select any option from the below drop down menu")),

                          selectInput("dt", "Showing data by :",
                                      c("Day" = "date",
                                        "Month" = "month",
                                        "Year" = "year"))
             ),

             # Show a plot of the generated distribution
             mainPanel(
               h3("Reviews over the time",style="margin:20px; margin-left:200px; z-index:100; position:absolute"),
               br(),br(),br(),
               plotlyOutput("reviewplot")
             )
           )

           ),
  
  ######Crearing tab for word Cloud########
  
  tabPanel("Word Cloud",
           sidebarLayout(
             sidebarPanel(h3("Word Cloud for Reviews"),width = 3,
                          sliderInput("freq", "Select frequecy of words:",
                                      min = 1, max = 1000 , value = 50),
                          sliderInput("max", "Select max of words:",
                                      min = 1, max = 600 , value = 100)),
             mainPanel(
               h2("What are the words people use the most when they leave reviews?"),
               plotOutput("wc")) 
             
           )),
  
  ########Creating tab for about the data#############
  
  tabPanel("About the data",
           
           mainPanel(
           img(src='capture.jpg', align = "center")
           #HTML('<center><img src="capture.jpg"></center>')
           )
           )
))
