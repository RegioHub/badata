library(purrr)

codes_with_names <- readxl::read_xlsx(
  "data-raw/317_334605_ALO_OST_B_JD.xlsx",
  sheet = 2,
  skip = 14,
  col_names = c("regions", "occupational_groups"),
  col_types = c(rep_len("text", 2), rep_len("skip", 20))
) |>
  as.list() |>
  map(discard, .p = \(x) is.na(x) || x == "Insgesamt") |>
  map(unique)

region_occupation_codes <- codes_with_names |>
  map(strsplit, split = "(?<=\\d)\\s", perl = TRUE) |>
  map(do.call, what = rbind) |>
  map(`colnames<-`, value = c("code", "name")) |>
  map(dplyr::as_tibble)

region_codes <- region_occupation_codes$regions

usethis::use_data(region_codes, overwrite = TRUE)

occupational_group_codes <- region_occupation_codes$occupational_groups

usethis::use_data(occupational_group_codes, overwrite = TRUE)
