#*****************************
#Run Second Portion of the Code
#*****************************
library(googlesheets)

table <- "mindfullness"

saveData <- function(data) {
# Grab the Google Sheet
  sheet <- gs_title(table)
# Add the data as a new row
  gs_add_row(sheet, input = data)
}

loadData <- function() {
  # Grab the Google Sheet
  sheet <- gs_title(table)
  # Read the data
  gs_read_csv(sheet)
}
