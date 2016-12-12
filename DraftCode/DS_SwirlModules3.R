# Swirl Modules
# Date: 10/5/15

#************************************  Fix R-Profile  ************************************ 
install.packages("devtools")
install.packages("swirl")
library(devtools)
library(swirl)
devtools::install_github("muschellij2/swirl", ref = "dev")

homedir = path.expand("~")
cat(paste0("Your home directory is \n ",homedir))

rp = file.path(homedir,".Rprofile")
has_rp = file.exists(rp)
if(!has_rp){
  file.create(rp)
}
cat(paste0("Your r-profile is located: ",rp))

options(
  swirl_data_dir = "~/Desktop/DataScience/swirl_classes",
  swirl_user = "ssalter2"
)

getOption("swirl_data_dir")
getOption("swirl_user")

uninstall_course("advdatasci_swirl") 
install_course_github("jtleek","advdatasci_swirl")
swirl()

#************************************ 1st module: loading data  ************************************

#Go to the second option--->download all the dependency packages needed

#Flat File
# a. csv
# b. txt
# c. tsv

#Create a directory to download & store the data we will be working with; let it be called data --- put it in current working directory
getwd()
remove(dir.create("~/Desktop/DataScience/data"))
?dir.create
dir.create("data")

#Verify that the file exists in my directory
list.files(".")

#Load "downloader" package to load the dataset
library(downloader)

#Assign the file url to the variable "file_url"--- data is of speed cameras in Baltimore
file_url = "https://data.baltimorecity.gov/Transportation/Baltimore-Fixed-Speed-Cameras/dz54-2aru/"
browseURL(file_url)

#Load lubridate package to record dates easily
library(lubridate)

#Record the time & date (since we are downloading a file from the internet) and want to ensure reproducibility 
date_downloaded <- now()

#Try downloading the data. Use the download command. Pass the URL & a destination file. 
#Save file to file.path
download(file_url,destfile=file.path("data","cameras.csv"))

#The website has the data table embedded n the html.
#We can read the first few lines downloaded to verify this.
#Use the command readLines to scan the file and read the text into a vector, element per line.
#Then assign this variable to the name cameras.
#Read the file from the "data" directory using file.path("data", "cameras.csv")
#NOTE: readLines must read a file 
cameras <- readLines(file.path("data", "cameras.csv"))
head(cameras)

#Need API to get at the actual csv file
#This requires that we use a different URL
#So, use a different URL: http://dl.dropboxusercontent.com/s/jy6xq7htk25j8su/cameras.csv?dl=0
#Assign this value to the variable, file_url
file_url <- "http://dl.dropboxusercontent.com/s/jy6xq7htk25j8su/cameras.csv?dl=0"

#Try downloading the data again.
#Use the download command; Note--- this will take a while.
download(file_url,destfile=file.path("data","cameras.csv"))

#Read the data into R using read.csv
cameras <- read.csv(file.path("data", "cameras.csv"))
library(readr) #this is faster than the base
cameras_readr <- read_csv(file.path("data","cameras.csv"))
#Fact: readr is faster than base
#Benefits of readr:  But it does a couple of things that are useful. 
                   # One is that it automatically stores all text fields as characters, not as factors. 
                   # Later when we are doing text processing this will be important. To see this use the 
                   # "str" command on the "cameras_readr" variable.

#Comparisons
str(cameras_readr)

#Now look at cameras using the str function
str(cameras)

#For huge text files the fastest way to get them into memory in R is using the "data.table" package. 
#Load that package now.
#You can use the fread command to load the data set in and assign it to the variable "cameras_fread"
install.packages("data.table")
library(data.table)
cameras_fread <- fread(file.path("data","cameras.csv"))

#This object is now a data.table object which works a little differently than we are used to. For example try looking
#at the first column of cameras_fread using the command cameras_fread[,1]
cameras_fread[,1]
#[1] 1

#This command doesn't show you a whole column with a data.table object. To use these objects you need to
#learn an entirely different syntax. I showed you this approach in case you need the fastest way to load
#data into R, but then you'd need to learn the data.table package syntax. Most data sets can be handled with
#read_csv.

#Evaluate the "readxl" package
library(readxl)
file_url <- "http://dl.dropboxusercontent.com/s/jxyvwvp7k8n8p0v/genomes.xlsx?dl=0"
download( "http://dl.dropboxusercontent.com/s/jxyvwvp7k8n8p0v/genomes.xlsx?dl=0", file.path("data","genomes.xlsx"))

#Record the data & time
genomes_download_date <- now()

#Open the excel file and look at it. You can see that it has multiple "sheets" and the data is formatted differently in each sheet.
#Use read_exceo or readxl command in the readxl package

#Use the data from the 5th sheet on final QC
#Pass the file path and the sheet number to read_excel
#This can also be done by sheet name (however, using the number is typically easier)
#Assign the result to the variable "final_qc"

#Create a new variable 
final_qc <- read_excel(file.path("data","genomes.xlsx"),sheet=5)
str(final_qc)

#Notice: the top line is causig problems with reading the sheet
#We can skup this line by using the parameter skip & specifying how many lines to skip
final_qc <- read_excel(file.path("data","genomes.xlsx"),sheet=5,skip=1)
str(final_qc)



#************************************ 2nd module: Grouping and Chaining with dplyr ************************************
#Background Information:  In the last lesson, you learned about the five main data manipulation 'verbs' in 
                          # dplyr: select(), filter(), arrange(), mutate(), and summarize(). The last of these, 
                          # summarize(), is most powerful when applied to grouped data.

#Grouping Data: The main idea behind grouping data is that you want to break up your dataset into 
                # groups of rows based on the values of one or more variables. The group_by() function 
                # is reponsible for doing this.

library(dplyr)
cran <- tbl_df(mydf)
rm("mydf")
cran


#Our first goal is to group the data by package name. Bring up the help file for group_by()
?group_by

#Group cran by the package variable and store the result in a new object called by_package.
group_by(cran, package)
by_package <- group_by(cran, package)

#Print by_package to the console
by_package

#Note: At the top of the output above, you'll see 'Groups: package', which tells us that this tbl 
     # has been grouped by the package variable. Everything else looks the same, but now any operation 
     # we apply to the grouped data will take place on a per package basis.

#Recall: when we applied mean(size) to the original tbl_df via summarize(), it returned a single number -- the
        # mean of all values in the size column. We may care about what that number is, but wouldn't it be so 
        # much more interesting to look at the mean download size for each unique package?
        # That's exactly what you'll get if you use summarize() to apply mean(size) to the grouped data in by_package.

#Use summarize() to apply mean(size) to the grouped data in by_package.
#Shows: the mean download size for each unique package
summarize(by_package, mean(size))
#Note: this does not return a single value--- summarize() now returns the mean size for EACH package in our dataset

#The R script called 'summarize1.R' is a partially constructed call to summarize()
#When you are ready to move on, save the script and type submit()
#Or type reset() to reset the script to its original state

#****************************************************************************************
#SCRIPT-- summarize1
#****************************************************************************************
# Compute four values, in the following order, from
# the grouped data:
#
# 1. count = n()
# 2. unique = n_distinct(ip_id)
# 3. countries = n_distinct(country)
# 4. avg_bytes = mean(size)
#
# A few thing to be careful of:
#
# 1. Separate arguments by commas
# 2. Make sure you have a closing parenthesis
# 3. Check your spelling!
# 4. Store the result in pack_sum (for 'package summary')
#
# You should also take a look at ?n and ?n_distinct, so
# that you really understand what is going on.

pack_sum <- summarize(by_package,
                      count = n(),
                      unique = n_distinct(ip_id) ,
                      countries = n_distinct(country),
                      avg_bytes = mean(size))
#****************************************************************************************
#****************************************************************************************

#Evaluate the script---
#Substitute the values defined in the comments and replace them in the code--- then enter submit() in the console 
submit()

#Print the resulting table, called pack_sum, to the console to examine its contents
pack_sum

n()
n_distinct(ip_id)
n_distinct(country)
mean(size)

#count = n() : contains the total number of rows (i.e. downloads) for each package
#unique = n_distinct(ip_id) : gives the total number of unique downloads for each package-- 
                            # as measured by the number of distinct ip_id's
#countries = n_distinct(country) : provides the number of countries in which each package was downloaded
#avg_bytes = mean(size) : contains the mean download size (in bytes) for each pacakge


#IMPORTANT: it's important that you understand how each column of pack_sum was created and 
          # what it means. Now that we've summarized the data by individual packages, let's 
          # play around with it some more to see what we can learn.


#NEXT: we'd like to know which packages were most popular on the day these data were collected (July 8, 2014). 
     # Let's start by isolating the top 1% of packages, based on the total number of downloads as
     # measured by the 'count' column.

     # We need to know the value of 'count' that splits the data into the top 1% and bottom 99% of 
     # packages based on total downloads. In statistics, this is called the 0.99, or 99%, sample quantile.
     # Use quantile(pack_sum$count, probs = 0.99) to determine this number.
quantile(pack_sum$count, probs = 0.99) 

#NOW: we can isolate only those packages which had more than 679 total downloads. 
    # Use filter() to select all rows from pack_sum for which 'count' is strictly greater (>) than 679. 
    # Store the result in a new object called top_counts.
top_counts <- filter(pack_sum,count>679)
top_counts

#There are only 61 packages in our top 1%, so we'd like to see all of them. 
#Since dplyr only shows us the first 10 rows, we can use the View() function to see more
View(top_counts)

#arrange() the rows of top_counts based on the 'count' column
#Assign the result to a new object called top_counts_sorted
#Goal: We want the packages with the highest number of downloads at the top
#This means we want 'count' to be in descending order
top_counts_sorted <- arrange(top_counts, desc(count))

#Arrange(): arrange(top_counts, desc(count)) will arrange the rows of top_counts 
            # based on the values of the 'count'variable, in descending order

View(top_counts_sorted)
#If we use total number of downloads as our metric for popularity, then the above output 
#shows us the most popular packages downloaded from the RStudio CRAN mirror on July 8, 2014. 
#Not surprisingly, ggplot2 leads the pack with 4602 downloads, followed by Rcpp, plyr, rJava,...

#UNIQUE: Perhaps we're more interested in the number of *unique* downloads on this particular day.
#In other words, if a package is downloaded ten times in one day from the same computer, we may 
#wish to count that as only one download. That's what the 'unique' column will tell us.

#QUANTILE FIND" find the .99 quantile for the unique variable 
quantile(pack_sum$unique, probs = 0.99)
#99%
#465

#Apply filter() to pack_sum: select all rows corresponding to values of 'unique' that are strictly
#greater than 465.  Assign the result to a object called top_unique.
top_unique <- filter(pack_sum , unique > 465)

#NEXT: look at the top contenders
View(top_unique)

#Arrange top_unique by the 'unique' column (in descending order)
#This will allow you to see which packages were downloaded from the greatest number of unique IP addresses
top_unique_sorted <-arrange(top_unique, desc(unique))
View(top_unique_sorted)


#****************************************************************************************
#SCRIPT summarize2
#****************************************************************************************
# Don't change any of the code below. Just type submit()
# when you think you understand it.

# We've already done this part, but we're repeating it
# here for clarity.

by_package <- group_by(cran, package)
pack_sum <- summarize(by_package,
                      count = n(),
                      unique = n_distinct(ip_id),
                      countries = n_distinct(country),
                      avg_bytes = mean(size))

# Here's the new bit, but using the same approach we've
# been using this whole time.

top_countries <- filter(pack_sum, countries > 60)
result1 <- arrange(top_countries, desc(countries), avg_bytes)

# Print the results to the console.
print(result1)
#****************************************************************************************
#****************************************************************************************

#CHAINING aka PIPING
#Chaining: allows you to string together multiple function calls in a way that is compact and readable,
         # while still accomplishing the desired result.

#Compute: last popularity metric from scratch, starting with our original data
#***** USE SCRIPT: 'summarize2.r'******* to complete
#This script can be left as is--- then hit submit

#SORTED PRIMARILY: It's worth noting that we sorted primarily by country, 
#But used avg_bytes (in ascending order) as a tie breaker 
#This means that if two packages were downloaded from the same number of countries, the package
#with a smaller average download size received a higher ranking.


#****************************************************************************************
#SUBMIT-- summarize3
#****************************************************************************************
#Goal:  accomplish same result as the last script, but avoid saving our intermediate results.
#Required: embed function calls within one another
#This is what was done in Script2-- result is equivalent but the code is not as readable
#Also the functions are far away from one another--- the new script SCRIPT 3 has a better solution
#Do Not Run This--- this is code that belongs to a script
result2 <-
  arrange(
    filter(
      summarize(
        group_by(cran,
                 package
        ),
        count = n(),
        unique = n_distinct(ip_id),
        countries = n_distinct(country),
        avg_bytes = mean(size)
      ),
      countries > 60
    ),
    desc(countries),
    avg_bytes
  )

print(result2)

#Essentially the script is good as is--- it just needs to be submitted
submit()
#****************************************************************************************
#****************************************************************************************


#****************************************************************************************
#SCRIPT 4
#****************************************************************************************
#Here there is a special chaining operator, %>%, used.
#The benefit of %>% is that it allows us to chain the function calls in a linear fashion. 
#The code to the right of %>% operates on the result from the code to the left of %>%

#Do Not Run--- This is code that belongs to a script
result3 <-
  cran %>%
  group_by(package) %>%
  summarize(count = n(),
            unique = n_distinct(ip_id),
            countries = n_distinct(country),
            avg_bytes = mean(size)
  ) %>%
  filter(countries > 60) %>%
  arrange(desc(countries), avg_bytes)

# Print result to console
print(result3)
#****************************************************************************************
#****************************************************************************************
submit()

#FACT**************** SCRIPTS WERE IDENTICAL
#Results of the last three scripts are all identical. 
#BUTTTT....The third script provides a convenient and concise alternative to the more traditional method
#that we've taken previously, which involves saving results as we go along.
View(result3)


#****************************************************************************************
#CHAIN 1
#****************************************************************************************
#CHAINING
#Build a chain of dplyr commands one step at a time
#Use Script Chain1.R

cran %>%
  select(
    ip_id,
    country,
    package,
    size
  ) %>%
  print
#****************************************************************************************
#****************************************************************************************

#****************************************************************************************
#CHAIN 2
#****************************************************************************************
#Second chain
# Use mutate() to add a column called size_mb that contains
# the size of each download in megabytes (i.e. size / 2^20).
#
# If you want your results printed to the console, add
# print to the end of your chain.

cran %>%
  select(ip_id, country, package, size)%>%
  mutate(size_mb = size/2^20)
#****************************************************************************************
#****************************************************************************************

#****************************************************************************************
#CHAIN 3
#****************************************************************************************
 # Use filter() to select all rows for which size_mb is
# less than or equal to (<=) 0.5.
#
# If you want your results printed to the console, add
# print to the end of your chain.
  
cran %>%
select(ip_id, country, package, size) %>%
mutate(size_mb = size / 2^20) %>%
# Your call to filter() goes here
filter(size_mb <= 0.5)
#****************************************************************************************
#****************************************************************************************

#****************************************************************************************
#CHAIN 4
#****************************************************************************************
# Chain 4
# arrange() the result by size_mb, in descending order.
#
# If you want your results printed to the console, add
# print to the end of your chain.

cran %>%
  select(ip_id, country, package, size) %>%
  mutate(size_mb = size / 2^20) %>%
  filter(size_mb <= 0.5) %>%
  # Your call to arrange() goes here
  arrange(desc(size_mb))


#In this lesson, you learned about grouping and chaining using dplyr. You combined
#some of the things you learned in the previous lesson with these more advanced ideas
#to produce concise, readable, and highly effective code. Welcome to the wonderful
#world of dplyr!
#****************************************************************************************
#****************************************************************************************


#************************************  3rd: Google Sheets  ************************************ 
#Keep in mind that if you are repeating this you need to go back into google drive and delete the spreadsheets that
#have been created---- if this is not done there will be all kinds of errors that will prevent the code.
library(googlesheets)

#We also need to load the dplyr package, from which we use the %>% pipe operator,
#among other things. googlesheets usage does not require you to use %>% though it was
#certainly designed to be pipe-friendly. This vignette uses pipes but you will find
#that all the examples in the help files use base R only.
library(dplyr)

#List your Google Sheets The gs_ls() function returns a data frame of the sheets you
#would see in your Google Sheets home screen.
#"https://docs.google.com/spreadsheets/." include sheets that you own 
#and may also show sheets owned by others but that you are permitted to access, 
#if you have visited the sheet in the browser. 
my_sheets <- gs_ls()

#Note: we are prompted to enter the following URL and use the access code it gives us to enter in the console so that we can proceed
#Get a Google Sheet to practice with Don’t worry if you don’t have any suitable
#Google Sheets lying around! The author published a sheet for you to practice with
#and have built functions into googlesheets to help you access it. The example sheet
#holds some of the Gapminder data. Feel free to visit the Sheet in the browser.
#"https://w3id.org/people/jennybc/googlesheets_gap_url"

#The code below will put a copy of this sheet into your Drive titled, Gapminder
gap <- gs_gap() %>% gs_copy(to = "Gapminder")
#Go check for a sheet named “Gapminder” in your Google Sheets home screen.
#"https://docs.google.com/spreadsheets/" You can also call gs_ls() again to see if
#the Gapminder sheet appears. Give it a regular expression to narrow the listing
#down, if you like.
gs_ls("Gapminder")


#You might see two sheets named Gapminder in your home screen, this is a bug caused
#by the swirl package, so you need to run gs_delete(gap) to delete one of them.
gs_delete(gap)

#Register a Sheet If you plan to consume data from a sheet or edit it, you must first
#register it. This is how googlesheets records important info about the sheet that is
#required downstream by the Google Sheets or Google Drive APIs. Once registered, you
#can print the result to get some basic info about the sheet.

gap <- gs_title("Gapminder")
gap

#Worried that a spreadsheet's registration is out-of-date? You can re-register it by:
gap <- gap %>% gs_gs()

#The registration functions gs_title(), and gs_gs() return a registered sheet as a
#googlesheet object, which is the first argument to practically every function in
#this package. Likewise, almost every function returns a freshly registered
#googlesheet object, ready to be stored or piped into the next command.
gap %>% gs_browse()
#Note: this code will bring you directly to the googlesheet


#Inspect a Sheet Once you’ve registered a Sheet, you can print it to get an overview
#of, e.g., its worksheets, their names, and dimensions. In addition, you can use
#gs_ws_ls() to get worksheet names as a character vector.
oceania <- gap %>% gs_read(ws = "Oceania")
oceania

#Read only certain cells You can target specific cells via the range argument. The
#simplest usage is to specify an Excel-like cell range, such as range = “D12:F15” or
#range = “R1C12:R6C15”. The cell rectangle can be specified in various other ways,
#using helper functions. It can be degenerate, i.e. open-ended.

#Let's see the worksheep 2 with range "A1:D8".
gap %>% gs_read(ws = 2, range = "A1:D8")

#Let's see the worksheep "Europe" with range cell_rows(1:4).
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))

#Let's see the worksheep "Asia" with range cell_limits(c(1, 4), c(5, NA)).
gap %>% gs_read(ws = "Asia", range = cell_limits(c(1, 4), c(5, NA)))

#Create a new Google sheet by boring_ss <- gs_new("boring", ws_title = "iris-gs_new",
#                                                 | input = head(iris), trim = TRUE, verbose = FALSE)
boring_ss <- gs_new("boring", ws_title = "iris-gs_new", input = head(iris), trim = TRUE, verbose = FALSE)
boring_ss %>% gs_read()

#Note how we store the returned value from gs_new() (and all other sheet editing functions).
#That’s because the registration info changes whenever we edit the sheet and we re-register it
#inside these functions, so this idiom will help you make sequential edits and queries to the
#same sheet. You can copy an entire Sheet with gs_copy() and rename one with gs_rename().

#Use gs_ws_new() to add some mtcars data as a second worksheet to boring_ss. 
boring_ss <- boring_ss %>% gs_ws_new(ws_title = "mtcars-gs_ws_new", input = head(mtcars), trim = TRUE,verbose = FALSE)

#Access this new worksheet by gs_read() with ws = 2.
boring_ss %>% gs_read(ws=2)

#We use gs_ws_delete() and gs_ws_rename() to delete the mtcars worksheet and rename the iris worksheets, respectively.
#Let's delete the second worksheet in boring_ss and rename the remaining worksheet to "iris". Note that these functions can be piped together.
boring_ss <- boring_ss %>% gs_ws_delete(ws = 2) %>% gs_ws_rename(to = "iris")

#Edit cells There are two ways to edit cells within an existing worksheet of an existing spreadsheet. - gs_edit_cells()
#can write into an arbitrary cell rectangle - gs_add_row() can add a new row to the bottom of an existing cell
#rectangle

#The previous two functions are both slow and you’re better off using gs_upload() to create a new sheet from a local
#file. We'll get to that later. Of the two, gs_add_row() is faster, but it can only be used when your data occupies a
#very neat rectangle in the upper left corner of the sheet.
#USE gs_upload() instead.... 

#Create a new sheet called foo
foo <- gs_new("foo") %>% gs_ws_rename(from = "Sheet1", to = "edit_cells") %>% gs_ws_new("add_row")

#OUTPUT FROM CREATING FOO
#Sheet "foo" created in Google Drive.
#Worksheet dimensions: 1000 x 26.
#Accessing worksheet titled 'Sheet1'.
#Sheet successfully identified: "foo"
#Worksheet "Sheet1" renamed to "edit_cells".
#Worksheet "add_row" added to sheet "foo".
#Worksheet dimensions: 1000 x 26.
#Warning message: At least one sheet matching "foo" already exists, so you may need to identify by key, not title, in future. 

#Use gs_edit_cells() to add the first six rows of iris data, e.g. use head(iris), into the blank sheet, edit_cells.
#Remember to trim the worksheet extent.
foo <- foo %>% gs_edit_cells(ws = "edit_cells", input = head(iris), trim = TRUE)

#Use gs_edit_cells() to initialize sheet, add_row, with column headers and the first row of data. 
#Remember to trim your sheet.
foo <- foo %>% gs_edit_cells(ws = "add_row", input = head(iris, 1), trim = TRUE)

#Add the second row of data using gs_add_row() to the worksheet add_row
foo <- foo %>% gs_add_row(ws = "add_row", input = iris[2, ])

#gs_add_row() will actually handle multiple rows at once, 
#try adding the last six rows of the iris data, e.g. use tail(iris)
foo <- foo %>% gs_add_row(ws="add_row", input=tail(iris))

#Let's inspect our work, e.g. the edit_cells worksheet, using gs_read()
foo %>% gs_read(ws="edit_cells")

#Let's inspect our work, the add_row worksheet, using gs_read()
foo %>% gs_read(ws = "add_row")

# Go to your Google Sheets home screen, find the new sheet foo and admire it.
# You should see some iris data in the worksheets named edit_cells and add_row.
# You could also use gs_browse() to take you directly to those worksheets.

# Protip - If your edit populates the sheet with everything it should have, set
# trim = TRUE and we will resize the sheet to match the data. Then the nominal
# worksheet extent is much more informative (vs. the default of 1000 rows and
# 26 columns) and future consumption via the cell feed will potentially be faster.
gs_delete(foo)

#Success. "foo" moved to trash in Google Drive.
#If you’d rather specify sheets for deletion by title, look at gs_grepdel()
#and gs_vecdel(). These functions also allow the deletion of multiple sheets
#at once.

#Make new Sheets from local delimited files or Excel workbooks Use gs_upload()
#to create a new Sheet de novo from a suitable local file. First, we’ll write
#then upload a comma-delimited excerpt from the iris data. Try the following
#command. iris %>% head(5) %>% write.csv("iris.csv", row.names = FALSE)
iris %>% head(5) %>% write.csv("iris.csv", row.names = FALSE)

#You can use gs_upload() to upload a multi-sheet Excel workbook as well.
#Download Sheets as csv, pdf, or xlsx file Use gs_download() to download a
#Google Sheet as a csv, pdf, or xlsx file. Downloading the spreadsheet as a
#csv file will export the first worksheet (default) unless another worksheet
#is specified.

#Now use gs_upload() to create a new Sheet from file iris.csv. Assign it to a variable named iris_ss.
#You can use gs_upload() to upload a multi-sheet Excel workbook as well.
iris_ss <- gs_upload("iris.csv")

#Let's register the work sheet "Gapminder" by its title and download its
#"Africa" worksheet and save the file as "gapminder-africa.csv".
gs_title("Gapminder") %>% gs_download(ws="Africa", to="gapminder-africa.csv")

#Or you can download the entire spreadsheet as an Excel workbook. Let's call
#it "gapminder.xlsx".
gs_title("Gapminder")%>%gs_download(to="gapminder.xlsx")


#************************************  4th: Timesheet  ************************************ 

#In this lesson, we'll explore the lubridate R package, by Garrett Grolemund and
#Hadley Wickham. According to the package authors, "lubridate has a consistent,
#memorable syntax, that makes working with dates fun instead of frustrating." If
#you've ever worked with dates in R, that statement probably has your attention.

#Unfortunately, due to different date and time representations, this lesson is only
#guaranteed to work with an "en_US.UTF-8" locale. To view your locale, type
#Sys.getlocale("LC_TIME").
Sys.getlocale("LC_TIME")

#If the output above is not "en_US.UTF-8", this lesson is not guaranteed to work
#correctly. Of course, you are welcome to try it anyway. We apologize for this
#inconvenience.

#lubridate was automatically installed (if necessary) and loaded upon starting this
#lesson. To build the habit, we'll go ahead and (re)load the package now. Type
#library(lubridate) to do so.
library(lubridate)

#lubridate contains many useful functions. We'll only be covering the basics here.
#Type help(package = lubridate) to bring up an overview of the package, including
#the package DESCRIPTION, a list of available functions, and a link to the official
#package vignette.
help(package = lubridate)

#The today() function returns today's date. Give it a try, storing the result in a
#new variable called this_day.
this_day <-today()
this_day

#There are three components to this date. In order, they are year, month, and day.
#We can extract any of these components using the year(), month(), or day()
#function, respectively. Try any of those on this_day now.
month(this_day)
#[1] 10

#We can also get the day of the week from this_day using the wday() function. It
#will be represented as a number, such that 1 = Sunday, 2 = Monday, 3 = Tuesday,
#etc. Give it a shot.
wday(this_day)

#Now try the same thing again, except this time add a second argument, label =
#TRUE, to display the *name* of the weekday (represented as an ordered factor).
wday(this_day, label=TRUE)
#[1] Wed
#Levels: Sun < Mon < Tues < Wed < Thurs < Fri < Sat


#In addition to handling dates, lubridate is great for working with date and time
#combinations, referred to as date-times. The now() function returns the date-time
#representing this exact moment in time. Give it a try and store the result in a
#variable called this_moment.
this_moment <- now()
this_moment
#[1] "2016-10-12 14:25:17 EDT"

#Just like with dates, we can extract the year, month, day, or day of week.
#However, we can also use hour(), minute(), and second() to extract specific time
#information. Try any of these three new functions now to extract one piece of time
#information from this_moment.

second(this_moment)
#[1] 17.89876

#today() and now() provide neatly formatted date-time information. When working
#with dates and times 'in the wild', this won't always (and perhaps rarely will) be
#the case.

#Fortunately, lubridate offers a variety of functions for parsing date-times. These
#functions take the form of ymd(), dmy(), hms(), ymd_hms(), etc., where each letter
#in the name of the function stands for the location of years (y), months (m), days
#(d), hours (h), minutes (m), and/or seconds (s) in the date-time being read in.

#To see how these functions work, try ymd("1989-05-17"). You must surround the date
#with quotes. Store the result in a variable called my_date.
my_date <- ymd("1989-05-17")

#It looks almost the same, except for the addition of a time zone, which we'll
#discuss later in the lesson. Below the surface, there's another important change
#that takes place when lubridate parses a date. Type class(my_date) to see what
#that is.

class(my_date)
#So ymd() took a character string as input and returned an object of class POSIXct.
#It's not necessary that you understand what POSIXct is, but just know that it is
#one way that R stores date-time information internally.

#"1989-05-17" is a fairly standard format, but lubridate is 'smart' enough to
#figure out many different date-time formats. Use ymd() to parse "1989 May 17".
#Don't forget to put quotes around the date!
ymd("1989 May 17")
#[1] "1989-05-17"

#Despite being formatted differently, the last two dates had the year first, then
#the month, then the day. Hence, we used ymd() to parse them. What do you think the
#appropriate function is for parsing "March 12, 1975"? Give it a try.
mdy("March 12 1975")
#[1] "1975-03-12"


#We can even throw something funky at it and lubridate will often know the right
#thing to do. Parse 25081985, which is supposed to represent the 25th day of August
#1985. Note that we are actually parsing a numeric value here -- not a character
#string -- so leave off the quotes.
dmy(25081985)
#[1] "1985-08-25"

#But be careful, it's not magic. Try ymd("192012") to see what happens when we give
#it something more ambiguous. Surround the number with quotes again, just to be
#consistent with the way most dates are represented (as character strings).
ymd("192012")
#[1] NA

#You got a warning message because it was unclear what date you wanted. When in
#doubt, it's best to be more explicit. Repeat the same command, but add two dashes
#OR two forward slashes to "192012" so that it's clear we want January 2, 1920.
ymd("1920-1-2")

#In addition to dates, we can parse date-times. I've created a date-time object
#called dt1. Take a look at it now.
dt1
#[1] "2014-08-23 17:23:02"

#Now parse dt1 with ymd_hms()
ymd_hms(dt1)
#[1] "2014-08-23 17:23:02 UTC"

#What if we have a time, but no date? Use the appropriate lubridate function to
#parse "03:22:14" (hh:mm:ss).
hms("03:22:14")
#[1] "3H 22M 14S"

#lubridate is also capable of handling vectors of dates, which is particularly
#helpful when you need to parse an entire column of data. I've created a vector of
#dates called dt2. View its contents now.
dt2
#[1] "2014-05-14" "2014-09-22" "2014-07-11"

#Now parse dt2 using the appropriate lubridate function.
ymd(dt2)
#[1] "2014-05-14" "2014-09-22" "2014-07-11"

#The update() function allows us to update one or more components of a date-time.
#For example, let's say the current time is 08:34:55 (hh:mm:ss). Update this_moment
#to the new time using the following command: update(this_moment, hours = 8, minutes = 34, seconds = 55).
update(this_moment, hours = 8, minutes = 34, seconds = 55)
#[1] "2016-10-12 08:34:55 EDT"

#It's important to recognize that the previous command does not alter this_moment
#unless we reassign the result to this_moment. To see this, print the contents of
#this_moment.
this_moment
#[1] "2016-10-12 14:25:17 EDT"

#Unless you're a superhero, some time has passed since you first created
#this_moment. Use update() to make it match the current time, specifying at least
#hours and minutes. Assign the result to this_moment, so that this_moment will
#contain the new time.
this_moment <- update(this_moment, hours = 10, minutes = 16, seconds = 0)

#Take one more look at this_moment to see that it's been updated.
this_moment

#Now, pretend you are in New York City and you are planning to visit a friend in
#Hong Kong. You seem to have misplaced your itinerary, but you know that your
#flight departs New York at 17:34 (5:34pm) the day after tomorrow. You also know
#that your flight is scheduled to arrive in Hong Kong exactly 15 hours and 50
#minutes after departure.

#Let's reconstruct your itinerary from what you can remember, starting with the
#full date and time of your departure. We will approach this by finding the current
#date in New York, adding 2 full days, then setting the time to 17:34.

#To find the current date in New York, we'll use the now() function again. This
#time, however, we'll specify the time zone that we want: "America/New_York". Store
#the result in a variable called nyc. Check out ?now if you need help.

nyc <- now(tzone="America/New_York")

#For a complete list of valid time zones for use with lubridate, check out the following Wikipedia page:
#http://en.wikipedia.org/wiki/List_of_tz_database_time_zones
#View the contents of nyc, which now contains the current date and time in New York.
nyc
#[1] "2016-10-12 15:06:00 EDT"

#Your flight is the day after tomorrow (in New York time), so we want to add two days to nyc. One nice aspect of lubridate is
#that it allows you to use arithmetic operators on dates and times. In this case, we'd like to add two days to nyc, so we can
#use the following expression: nyc + days(2). Give it a try, storing the result in a variable called depart.

depart <- nyc + days(2)
depart
#[1] "2016-10-14 15:06:00 EDT"

#So now depart contains the date of the day after tomorrow. Use update() to add the correct hours (17) and minutes (34) to
#depart. Reassign the result to depart.
depart<-update(depart, hours = 17, minutes = 34)
depart

#Your friend wants to know what time she should pick you up from the airport in Hong Kong. Now that we have the exact date
#and time of your departure from New York, we can figure out the exact time of your arrival in Hong Kong.

#The first step is to add 15 hours and 50 minutes to your departure time. Recall that nyc + days(2) added two days to the
#current time in New York. Use the same approach to add 15 hours and 50 minutes to the date-time stored in depart. Store the
#result in a new variable called arrive.
arrive <- depart + hours(15) + minutes(50)

#The arrive variable contains the time that it will be in New York when you arrive in Hong Kong. What we really
#want to know is what time it will be in Hong Kong when you arrive, so that your friend knows when to meet you.

#The with_tz() function returns a date-time as it would appear in another time zone. Use ?with_tz to check out
#the documentation.
?with_tz

#Use with_tz() to convert arrive to the "Asia/Hong_Kong" time zone. Reassign the result to arrive, so that it
#will get the new value.
arrive <- with_tz(arrive,tzone="Asia/Hong_Kong")
#Print the value of arrive to the console, so that you can tell your friend what time to pick you up from the airport.
arrive
#[1] "2016-10-15 21:24:00 HKT"

#Fast forward to your arrival in Hong Kong. You and your friend have just met at the airport and you realize
#that the last time you were together was in Singapore on June 17, 2008. Naturally, you'd like to know exactly
#how long it has been.

#Use the appropriate lubridate function to parse "June 17, 2008", just like you did near the beginning of this
#lesson. This time, however, you should specify an extra argument, tz = "Singapore". Store the result in a
#variable called last_time.
last_time <- mdy("June 17, 2008", tz = "Singapore") 
last_time

#Pull up the documentation for interval(), which we'll use to explore how much time has passed between arrive
# | and last_time.
?interval 

#Create an interval() that spans from last_time to arrive. Store it in a new variable called how_long.
how_long <- interval(start=last_time, end=arrive)

#Now use as.period(how_long) to see how long it's been.
as.period(how_long)
#[1] "8y 3m 28d 21H 24M 0.724064111709595S"

#This is where things get a little tricky. Because of things like leap years, leap seconds, and daylight
#savings time, the length of any given minute, day, month, week, or year is relative to when it occurs. In
#contrast, the length of a second is always the same, regardless of when it occurs.

#To address these complexities, the authors of lubridate introduce four classes of time related objects:
#instants, intervals, durations, and periods. These topics are beyond the scope of this lesson, but you can
#find a complete discussion in the 2011 Journal of Statistical Software paper titled 'Dates and Times Made Easy
#with lubridate'.

#This concludes our introduction to working with dates and times in lubridate. I created a little timer that
#started running in the background when you began this lesson. Type stopwatch() to see how long you've been
#working!
stopwatch()
#[1] "1H 44M 49.7007150650024S"


