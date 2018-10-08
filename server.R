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

mydata <- read.csv("listings_wrangled.csv") # reading the data
#x <- palette(c("red","green", "blue" ))
x <-c("red","green", "blue" )  # defining vector of three colours
pal <- colorFactor(palette = x ,domain = mydata$room_type)  # applying the colour to room type


#### calculating mean price  group by room type####
avgroomprice <- mydata %>%
  group_by(room_type) %>%
  summarise(count = mean(price)) 

#### calculating mean price  group by room type and m\neighbbourhood####
avgroomprice_neighbourhood <- mydata %>%
  group_by(room_type,neighbourhood) %>%
  summarise(count = mean(price)) 


####converting to data frame
avgroomprice <- as.data.frame(avgroomprice)
avgroomprice_neighbourhood <- as.data.frame(avgroomprice_neighbourhood)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  
  output$distPlot <- renderLeaflet({
    
    if(input$Neighbourhood == "Boston")
    {
      mydata <- subset(mydata,room_type == input$roomtype[1] | room_type == input$roomtype[2] | room_type == input$roomtype[3]) # accepting input based on the checked box tick
       mydata <- subset(mydata,price >input$price[1] & price < input$price[2])  #accepting input based on price range
       mydata <- subset(mydata,review_scores_rating >=input$rating[1] & review_scores_rating <= input$rating[2]) #accepting input based on rating
       mydata <- subset(mydata,number_of_reviews >=input$noreviews[1] & number_of_reviews <= input$noreviews[2]) #accepting input based on reviews range
      
       
       ##Plotting map#### 
       
      leaflet(data = mydata) %>% addTiles()  %>%
        addCircles(lng= mydata$longitude, lat = mydata$latitude, color = ~pal(room_type))  %>% 
        addCircleMarkers(~longitude, ~latitude, radius = 2, color= ~pal(room_type),popup = paste("Room Type", mydata$room_type, "<br>",
                                                                                                  "Price:", mydata$price, "<br>"))  %>%   
        addLegend("topright",pal = pal, values = ~room_type , title = "Room Type")
    }
    else
    {
      ydata<- data.frame(mydata)
      ydata <- ydata[ydata$neighbourhood == input$Neighbourhood,] #getting input about neighbourhood
      #ydata <- ydata[ydata$room_type == input$roomtype,]
      #ydata <- subset(ydata,room_type == input$roomtype[1] | room_type == input$roomtype[2] | room_type == input$roomtype[3])
      ydata <- subset(ydata, room_type %in% input$roomtype) # getting input from check boxes
      ydata <- subset(ydata,price >=input$price[1] & price <= input$price[2]) #accepting input based on price
       ydata <- subset(ydata,review_scores_rating >=input$rating[1] & review_scores_rating <= input$rating[2])  #accepting input based on rating
       ydata <- subset(ydata,number_of_reviews >=input$noreviews[1] & number_of_reviews <= input$noreviews[2])  #accepting input based on number of reviews rating
      
      #ydata <- subset(ydata,price >input$price[1] & price < input$price[2])
      
      leaflet(data = ydata) %>% addTiles()  %>%
        addCircles(lng= ydata$longitude, lat = ydata$latitude, color = ~pal(room_type))  %>% 
        addCircleMarkers(~longitude, ~latitude, radius = 2, color= ~pal(room_type),popup = paste("Room Type", ydata$room_type, "<br>",
                                                                                                  "Price:", ydata$price, "<br>"))  %>%   
        addLegend("topright",pal = pal, values = ~room_type , title = "Room Type")
    }
  })
  
  
  
  #plotting barchart for average price#
  output$avgprice <- renderPlotly({
    if(input$Neighbourhood == "Boston")
    {
      plot_ly(data=avgroomprice,x =~room_type,y =~count,type = 'bar', width = 500, height = 250,marker =list(color = x))  %>%
        layout(title = paste('Avg Price in',input$Neighbourhood),xaxis = list(
          title = "RoomType"),
          yaxis = list(
            title = 'Average Price per night'))
    }
    else
    {
      avgroomprice_neighbourhood <- avgroomprice_neighbourhood[avgroomprice_neighbourhood$neighbourhood == input$Neighbourhood,]
      plot_ly(data=avgroomprice_neighbourhood,x =~room_type,y =~count,type = 'bar', width = 500, height = 250,marker =list(color = x))  %>%
        layout(title = paste('Avg Price in',input$Neighbourhood) ,xaxis = list(
          title = "RoomType"),
          yaxis = list(
            title = 'Price per night'))
    }
  })
  
  
  # output$check <- renderText({
  #   paste(input$roomtype, collapse= ',') 
  #   
  # })
  
  
  
  #########Word Cloud#########
  
  text <- readLines("Reviews_txt.txt",encoding="UTF-8") # reading a text file
  
  myCorpus = Corpus(VectorSource(text))
  myCorpus = tm_map(myCorpus, content_transformer(tolower)) # making all words to lower
  myCorpus = tm_map(myCorpus, removePunctuation) # removing punction
  myCorpus = tm_map(myCorpus, removeNumbers) # removing numbers
  myCorpus = tm_map(myCorpus, removeWords,
                    c(stopwords("english"), "this", "thou", "thee", "the", "and", "but")) # removing stop words
  #png("wordcloud_packages.png", width=25,height=25, units='in', res=400)
  
  
  ##creating a word cloud####
  output$wc <- renderPlot({
    wordcloud(myCorpus, min.freq = input$freq,
              max.words=input$max, random.order=FALSE, rot.per=0.35, 
              colors=brewer.pal(8, "Dark2") )
  })
    
    
    
  
  
  #########Reviews over time#########
  
    
    rev <- read.csv("Reviews_date.csv")  #reading a csv file
    
    output$reviewplot <- renderPlotly({
      if (input$dt == "date"){         # based on input creating a subset of data
        top_rev <- rev %>%
          group_by(date) %>%
          summarise(number_of_reviews = n()) %>%
          arrange(desc(number_of_reviews))
        
        top_revs <- as.data.frame(top_rev)
        
        p <- ggplot(data = top_revs, aes(x=date, y=number_of_reviews, group = 2),ylab = "Total Reviews") + geom_line(col = 'red') # creating a plot
        q<- ggplotly(p) %>% layout(autosize = F, width = 750, height = 500)
        q
      }
      
      else if (input$dt == "month"){   # based on input creating a subset of data
        top_rev <- rev %>%
          group_by(month) %>%
          summarise(number_of_reviews = n()) %>%
          arrange(desc(number_of_reviews))
        
        top_revs <- as.data.frame(top_rev)
        
        x = c("January", "February", "March", "April", "May","June", "July", "August","September", "October", "November", "December") # creating factors to arrane the output ascending wise
        top_revs$month <- factor( top_revs$month, levels = x )
        
        p <- ggplot(data = top_revs, aes(x=month, y=number_of_reviews, group = 2),ylab = "Total Reviews") + geom_line(col = 'red') + geom_point()  # plotting a graph
        q<- ggplotly(p) %>% layout(autosize = F, width = 750, height = 500)
        q
      }
      
      else if (input$dt == "year"){    # based on input creating a subset of data
        top_rev <- rev %>%
          group_by(year) %>%
          summarise(number_of_reviews = n()) %>%
          arrange(desc(number_of_reviews))
        
        top_revs <- as.data.frame(top_rev)
        
        p <- ggplot(data = top_revs, aes(x=year, y=number_of_reviews, group = 2),ylab = "Total Reviews") + geom_line(col = 'red') + geom_point()  ###plotting a graph
        q<- ggplotly(p) %>% layout(autosize = F, width = 750, height = 500)
        q
      }
      
    })
  })

