separate_fixed <- function(data, col, into, sep, remove = TRUE, convert = FALSE) {
  dplyr::mutate(
    data,
    as.data.frame(data.table::tstrsplit(
      {{ col }},
      split = sep,
      fixed = TRUE,
      type.convert = convert,
      names = into
    )),
    .keep = if (remove) "unused" else "all"
  )
}
