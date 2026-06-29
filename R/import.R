library(readr)
library(dplyr)

# Function to import the omnipath interactions data
import_omnipath_data <- function(file_path) {
  data <- read_csv(file_path)
  return(data)
}

# Load the data
omnipath_data <- import_omnipath_data("data/omnipath_interactions_table.csv")

# Function to get unique gene symbols
get_unique_genes <- function(data) {
  unique_genes <- unique(c(data$source_genesymbol, data$target_genesymbol))
  return(unique_genes)
}

# Get the list of unique gene symbols
unique_genes_list <- get_unique_genes(omnipath_data)