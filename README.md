# Vesiclepedia-scraping-and-matching
Project to scrape specific datasets from Vesiclepedia [in this case CRC cells data] to run my list of proteins against it

Script #1: Scrape the datasets
Requirement: Link to vesiclepedia with list of datasets 

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


Script #2: Run a list of proteins against the output from last script
Requirement: List of proteins of interest

# Load the necessary libraries
library(readxl)

# Read the data from the file
microvesicles_data <- read_excel("microvesicles_data.xlsx")

# Define the list of proteins to check
protein_list <- c("IZUMO1R", "FOLR4", "JUNO", "GFRA2", "GDNFRB", "RETL2", "TRNR2", "TNFRSF10C", "DCR1", "LIT", "TRAILR3", "TRID", "UNQ321/PRO366", "TREH", "TREA", "PSCA", "UNQ206/PRO232", "XPNPEP2", "EFNA2", "EPLG6", "LERK6", "GFRA3", "UNQ339/PRO538/PRO3664", "FCGR3B", "CD16B", "FCG3", "FCGR3", "IGFR3", "SEMA7A", "CD108", "SEMAL", "TECTA", "GPC4", "UNQ474/PRO937", "CNTN5", "LYPD3", "C4.4A", "UNQ491/PRO1007", "VNN1", "VNN2", "LY6G6C", "C6orf24", "G6C", "NG24", "UNQ1947/PRO4430", "LY6G6D", "C6orf23", "G6D", "MEGT1", "NG25", "CD160", "BY55", "RECK", "ST15", "PRNP", "ALTPRP", "PRIP", "PRP", "THY1", "ALPL", "ALPP", "PLAP", "CEACAM5", "CEA", "UMOD", "CD55", "CR", "DAF", "CD14", "MELTF", "MAP97", "MFI2", "CD48", "BCM1", "BLAST1", "ALPI", "CFC1", "LYNX1", "TFPI", "LACI", "TFPI1", "ALPG", "ALPPL", "ALPPL2", "TDGF1", "CRIPTO", "NCAM1", "NCAM", "CD59", "MIC11", "MIN1", "MIN2", "MIN3", "MSK21", "FOLR2", "CPM", "FOLR1", "FOLR", "DPEP1", "MDP", "RDP", "EFNA1", "EPLG1", "LERK1", "TNFAIP4", "NT5E", "NT5", "NTE", "ACHE", "CA4", "OMG", "OMGP", "CD24", "CD24A", "CNTFR", "CD52", "CDW52", "HE5", "CEACAM8", "CGM6", "GPC1", "SPAM1", "HYAL3", "PH20", "CEACAM6", "NCA", "GPC3", "OCI5", "EFNA3", "EFL2", "EPLG3", "LERK3", "EFNA4", "EPLG4", "LERK4", "EFNA5", "EPLG7", "LERK7", "ART1", "GP2", "CDH13", "CDHH", "GFRA1", "GDNFRA", "RETL1", "TRNR1", "GPC5", "CNTN2", "AXT", "TAG1", "TAX1","PLAUR", "MO3", "UPAR", "BST1", "BST2", "CNTN1", "HYAL2", "LUCA2", "MSLN", "MPF", "LSAMP", "IGLON3", "LAMP", "ART3", "TMART", "CEACAM7", "CGM2", "LY6D", "E48", "OPCML", "IGLON1", "OBCAM", "LY6E", "9804", "RIGE", "SCA2", "TSA1", "RAET1L", "ULBP6", "RAET1G", "ULBP5", "RGMB", "PRSS55", "TSP1", "UNQ9391/PRO34284", "LYPD5", "UNQ1908/PRO4356", "ENPP6", "UNQ1889/PRO4334", "CD109", "CPAMD7", "HJV", "HFE2", "RGMC", "OTOA", "NEGR1", "IGLON4", "UNQ2433/PRO4993", "RTN4RL1", "NGRH2", "NGRL2", "RTN4RL2", "NGRH1", "NGRL3", "LYPD6", "UNQ3023/PRO9821", "GPIHBP1", "HBP1", "CPO", "CNTN4", "GPC2", "LYPD1", "Lynx2", "LYPDC1", "PSEC0181", "UNQ3079/PRO9917", "CD177", "NB1", "PRV1", "UNQ595/PRO1181", "MDGA1", "MAMDC3", "ITLN1", "INTL", "ITLN", "LFR", "UNQ640/PRO1270", "SMPDL3B", "ASML3B", "ASMLPD", "ART4", "DO", "DOK1", "RGMA", "RGM", "NTNG2", "KIAA1857", "LMNT2", "UNQ9381/PRO34206", "BCAN", "BEHAB", "CSPG7", "UNQ2525/PRO6018", "TEX101", "SGRG", "UNQ867/PRO1884", "ULBP3", "N2DL3", "RAET1N", "ULBP2", "N2DL2", "RAET1H", "UNQ463/PRO791", "ULBP1", "N2DL1", "RAET1I", "RTN4R", "NOGOR", "UNQ330/PRO526", "GFRA4", "DPEP2", "UNQ284/PRO323", "MMP25", "MMP20", "MMPL1", "MT6MMP", "NTM", "IGLON2", "NT", "UNQ297/PRO337", "CNTN3", "KIAA1496", "PANG", "PRND", "DPL", "UNQ1830/PRO3443", "MMP17", "MT4MMP", "CNTN6", "NTNG1", "KIAA0976", "LMNT1", "UNQ571/PRO1133", "GPC6", "UNQ369/PRO705", "PRSS21", "ESP1","GAS1", "LY6K", "CO16", "GLIPR1L1", "UNQ2972/PRO7434", "PRSS41", "TESSP1", "MDGA2", "MAMDC1", "UNQ8188/PRO23197", "PRSS42P", "PRSS42", "TESSP2", "LYPD6B", "SPACA4", "SAMP14", "UNQ3046/PRO9862", "TECTB", "DPEP3", "UNQ834/PRO1772", "NRN1L", "UNQ2446/PRO5725", "SPRN", "SHO", "PLET1", "C11orf34", "LYPD4", "UNQ2552/PRO6181", "LYPD8", "UNQ511/PRO1026", "LYPD2", "LYPDC2", "UNQ430/PRO788", "IGSF21", "GML", "LY6DL", "NRN1", "NRN", "LY6L", "LY6S")

# Check for matches in the microvesicles_data file
matched_proteins <- unique(microvesicles_data$X3[microvesicles_data$X3 %in% protein_list])

# Write the matched proteins to a new file
write_xlsx(data.frame(matched_proteins), "matched_proteins2.xlsx")
