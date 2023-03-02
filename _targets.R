## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

version = "20230302"

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

  tar_file(state_minimum_bins_csv, "state_minimum_bins.csv"),
  org_results = create_org_pdf(2022, state_minimum_bins_csv),
  quarto_execute_params = create_report_params(org_results),
  
  tar_quarto_rep(
    report,
    path = "results.qmd",
    execute_params = quarto_execute_params
  )

)
