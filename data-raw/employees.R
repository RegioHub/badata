library(tidyverse)
source("data-raw/utils.R")

xlsx_by_workplace <- "data-raw/317-408036-SvB-GeB-AO-KldB10.xlsx"
xlsx_by_residence <- "data-raw/317-408036-SvB-GeB-WO-KldB10.xlsx"

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
    mutate(x2 = na_if(x2, "darunter")) |>
    fill(x1, x2) |>
    mutate(
      x1 = case_when(
        x1 == "Region" ~ "region",
        x1 == "Ausgeübte Tätigkeit nach KldB 2010" ~ "occupational_group",
        str_detect(x1, "^\\d{5}$") ~ x1 |>
          as.numeric() |>
          as.Date(origin = "1900-01-01") |>
          lubridate::year() |>
          as.character(),
        TRUE ~ x1
      ),
      x2 = case_when(
        x2 == "Sozialversicherungspflichtig Beschäftigte" ~ "social insurance",
        x2 == "Geringfügig entlohnte Beschäftigte" ~ "marginal part-time",
        TRUE ~ x2
      ),
      x3 = case_when(
        x3 == "Insgesamt" ~ "total",
        x3 == "Ausländer" ~ "foreigners",
        x3 == "Frauen" ~ "women",
        # The un-labeled/master sub-column (no "darunter" marker) implicitly
        # means "total"; it's blank in the header rather than "Insgesamt".
        is.na(x3) & !is.na(x2) ~ "total",
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

employees_by_workplace <- read_sheet(xlsx_by_workplace, 2)

usethis::use_data(employees_by_workplace, overwrite = TRUE)

employees_by_residence <- read_sheet(xlsx_by_residence, 2)

usethis::use_data(employees_by_residence, overwrite = TRUE)
