# 02_chemo-doses.R
# Converts the recorded chemotherapy (regimen code + number of cycles, for the
# primary treatment and up to two follow-up / relapse treatment courses) into
# cumulative doses (mg/m2) and yes/no exposure variables:
#   - doxorubicin dose                          (primary anthracycline exposure)
#   - epirubicin yes/no, other anthracycline/anthraquinone yes/no
#   - doxorubicin-equivalent dose               (sensitivity analysis only)
#   - procarbazine dose                         (+ sensitivity version S-CT98)
#   - doxorubicin yes/no and procarbazine yes/no
#
# Output (in out_dir from 00_config.R):
#   chemo_slots_long.Rds      one row per patient x course x regimen slot
#   chemo_doses_course.Rds    one row per patient x course (prim / fup / fup2),
#                             with the course start date, so a later script can
#                             split exposure into "before start of follow-up"
#                             and "time-varying after start of follow-up" (D5)
#   chemo_registry_flags.Rds  one row per patient: the registry's own
#                             anthrac / procarbazine flags, kept for comparison
#   chemo_dose_review.Rds     patients flagged by the plausibility checks (D12)
#
# Dose categories (D11) are NOT applied here: they apply to the cumulative dose
# in the exposure window, which is built in a later script once the start of
# follow-up is known. The cut-offs are written down in section 8 so that the
# later script uses exactly these.
#
# Full rationale and references: docs/proposal_exposure-definitions.md
#
# Run from the project:  source(here::here("scripts", "02_chemo-doses.R"))

# ---- decision log ------------------------------------------------------------
# Questions put to the project leader (G. Watt) and the answers given. Each
# decision is referred to by its tag (D1, D2, ...) where it is applied below.
#
# D1 (2026-10-13) Q: Are the doses in the lookup tables mg/m2 per cycle, and is
#    cumulative dose = per-cycle dose x number of cycles?   A: Yes.
# D2 (2026-10-13) Q: Is a cycle count of 999 "unknown" (dose then missing)?
#    A: Yes.
# D3 (2026-10-13) Q: Convert non-doxorubicin anthracyclines with literature
#    conversion factors? A: Yes; propose factors with verified citations and
#    check that converted doses are reasonable. -> Superseded by D6: the
#    converted dose is the SENSITIVITY analysis, not the primary exposure.
# D4 (2026-10-13) Q: Day of month is in the export but not in the codebook.
#    Use exact dates? A: No, day is unreliable; use mid-month (day 15).
# D5 (2026-10-13) Q: Which treatment counts as exposure? A: Treatment before
#    the start of follow-up (5 years after HL diagnosis); treatment after that
#    is a time-varying exposure. -> This script keeps every course's start
#    date so the exposure script can apply D5.
# D6 (2026-10-14, Q-CT1) Q: Primary anthracycline exposure: (A) doxorubicin
#    dose + epirubicin yes/no, or (B) one doxorubicin-equivalent dose?
#    A: Option A. Doxorubicin-equivalent dose (Feijen 2019 / IGHG 2025 ratios;
#    COG ratios as a further check) is a sensitivity analysis. Mitoxantrone /
#    daunorubicin: separate "other anthracycline/anthraquinone" yes/no.
# D7 (2026-10-14, Q-CT2) Q: Procarbazine: cumulative procarbazine dose, or
#    convert other alkylating agents to "procarbazine equivalents"? Also
#    compute CED? A: Cumulative procarbazine dose; no conversion; no CED.
# D8 (2026-10-14) Q: Keep yes/no variables next to the doses?
#    A: Yes, doxorubicin yes/no and procarbazine yes/no. Both the regimen-
#    derived version and the registry flags (anthrac, procarbazine) are kept.
# D9 (2026-10-14, Q-CT3/Q-CT4) Q: Correct the lookup tables?
#    A: Do NOT change any lookup value that already has a number: codes 58
#    (COPP), 69 (ChlVPP), 61 and 94 (MOPP/ABV(D) alternating, full per-cycle
#    doses), 98 (ChlVPP/ABV: contains procarbazine, 1000 per cycle even though
#    its lookup flag says "No"), 105 (Pro-MACE, doxorubicin 25; only the
#    text-to-code match is fixed). Code 83 (EBVP): epirubicin 70 mg/m2 per
#    cycle (Neppelenbroek 2024). Codes 223/224, 70, 86, 109, 225 and 71: leave
#    the dose missing.
# D10 (2026-10-14, S-CT98) Q: Sensitivity analysis for code 98, because the
#    published hybrid schedules give 560-700 mg/m2 procarbazine per cycle?
#    A: Yes: 700 mg/m2 per cycle in procarb_dose_s98.
# D11 (2026-10-14, Q-CT5/Q-CT6) Q: Dose cut-offs? A: Neppelenbroek 2024.
#    Doxorubicin 0 / 1-200 / >200 mg/m2 + continuous per 100 mg/m2;
#    sensitivity 0 / 1-200 / 201-349 / 350-700. Procarbazine 0 / <=4.2 /
#    4.3-8.4 / >8.4 g/m2.
# D12 (2026-10-14, Q-CT5) Q: Plausibility checks? A: List for review:
#    doxorubicin > 450 mg/m2 or procarbazine > 12 g/m2 without relapse
#    treatment, or ABVD > 8 cycles.
# D13 (2026-10-14) Q: Follow-up course with the chemotherapy flag (ctfup /
#    ctfup2) missing AND no regimen recorded: drug status "unknown" or "no"?
#    A: If no relapse is recorded (recur = 0): code as "no relapse". If a
#    relapse IS recorded (recur = 1): code as "no relapse chemotherapy". In
#    both cases the course contributes dose 0 and drug "no". If recur itself
#    is missing, the course stays "unknown" (not covered by the decision).

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(readxl)
library(lubridate)

# ---- 1. read the raw export ----------------------------------------------------

# read_raw() (00_config.R) reads all columns as character on purpose: the
# chemotherapy codes have different missing-value codes per variable (e.g.
# regimen code 99 is a real regimen, "CCNU / VP-16", and 777 means "other
# chemotherapy"), so a blanket "set 99/777/999 to NA in every numeric
# column" would destroy real information. Each variable is recoded
# explicitly below, following the codebook. Patients with a duplicated
# ResearchID are removed (C13 in 00_config.R).
raw <- read_raw()

# ---- 2. helper functions ---------------------------------------------------------

# Values that the data use for "unknown" in free-entry fields.
# "onbekend" is Dutch for "unknown" and occurs in the export.
unknown_text <- c("onbekend", "Onbekend", "ONBEKEND")

# Mid-month date from month and year columns (D4). The day is always 15.
# Returns NA when the month or year is missing/unknown, when the year is an
# implausible placeholder (the dummy data contain year "1"), or when the
# month is not 1-12. A missing month with a known year is NOT imputed here;
# that is a separate decision for the cleaning script.
mid_month_date <- function(month, year) {
  m <- suppressWarnings(as.integer(ifelse(month %in% unknown_text, NA, month)))
  y <- suppressWarnings(as.integer(ifelse(year %in% unknown_text, NA, year)))
  m[!m %in% 1:12] <- NA
  y[!is.na(y) & (y < 1900 | y > 2100)] <- NA # placeholder years such as 1
  make_date(y, m, 15L)
}

# Yes/no flags coded 0 = no, 1 = yes, 9 = unknown (codebook: ctprim, ctfup,
# ctfup2, anthrac, procarbazine). Anything else is set to NA and reported in
# the checks below (the dummy data code ctfup as 1/2, which does not match
# the codebook; on the real data this must be checked).
recode_yes_no <- function(x) {
  x <- suppressWarnings(as.integer(x))
  case_when(
    x == 1 ~ "yes",
    x == 0 ~ "no",
    x == 9 ~ "unknown",
    TRUE ~ NA_character_
  )
}

# Combine slot-level yes/no into one value for a course or patient:
# any "yes" -> yes; otherwise any "unknown" -> unknown; otherwise no.
combine_yes_no <- function(x) {
  if (any(x == "yes", na.rm = TRUE)) return("yes")
  if (any(x == "unknown" | is.na(x))) return("unknown")
  "no"
}

# Sum doses over slots. If ANY slot is NA the total is unknown (NA): adding
# only the known slots would under-estimate the dose. The sum of the known
# slots is kept separately (as "_known_part") as a lower bound for checking.
sum_or_na <- function(x) if (anyNA(x)) NA_real_ else sum(x)

# ---- 3. one row per patient x course x regimen slot ----------------------------

# Each course (prim, fup, fup2) has up to 6, 7 and 8 regimen "slots":
# c<k>ct<course> = regimen code, n<k>ct<course> = number of cycles.
# The free-text remarks (o<k>ct<course>, in Dutch) are not used for doses.
course_info <- tibble(
  course = c("prim", "fup", "fup2"),
  n_slots = c(6L, 7L, 8L)
)

slot_cols <- course_info |>
  rowwise() |>
  reframe(course = course, slot = seq_len(n_slots)) |>
  mutate(
    code_col = str_glue("c{slot}ct{course}"),
    cycles_col = str_glue("n{slot}ct{course}")
  )

# Keep only the slots that exist in this export (defensive: the real export
# may have more or fewer slots than the codebook lists).
slot_cols <- slot_cols |>
  filter(code_col %in% names(raw), cycles_col %in% names(raw))

slots_long <- purrr::pmap_dfr(slot_cols, function(course, slot, code_col, cycles_col) {
  tibble(
    researchid = raw$researchid,
    course = course,
    slot = slot,
    regimen_raw = raw[[code_col]],
    cycles_raw = raw[[cycles_col]]
  )
}) |>
  # A slot with neither a regimen nor a cycle count was not used: drop it.
  filter(!(is.na(regimen_raw) & is.na(cycles_raw))) |>
  mutate(
    regimen_code = suppressWarnings(as.integer(regimen_raw)),
    # Regimen status, following the drug-coding table in the codebook:
    #   999 = unknown regimen, 777 = other (not in the list).
    #   A cycle count without any regimen code is also "unknown regimen".
    regimen_status = case_when(
      is.na(regimen_raw) ~ "unknown regimen",
      regimen_code == 999 ~ "unknown regimen",
      regimen_code == 777 ~ "other regimen",
      is.na(regimen_code) ~ "unreadable code",
      TRUE ~ "coded"
    ),
    # Number of cycles. D2: 999 = unknown -> NA. Non-numeric -> NA.
    # 0 cycles is kept as 0 (planned but not given) and listed in the checks.
    cycles = suppressWarnings(as.numeric(cycles_raw)),
    cycles = if_else(cycles == 999, NA_real_, cycles)
  )

# ---- 4. regimen -> dose per cycle crosswalk -------------------------------------

chem_drugs <- read_xlsx(lookup_files$chem_drugs) # code, drug, desc
doxo_lu <- read_xlsx(lookup_files$doxorubicin) # trt, doxo (Yes/No), dose
procarb_lu <- read_xlsx(lookup_files$procarbazine) # trt-full.name, ..., dose

# The two dose lookups identify regimens by their DESCRIPTION TEXT, not by
# code. Match the text (whitespace- and case-insensitive) to the description
# in chem_drugs, or to the drug name for single drugs (e.g. "Doxorubicin").
text_key <- function(x) str_to_lower(str_squish(x))
code_from_text <- function(txt) {
  by_desc <- match(text_key(txt), text_key(chem_drugs$desc))
  by_drug <- match(text_key(txt), text_key(chem_drugs$drug))
  chem_drugs$code[coalesce(by_desc, by_drug)]
}

doxo_lu <- doxo_lu |>
  mutate(code = code_from_text(trt))
procarb_lu <- procarb_lu |>
  mutate(code = code_from_text(`trt-full.name`))

# D9, code 105 (Pro-MACE): the doxorubicin lookup row text differs slightly
# from chem_drugs ("Cyclophosphamide" vs "Cyclofosfamide"), so the automatic
# match fails. The row is matched by its leading name instead; its value (25)
# is NOT changed. The other unmatched row ("BEAC ...") contains no
# anthracycline (doxo = "No"), so leaving it unmatched loses nothing.
doxo_lu <- doxo_lu |>
  mutate(code = if_else(is.na(code) & str_detect(trt, "^Pro-MACE"), 105, code))

cat("\n== Lookup rows still not matched to a regimen code ==\n")
print(tibble(table = "doxorubicin", trt = doxo_lu$trt[is.na(doxo_lu$code)]))
print(tibble(table = "procarbazine", trt = procarb_lu$`trt-full.name`[is.na(procarb_lu$code)]))

doxo_lu <- doxo_lu |>
  filter(!is.na(code)) |>
  select(code, doxo_flag = doxo, doxo_lookup = dose)
procarb_lu <- procarb_lu |>
  filter(!is.na(code)) |>
  select(code, procarb_flag = procarbazin, procarb_lookup = dose)

# Which anthracycline / anthraquinone a regimen contains, by code, from the
# codebook's drug-coding table. Assigned by code (not text search) so that
# it can be reviewed line by line.
anthracycline_by_code <- tribble(
  ~code, ~anthracycline,
  2,   "doxorubicin",   # single agent
  41,  "doxorubicin",   # ABVD
  50,  "doxorubicin",   # CHVP / ACVmP
  61,  "doxorubicin",   # MOPP/ABVD
  64,  "doxorubicin",   # B-CAVe
  70,  "doxorubicin",   # VCR + bleomycin + Adriablastine
  80,  "doxorubicin",   # ABV
  81,  "doxorubicin",   # MOPP/ABV hybrid
  82,  "doxorubicin",   # BEACOPP baseline
  86,  "doxorubicin",   # Stanford V
  94,  "doxorubicin",   # MOPP/ABV alternating
  98,  "doxorubicin",   # ChlVPP/ABV
  104, "doxorubicin",   # BEACOPP escalated
  105, "doxorubicin",   # Pro-MACE
  108, "doxorubicin",   # CAV(e)
  217, "doxorubicin",   # OEPA
  218, "doxorubicin",   # OPPA
  219, "doxorubicin",   # CHOP
  220, "doxorubicin",   # CHOP-R
  222, "doxorubicin",   # CAVMP B/V
  225, "doxorubicin",   # R-CHVmP-VB
  230, "doxorubicin",   # AVD
  231, "doxorubicin",   # AV
  237, "doxorubicin",   # ANZA st I&II
  9,   "daunorubicin",  # single agent
  83,  "epirubicin",    # EBVP
  109, "epirubicin",    # EBVD
  110, "epirubicin",    # single agent
  39,  "mitoxantrone",  # single agent
  100, "mitoxantrone",  # vindesine + Novantrone + Endoxan + prednisone
  223, "mitoxantrone",  # CNOP
  224, "mitoxantrone",  # CNOP-R
  26,  "losoxantrone",  # biantrazole (= losoxantrone)
  38,  "losoxantrone"   # losoxantrone (DUP-941)
)

# Procarbazine-containing regimens that are NOT in the procarbazine lookup.
# Code 71 (CCNU + Velbe + Endoxan + Natulan): dose left missing (D9), but it
# does contain procarbazine, which matters for procarbazine yes/no (D8).
procarb_not_in_lookup <- c(71)

# Per-cycle dose (mg/m2 of the drug itself) for anthracyclines whose dose is
# not in the doxorubicin lookup.
#   83 EBVP: epirubicin 70 (D9; Neppelenbroek 2024: 6 x EBVP = 420).
#   All other non-doxorubicin regimens: missing (D9).
anthra_dose_extra <- tribble(
  ~code, ~anthra_extra,
  83, 70
)

# Doxorubicin-equivalence ratios for the SENSITIVITY analysis (D6). These are
# cardiotoxicity-derived; no ratio exists for second cancers (see proposal).
#   feijen: Feijen 2019 JAMA Oncol (doi:10.1001/jamaoncol.2018.6634) /
#           IGHG 2025 (doi:10.1016/j.jaccao.2025.05.009)
#   cog:    COG Long-Term Follow-Up guideline factors, as cited by Koskela
#           2025 (doi:10.1002/ijc.35247); primary COG document unverified
# Losoxantrone has no published ratio: NA in both.
equivalence_ratios <- tribble(
  ~anthracycline, ~ratio_feijen, ~ratio_cog,
  "doxorubicin",  1,             1,
  "daunorubicin", 0.6,           0.5,
  "epirubicin",   0.8,           0.67,
  "mitoxantrone", 10.5,          10,
  "losoxantrone", NA_real_,      NA_real_
)

crosswalk <- chem_drugs |>
  select(code, drug, desc) |>
  left_join(doxo_lu, by = "code") |>
  left_join(procarb_lu, by = "code") |>
  left_join(anthracycline_by_code, by = "code") |>
  left_join(anthra_dose_extra, by = "code") |>
  left_join(equivalence_ratios, by = "anthracycline") |>
  mutate(
    # -- doxorubicin itself (primary exposure, D6) --
    # Regimens without doxorubicin: 0. Doxorubicin regimens: the lookup value
    # unchanged (D9); NA where the lookup has no value (codes 70, 86, 225).
    doxo_per_cycle = case_when(
      anthracycline %in% "doxorubicin" ~ doxo_lookup,
      TRUE ~ 0
    ),
    # -- dose of the anthracycline actually in the regimen, in mg/m2 of that
    #    drug (used only for the doxorubicin-equivalent sensitivity, D6) --
    anthra_per_cycle = case_when(
      is.na(anthracycline) ~ 0,
      anthracycline == "doxorubicin" ~ doxo_lookup,
      TRUE ~ anthra_extra # 83 = 70; others NA (D9)
    ),
    doxo_eq_feijen_per_cycle = anthra_per_cycle * coalesce(ratio_feijen, if_else(is.na(anthracycline), 0, NA_real_)),
    doxo_eq_cog_per_cycle = anthra_per_cycle * coalesce(ratio_cog, if_else(is.na(anthracycline), 0, NA_real_)),
    # -- procarbazine (D7, D9) --
    # The lookup value is used whenever it is a number, including code 98
    # whose flag says "No" (D9: it does contain procarbazine). A regimen in
    # the lookup with flag "No" and no number -> 0. A regimen not in the
    # lookup -> 0, except code 71 which contains procarbazine -> NA.
    procarb_per_cycle = case_when(
      code %in% procarb_not_in_lookup ~ NA_real_,
      !is.na(procarb_lookup) & procarb_lookup > 0 ~ procarb_lookup,
      TRUE ~ 0
    ),
    # S-CT98 (D10): code 98 at 700 mg/m2 per cycle; everything else equal.
    procarb_per_cycle_s98 = if_else(code == 98, 700, procarb_per_cycle),
    # -- contains the drug? (for yes/no, D6/D8) --
    has_doxo = anthracycline %in% "doxorubicin",
    has_epirubicin = anthracycline %in% "epirubicin",
    has_other_anthra = anthracycline %in% c("daunorubicin", "mitoxantrone", "losoxantrone"),
    has_procarb = code %in% procarb_not_in_lookup |
      (!is.na(procarb_lookup) & procarb_lookup > 0)
  )

# ---- 5. dose per slot ------------------------------------------------------------

# D1: slot dose = per-cycle dose x number of cycles. Rules for missing:
#   - regimen unknown / other / unreadable: dose NA, drug yes/no "unknown";
#   - regimen without the drug: dose 0 even if the cycle count is unknown;
#   - regimen with the drug but unknown cycles (D2) or no per-cycle dose
#     (D9): dose NA, drug yes/no "yes".
slot_dose <- function(status, per_cycle, cycles) {
  case_when(
    status != "coded" ~ NA_real_,
    per_cycle %in% 0 ~ 0,
    TRUE ~ per_cycle * cycles
  )
}
slot_yes_no <- function(status, has_drug) {
  case_when(
    status != "coded" ~ "unknown",
    has_drug ~ "yes",
    TRUE ~ "no"
  )
}

slots_long <- slots_long |>
  left_join(
    crosswalk |>
      select(code, anthracycline, doxo_per_cycle, doxo_eq_feijen_per_cycle,
             doxo_eq_cog_per_cycle, procarb_per_cycle, procarb_per_cycle_s98,
             has_doxo, has_epirubicin, has_other_anthra, has_procarb),
    by = c("regimen_code" = "code")
  ) |>
  mutate(
    # Coded regimens that are not in chem_drugs at all: treat as unknown.
    regimen_status = if_else(regimen_status == "coded" & is.na(has_doxo),
                             "code not in chem_drugs", regimen_status),
    doxo_dose = slot_dose(regimen_status, doxo_per_cycle, cycles),
    doxo_eq_feijen_dose = slot_dose(regimen_status, doxo_eq_feijen_per_cycle, cycles),
    doxo_eq_cog_dose = slot_dose(regimen_status, doxo_eq_cog_per_cycle, cycles),
    procarb_dose = slot_dose(regimen_status, procarb_per_cycle, cycles),
    procarb_dose_s98 = slot_dose(regimen_status, procarb_per_cycle_s98, cycles),
    doxo_any = slot_yes_no(regimen_status, has_doxo),
    epirubicin_any = slot_yes_no(regimen_status, has_epirubicin),
    other_anthra_any = slot_yes_no(regimen_status, has_other_anthra),
    procarb_any = slot_yes_no(regimen_status, has_procarb)
  )

# ---- 6. one row per patient x course -------------------------------------------

# Course-level yes/no flag and start date (mid-month, D4).
course_flags <- bind_rows(
  tibble(researchid = raw$researchid, course = "prim",
         ct_given = recode_yes_no(raw$ctprim),
         ct_start = mid_month_date(raw$m_ctprim, raw$y_ctprim)),
  tibble(researchid = raw$researchid, course = "fup",
         ct_given = recode_yes_no(raw$ctfup),
         ct_start = mid_month_date(raw$m_ctfup, raw$y_ctfup)),
  tibble(researchid = raw$researchid, course = "fup2",
         ct_given = recode_yes_no(raw$ctfup2),
         ct_start = mid_month_date(raw$m_ctfup2, raw$y_ctfup2))
)

doses_course <- slots_long |>
  group_by(researchid, course) |>
  summarise(
    n_slots = n(),
    doxo_dose = sum_or_na(doxo_dose),
    doxo_dose_known_part = sum(doxo_dose, na.rm = TRUE),
    doxo_eq_feijen_dose = sum_or_na(doxo_eq_feijen_dose),
    doxo_eq_cog_dose = sum_or_na(doxo_eq_cog_dose),
    procarb_dose = sum_or_na(procarb_dose),
    procarb_dose_known_part = sum(procarb_dose, na.rm = TRUE),
    procarb_dose_s98 = sum_or_na(procarb_dose_s98),
    doxo_any = combine_yes_no(doxo_any),
    epirubicin_any = combine_yes_no(epirubicin_any),
    other_anthra_any = combine_yes_no(other_anthra_any),
    procarb_any = combine_yes_no(procarb_any),
    abvd_cycles_max = suppressWarnings(max(cycles[regimen_code %in% 41], na.rm = TRUE)),
    .groups = "drop"
  ) |>
  mutate(abvd_cycles_max = if_else(is.finite(abvd_cycles_max), abvd_cycles_max, NA_real_))

dose_vars <- c("doxo_dose", "doxo_eq_feijen_dose", "doxo_eq_cog_dose",
               "procarb_dose", "procarb_dose_s98")
yes_no_vars <- c("doxo_any", "epirubicin_any", "other_anthra_any", "procarb_any")

# Relapse of HL (codebook: recur 0 = no, 1 = yes). Used for D13.
relapse <- tibble(
  researchid = raw$researchid,
  recur = suppressWarnings(as.integer(raw$recur))
) |>
  mutate(recur = if_else(recur %in% c(0L, 1L), recur, NA_integer_))

doses_course <- course_flags |>
  left_join(doses_course, by = c("researchid", "course")) |>
  left_join(relapse, by = "researchid") |>
  mutate(
    n_slots = coalesce(n_slots, 0L),
    # Status of the course, so it is clear WHY a dose is 0 or missing:
    #   "chemotherapy recorded"     regimen slot(s) present
    #   "no chemotherapy"           flag = no, no regimen
    #   "no relapse"                D13: follow-up flag missing, no regimen,
    #                               recur = 0
    #   "no relapse chemotherapy"   D13: follow-up flag missing, no regimen,
    #                               recur = 1
    #   "unknown"                   anything else without a regimen (e.g.
    #                               flag yes/unknown, or recur missing)
    ct_course_status = case_when(
      n_slots > 0 ~ "chemotherapy recorded",
      ct_given %in% "no" ~ "no chemotherapy",
      course != "prim" & is.na(ct_given) & recur %in% 0L ~ "no relapse",
      course != "prim" & is.na(ct_given) & recur %in% 1L ~ "no relapse chemotherapy",
      TRUE ~ "unknown"
    ),
    # Dose 0 and drug "no" (not missing) for the three "no" statuses.
    no_ct = ct_course_status %in% c("no chemotherapy", "no relapse",
                                    "no relapse chemotherapy"),
    across(all_of(dose_vars), ~ if_else(no_ct, 0, .x)),
    across(all_of(yes_no_vars), ~ if_else(no_ct, "no", .x)),
    # Chemotherapy "yes" (or status unknown) but no regimen recorded: drug
    # status unknown.
    across(all_of(yes_no_vars), ~ coalesce(.x, "unknown"))
  ) |>
  select(-no_ct, -recur)

# The registry's own yes/no flags (patient level, any time). Kept next to
# the regimen-derived flags for comparison (D8). NOTE: anthrac = ANY
# anthracycline, not only doxorubicin, so e.g. EBVP gives anthrac = yes but
# doxo_any = no.
registry_flags <- tibble(
  researchid = raw$researchid,
  anthrac_registry = recode_yes_no(raw$anthrac),
  anthrac5_registry = recode_yes_no(raw$anthrac5),
  procarb_registry = recode_yes_no(raw$procarbazine)
)

# ---- 7. checks (printed; nothing is changed here) -------------------------------

cat("\n== Course flag vs regimen slots (codebook: 0/1/9) ==\n")
print(count(doses_course, course, ct_given, has_slots = n_slots > 0))

cat("\n== Course status (D13) ==\n")
print(count(doses_course, course, ct_course_status))

cat("\n== Slot regimen status ==\n")
print(count(slots_long, course, regimen_status))

cat("\n== Slots with 0 cycles ==\n")
print(nrow(filter(slots_long, cycles == 0)))

cat("\n== Slots whose doxorubicin or procarbazine dose is NA, by reason ==\n")
print(
  slots_long |>
    filter(is.na(doxo_dose) | is.na(procarb_dose)) |>
    mutate(reason = case_when(
      regimen_status != "coded" ~ regimen_status,
      is.na(cycles) ~ "cycles unknown",
      TRUE ~ "regimen dose missing (D9)"
    )) |>
    count(reason)
)

cat("\n== Cumulative doses per course (mg/m2), where known ==\n")
print(
  doses_course |>
    group_by(course) |>
    summarise(
      n = n(),
      doxo_known = sum(!is.na(doxo_dose)),
      doxo_median = median(doxo_dose[doxo_dose > 0], na.rm = TRUE),
      doxo_max = suppressWarnings(max(doxo_dose, na.rm = TRUE)),
      procarb_known = sum(!is.na(procarb_dose)),
      procarb_median = median(procarb_dose[procarb_dose > 0], na.rm = TRUE),
      procarb_max = suppressWarnings(max(procarb_dose, na.rm = TRUE))
    )
)

cat("\n== Per-regimen doxorubicin dose (mg/m2) ==\n")
print(
  slots_long |>
    filter(regimen_status == "coded", has_doxo) |>
    group_by(regimen_code, doxo_per_cycle) |>
    summarise(n = n(), cycles_med = median(cycles, na.rm = TRUE),
              cycles_max = suppressWarnings(max(cycles, na.rm = TRUE)),
              dose_max = suppressWarnings(max(doxo_dose, na.rm = TRUE)),
              .groups = "drop"),
  n = Inf
)

cat("\n== Per-regimen procarbazine dose (mg/m2) ==\n")
print(
  slots_long |>
    filter(regimen_status == "coded", has_procarb) |>
    group_by(regimen_code, procarb_per_cycle) |>
    summarise(n = n(), cycles_med = median(cycles, na.rm = TRUE),
              cycles_max = suppressWarnings(max(cycles, na.rm = TRUE)),
              dose_max = suppressWarnings(max(procarb_dose, na.rm = TRUE)),
              .groups = "drop"),
  n = Inf
)

cat("\n== Regimen-derived vs registry flags (any course) ==\n")
patient_any <- doses_course |>
  group_by(researchid) |>
  summarise(doxo_any = combine_yes_no(doxo_any),
            epirubicin_any = combine_yes_no(epirubicin_any),
            procarb_any = combine_yes_no(procarb_any), .groups = "drop") |>
  left_join(registry_flags, by = "researchid")
print(count(patient_any, anthrac_registry, doxo_any, epirubicin_any))
print(count(patient_any, procarb_registry, procarb_any))

# S-CT98 (D10): how many patients received code 98, and how many would
# change procarbazine category (D11) because of it. Primary course only here;
# the final count uses the exposure window in the later script.
cat("\n== S-CT98: patients with ChlVPP/ABV (code 98) ==\n")
# procarb_cat() is defined in 00_config.R (D11).
s98 <- doses_course |>
  filter(course == "prim") |>
  semi_join(filter(slots_long, regimen_code == 98), by = "researchid") |>
  mutate(cat_primary = procarb_cat(procarb_dose),
         cat_s98 = procarb_cat(procarb_dose_s98))
cat("patients:", nrow(s98), " category changes:",
    sum(as.character(s98$cat_primary) != as.character(s98$cat_s98), na.rm = TRUE), "\n")

# D12: plausibility review list. "Without relapse treatment" = no
# chemotherapy recorded in the follow-up courses.
relapse_ct <- doses_course |>
  filter(course %in% c("fup", "fup2")) |>
  group_by(researchid) |>
  summarise(relapse_ct = any(ct_given %in% "yes" | n_slots > 0), .groups = "drop")

dose_review <- doses_course |>
  filter(course == "prim") |>
  left_join(relapse_ct, by = "researchid") |>
  mutate(relapse_ct = coalesce(relapse_ct, FALSE)) |>
  mutate(
    flag_doxo = !relapse_ct & doxo_dose > 450,
    flag_procarb = !relapse_ct & procarb_dose > 12000,
    flag_abvd = abvd_cycles_max > 8
  ) |>
  filter(flag_doxo | flag_procarb | flag_abvd) |>
  select(researchid, doxo_dose, procarb_dose, abvd_cycles_max,
         flag_doxo, flag_procarb, flag_abvd)
cat("\n== D12 plausibility review: patients flagged ==\n")
print(summarise(dose_review, n = n(), doxo = sum(flag_doxo, na.rm = TRUE),
                procarb = sum(flag_procarb, na.rm = TRUE),
                abvd = sum(flag_abvd, na.rm = TRUE)))

# ---- 8. dose categories (D11) ---------------------------------------------------

# The cut-off functions doxo_cat(), doxo_cat_fine() and procarb_cat() are in
# 00_config.R so that every script uses exactly the same categories.

# ---- 9. save ----------------------------------------------------------------------

saveRDS(slots_long, file.path(out_dir, "chemo_slots_long.Rds"))
saveRDS(doses_course, file.path(out_dir, "chemo_doses_course.Rds"))
saveRDS(registry_flags, file.path(out_dir, "chemo_registry_flags.Rds"))
saveRDS(dose_review, file.path(out_dir, "chemo_dose_review.Rds"))
