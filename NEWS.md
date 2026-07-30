# badata 0.2.0

* New data delivery from BA (Auftragsnummer 408036) extends coverage:
  `employees_by_workplace`/`employees_by_residence` now span 2013-2025
  (previously 2016-2021), and `jobs`/`unemployed_total`/
  `unemployed_foreigners` now span 2012-2025 (previously 2012-2021).

* Fixed two parsing bugs surfaced by a change in BA's export format:

  - the "darunter" (foreigners/women) sub-columns were colliding into
    identical names across the two employee types, silently dropping
    the foreigners/women breakdown for one of them
  - the un-labeled "total" sub-column was being dropped entirely
    instead of set to `"total"` in the `group` column of
    `employees_by_workplace`/`employees_by_residence`

* Fixed a pre-existing bug, present since the original release, where
  `region_occupation_codes.R` picked up the source sheet's trailing
  metadata line ("Erstellungsdatum: ...") as a bogus entry in
  `region_codes`.

* Fixed `occupational_group_codes`'s "ohne Angabe zum Zielberuf"
  catch-all category, which previously had the same string duplicated
  into both `code` and `name`. It now has `code = NA` and the correct
  `name`, so a `left_join()` against the `NA` occupational_group values
  in the main tables now attaches the label correctly.

* Hanau split off from Main-Kinzig-Kreis as an independent city (region
  code `06415`), retroactively restated across all historical years per
  BA's "Gebietsstand Juli 2026" convention. Anyone comparing region
  `06435` figures against pre-0.2.0 data will see a level shift, since
  it now excludes Hanau's share.

* 4 military occupational codes (`011`-`014`, e.g. "Offiziere") are no
  longer reported in the employees export and are absent from
  `employees_by_workplace`/`employees_by_residence` from this release
  on.

* Remaining differences in overlapping years (roughly 0.3-1.5% of
  matched cells) reflect BA's own disclosed data-revision policy, not a
  parsing issue.

* Konstantin Wandel joins as a package author.
