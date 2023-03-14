# Vesiclepedia-scraping-and-matching
#Project to scrape specific datasets from Vesiclepedia [in this case CRC cells data] to run my list of proteins against it

#Script #1: Scrape the datasets
# Requirement: Link to vesiclepedia with list of datasets 

# Load the necessary libraries
library(RSelenium)
library(rvest)
library(tidyverse)
library(stringr)
library(writexl)

# Start the Selenium server and open a browser window
rD <- rsDriver(browser = "firefox")
remDr <- rD$client

# Navigate to the main page
remDr$navigate("http://microvesicles.org/browse_results?org_name=&cont_type=&tissue=Colorectal%20cancer%20cells&gene_symbol=&ves_type=")

# Wait for the JavaScript to load
Sys.sleep(10)

# Extract the Vesiclepedia IDs
page_source <- remDr$getPageSource()[[1]]
ids <- str_extract_all(page_source, "Vesiclepedia_\\d{1,3}")[[1]]

# Loop through the IDs and extract the data from each page
data_list <- list()
for (i in 1:length(ids)) {
  # Construct the URL for the page
  url <- paste0("http://microvesicles.org/exp_summary?exp_id=", str_extract(ids[i], "\\d{1,3}"))
  
  # Navigate to the page
  remDr$navigate(url)
  
  # Wait for the JavaScript to load
  Sys.sleep(10)
  
  # Extract the data from the table
  table_html <- remDr$getPageSource()[[1]] %>%
    read_html() %>%
    html_table(fill = TRUE)
  
  # Check if table_html has at least three elements
  if (length(table_html) >= 3) {
    # Store the data in the list
    if (nrow(table_html[[3]]) > 1) {
      data_list[[i]] <- table_html[[3]]
    }
  } else {
    # If there is no third element, move on to the next iteration
    next
  }
}

# Stop the Selenium server
remDr$close()
rD$server$stop()

# Combine the data into a single data frame and write it to a file
final_data <- bind_rows(data_list)
# Write the data to an Excel file
write_xlsx(final_data, "microvesicles_data.xlsx")