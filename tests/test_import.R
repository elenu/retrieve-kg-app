library(testthat)
library(readr)

test_that("App objects and data import work correctly", {
  app_file <- file.path("..", "app.R")
  expect_true(file.exists(app_file), info = "app.R not found in parent directory of tests/")

  # To ensure a small sample data file exists so tests don't trigger network downloads
  data_dir <- file.path("..", "data")
  data_file <- file.path(data_dir, "omnipath_interactions_table.csv")
  created_dummy <- FALSE
  if (!file.exists(data_file)) {
    dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
    sample_df <- data.frame(
      source_genesymbol = c("GENE_A", "GENE_B"),
      target_genesymbol = c("GENE_B", "GENE_C"),
      interaction_type = c("activation", "inhibition"),
      interaction_strength = c(0.8, -0.5),
      stringsAsFactors = FALSE
    )
    readr::write_csv(sample_df, data_file)
    created_dummy <- TRUE
  }

  # Here we read app.R and avoid launching the shiny app by stripping the final shiny::shinyApp(...) call
  lines <- readLines(app_file, warn = FALSE)
  app_launch_idx <- grep("shiny::shinyApp\\s*\\(", lines)
  if (length(app_launch_idx) > 0) {
    lines <- lines[1:(min(app_launch_idx) - 1)]
  }
  env <- new.env()
  eval(parse(text = paste(lines, collapse = "\n")), envir = env)

  # Clean up dummy file after sourcing app.R (if we created it)
  if (created_dummy) {
    try(unlink(data_file), silent = TRUE)
  }

  # To check important objects were created
  expect_true(exists("df", envir = env), info = "df not created by app.R")
  expect_true(exists("ui", envir = env), info = "ui not created by app.R")
  expect_true(exists("server", envir = env), info = "server not created by app.R")
  expect_true(exists("server_network_render", envir = env), info = "server_network_render not created by app.R")
  expect_true(exists("genes", envir = env), info = "genes not created by app.R")

  df <- get("df", envir = env)

  # Basic CSV/data checks
  expect_true(!is.null(df))
  expect_true(nrow(df) > 0, info = "df appears empty")
  expect_true("source_genesymbol" %in% colnames(df))
  expect_true("target_genesymbol" %in% colnames(df))

  # UI contains expected input ids (basic string presence check)
  ui_txt <- paste(capture.output(print(env$ui)), collapse = "\n")
  expect_true(grepl("source_gene", ui_txt), info = "source_gene input id missing in ui")
  expect_true(grepl("target_gene", ui_txt), info = "target_gene input id missing in ui")
  expect_true(grepl("build", ui_txt), info = "build button id missing in ui")
  expect_true(grepl("reset_view", ui_txt), info = "reset_view button id missing in ui")

  # server_network_render produces an htmlwidget (visNetwork) for a small subset
  server_network_render <- get("server_network_render", envir = env)
  eds <- head(df, 10)
  widget <- server_network_render(eds)
  expect_true(inherits(widget, "htmlwidget"), info = "server_network_render should return an htmlwidget (visNetwork)")
})