create_org_pdf <- function(years, bins) {
  org <- epiextractr::load_org(years, month, orgwgt, statefips, wageotc) %>% 
    filter(wageotc > 0) %>% 
    mutate(
      wage_bin = ceiling(wageotc),
      # last bin will be > $20
      wage_bin = if_else(wage_bin >= 21, 21, wage_bin),
      state_abb = as.character(haven::as_factor(statefips))
    )
  
  min_bins <- read_csv(bins)
  
  org %>% 
    # merge state-specific mins
    inner_join(min_bins, by = "state_abb") %>% 
    mutate(wage_bin = if_else(wage_bin < minimum_bin, minimum_bin, wage_bin)) %>% 
    summarize(count = sum(orgwgt / 12), .by = c(state_abb, wage_bin)) %>% 
    arrange(state_abb, wage_bin) %>% 
    mutate(count = round(count / 1000) * 1000) %>% 
    mutate(cumulative_count = cumsum(count), .by = state_abb) %>% 
    mutate(
      count = scales::label_comma(1)(count),
      cumulative_count = scales::label_comma(1)(cumulative_count)
    ) %>% 
    filter(wage_bin != 21) %>% 
    mutate(wage_bin = if_else(
      wage_bin == min(wage_bin),
      paste0("$", wage_bin, ".00 and under"),
      paste0("$", wage_bin - 1, ".01 - $", wage_bin, ".00")
      ), .by = state_abb
    )
}


create_report_params <- function(df) {
  df %>% 
    count(state_abb) %>% 
    transmute(
      state_abb, 
      output_file = paste0("wagebins_", state_abb, "_", version, ".pdf")
    )
}