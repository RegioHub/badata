library(tidyverse)
source("data-raw/utils.R")

xlsx <- "data-raw/317_334605_ALO_OST_B_JD.xlsx"

read_sheet <- function(xlsx, sheet, data_col_names) {
  stopifnot(length(data_col_names) == 2)

  col_names <- readxl::read_xlsx(xlsx,
    sheet = sheet,
    col_names = FALSE,
    skip = 11,
    n_max = 2,
    .name_repair = "minimal"
  ) |>
    t() |>
    as_tibble(.name_repair = \(x) paste0("x", seq_along(x))) |>
    fill(x1) |>
    nest(rest = -x1) |>
    # Rename column prefixes:
    mutate(x1 = c("region", "occupational_group", data_col_names)) |>
    unnest(rest) |>
    pmap_chr(paste, sep = "__") |>
    sub(pattern = "__NA", replacement = "", fixed = TRUE)

  readxl::read_xlsx(xlsx,
    sheet = sheet,
    skip = 14,
    col_names = col_names,
    na = c("", "-", "x")
  ) |>
    slice_head(n = -1) |> # "© Statistik der Bundesagentur für Arbeit"
    fill(region) |>
    pivot_longer(-c(region, occupational_group), names_to = "x_year") |>
    separate_fixed(x_year, c("x", "year"), sep = "__", convert = TRUE) |>
    pivot_wider(names_from = x, values_from = value) |>
    filter(region != "Insgesamt" & occupational_group != "Insgesamt") |>
    mutate(across(c(region, occupational_group), \(x) str_extract(x, "^\\d+")))
}

unemployed_total <- read_sheet(xlsx, 2, c("total", "women"))

usethis::use_data(unemployed_total, overwrite = TRUE)

unemployed_foreigners <- read_sheet(xlsx, 3, c("total", "women"))

usethis::use_data(unemployed_foreigners, overwrite = TRUE)

jobs <- read_sheet(xlsx, 4, c("total", "social_insurance"))

usethis::use_data(jobs, overwrite = TRUE)
