
library("shiny")
library("shinyjs")
library("readr")
library("dplyr")
library("googlesheets")
library("lubridate")
library("datasets")

# CODE FROM ss

# ENCRYPTION INFORMATION

Logged = FALSE;
PASSWORD <- data.frame(Name = c("Bob","Matt","Sarah","John","Nattyboh","Johnnyhops","bob"), 
                       Password = c("2fc1c0beb992cd7096975cfebf9d5c3b",  # Bob
                                    "7c1f90bd9bdc70cc059640a7a6209389",  # Matt
                                    "28e5481a80aa2bd18c8cf35d0495980a",  # Sarah
                                    "61409aa1fd47d4a5332de23cbf59a36f",  # John
                                    "25d55ad283aa400af464c76d713c07ad",  # 12345678 
                                    "1de6647f72fe23f908e815385dd6a28a",  # Hopkins
                                    "9f9d51bc70ef21ca5c14f307980a29d8")) # bob
# Define server logic required to summarize and view the selected dataset


# need a better way to authenticate google sheets.

data <- gs_title("mindfullness")

## mc BELOW functions dealing with javascript


write_date <- function(user, file, action, date, h, m, s){
  # attempt to store data to a google sheet. 
  
  new_data <- c(user, file, action, date, h, m, s)
  
  data %>%
    gs_add_row(ws = 1, new_data)
}     


shinyServer(function(input, output, session) {
  ## ss below
  source("rscripts/Login.R",  local = TRUE)
  
  ## mc below
  ## ss edited: sourcing the Login.R script grab the username entered into the Login widget 
  output$results = renderPrint({
    as.data.frame(input$plays_r, input$userName)
  })
  
  
  
  
  observeEvent(input$plays_r, {
    write_date(user = input$userName[1], file = input$plays_r[1], 
               action = "play", date = as.character(today()),
               h = hour(ymd_hms(now())), m = minute(ymd_hms(now())),
               s = second(ymd_hms(now())))
  })
  observeEvent(input$pause_r, {
    write_date(user = input$userName[1] , file = input$pause_r[1], 
               action = "pause", date = as.character(today()),
               h = hour(ymd_hms(now())), m = minute(ymd_hms(now())),
               s = second(ymd_hms(now())))
  })
  
  # ss below
  
  observe({
    if (USER$Logged == TRUE) {
      output$obs <- renderUI({ page })
    }
  })
}) 



