# 01_clean-data.R
# Reads the raw ResearchDB export and builds, step by step:
#   1. cleaned patient-level variables (dates at mid-month, age, era, vital
#      status, relapse, smoking, ...), each recoded explicitly from the
#      codebook
#   2. a long table of all recorded SMNs (one row per patient x SMN), with
#      behaviour category, site group, non-melanoma skin cancer flag and the
#      body region used to match sarcoma / skin SMNs to RT fields
#   3. follow-up and competing-risk outcomes for "any invasive SMN" and for
#      each SMN site group
#   4. the analytic cohort, with an exclusion flow table
#
# Output (in out_dir from 00_config.R):
#   patients_all.Rds        all patients, cleaned + derived, with exclusion
#                           reason (NA = in the analytic cohort)
#   smn_long.Rds            one row per patient x recorded SMN
#   analytic_cohort.Rds     the analytic cohort (one row per patient), with
#                           the any-invasive-SMN outcome
#   outcome_site_long.Rds   analytic cohort x SMN site group: site-specific
#                           competing-risk outcome
#   exclusion_flow.Rds      counts for the cohort flow diagram
#
# The raw export is never modified. Exposures are derived separately in
# 02_chemo-doses.R and 03_rt-exposure.R and joined in a later script.
#
# NOTE: scripts/SMN-risk.qmd still expects the OLD output of this script
# (variables such as cmpr_inv, ftime_cmpr_inv); it will be rewritten for the
# analysis stage.
#
# Run from the project:  source(here::here("scripts", "01_clean-data.R"))

# ---- decision log ------------------------------------------------------------
# Questions put to the project leader (G. Watt) and the answers given.
#
# C1 (2026-10-13) Cohort: HL diagnosed in 1989 or later AND aged 15-50 at
#    diagnosis.
# C2 (2026-10-13) Follow-up starts 5 years after HL diagnosis (5-year
#    survivors). SAP: follow-up time is time since HL diagnosis -> the time
#    scale is years since diagnosis, with entry at 5 years (both the
#    since-diagnosis and since-start-of-follow-up times are saved).
# C3 (2026-10-13) Diagnosis eras: 1989-1994, 1995-2004, 2005-latest.
# C4 (2026-10-13) Refactor this script (rather than start fresh), keeping the
#    dummy/real switch (now in 00_config.R).
# C5 (2026-10-13) Day of month is unreliable: all dates are set to the 15th
#    of the month (mid-month).
# C6 (2026-10-13) SMN behaviour: the analysis uses invasive SMNs only
#    (behaviour 3). In situ (2) and benign (0) are kept as separate
#    categories for future analyses.
# C7 (2026-10-13) Site groups: propose groupings based on Schaapveld 2015
#    (NEJM) and the SEER site recode, for sign-off. -> DRAFT in section 5.
# C8 (2026-10-14) "Any SMN": non-melanoma skin cancer EXCLUDED (kept as its
#    own site group). Unknown primary site (C80.9) INCLUDED only if invasive.
# C9 (2026-10-14, R2) Sarcoma and skin SMNs: match each tumour to the RT
#    fields by its topography where possible. -> body region derived here
#    (section 6); matched to fields in the exposure script.
# C10 (2026-10-14) Missing-value codes are applied per variable, following
#    the codebook (the old blanket "99/777/888/999 -> NA in every column"
#    destroyed real codes, e.g. regimen 99 and "other" chemotherapy 777).
#
# P1-P9 were proposed on 2026-10-14 and APPROVED by the project leader on
# 2026-10-14 (P5 with an addition, see below). They are set in section 0 so
# that they stay easy to change.
# P1 Vital status 2 = "moved abroad": censor at the date of emigration
#    (vital-status date). [The old script coded it as DEAD by mistake.]
# P2 End of follow-up: SMNs are known up to the date of last contact
#    (codebook). Death is a competing event if it occurred on or before the
#    last-contact date; a death AFTER last contact is censored at last
#    contact (SMN status between last contact and death is unknown).
# P3 A date with a known year but missing month: set to 1 July (mid-year)
#    and flag it as imputed.
# P4 Patients with an invasive SMN (as defined in C8) BEFORE the start of
#    follow-up are excluded from the analytic cohort (as in the old script).
# P5 Site-specific outcomes: the event is the first invasive SMN of THAT
#    site after the start of follow-up, even if another SMN came first (the
#    patient is not censored at the other SMN). APPROVED WITH ADDITION: the
#    analysis must account statistically for the other SMN. -> For each
#    site, the date of the first invasive SMN of ANY OTHER site during
#    follow-up (before the site event) is saved (date_other_smn), so that it
#    can enter the models as a time-varying covariate (section 10).
# P6 A second Hodgkin lymphoma (morphology 9650-9667) is not counted as an
#    SMN (likely relapse/progression of the first HL).
# P7 Age 15-50 means 15 <= age at diagnosis < 51 (completed years 15-50).
# P8 Non-melanoma skin cancer = skin (C44) with morphology 8000-8110 (SEER
#    convention: carcinoma NOS, basal and squamous cell). Other skin
#    tumours (e.g. adnexal, Merkel cell) are "other skin".
# P9 An invasive SMN with an unknown date cannot be placed in time: the
#    patient is excluded from the analytic cohort and listed for review.
#
# C13 (2026-10-14) Duplicated ResearchIDs (25 in the real export): all rows
#    of these patients are excluded for now (option C). To do: ask the data
#    manager which record is authoritative. Applied in read_raw() in
#    00_config.R; counted first in the exclusion flow.
# C14 (2026-10-14) Q: Invasive SMN diagnosed after the recorded last-contact
#    date? A: Use the date of the invasive SMN as the last-contact date
#    (section 7). The recorded date is kept as date_lc_recorded.
# C15 (2026-10-14) Q: Age groups for the descriptive table? A: Scenario C:
#    15-20 / 21-30 / 31-40 / 41-50 (completed years). The scenario table is
#    still printed in section 11 for reference.
# C16 (2026-10-14) Q: Two-group age split for the "young adult vs older"
#    plots (SAP E.1)? A: AYA 15-39 vs 40-50 (scenario E): age_dx_aya.
# C17 (2026-10-14) Q: Courses (or other data) dated after the end of
#    observation? A: That is real follow-up. Total follow-up runs until the
#    LAST DATE OF ANY DATA: last contact, vital status, SMN, HL relapse or
#    treatment course (section 8). Death remains the competing event. This
#    replaces P2 and the emigration rule of P1 in the main analysis; the
#    earlier last-contact rule is kept for a sensitivity analysis
#    (date_end_obs_lc, death_competing_lc). The project leader asked that
#    the analysis script MUST include this sensitivity analysis (C17-LC).
# C11 (2026-10-14) Site groups (section 5): APPROVED as shown. Small site
#    groups are NOT merged in the data: every group is kept in smn_long and
#    outcome_site_long, and all groups appear in a comprehensive SMN table in
#    the descriptive analysis. Case-count thresholds for plots and models
#    are set in 00_config.R (C12 there).
#
# STILL OPEN:
#   (none)

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(purrr)
library(lubridate)

# ---- 0. settings for the P-decisions (approved 2026-10-14) ----------------------

# Each setting below implements one P-item from the decision log. Changing a
# value here changes the behaviour everywhere it is used.
p1_moved_abroad <- "censor" # P1: "censor" at emigration date
p2_death_after_lc <- "censor_at_lc" # P2: death after last contact -> censor at last contact
p3_missing_month <- 7L # P3: month used when only the year is known (NA = leave missing)
p4_exclude_prior_smn <- TRUE # P4: exclude invasive SMN before start of follow-up
p6_exclude_second_hl <- TRUE # P6: second HL is not an SMN
p7_age_upper_exclusive <- 51 # P7: age at diagnosis < 51
p8_nmsc_morph <- 8000:8110 # P8: NMSC morphology codes on C44
p9_exclude_undated_smn <- TRUE # P9: exclude patients with an undated invasive SMN

# ---- 1. read the raw export ----------------------------------------------------

# Every column is read as character and recoded explicitly below (C10).
# read_raw() (00_config.R) also removes ALL rows of patients whose
# ResearchID occurs more than once (C13); they are counted in the exclusion
# flow (section 9).
raw <- read_raw()
n_duplicate_ids <- length(attr(raw, "duplicate_ids"))

# From here on there is one row per patient (codebook: "one row per
# individual").
stopifnot(!anyDuplicated(raw$researchid))

# ---- 2. helper functions ---------------------------------------------------------

# "onbekend" is Dutch for "unknown" and occurs in free-entry fields.
unknown_text <- c("onbekend", "Onbekend", "ONBEKEND")

# Integer from a character column; "onbekend" and non-numbers -> NA.
as_int <- function(x) {
  suppressWarnings(as.integer(ifelse(x %in% unknown_text, NA, x)))
}
as_num <- function(x) {
  suppressWarnings(as.numeric(ifelse(x %in% unknown_text, NA, x)))
}

# Date at mid-month (C5). Year outside 1900-2100 (e.g. the placeholder
# year 1 in the dummy data) -> NA. Month outside 1-12 -> treated as missing;
# if only the month is missing, P3 decides (1 July by default) and the date
# is flagged as imputed via mid_month_imputed().
mid_month_date <- function(month, year) {
  m <- as_int(month)
  y <- as_int(year)
  m[!m %in% 1:12] <- NA
  y[!is.na(y) & (y < 1900 | y > 2100)] <- NA
  m_use <- if_else(is.na(m) & !is.na(y), p3_missing_month, m)
  day <- if_else(is.na(m) & !is.na(y), 1L, 15L) # 1 July for mid-year (P3)
  make_date(y, m_use, day)
}
mid_month_imputed <- function(month, year) {
  m <- as_int(month)
  y <- as_int(year)
  y[!is.na(y) & (y < 1900 | y > 2100)] <- NA
  !is.na(y) & !(m %in% 1:12)
}

# Years between two dates (lubridate handles leap years).
years_between <- function(from, to) time_length(interval(from, to), "years")

# ---- 3. patient-level variables ---------------------------------------------------

pat <- tibble(researchid = raw$researchid) |>
  mutate(
    hospital = raw$zkh,

    # Sex (codebook): 0 male, 1 female, 2 other, 99 unknown.
    sex = case_when(
      as_int(raw$sex) == 0L ~ "male",
      as_int(raw$sex) == 1L ~ "female",
      as_int(raw$sex) == 2L ~ "other",
      TRUE ~ NA_character_
    ),

    # Dates at mid-month (C5).
    date_birth = mid_month_date(raw$m_birth, raw$y_birth),
    date_dx = mid_month_date(raw$m_diagnose, raw$y_diagnose),
    date_lc = mid_month_date(raw$m_lcontact, raw$y_lcontact), # SMNs known up to here
    date_vs = mid_month_date(raw$m_livedead, raw$y_livedead), # vital status / death
    date_recur = mid_month_date(raw$m_recur, raw$y_recur),
    imputed_month_dx = mid_month_imputed(raw$m_diagnose, raw$y_diagnose),
    imputed_month_lc = mid_month_imputed(raw$m_lcontact, raw$y_lcontact),
    imputed_month_vs = mid_month_imputed(raw$m_livedead, raw$y_livedead),
    year_dx = year(date_dx),
    age_dx = years_between(date_birth, date_dx),

    # Diagnosis era (C3). "before 1989" is outside the cohort (C1) but kept
    # so that excluded patients can be described.
    era = cut(year_dx, c(-Inf, 1988, 1994, 2004, Inf),
      labels = c("before 1989", "1989-1994", "1995-2004", "2005-latest")
    ),

    # Age groups for the descriptive table (C15, scenario C): completed
    # years 15-20 / 21-30 / 31-40 / 41-50 (consistent with P7: ages are
    # floored, so 50.9 is "41-50").
    age_dx_group = cut(floor(age_dx), c(15, 21, 31, 41, 51),
      right = FALSE,
      labels = c("15-20", "21-30", "31-40", "41-50")
    ),
    # Two-group split for the "young adult vs older" cumulative incidence
    # plots (C16): adolescents and young adults (AYA, 15-39) vs 40-50.
    age_dx_aya = cut(floor(age_dx), c(15, 40, 51),
      right = FALSE,
      labels = c("AYA 15-39", "40-50")
    ),

    # Vital status (codebook): 0 alive, 1 dead, 2 moved abroad, 99 unknown.
    vital = case_when(
      as_int(raw$livedead) == 0L ~ "alive",
      as_int(raw$livedead) == 1L ~ "dead",
      as_int(raw$livedead) == 2L ~ "moved abroad",
      TRUE ~ NA_character_
    ),

    # HL relapse (codebook): 0 no, 1 yes.
    relapse = case_when(
      as_int(raw$recur) == 1L ~ "yes",
      as_int(raw$recur) == 0L ~ "no",
      TRUE ~ NA_character_
    ),

    # Smoking ever (codebook): 0 no, 1 yes, 99 unknown -> NA. Unknown is
    # excluded (listwise) in the lung x smoking models (decision Q-RT3b).
    smoke_ever = case_when(
      as_int(raw$smoke_ever) == 1L ~ "yes",
      as_int(raw$smoke_ever) == 0L ~ "no",
      TRUE ~ NA_character_
    ),

    # BMI at diagnosis (codebook: numeric, 99 unknown). Stored as text in
    # the export; values outside 10-80 are treated as missing.
    bmi_dx = as_num(raw$bmi_diag),
    bmi_dx = if_else(bmi_dx == 99 | bmi_dx < 10 | bmi_dx > 80, NA_real_, bmi_dx),

    # HL morphology (ICD-O-3), for description of HL subtype.
    hl_morph = as_int(raw$pc_morph),

    # Start of follow-up: 5 years after HL diagnosis (C2).
    date_fup_start = date_dx %m+% years(5)
  )

# ---- 4. SMN long table ------------------------------------------------------------

# Up to 7 SMNs per patient: smn<k>_site (topography, e.g. "C504"),
# smn<k>_morph (4-digit morphology; 9999 unknown), smn<k>_behav (behaviour
# code), m_/y_smn<k> (month/year of diagnosis).
smn_long <- map_dfr(1:7, function(k) {
  tibble(
    researchid = raw$researchid,
    smn_number = k,
    topo_raw = raw[[paste0("smn", k, "_site")]],
    morph = as_int(raw[[paste0("smn", k, "_morph")]]),
    behav = as_int(raw[[paste0("smn", k, "_behav")]]),
    date_smn = mid_month_date(raw[[paste0("m_smn", k)]], raw[[paste0("y_smn", k)]]),
    imputed_month_smn = mid_month_imputed(raw[[paste0("m_smn", k)]], raw[[paste0("y_smn", k)]])
  )
}) |>
  # Keep only SMN slots with any information recorded.
  filter(!is.na(topo_raw) | !is.na(morph) | !is.na(behav) | !is.na(date_smn)) |>
  mutate(
    morph = if_else(morph == 9999L, NA_integer_, morph), # codebook: 9999 unknown
    # Topography: upper case, without the dot, e.g. "C50.4" -> "C504".
    topo = str_remove_all(str_to_upper(str_trim(topo_raw)), "\\."),
    topo = if_else(str_detect(topo, "^C[0-9]{3}$"), topo, NA_character_),
    topo3 = str_sub(topo, 1, 3), # e.g. "C50"
    topo_num = as.integer(str_sub(topo, 2, 3)), # e.g. 50

    # Behaviour category (C6).
    behav_cat = case_when(
      behav == 3L ~ "invasive",
      behav == 2L ~ "in situ",
      behav == 0L ~ "benign",
      behav == 1L ~ "uncertain",
      behav == 6L ~ "metastatic",
      behav == 9L ~ "malignant, primary/metastatic unknown",
      TRUE ~ "unknown"
    )
  )

# ---- 5. SMN site groups (C7, approved C11) ------------------------------------------

# Based on the SEER site recode (ICD-O-3) and the site groups in Schaapveld
# 2015. Haematological and some other tumours are grouped by MORPHOLOGY
# first (e.g. a lymphoma in the stomach is a lymphoma, not a stomach
# cancer); all other tumours by TOPOGRAPHY. rt_site links the site group to
# the organ-exposure mapping in 03_rt-exposure.R.
in_rng <- function(x, lo, hi) !is.na(x) & x >= lo & x <= hi

smn_long <- smn_long |>
  mutate(
    site_group = case_when(
      # -- by morphology --
      in_rng(morph, 9650, 9667) ~ "Hodgkin lymphoma",
      in_rng(morph, 9590, 9597) | in_rng(morph, 9670, 9729) |
        in_rng(morph, 9735, 9738) ~ "Non-Hodgkin lymphoma",
      in_rng(morph, 9731, 9734) ~ "Myeloma / plasmacytoma",
      in_rng(morph, 9740, 9992) ~ "Leukaemia / MDS / other myeloid",
      in_rng(morph, 8720, 8790) ~ "Melanoma",
      in_rng(morph, 9050, 9055) ~ "Mesothelioma",
      morph %in% 9140L ~ "Kaposi sarcoma",
      in_rng(morph, 8800, 8936) | in_rng(morph, 8990, 8991) |
        in_rng(morph, 9040, 9044) | in_rng(morph, 9120, 9139) |
        in_rng(morph, 9141, 9251) | morph %in% 9260L |
        in_rng(morph, 9540, 9581) ~ "Sarcoma (bone / soft tissue)",
      # -- by topography --
      topo3 %in% c("C40", "C41", "C47", "C49") ~ "Sarcoma (bone / soft tissue)",
      topo3 == "C44" & morph %in% p8_nmsc_morph ~ "Non-melanoma skin (basal/squamous)", # P8
      topo3 == "C44" ~ "Other skin",
      in_rng(topo_num, 0, 14) | topo3 %in% c("C30", "C31", "C32") ~ "Head and neck",
      topo3 == "C15" ~ "Oesophagus",
      topo3 == "C16" ~ "Stomach",
      topo3 %in% c("C18", "C19", "C20") ~ "Colorectum",
      topo3 %in% c("C22", "C23", "C24") ~ "Liver / biliary",
      topo3 == "C25" ~ "Pancreas",
      topo3 %in% c("C17", "C21", "C26", "C48") ~ "Other digestive",
      topo3 == "C34" ~ "Lung",
      topo3 %in% c("C33", "C37", "C38", "C39") ~ "Other thoracic / respiratory",
      topo3 == "C50" ~ "Breast",
      topo3 == "C53" ~ "Cervix",
      topo3 %in% c("C54", "C55") ~ "Corpus uteri",
      topo3 == "C56" ~ "Ovary",
      topo3 %in% c("C51", "C52", "C57", "C58") ~ "Other female genital",
      topo3 == "C61" ~ "Prostate",
      topo3 == "C62" ~ "Testis",
      topo3 %in% c("C60", "C63") ~ "Other male genital",
      topo3 == "C67" ~ "Bladder",
      topo3 %in% c("C64", "C65", "C66", "C68") ~ "Kidney / other urinary",
      topo3 == "C69" ~ "Eye",
      topo3 %in% c("C70", "C71", "C72") ~ "Brain / CNS",
      topo3 == "C73" ~ "Thyroid",
      topo3 %in% c("C74", "C75") ~ "Other endocrine",
      topo3 %in% c("C42", "C77") ~ "Other haematopoietic / lymph node (non-lymphoma morphology)",
      topo == "C809" ~ "Unknown primary (C80.9)",
      topo3 %in% c("C76", "C80") ~ "Ill-defined sites",
      TRUE ~ "Site not recorded"
    ),
    # Link to the organ-exposure mapping in 03_rt-exposure.R.
    rt_site = case_when(
      site_group == "Breast" ~ "breast",
      site_group == "Lung" ~ "lung",
      site_group == "Thyroid" ~ "thyroid",
      site_group == "Oesophagus" ~ "oesophagus",
      site_group == "Stomach" ~ "stomach",
      site_group == "Pancreas" ~ "pancreas",
      site_group == "Colorectum" ~ "colorectum",
      site_group %in% c("Bladder", "Prostate", "Cervix") ~ "pelvic_organs",
      site_group == "Head and neck" ~ "head_neck",
      site_group %in% c(
        "Sarcoma (bone / soft tissue)", "Melanoma",
        "Non-melanoma skin (basal/squamous)", "Other skin"
      ) ~ "by_topography",
      TRUE ~ "not_organ_specific"
    ),
    is_nmsc = site_group == "Non-melanoma skin (basal/squamous)",

    # Counts as an invasive SMN for "any SMN" (C6, C8, P6): behaviour 3,
    # not NMSC, not a second HL. C80.9 counts only if invasive (C8), which
    # the behaviour condition already ensures.
    counts_any_smn = behav_cat == "invasive" & !is_nmsc &
      !(p6_exclude_second_hl & site_group == "Hodgkin lymphoma"),
    # Counts as an invasive SMN for its own site group (NMSC included here,
    # as its own site, C8).
    counts_site_smn = behav_cat == "invasive" &
      !(p6_exclude_second_hl & site_group == "Hodgkin lymphoma")
  )

# ---- 6. body region for sarcoma and skin SMNs (C9, DRAFT) -------------------------

# Sarcoma and skin tumours can arise anywhere, so whether they were in an RT
# field depends on WHERE they arose. The topography sub-site gives a body
# region, which the exposure script will match to the RT field groups.
# Mapping (draft, to be reviewed together with the RT mapping by Berthe):
#   head / face / neck: C44.0-C44.4, C49.0, C41.0-C41.1 (skull, mandible)
#   upper limb / shoulder: C44.6, C49.1, C40.0-C40.1
#   lower limb / hip: C44.7, C49.2, C40.2-C40.3
#   thorax / chest wall: C49.3, C41.3 (ribs, sternum, clavicle)
#   trunk, skin (front/back not specified): C44.5
#   abdomen: C49.4; retroperitoneum C48.0
#   pelvis: C49.5, C41.4 (pelvic bones, sacrum, coccyx)
#   spine: C41.2 (vertebral column; may be in several fields)
#   other / unspecified: everything else (C44.8-C44.9, C49.6, C49.8-C49.9, ...)
smn_long <- smn_long |>
  mutate(
    body_region = case_when(
      rt_site != "by_topography" ~ NA_character_,
      topo %in% c("C440", "C441", "C442", "C443", "C444", "C490", "C410", "C411") ~ "head / neck",
      topo %in% c("C446", "C491", "C400", "C401") ~ "upper limb / shoulder",
      topo %in% c("C447", "C492", "C402", "C403") ~ "lower limb / hip",
      topo %in% c("C493", "C413") ~ "thorax / chest wall",
      topo %in% c("C445") ~ "trunk (skin)",
      topo %in% c("C494", "C480") ~ "abdomen / retroperitoneum",
      topo %in% c("C495", "C414") ~ "pelvis",
      topo %in% c("C412") ~ "spine",
      TRUE ~ "other / unspecified"
    )
  )

# ---- 7. SMNs relative to the start of follow-up -----------------------------------

smn_long <- smn_long |>
  left_join(pat |> select(researchid, date_dx, date_fup_start), by = "researchid") |>
  mutate(
    smn_timing = case_when(
      is.na(date_smn) ~ "date unknown",
      date_smn < date_fup_start ~ "before start of follow-up",
      TRUE ~ "during follow-up"
    ),
    years_since_dx = years_between(date_dx, date_smn)
  ) |>
  select(-date_dx, -date_fup_start)

# First invasive SMN (any-SMN definition) before / during follow-up.
first_any <- smn_long |>
  filter(counts_any_smn) |>
  group_by(researchid) |>
  summarise(
    any_smn_undated = any(smn_timing == "date unknown"),
    any_smn_before_fup = any(smn_timing == "before start of follow-up"),
    date_first_any_smn = suppressWarnings(min(date_smn[smn_timing == "during follow-up"])),
    .groups = "drop"
  ) |>
  mutate(date_first_any_smn = if_else(is.finite(date_first_any_smn),
    date_first_any_smn, as.Date(NA)
  ))

pat <- pat |>
  left_join(first_any, by = "researchid") |>
  mutate(across(c(any_smn_undated, any_smn_before_fup), ~ coalesce(.x, FALSE)))

# C14: an invasive SMN diagnosed AFTER the recorded last-contact date shows
# the patient was in contact at least until then, so last contact is moved
# to the date of the latest such SMN. "Invasive" = behaviour 3, any site
# (including NMSC and a second HL, because any invasive diagnosis is a
# contact). Only applied when last contact is known; the original date is
# kept as date_lc_recorded.
latest_inv_smn <- smn_long |>
  filter(behav_cat == "invasive", !is.na(date_smn)) |>
  group_by(researchid) |>
  summarise(date_latest_inv_smn = max(date_smn), .groups = "drop")

pat <- pat |>
  left_join(latest_inv_smn, by = "researchid") |>
  mutate(
    date_lc_recorded = date_lc,
    lc_moved_to_smn = !is.na(date_lc) & !is.na(date_latest_inv_smn) &
      date_latest_inv_smn > date_lc,
    date_lc = if_else(lc_moved_to_smn, date_latest_inv_smn, date_lc)
  ) |>
  select(-date_latest_inv_smn)

# ---- 8. end of follow-up and competing-risk outcome (any invasive SMN) -----------

# C17 (end of follow-up): follow-up runs until the LAST DATE OF ANY DATA for
# the patient: last contact, vital-status date, any SMN (any behaviour), HL
# relapse, or the start of any treatment course. Death is the competing
# event (on the death date); everyone else is censored at the last data
# date. This supersedes P2 and the emigration part of P1 for the MAIN
# analysis; the earlier last-contact rule is kept as a sensitivity version
# (date_end_obs_lc, death_competing_lc).
# Event coding: 1 = invasive SMN, 2 = death (competing), 0 = censored.
course_dates <- tibble(
  researchid = raw$researchid,
  date_ctprim = mid_month_date(raw$m_ctprim, raw$y_ctprim),
  date_ctfup = mid_month_date(raw$m_ctfup, raw$y_ctfup),
  date_ctfup2 = mid_month_date(raw$m_ctfup2, raw$y_ctfup2),
  date_rtprim = mid_month_date(raw$m_rtprim, raw$y_rtprim),
  date_rtfup = mid_month_date(raw$m_rtfup, raw$y_rtfup),
  date_rtfup2 = mid_month_date(raw$m_rtfup2, raw$y_rtfup2)
)
latest_smn_any_behaviour <- smn_long |>
  filter(!is.na(date_smn)) |>
  group_by(researchid) |>
  summarise(date_latest_smn = max(date_smn), .groups = "drop")

pat <- pat |>
  left_join(course_dates, by = "researchid") |>
  left_join(latest_smn_any_behaviour, by = "researchid") |>
  mutate(
    date_last_data = pmax(date_lc_recorded, date_vs, date_recur, date_latest_smn,
                          date_ctprim, date_ctfup, date_ctfup2,
                          date_rtprim, date_rtfup, date_rtfup2, na.rm = TRUE),
    # Which source gave the last data date (for checking).
    last_data_source = case_when(
      is.na(date_last_data) ~ NA_character_,
      (date_last_data == date_lc_recorded) %in% TRUE ~ "last contact",
      (date_last_data == date_vs) %in% TRUE ~ "vital status",
      (date_last_data == date_latest_smn) %in% TRUE ~ "SMN",
      (date_last_data == date_recur) %in% TRUE ~ "HL relapse",
      TRUE ~ "treatment course"
    ),

    # -- main rule (C17) --
    death_competing = vital %in% "dead" & !is.na(date_vs),
    date_end_obs = if_else(death_competing, date_vs, date_last_data),
    # Data dated after the death date are inconsistent; listed below.
    data_after_death = death_competing & date_last_data > date_vs,

    # -- sensitivity: earlier last-contact rule (P1, P2, C14) --
    death_competing_lc = vital %in% "dead" & !is.na(date_vs) & !is.na(date_lc) &
      date_vs <= date_lc,
    date_end_obs_lc = case_when(
      vital %in% "moved abroad" & p1_moved_abroad == "censor" ~ pmin(date_vs, date_lc, na.rm = TRUE),
      death_competing_lc ~ date_vs,
      TRUE ~ date_lc
    ),
    # Any-SMN outcome.
    status_any = case_when(
      !is.na(date_first_any_smn) & date_first_any_smn <= coalesce(date_end_obs, date_first_any_smn) ~ 1L,
      death_competing ~ 2L,
      !is.na(date_end_obs) ~ 0L,
      TRUE ~ NA_integer_
    ),
    date_exit_any = case_when(
      status_any == 1L ~ date_first_any_smn,
      TRUE ~ date_end_obs
    ),
    # Two time scales (C2): years since start of follow-up, and years since
    # HL diagnosis (entry at 5 years; exit = 5 + time since start).
    time_any = years_between(date_fup_start, date_exit_any),
    time_entry_dx = years_between(date_dx, date_fup_start), # = 5
    time_exit_dx_any = years_between(date_dx, date_exit_any),
    # SMN diagnosed after the RECORDED last-contact date (last contact was
    # moved to the SMN date, C14); counted below.
    smn_after_lc = lc_moved_to_smn
  )

# ---- 9. analytic cohort and exclusion flow ----------------------------------------

pat <- pat |>
  mutate(
    exclusion = case_when(
      is.na(year_dx) ~ "HL diagnosis year unknown",
      year_dx < 1989 ~ "HL diagnosed before 1989 (C1)",
      is.na(age_dx) ~ "age at diagnosis unknown",
      age_dx < 15 | age_dx >= p7_age_upper_exclusive ~ "age at diagnosis outside 15-50 (C1, P7)",
      is.na(date_end_obs) ~ "end of follow-up unknown",
      vital %in% "dead" & !is.na(date_vs) & date_vs < date_fup_start ~ "died before start of follow-up (C2)",
      date_end_obs <= date_fup_start ~ "not under follow-up at start of follow-up (C2)",
      p4_exclude_prior_smn & any_smn_before_fup ~ "invasive SMN before start of follow-up (P4)",
      p9_exclude_undated_smn & any_smn_undated ~ "invasive SMN with unknown date (P9)",
      TRUE ~ NA_character_
    )
  )

# Flow table: patients excluded at each step, in the order above. The
# patients with a duplicated ResearchID (C13) were removed on reading, so
# they are added here as the first step.
exclusion_flow <- pat |>
  mutate(exclusion = coalesce(exclusion, "included in analytic cohort")) |>
  count(exclusion, name = "n") |>
  bind_rows(tibble(
    exclusion = "ResearchID on more than one row (C13)",
    n = n_duplicate_ids
  )) |>
  filter(n > 0) |>
  mutate(order = match(exclusion, c(
    "ResearchID on more than one row (C13)",
    "HL diagnosis year unknown", "HL diagnosed before 1989 (C1)",
    "age at diagnosis unknown", "age at diagnosis outside 15-50 (C1, P7)",
    "end of follow-up unknown", "died before start of follow-up (C2)",
    "not under follow-up at start of follow-up (C2)",
    "invasive SMN before start of follow-up (P4)",
    "invasive SMN with unknown date (P9)", "included in analytic cohort"
  ))) |>
  arrange(order) |>
  select(-order)

cohort <- pat |> filter(is.na(exclusion))

# ---- 10. site-specific outcomes (P5) ----------------------------------------------

# For each site group, the first invasive SMN of that site during follow-up
# is the event, whether or not another SMN came first (P5). Death is the
# competing event; censoring as for any SMN. NMSC is included as its own
# site (C8). Sites are restricted to the analytic cohort.
site_first <- smn_long |>
  filter(
    counts_site_smn, smn_timing == "during follow-up",
    researchid %in% cohort$researchid
  ) |>
  group_by(researchid, site_group, rt_site) |>
  summarise(date_first_site = min(date_smn), .groups = "drop")

site_list <- sort(unique(site_first$site_group))

# P5 addition: first invasive SMN of any OTHER site during follow-up. Uses
# counts_site_smn, so another site's NMSC also counts as "other SMN" here;
# whether NMSC should count is a modelling choice to make at that stage
# (other_smn_is_nmsc_only flags it).
other_smn <- smn_long |>
  filter(
    counts_site_smn, smn_timing == "during follow-up",
    researchid %in% cohort$researchid
  ) |>
  select(researchid, other_site = site_group, date_smn, is_nmsc)

outcome_site_long <- cohort |>
  select(researchid, sex, date_dx, date_fup_start, date_end_obs, death_competing) |>
  tidyr::crossing(site_group = site_list) |>
  left_join(site_first, by = c("researchid", "site_group")) |>
  mutate(
    status = case_when(
      !is.na(date_first_site) & date_first_site <= date_end_obs ~ 1L,
      death_competing ~ 2L,
      TRUE ~ 0L
    ),
    date_exit = if_else(status == 1L, date_first_site, date_end_obs),
    time = years_between(date_fup_start, date_exit),
    time_exit_dx = years_between(date_dx, date_exit)
  ) |>
  select(-date_end_obs, -death_competing)

# Attach the first other-site SMN that occurred BEFORE this site's exit date
# (afterwards it cannot affect this outcome). Time since start of follow-up
# at which it occurred: time_other_smn (NA = none).
other_by_site <- outcome_site_long |>
  select(researchid, site_group, date_exit) |>
  inner_join(other_smn, by = "researchid", relationship = "many-to-many") |>
  filter(other_site != site_group, date_smn < date_exit) |>
  group_by(researchid, site_group) |>
  summarise(
    date_other_smn = min(date_smn),
    other_smn_is_nmsc_only = all(is_nmsc),
    .groups = "drop"
  )

n_before <- nrow(outcome_site_long)
outcome_site_long <- outcome_site_long |>
  left_join(other_by_site, by = c("researchid", "site_group")) |>
  mutate(time_other_smn = years_between(date_fup_start, date_other_smn))
stopifnot(nrow(outcome_site_long) == n_before) # still one row per patient x site

# ---- 11. checks (printed; nothing is changed here) -------------------------------

cat("\n== Exclusion flow ==\n")
print(exclusion_flow)

cat("\n== Any invasive SMN outcome, analytic cohort (1 SMN, 2 death, 0 censored) ==\n")
print(count(cohort, status_any))
cat(
  "Follow-up (years since start of follow-up): median",
  round(median(cohort$time_any, na.rm = TRUE), 1), " max",
  round(max(cohort$time_any, na.rm = TRUE), 1), "\n"
)

cat("\n== Vital status (moved abroad: P1) ==\n")
print(count(pat, vital))
cat("Deaths: competing events", sum(pat$death_competing), "\n")
cat("Records with data dated after the death date (C17; to review):",
    sum(pat$data_after_death, na.rm = TRUE), "\n")

cat("\n== Source of the last data date (C17), analytic cohort ==\n")
print(count(cohort, last_data_source))
cat("Median extra follow-up vs the last-contact rule (years):",
    round(median(years_between(cohort$date_end_obs_lc, cohort$date_end_obs), na.rm = TRUE), 2), "\n")

cat("\n== Dates with imputed month (P3) ==\n")
print(c(
  dx = sum(pat$imputed_month_dx), lc = sum(pat$imputed_month_lc),
  vs = sum(pat$imputed_month_vs), smn = sum(smn_long$imputed_month_smn)
))

cat("\n== SMN behaviour categories (all recorded SMNs) ==\n")
print(count(smn_long, behav_cat))

cat("\n== Site groups: invasive SMNs during follow-up, analytic cohort ==\n")
print(
  smn_long |>
    filter(
      researchid %in% cohort$researchid, behav_cat == "invasive",
      smn_timing == "during follow-up"
    ) |>
    count(site_group, sort = TRUE),
  n = Inf
)

cat("\n== Sarcoma / skin body regions (C9) ==\n")
print(count(filter(smn_long, rt_site == "by_topography"), site_group, body_region))

# Age-group scenarios for the descriptive table (STILL OPEN). Each scenario
# shows the number of patients, the share of the cohort and the number of
# invasive SMNs (any-SMN definition) per group, so group sizes can be judged.
# Ages are in completed years (floor), consistent with P7.
age_scenarios <- list(
  "A: <25 / 25-34 / 35-50"            = c(15, 25, 35, 51),
  "B: 15-24 / 25-34 / 35-44 / 45-50"  = c(15, 25, 35, 45, 51),
  "C: 15-20 / 21-30 / 31-40 / 41-50"  = c(15, 21, 31, 41, 51),
  "D: young adult 15-29 / 30-50"      = c(15, 30, 51),
  "E: AYA 15-39 / 40-50"              = c(15, 40, 51)
)
age_scenario_table <- imap_dfr(age_scenarios, function(brks, name) {
  cohort |>
    mutate(
      age_c = floor(age_dx),
      group = cut(age_c, brks,
        right = FALSE,
        labels = paste0(head(brks, -1), "-", tail(brks, -1) - 1)
      )
    ) |>
    group_by(group) |>
    summarise(n = n(), smn = sum(status_any == 1L, na.rm = TRUE), .groups = "drop") |>
    mutate(pct = round(100 * n / sum(n), 1), scenario = name, .before = 1)
})
cat("\n== Age-group scenarios (analytic cohort) ==\n")
print(age_scenario_table, n = Inf)
saveRDS(age_scenario_table, file.path(out_dir, "age_group_scenarios.Rds"))

cat("\n== Records to review ==\n")
cat("invasive SMN after recorded last contact (last contact moved to SMN date, C14):",
    sum(pat$smn_after_lc), "\n")
cat("invasive SMN with unknown date:", sum(pat$any_smn_undated), "\n")
cat(
  "topography not in C00.0-C80.9 format:",
  sum(!is.na(smn_long$topo_raw) & is.na(smn_long$topo)), "\n"
)

# ---- 12. save ----------------------------------------------------------------------

saveRDS(pat, file.path(out_dir, "patients_all.Rds"))
saveRDS(smn_long, file.path(out_dir, "smn_long.Rds"))
saveRDS(cohort, file.path(out_dir, "analytic_cohort.Rds"))
saveRDS(outcome_site_long, file.path(out_dir, "outcome_site_long.Rds"))
saveRDS(exclusion_flow, file.path(out_dir, "exclusion_flow.Rds"))

message(
  "Saved ", nrow(pat), " patients (all) and ", nrow(cohort),
  " (analytic cohort) to ", out_dir
)
