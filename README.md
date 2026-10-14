Date README last edited: 2026-10-14

# Watt-HL-SMN
*Risk of subsequent malignant neoplasms for >5-year survivors of Hodgkin Lymphoma in the Netherlands*

## People and permissions

Gordie Watt (rw)
Michael Schaapveld (r)
Beatriz Torrinha (r)

## Open issues

- [ ] **RT field-to-organ mapping and SMN body-region mapping are drafts.** They need
  approval by Berthe before any RT results are reported. See
  `docs/proposal_exposure-definitions.md` (section 1), `scripts/03_rt-exposure.R`
  (section 4) and `scripts/01_clean-data.R` (section 6).
- [ ] **Age groups for the descriptive table**: scenarios are printed by
  `01_clean-data.R`; choice pending.
- [ ] **Analysis stage** (descriptive table, cumulative incidence, models,
  figures): not started. `scripts/SMN-risk.qmd` uses the old variable names
  and will be rewritten.
- [x] **SMN site groups approved** (2026-10-14). All groups are kept in the data
  and in a comprehensive SMN table. Sites with **>= 10 invasive SMNs** get their
  own plots and models (`min_cases_plot`, `min_cases_model` in `00_config.R`;
  changed from the SAP's > 20 / >= 50).
- [x] **Check follow-up time units** (fixed 2026-10-12). All follow-up times
  and `age_dx` now use `lubridate` year lengths.
- [x] **Blanket missing-value recode removed** (2026-10-14). The old cleaning
  set 99/777/888/999 to `NA` in every numeric column, which wiped out real
  codes (e.g. regimen 99, "other chemotherapy" 777). Each variable is now
  recoded from the codebook.
- [x] **"Moved abroad" was coded as dead** in the old cleaning script (fixed
  2026-10-14: censored at the emigration date).

## Project Description

### Purpose
The last comprehensive update on SMN risk in the HL cohort was in 2015
(Schaapveld _et al. NEJM_ 2015). Since then, the cohort has continued to grow,
including treatment date through 2013 and follow-up through 2022.

The purpose of this study is to evaluate the risk of SMNs for a more contemporary
set of survivors, treated from 1989-2013, with up to 28 years of follow-up.
The audience is ISORED (radiation epidemiology and dosimetry), so the report
emphasises radiotherapy exposure.

The statistical analysis plan is `scripts/SAP_claude.txt`. In short:

- **Cohort:** HL diagnosed in 1989 or later, aged 15-50 at diagnosis, alive
  and under follow-up 5 years after diagnosis, with no invasive SMN before
  then.
- **Follow-up** starts 5 years after HL diagnosis and ends at the first
  invasive SMN, death (competing risk) or last contact. Times are kept on two
  scales: years since start of follow-up, and years since HL diagnosis (entry
  at 5 years).
- **Outcome:** invasive SMNs (behaviour 3). "Any SMN" excludes non-melanoma
  skin cancer and a second Hodgkin lymphoma; site-specific outcomes use the
  first SMN of that site.
- **Exposures:** organ-level RT exposure from field flags (0 none / 1
  bordering / 2 in field) and RT technique; cumulative doxorubicin and
  procarbazine dose. Treatment before the start of follow-up is fixed;
  later treatment is time-varying.

### How decisions are recorded

The SAP asks for every analysis decision to be agreed with the project leader
and documented in the code. Two places hold them:

1. **The decision log at the top of each script** (`C1`, `D1`, `R1`, ...),
   with the question, the answer and the date. Each decision tag is repeated
   at the line where it is applied.
2. **`docs/proposal_exposure-definitions.md`** (rendered as `.html`): the
   literature-based proposal for the exposure definitions, with a dated
   decision table and references. Re-render it after editing with
   `quarto render docs/proposal_exposure-definitions.md --to html -M embed-resources:true -M toc:true`.

### Basic wayfinding

`renv` is used for managing dependencies. The lockfile `renv.lock` can be read in
when recreating this work to ensure that R version and package dependencies
are satisfied (`renv::restore()`). The server runs R 4.4.3; `Deriv` is pinned
to 4.1.6 because newer versions need R 4.5. Quarto is at
`/usr/lib/rstudio-server/bin/quarto/bin/quarto` on the analysis server (not on
the default `PATH`).

`git` is used for version control. The primary repository is
https://gitlab.rhpc.nki.nl/Epi-H8/hl-smn/watt-hl-smn; a copy is kept on GitHub
(https://github.com/wattgp/HL-SMN-risk). The main branch used by
G. Watt during analysis is protected. Please create a new branch for further
analyses (current work: branch `sap-analysis`).

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

### Workflow

All code is developed and checked on a **synthetic dummy dataset**. One switch
in `scripts/00_config.R` decides which data every script uses:

```r
use_dummy <- TRUE   # synthetic data -> secure_data/intermediate/dummy/
use_dummy <- FALSE  # real export   -> secure_data/intermediate/
```

Only the project leader sets `use_dummy <- FALSE`, after reviewing the code.
Dummy and real derived files go to separate folders, so they cannot be mixed
up.

Run the scripts in order from the project root (each is self-contained and
reads the raw export itself, so 01-03 can run in any order, but the later
analysis needs all three):

| Step | Script | What it does | Main output (in `secure_data/intermediate[/dummy]/`) |
|---|---|---|---|
| 0 | `scripts/00_config.R` | Dummy/real switch, file paths, lookup files. Sourced by every script; not run alone. | – |
| 1 | `scripts/01_clean-data.R` | Recodes every variable from the codebook; mid-month dates; SMN table with behaviour, site group, NMSC flag and body region; any-SMN and site-specific competing-risk outcomes (with the date of any other SMN, for adjustment); analytic cohort and exclusion flow; age-group scenarios. | `patients_all.Rds`, `smn_long.Rds`, `analytic_cohort.Rds`, `outcome_site_long.Rds`, `exclusion_flow.Rds`, `age_group_scenarios.Rds` |
| 2 | `scripts/02_chemo-doses.R` | Regimen code x cycles -> cumulative doxorubicin dose, procarbazine dose (+ sensitivity S-CT98), doxorubicin-equivalent dose (sensitivity), yes/no variables, registry flags, plausibility review list. Per treatment course, with start dates. | `chemo_slots_long.Rds`, `chemo_doses_course.Rds`, `chemo_registry_flags.Rds`, `chemo_dose_review.Rds` |
| 3 | `scripts/03_rt-exposure.R` | RT field flags -> organ exposure (0/1/2) per SMN site, RT technique, mediastinal, pelvic, supra-/infradiaphragmatic RT; descriptive tables of recorded RT doses. Per course, with start dates. | `rt_fields_course.Rds`, `rt_organ_course.Rds`, `rt_dose_description.Rds` |
| 4 | *(to do)* exposure window | Joins 1-3: fixed exposure up to the start of follow-up, time-varying after; matches sarcoma/skin SMNs to RT fields by body region; applies the dose categories. | – |
| 5 | *(to do)* analysis | Descriptive table (gtsummary), cumulative incidence with death as competing risk, multivariable models, exploratory ML for breast cancer, figures. Replaces `SMN-risk.qmd`. | `output/` |

```r
source(here::here("scripts", "01_clean-data.R"))
source(here::here("scripts", "02_chemo-doses.R"))
source(here::here("scripts", "03_rt-exposure.R"))
```

Each script prints checks (counts, cross-tables, records to review) when it
runs. Read them after every run on the real data.

Output is saved in `output`. Anything that is included in the manuscripts
should be findable here.

### Repository layout

```
Watt-HL-SMN.Rproj
scripts/
  SAP_claude.txt                   statistical analysis plan
  00_config.R                      dummy/real switch, paths
  01_clean-data.R                  raw export -> cleaned data, SMN outcomes, analytic cohort
  02_chemo-doses.R                 chemotherapy regimens -> doses and yes/no exposure
  03_rt-exposure.R                 RT field flags -> organ exposure, RT technique
  make_dummy_dataset.R             builds the synthetic dummy dataset from the real export
  SMN-risk.qmd                     OLD analysis file (old variable names; to be replaced)
  anthra_dose_Eline.R              old anthracycline dose code (reference only; different coding)
  code-skeleton-anthra_...R        old draft lookup approach (reference only)
  stata/                           2015 NEJM Stata cleaning/analysis code (reference only)
docs/
  proposal_exposure-definitions.md/.html   exposure definitions, decision log, references
output/                            figures and tables for the manuscripts
secure_data/                       NOT in git: raw and intermediate data (see below)
renv.lock, renv/                   pinned R package versions
```

### Data

Patient-level data are never committed. They live in `secure_data/` in the
project root on the analysis server, which is excluded by `.gitignore`:

- `secure_data/ResearchDB_Export_from-Power-BI.csv`: raw export of 2024-12-12
  (read-only; see `secure_data/README.md` for how it was copied)
- `secure_data/DUMMY_research_dataset.csv`: synthetic dataset with the same
  layout, made by `scripts/make_dummy_dataset.R`. Values are generated
  column by column, so combinations across columns are not realistic.
- `secure_data/Research dataset - Data Dictionary Hodgkin cohort.docx`: codebook
- `secure_data/chem_drugs.xlsx`, `secure_data/Doxorubicin-dosages-for-available-treatments.xlsx`,
  `secure_data/Procarbazine-dosages-for available-treatments.xlsx`:
  chemotherapy lookup tables (regimen -> mg/m2 per cycle)
- `secure_data/intermediate/` (real) and `secure_data/intermediate/dummy/`
  (dummy): derived data written by scripts 01-03 (see the workflow table)

Check `git status` before committing anything new.
