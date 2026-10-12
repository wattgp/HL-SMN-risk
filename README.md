Date README last edited: 2026-10-07

# Watt-HL-SMN
*Risk of subsequent malignant neoplasms for >5-year survivors of Hodgkin Lymphoma in the Netherlands*

## People and permissions

Gordie Watt (rw)
Michael Schaapveld (r)
Beatriz Torrinha (r)

## Open issues

- [x] **Check follow-up time units** (fixed 2026-10-12). Follow-up times were
  computed as `as.numeric(date_a - date_b)/86400/365.25`, but date-time
  differences are in days, so they were about 86,400 times too small (and
  `ftime_breast`, divided by `365.25` only, was on a different scale). All
  follow-up times and `age_dx` now use
  `lubridate::time_length(date_a - date_b, "years")`.

## Project Description

### Purpose 
The last comprehensive update on SMN risk in the HL cohort was in 2015
(Schaapveld _et al. NEJM_ 2015). Since then, the cohort has continued to grow, 
including treatment date through 2013 and follow-up through 2022. 

The purpose of this study is to evaluate the risk of SMNs for a more contemporary 
set of survivors, treated from 1989-2013, with up to 28 years of follow-up.

Follow-up starts 5 years after HL diagnosis and ends at the first invasive SMN,
death, or last contact; death is a competing risk. The analytic cohort is
restricted to diagnosis in 1989 or later and age 15-50 at diagnosis (as in the
NEJM paper). Secondary analyses look at first invasive breast cancer (women)
and prostate cancer (men).

### Basic wayfinding

`renv` is used for managing dependencies. The lockfile `renv.lock` can be read in
when recreating this work to ensure that R version and package dependencies
are satisfied (`renv::restore()`).

`git` is used for version control. The primary repository is 
https://gitlab.rhpc.nki.nl/Epi-H8/hl-smn/watt-hl-smn; a copy is kept on GitHub
(https://github.com/wattgp/HL-SMN-risk). The main branch used by 
G. Watt during analysis is protected. Please create a new branch for further
analyses.

Remote set-up in G. Watt's working copy (collaborators cloning from GitLab
only need the usual `origin`):

```bash
git remote add gitlab https://gitlab.rhpc.nki.nl/Epi-H8/hl-smn/watt-hl-smn.git
git remote set-url --add --push origin https://github.com/wattgp/HL-SMN-risk.git
git remote set-url --add --push origin https://gitlab.rhpc.nki.nl/Epi-H8/hl-smn/watt-hl-smn.git
```

- `origin` fetches from GitHub but pushes to both GitHub and GitLab, so
  `git push origin <branch>` keeps the two copies in sync.
- `gitlab` points to GitLab only. Use it to pull GitLab changes:
  `git pull gitlab main`.
- Check the set-up with `git remote -v`.

The .gitignore file includes proprietary files (.docx) plus anything
that may include data (i.e. all delimited, binary, and .xslx files, and the
`secure_data/` folder).

This is an R project (Watt-HL-SMN.Rproj). Paths are built with `here::here()`
relative to the project root.

Data cleaning and analysis are split:

1. `scripts/01_clean-data.R` reads the raw export, cleans it, derives the
   outcome and follow-up variables, restricts to the analytic cohort and saves
   the results to `secure_data/intermediate/`. Re-run it whenever the raw
   export or a variable definition changes:
   `source(here::here("scripts", "01_clean-data.R"))`
2. `scripts/SMN-risk.qmd` is the main analysis file for the manuscripts. It
   reads the analytic cohort and makes the tables and figures:
   `quarto render scripts/SMN-risk.qmd`

There are a number of 'helper scripts' with miscellaneous 
functions or derivations that are saved separately alongside this file in the 
`/scripts` directory.

Output is saved in `output`. Anything that is included in the manuscripts 
should be findable here.

### Repository layout

```
Watt-HL-SMN.Rproj
scripts/
  01_clean-data.R                  raw export -> cleaned and derived datasets
  SMN-risk.qmd                     main analysis (tables, figures); reads derived data
  anthra_dose_Eline.R              anthracycline dose derivation (adapted from Eline)
  code-skeleton-anthra_...R        draft lookup-table approach to chemotherapy doses
  stata/                           2015 NEJM Stata cleaning/analysis code (reference only)
output/                            figures and tables for the manuscripts
secure_data/                       NOT in git: raw and intermediate data (see below)
renv.lock, renv/                   pinned R package versions
```

### Data

Patient-level data are never committed. They live in `secure_data/` in the
project root on the analysis server, which is excluded by `.gitignore`:

- `secure_data/2024-12-12/ResearchDB_Export_from-Power-BI.csv`: raw export (read-only)
- `secure_data/intermediate/`: derived data, all written by `scripts/01_clean-data.R`
  - `full_dataset_basic_cleaning.Rds`: after basic cleaning (missing-value
    codes set to `NA`, cleaned names)
  - `full_dataset_derived.Rds`: all patients, with dates, SMN outcomes and
    follow-up variables
  - `analytic_cohort.Rds`: analytic cohort (`dtaf`; diagnosed 1989+, age 15-50,
    at risk at start of follow-up), read by `SMN-risk.qmd`
- `secure_data/chem_drugs.xlsx`, `secure_data/*dosages for available treatments.xlsx`:
  chemotherapy lookup tables

Check `git status` before committing anything new.
