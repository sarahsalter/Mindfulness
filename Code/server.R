library(shiny)
library(datasets)
Logged = FALSE;
PASSWORD <- data.frame(Name = "USER", Password = "25d55ad283aa400af464c76d713c07ad")
# Define server logic required to summarize and view the selected dataset
shinyServer(function(input, output) {
  source("www/Login.R",  local = TRUE)
  
  observe({
    if (USER$Logged == TRUE) {
      output$obs <- renderUI({
        
        
        # Added the original UI R-Script here--- renderUI allows the login to be displayed first
        # Then after login the audio files are displayed 
        fluidPage(
          useShinyjs(),
          # Application title
          titlePanel("Be mindful"),
          
          # Sidebar with a slider input for number of bins
          navlistPanel(
            tabPanel("Well Wishes",
                     mainPanel("Well Wishes Audio Recordings", 
                               fluidRow(
                                 tags$audio(id = "Audio1", src = "well_wish_5.mp3", 
                                            type = "audio/mp3", 
                                            controls = F,
                                            onplaying = "playCounter()"
                                 )
                               ), # add js
                               
                               fluidRow(
                                 tags$audio(src = "well_wish_10.mp3", 
                                            type = "audio/mp3", 
                                            controls = T,
                                            onplaying = "pauseCounter()")))
            ),
            
            
            tabPanel("Self Kindness",
                     mainPanel("Self Kindness Audio Recordings", 
                               fluidRow(
                                 tags$audio(src = "self_kindness_5.mp3", 
                                            type = "audio/mp3", 
                                            controls = T,
                                            onended = "endCounter()")
                               ), # add js
                               fluidRow(
                                 tags$audio(src = "self_kindness_10.mp3", 
                                            type = "audio/mp3", 
                                            controls = T)
                               )
                     )
            ),
            
            tabPanel("Just Breathe and Be",
                     mainPanel("Breathe & Be Audio Recordings", 
                               fluidRow(
                                 tags$audio(src = "NICU_5_mins_Just_breathe_and_be.mp3", 
                                            type = "audio/mp3", 
                                            controls = T,
                                            onended="rscripts/record.R")
                               ), # add js
                               fluidRow(
                                 tags$audio(src = "NICU_10mins_Just_breathe_and_be.mp3", 
                                            type = "audio/mp3", 
                                            controls = T)
                               )
                     )
            ),
            
            tabPanel("Arriving",
                     mainPanel("Arriving Audio Recordings", 
                               fluidRow(
                                 tags$audio(src = "NICU_Arriving_5min.mp3", 
                                            type = "audio/mp3", 
                                            controls = T,
                                            onended="rscripts/record.R")
                               ), # add js
                               fluidRow(
                                 tags$audio(src = "NICU_Arriving_10mins.mp3", 
                                            type = "audio/mp3", 
                                            controls = T)
                               )
                     )
            )
            
            
          )
          
          #Removed the code that was here---- Not sure what it was for 
          )
        
        
      })

      
      
    }
  })
})
