# badata

Data package: BA (Bundesagentur für Arbeit) regional job market
statistics by district (Kreis) and occupational group (KldB 2010). Pure
data package, no exported functions (`NAMESPACE` only lists the roxygen
boilerplate) — everything happens once in `data-raw/*.R` and ships as
`data/*.rda`.

## Where the raw data comes from

Not an open download. Each delivery is a paid, bespoke
“Sonderauswertung” from BA-Statistik-Service-West
(<statistik-service-west@arbeitsagentur.de>), tied to a specific order
number (e.g. `317-408036`) referenced in both the delivered filenames
and the email subject line. Requesting an update means emailing that
address, referencing the previous order number so they replicate the
same Kreis × KldB-2010 × year breakdown, not finding a public portal
download.

Two BA products per delivery: - `*_ALO_OST_B_*` / `*-ALO-OST-B-*` →
unemployed (`Arbeitslose`) + jobs (`Arbeitsstellen`) → feeds
`unemployed_total`, `unemployed_foreigners`, `jobs` - `*_SvB_GeB*` /
`*-SvB-GeB-*` → employees subject to social insurance (SvB) + marginally
employed (GeB) → feeds `employees_by_workplace` (AO/Arbeitsort),
`employees_by_residence` (WO/Wohnort)

Source `.xlsx` files are gitignored (`data-raw/*.xlsx`) and never
committed — only the parsed `.rda` output is.

## Standing gotcha: BA changes the export format between deliveries without notice

**The trap (2026-07-30 update, order 334605 → 408036).** Rerunning the
existing `data-raw/*.R` scripts unmodified against a new BA delivery
produced silently wrong data in three different ways, not an error. BA’s
export format is not a stable contract across delivery cycles. Before
trusting a rerun against new files, diff the raw header structure (row
offsets, exact label text, sheet count/names) against what the current
scripts assume — do not assume “same BA product name” means “same
layout.”

Concretely hit this round: - **Row offset shift.** The
`unemployed`/`jobs` file’s header block moved down by exactly one row
between deliveries (an extra line inserted somewhere in the preamble).
Silent until you check exact `skip=`/row content — no error, just wrong
columns read as headers. - **Abbreviated → full label text.**
`"Sv-pflichtig Beschäftigte"` →
`"Sozialversicherungspflichtig Beschäftigte"`,
`"Tätigkeit nach KldB 2010"` → `"Ausgeübte Tätigkeit nach KldB 2010"`.
Any `case_when(x == "old label", ...)` match silently falls through to
`TRUE ~ x` instead of erroring, so this corrupts data quietly rather
than crashing. - **Header cells that used to be blank now contain
literal filler text.** The new employees file writes the literal word
`"darunter"` into every foreigners/women sub-column instead of leaving
it blank, which broke `fill()`-based label propagation and collided both
employment types’ foreigners/women columns into identical names. The new
unemployed/jobs file does the opposite: the “total” sub-column’s header
is blank where the old file wrote `"Insgesamt"` literally, so
`x == "Insgesamt"` stopped matching and the group was dropped instead of
set to `"total"`. - **File bundling changed.** Employees data moved from
one file with two sheets (workplace/residence) to two separate files,
one sheet each.

**Standing instruction.** When new BA files land in `data-raw/`, before
re-running anything: `readxl::excel_sheets()` each file, dump the raw
header rows (`col_names = FALSE`, no skip) for each relevant sheet, and
diff that against the current script’s assumed `skip=`/label strings.
Treat every `case_when`/exact-string match in the parsing code as a
thing that can silently break, not just the row offsets.

## Known pre-existing data quirks (not bugs, don’t “fix” without a deliberate decision)

- `occupational_group_codes` / `region_codes` won’t perfectly 1:1 match
  every BA product’s occupational_group/region values — some categories
  are catch-alls with no numeric KldB code
  (e.g. `"ohne Angabe zum Zielberuf"`). As of 0.2.0 these get
  `code = NA` with the real name preserved (so `left_join()` on
  `code`/`occupational_group` works via NA-matching), rather than the
  code accidentally duplicating into the name column.
- Historical years get **retroactively restated** to current
  administrative boundaries whenever BA/BKG changes Kreis boundaries
  (their “Gebietsstand” convention). A region code’s historical value
  can *change* between package versions with no error — e.g. Hanau split
  off from Main-Kinzig-Kreis as its own `Kreisfreie Stadt` (06415) in
  the 0.2.0 delivery, retroactively applied back to 2016. This is BA
  doing the right thing (comparable boundaries across years), not a
  defect, but it does mean `06435`’s 2016 value differs between badata
  0.1.x and 0.2.0. Check `NEWS.md` before assuming a rerun should
  reproduce old values exactly.
- BA’s own disclaimer (“Datenrevisionen können zu Abweichungen …
  führen”) means a small fraction (seen: ~0.3-1.5%) of overlapping-year
  values will legitimately differ release to release. Don’t chase 100%
  reproduction of old values as a correctness bar; anti-join on keys
  (not a naive full outer join on value columns) to separate “row
  genuinely absent” from “value merely changed.”

## Mapping / geodata

No shapefile ships with the package (it’s Kreis-code tabular data only).
To map, join `region_codes$code` (or any table’s
`region`/`occupational_group` column) against BKG’s official VG250 Kreis
boundaries
(`daten.gdz.bkg.bund.de/produkte/vg/vg250_ebenen_0101/aktuell/...`,
`VG250_KRS` layer, join key `AGS`) — same AGS/Kreis-code system BA uses,
so it joins cleanly without name-matching. GADM’s German boundaries
(used elsewhere in this workspace, e.g. `RegioPress/data/geo/gadm/`) use
`NAME_2`, not AGS codes, and are not guaranteed current on recent Kreis
boundary changes (Hanau) — prefer VG250 for this package specifically.

## CI: “Update CITATION.cff” workflow is broken (org policy, not the workflow itself)

`.github/workflows/update-citation-cff.yaml` runs `cff_write()`
correctly but its `git push` step fails with a 403
(`Permission ... denied to github-actions[bot]`), silently swallowed by
the workflow’s own `git push || echo "No changes to commit"`, so the job
still reports success. Root cause: RegioHub org-level Actions policy has
“Workflow permissions” set to read-only, overriding any repo-level
setting. Fixing it needs an org owner to change it at
`github.com/organizations/RegioHub/settings/actions` (or via
`gh api -X PUT orgs/RegioHub/actions/permissions/workflow`, which needs
the `admin:org` OAuth scope —
`gh auth refresh -h github.com -s admin:org` and complete the
device-code browser flow). Until that’s fixed, regenerate `CITATION.cff`
manually after any `DESCRIPTION`/`inst/CITATION` change:
`conda run -n rstats Rscript -e 'library(cffr); cff_write(keys = list())'`,
then commit it as a normal commit (that push works fine, it’s only the
bot’s default token that’s restricted).

## Environment

R env: conda env `rstats` (`/home/researcher/miniconda3/envs/rstats`),
not `base`. Needs `pandoc` on `PATH` for `devtools::build_readme()` —
invoke via `conda run -n rstats Rscript ...`, not `rstats/bin/Rscript`
directly by full path (that skips env activation, so `PATH` won’t
include the env’s `pandoc`).
