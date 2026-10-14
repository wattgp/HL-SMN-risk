# 05_analysis-data.R
# Builds the analysis datasets used by every analysis script (06 onwards):
#   - the analytic cohort (01) joined with baseline exposure (04);
#   - patients with KEY OUTSTANDING DATA QUESTIONS are held out for now
#     (data-quality hold, DQ; see docs/data-manager-queries.md);
#   - outcomes under the main follow-up rule (C17) and under the sensitivity
#     rule (C17-LC: end of follow-up at last contact), for "any SMN" and per
#     SMN site group.
#
# Output (in out_dir from 00_config.R):
#   analysis_patients.Rds   one row per patient in the analysis: patient
#                           characteristics, baseline exposure, any-SMN
#                           outcome (main and _lc)
#   analysis_site_long.Rds  one row per patient x SMN site group: site
#                           outcome (main and _lc) and other-SMN timing
#   analysis_tv.Rds         time-varying exposure (04) for the same patients
#   dq_hold.Rds             patients held out, with the reason(s)
#
# Run after 01-04:  source(here::here("scripts", "05_analysis-data.R"))

# ---- decision log ------------------------------------------------------------
# DQ (2026-10-14) Q: Patients affected by outstanding data questions? A: The
#    project leader: "Observations with key outstanding questions can be
#    excluded for now." PROPOSED definition of "key" (settings in section 0,
#    to be confirmed): questions that leave the OUTCOME or the FOLLOW-UP
#    TIME of a patient uncertain:
#      DQ1 data dated after the death date (query Q5a): follow-up end unknown
#      DQ2 an SMN with a site and a date during follow-up but no behaviour
#          code (query Q3): whether the patient had an SMN event is unknown
#    Questions about EXPOSURE details are not held out, because agreed rules
#    already handle them (caps, W1, PRIM, D14, REG) and the remaining
#    missing exposure is analysed as missing data.
#    The duplicated ResearchIDs (Q1) are already excluded in 01 (C13).
# C17-LC (2026-10-14) The last-contact follow-up rule is a required
#    sensitivity analysis: its outcomes are built here (suffix _lc).

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(lubridate)

# ---- 0. settings ------------------------------------------------------------------

dq_hold_after_death <- TRUE      # DQ1 (proposed)
dq_hold_smn_no_behaviour <- TRUE # DQ2 (proposed)

years_between <- function(from, to) time_length(interval(from, to), "years")

# ---- 1. inputs -------------------------------------------------------------------

cohort <- readRDS(file.path(out_dir, "analytic_cohort.Rds"))
smn_long <- readRDS(file.path(out_dir, "smn_long.Rds"))
site_long <- readRDS(file.path(out_dir, "outcome_site_long.Rds"))
baseline <- readRDS(file.path(out_dir, "exposure_baseline.Rds"))
tv <- readRDS(file.path(out_dir, "exposure_tv.Rds"))

# ---- 2. data-quality hold (DQ) -----------------------------------------------------

dq_smn_no_behav <- smn_long |>
  filter(behav_cat == "unknown", !is.na(topo3), smn_timing == "during follow-up") |>
  distinct(researchid)

dq_hold <- bind_rows(
  if (dq_hold_after_death) {
    cohort |> filter(data_after_death %in% TRUE) |>
      transmute(researchid, reason = "DQ1: data dated after the death date (Q5a)")
  },
  if (dq_hold_smn_no_behaviour) {
    cohort |> semi_join(dq_smn_no_behav, by = "researchid") |>
      transmute(researchid, reason = "DQ2: SMN during follow-up without behaviour code (Q3)")
  }
)

keep_ids <- setdiff(cohort$researchid, dq_hold$researchid)

# ---- 3. outcomes under the last-contact rule (C17-LC) ------------------------------

# Same event definitions as 01, but follow-up ends at date_end_obs_lc and the
# competing death is death_competing_lc.
lc_outcome <- function(date_event, date_fup_start, date_end, death_comp) {
  status <- case_when(
    !is.na(date_event) & !is.na(date_end) & date_event <= date_end ~ 1L,
    death_comp ~ 2L,
    !is.na(date_end) ~ 0L,
    TRUE ~ NA_integer_
  )
  exit <- if_else(status %in% 1L, date_event, date_end)
  tibble(status = status, time = years_between(date_fup_start, exit))
}

patients <- cohort |>
  filter(researchid %in% keep_ids) |>
  left_join(baseline, by = "researchid")
lc_any <- lc_outcome(patients$date_first_any_smn, patients$date_fup_start,
                     patients$date_end_obs_lc, patients$death_competing_lc)
patients <- patients |>
  mutate(status_any_lc = lc_any$status, time_any_lc = lc_any$time)

site <- site_long |>
  filter(researchid %in% keep_ids) |>
  left_join(cohort |> select(researchid, date_end_obs_lc, death_competing_lc),
            by = "researchid")
lc_site <- lc_outcome(site$date_first_site, site$date_fup_start,
                      site$date_end_obs_lc, site$death_competing_lc)
site <- site |>
  mutate(status_lc = lc_site$status, time_lc = lc_site$time) |>
  select(-date_end_obs_lc, -death_competing_lc)

tv <- tv |> filter(researchid %in% keep_ids)

# ---- 4. checks -------------------------------------------------------------------

cat("\n== Data-quality hold (DQ) ==\n")
print(count(dq_hold, reason))
cat("Patients held out:", n_distinct(dq_hold$researchid), "of", nrow(cohort),
    "| in the analysis:", length(keep_ids), "\n")
cat("ACTION: report these as 'excluded pending data queries' in the flow",
    "diagram; re-run when the data manager has answered.\n")

cat("\n== Any invasive SMN: main rule vs last-contact rule (C17-LC) ==\n")
print(table(main = patients$status_any, last_contact = patients$status_any_lc,
            useNA = "ifany"))

# ---- 5. save ----------------------------------------------------------------------

saveRDS(patients, file.path(out_dir, "analysis_patients.Rds"))
saveRDS(site, file.path(out_dir, "analysis_site_long.Rds"))
saveRDS(tv, file.path(out_dir, "analysis_tv.Rds"))
saveRDS(dq_hold, file.path(out_dir, "dq_hold.Rds"))
