library(purrr)

xlsx <- "data-raw/317-408036-ALO-OST-B-ZR.xlsx"
sheet <- 2

n_col <- ncol(readxl::read_xlsx(
  xlsx,
  sheet = sheet,
  skip = 15,
  col_names = FALSE,
  n_max = 1,
  .name_repair = "minimal"
))

codes_with_names <- readxl::read_xlsx(
  xlsx,
  sheet = sheet,
  skip = 15,
  col_names = c("regions", "occupational_groups"),
  col_types = c(rep_len("text", 2), rep_len("skip", n_col - 2))
) |>
  dplyr::slice_head(n = -1) |> # "Erstellungsdatum: ..." / "© Statistik der Bundesagentur für Arbeit"
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
