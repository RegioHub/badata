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

parse_code_name <- function(x) {
  split <- strsplit(x, split = "(?<=\\d)\\s", perl = TRUE)
  has_code <- lengths(split) == 2
  dplyr::tibble(
    code = ifelse(has_code, map_chr(split, 1, .default = NA_character_), NA_character_),
    # Entries with no leading code (e.g. "ohne Angabe zum Zielberuf") keep
    # their full text as the name and get code = NA.
    name = ifelse(has_code, map_chr(split, 2, .default = NA_character_), x)
  )
}

region_occupation_codes <- codes_with_names |>
  map(parse_code_name)

region_codes <- region_occupation_codes$regions

usethis::use_data(region_codes, overwrite = TRUE)

occupational_group_codes <- region_occupation_codes$occupational_groups

usethis::use_data(occupational_group_codes, overwrite = TRUE)
