library(googlesheets)
library(dplyr)

#Evaluate all of the sheets that are stored in Google Sheets Drive
#Confirm that there is only one Mindfulness Sheet; if more than one use delete copies (not most up-to-date)
my_sheets <- gs_ls()
my_sheets

#Evaluate the Mindfulness Sheet
gs_ls("Mindfulness")

#Register the Sheet in order to Edit it 
sheet <- gs_title("Mindfulness")

#Ensure that the Sheet (even if already registered) is Up-to-Date 
sheet <- sheet %>% gs_gs()

#Browse the Most Recent Version of the GoogleSheet 
sheet %>% gs_browse()

#Data Sheet to Read the Sheet in Mindfulness called Data 
data_sheet <- sheet %>% gs_read(ws = "Data")
data_sheet



#********************************************************************************************************
#********************************************************************************************************
#********************************************************************************************************
#Create data for Google Sheet 1------ 
username <-c("User1", "User2", "User3", "User4", "User5", "User6", "User7", "User8")
password <-c("Password1", "Password2", "Password3", "Password4", "Password5", "Password6", "Password7", "Password8")

NumberAudioFilesAccesssed <-rep(NA,8)
NumberAudioFilesListenedTo90PercentCompletion <-rep(NA,8)

TotalUsed_WellWishes5Mins <-rep(NA,8)
TotalUsed_WellWishes10Mins <-rep(NA,8)

TotalUsed_SelfKindness5Mins <-rep(NA,8)
TotalUsed_SelfKindness10Mins <-rep(NA,8)

TotalUsed_JustBreathe5Mins <-rep(NA,8)
TotalUsed_JustBreathe10Mins <-rep(NA,8)

mindfulness_data<- data.frame(username,password,NumberAudioFilesAccesssed,NumberAudioFilesListenedTo90PercentCompletion,TotalUsed_WellWishes5Mins,
                              TotalUsed_WellWishes10Mins,TotalUsed_SelfKindness5Mins,TotalUsed_SelfKindness10Mins,TotalUsed_JustBreathe5Mins,TotalUsed_JustBreathe10Mins)
mindfulness_data
View(mindfulness_data)
#Create data for Google Sheet 2------ 


#Create a GoogleSheet------ 
mindfulness_sheet <- gs_new("Mindfulness_Draft", ws_title = "Identification", input = mindfulness_data, trim = TRUE, verbose = FALSE)
mindfulness_sheet %>% gs_read()

mindfulness_sheet2 <- gs_ws_new(mindfulness_sheet, ws_title = "Data", input = mindfulness_data, trim = TRUE, verbose = FALSE)
mindfulness_sheet2 %>% gs_read()

#Adding Columns
https://mashe.hawksey.info/2011/10/google-spreadsheets-as-a-database-insert-with-apps-script-form-postget-submit-method/
  
#GoogleSheet Code
https://github.com/jennybc/googlesheets#load-googlesheets












