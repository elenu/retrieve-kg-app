## Safe helper to fetch Omnipath data. Avoid running on package/source time.
fetch_omnipath_data <- function(cache_dir = "omnipathr-cache",
																out_file = file.path("data", "omnipath_interactions_table.csv"),
																license = "academic",
																organism = 9606,
								force = FALSE) {
	# If output file already exists and user did not force, return it immediately
	if (!isTRUE(force) && file.exists(out_file)) {
		message("Data file already exists at: ", out_file, " — skipping download.")
		return(invisible(readr::read_csv(out_file, show_col_types = FALSE)))
	}

	if (!requireNamespace("OmnipathR", quietly = TRUE)) {
		message("OmnipathR is not installed. Install with: BiocManager::install('OmnipathR')")
		return(invisible(NULL))
	}

	# ensure cache dir exists and set option used by OmnipathR
	if (!dir.exists(cache_dir)) dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
	options(omnipath.cache = normalizePath(cache_dir))

	# prefer the newer API; import_all_interactions was deprecated
	if (exists("all_interactions", where = asNamespace("OmnipathR"), inherits = FALSE)) {
		df <- OmnipathR::all_interactions(license = license, organism = organism)
	} else {
		df <- OmnipathR::import_all_interactions(license = license, organism = organism)
	}

	# write out to data directory
	dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
	readr::write_csv(df, out_file)
	invisible(df)
}

# Only attempt download automatically when running interactively and data missing
if (interactive()) {
	data_file <- file.path("data", "omnipath_interactions_table.csv")
	if (!file.exists(data_file)) {
		tryCatch({
			fetch_omnipath_data()
		}, error = function(e) {
			message("Omnipath data fetch failed: ", conditionMessage(e))
		})
	}
}
