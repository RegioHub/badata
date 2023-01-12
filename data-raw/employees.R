library(tidyverse)
source("data-raw/utils.R")

xlsx <- "data-raw/317_334605_SvB_GeB.xlsx"

read_sheet <- function(xlsx, sheet) {
  col_names <- readxl::read_xlsx(xlsx,
    sheet = sheet,
    col_names = FALSE,
    skip = 11,
    n_max = 3,
    .name_repair = "minimal"
  ) |>
    t() |>
    as_tibble(.name_repair = \(x) paste0("x", seq_along(x))) |>
    fill(x1, x2) |>
    mutate(
      x1 = case_when(
        x1 == "Region" ~ "region",
        x1 == "Tätigkeit nach KldB 2010" ~ "occupational_group",
        str_detect(x1, "^\\d{5}$") ~ x1 |>
          as.numeric() |>
          as.Date(origin = "1900-01-01") |>
          lubridate::year() |>
          as.character(),
        TRUE ~ x1
      ),
      x2 = case_when(
        x2 == "Sv-pflichtig Beschäftigte" ~ "social insurance",
        x2 == "Geringf. entlohnte Beschäftigte" ~ "marginal part-time",
        TRUE ~ x2
      ),
      x3 = case_when(
        x3 == "Insgesamt" ~ "total",
        x3 == "Ausländer" ~ "foreigners",
        x3 == "Frauen" ~ "women",
        TRUE ~ x3
      )
    ) |>
    pmap_chr(paste, sep = "__") |>
    gsub(pattern = "__NA", replacement = "", fixed = TRUE)

  readxl::read_xlsx(xlsx,
    sheet = sheet,
    skip = 15,
    col_names = col_names,
    na = c("", "-", "*")
  ) |>
    slice_head(n = -1) |> # "© Statistik der Bundesagentur für Arbeit"
    fill(region) |>
    pivot_longer(
      -c(region, occupational_group),
      names_to = "year_type_group",
      values_to = "n"
    ) |>
    separate_fixed(
      year_type_group,
      c("year", "type", "group"),
      sep = "__",
      convert = TRUE
    ) |>
    filter(region != "Insgesamt" & occupational_group != "Insgesamt") |>
    mutate(across(c(region, occupational_group), \(x) str_extract(x, "^\\d+"))) |>
    relocate(n, .after = everything())
}

employees_by_workplace <- read_sheet(xlsx, 2)

usethis::use_data(employees_by_workplace, overwrite = TRUE)

employees_by_residence <- read_sheet(xlsx, 3)

usethis::use_data(employees_by_residence, overwrite = TRUE)
