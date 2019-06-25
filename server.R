library(shinydashboard)
library(dplyr)
library(shiny)
library(ggplot2)
library(reticulate)
library(keras)
library(text2vec)
library(wordcloud)
library(tm)
library(RColorBrewer)
library(SnowballC)
setwd("D:\\Top Searches")
use_python("C:\\Users\\Kafeel Basha\\Anaconda2\\envs\\P35\\python.exe")
use_condaenv("C:\\Users\\Kafeel Basha\\Anaconda2\\envs\\P35\\r-tensorflow")
server <- shinyServer(function(input,output,session){
  
  # read file
  values <- reactive({read.csv(input$file$datapath,na.strings=c(" ","","  ","   "),stringsAsFactors = FALSE) })
  
  data<-reactive({
    dat<-values()
    
    model=load_model_hdf5("Key_words.h5",custom_objects = NULL,compile = TRUE)
    source("preprocess.R")
    load("df.RData") 
    load("D:\\Top Searches\\corp.Rdata")
    #Preparation
    pruned_vocab = prune_vocabulary(v,doc_proportion_max = 0.2,term_count_min = 1)
    vectorizer=vocab_vectorizer(pruned_vocab)
    tokenq=itoken(dat$text,preprocess_function=ls,tokenizer=word_tokenizer)
    #Document term matrix
    dtm=create_dtm(tokenq,vectorizer)
    #Prediction
    model%>%predict_classes(dtm)%>%as.integer()->y
    dat$y<-y
    dat=merge(dat,df,by="y",sort=FALSE)
    
    #Date conversion
    dat$date=as.Date(dat$date, format="%d-%m-%Y %H:%M")
    dat$duration=max(dat$date)-dat$date
    dat$duration=as.numeric(gsub(" days","",dat$duration))
    dat
    })
  
  # observeEvent for input$file
  observeEvent(input$file, {

    # render tables at file upload
    output$data.frame <- renderTable(data())
    
  })
  
  observeEvent(input$file, {
  # update selectInput Cluster tag
  updateSelectInput(
    session, 
    inputId = "cluster",
    choices=names(data()),    
    selected=names(data())[3]
  )
    
  updateSelectInput(
    session,
    inputId = "labels",
    choices = as.character(unique(data()[,"labels"])),
    selected = as.character(unique(data()[,"labels"]))[1]
    )
   
    
})
 
  

# observeEvent for input$Go
  observeEvent(input$Go, {
    d=data.frame(table(data()[,input$cluster]))
    d%>%arrange(-d[,2])->d
    
   output$box<-renderPlot({
    
     ggplot(d,aes(x=d[,1],y=d[,2],fill=d[,1]))+geom_bar(stat="identity")+geom_text(data=d,aes(label=d[,2]))+theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")+xlab("Clusters")+ylab("Frequency")+ggtitle("Distribution of Overall key searches")
     
   })
   
   
   output$monthly<-renderPlot({
     dm=data()
     dm%>%filter(duration<=31)%>%group_by(labels)%>%summarise(N=n())%>%as.data.frame->dm
     ggplot(dm,aes(x=labels,y=N,fill=dm[,1]))+geom_bar(stat="identity")+geom_text(data=dm,aes(label=N))+theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")+xlab("Clusters")+ylab("Frequency")+ggtitle("Distribution of Monthly(28-31) key searches")
     
     
   })
   
   output$ninety<-renderPlot({
     dn=data()
     dn%>%filter(duration<=92)%>%group_by(labels)%>%summarise(N=n())%>%as.data.frame->dn
     ggplot(dn,aes(x=labels,y=N,fill=dn[,1]))+geom_bar(stat="identity")+geom_text(data=dn,aes(label=N))+theme(axis.text.x = element_text(angle = 90, hjust = 1),legend.position="none")+xlab("Clusters")+ylab("Frequency")+ggtitle("Distribution of key searches in last 90 days")
     
     
   })
   
   output$cloud<-renderPlot({
     df<-data()
     df<-df[df$labels == input$labels,]
     df<-df[!df$text ==" ",]
     df<-df[!df$text=="",]
     dev.new(width=5,height=4)
     wordcloud(df$text,max.words =250,min.freq=1,colors=brewer.pal(8,"Dark2"),random.order=T, rot.per=.15)
   })
   
   
   
    
      
    })
    
    
    
  })