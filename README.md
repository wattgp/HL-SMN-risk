# SMN-risk

Risk of subsequent malignant neoplasms (SMNs) among Hodgkin lymphoma (HL)
survivors in the HL survivorship cohort, diagnosed 1989 or later.

Follow-up starts 5 years after HL diagnosis and ends at the first invasive
SMN, death, or last contact. Death is treated as a competing risk.
Secondary analyses look at first invasive breast cancer (women) and first
invasive prostate cancer (men).

## Open issues

- [ ] **Check follow-up time units.** Every `ftime_*` variable in
  `scripts/01_clean-data.R` is computed as
  `as.numeric(date_a - date_b)/86400/365.25`, which assumes the difference is
  in seconds. Subtracting two date-times in R normally returns a `difftime`
  in *days*, which would make follow-up times about 86,400 times too small.
  Check with `summary(dta2$ftime_cmpr_inv)`; if values are tiny, switch to
  `lubridate::time_length(date_a - date_b, "years")`.

## Repository layout

```
SMN-risk.qmd             report (Quarto -> Word); reads derived data only
scripts/
  00_paths.R             locations of raw and derived data on the secure drive
  01_clean-data.R        raw export -> derived datasets
  stata/                 earlier Stata cleaning/analysis code (reference only)
output/                  non-identifiable check files and outputs
renv.lock, renv/         pinned R package versions
SMN-risk.Rproj           RStudio project
```

## Data

Patient-level data are **never stored in this repository**. They live on the
secure drive and are located by `scripts/00_paths.R`:

| | Windows (MDW) | Mac |
|---|---|---|
| Secure root | `U://HL/SMN-risk/secure_data` | `/Volumes/g.watt/HL/SMN-risk/secure_data` |

- **Raw (read-only):** `secure_data/2024-12-12/ResearchDB_Export_from-Power-BI.csv`
- **Derived (written by the cleaning script):** `secure_data/derived/`
  - `smn_derived_full.rds`: all patients, with derived variables
  - `smn_analytic_cohort.rds`: analytic cohort (diagnosed 1989+, at risk at
    start of follow-up), with treatment and covariate recodes

`.gitignore` excludes common data formats (`.csv`, `.xl*`, `.dta`, `.rds`,
...). Check `git status` before committing anything new.

## Setup

Requires R 4.4.2 and Quarto.

```r
renv::restore()   # install the package versions in renv.lock
```

## Running the analysis

From the project root (open `SMN-risk.Rproj`):

1. Build the derived data (re-run whenever the raw export or a variable
   definition changes):
   ```r
   source("scripts/01_clean-data.R")
   ```
2. Render the report:
   ```sh
   quarto render SMN-risk.qmd
   ```
   This produces `SMN-risk.docx`.

When a new raw export arrives, put it in a new dated folder under
`secure_data/` and update `raw_file` in `scripts/00_paths.R`.

## Key definitions

- **Invasive SMN:** ICD-O behaviour code 3, 6 or 9.
- **Start of follow-up (`fup_start`):** HL diagnosis date + 5 years.
- **Competing-risk outcomes (`cmpr_*`):** 0 = censored, 1 = event,
  2 = death (competing risk). Matching times are in `ftime_cmpr_*`.
- **SMN site groups:** derived from ICD-O topography codes; see
  `*_sitename` in `scripts/01_clean-data.R`.
