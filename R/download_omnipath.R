if (!requireNamespace("BiocManager", quietly = TRUE)) install.packages("BiocManager")
if (!requireNamespace("OmnipathR", quietly = TRUE)) install.packages("OmnipathR")

library(OmnipathR)
options(omnipath.cache = "./Your_directory/")

acad_interactions <- import_all_interactions(license = "academic", organism = 9606)
write_csv(acad_interactions, file = "./data/omnipath_interactions_table.csv")
