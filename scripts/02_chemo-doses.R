# 02_chemo-doses.R
# Converts the recorded chemotherapy (regimen code + number of cycles, for the
# primary treatment and up to two follow-up / relapse treatment courses) into
# cumulative doses in mg/m2:
#   - doxorubicin-equivalent dose (anthracyclines and anthraquinones)
#   - procarbazine dose
#
# Output (in out_dir from 00_config.R):
#   chemo_slots_long.Rds    one row per patient x course x regimen slot
#   chemo_doses_course.Rds  one row per patient x course (prim / fup / fup2),
#                           with the course start date, so a later script can
#                           split exposure into "before start of follow-up"
#                           and "time-varying after start of follow-up"
#
# STATUS: DRAFT. Conversion factors for non-doxorubicin anthracyclines and
# several lookup gaps are PENDING the project leader's decision (see the
# "PENDING" items below). Until then those regimens get an NA dose and are
# counted in the "dose unknown" checks.
#
# Run from the project:  source(here::here("scripts", "02_chemo-doses.R"))

# ---- decision log ------------------------------------------------------------
# Questions put to the project leader (G. Watt) and the answers given. Each
# decision is referred to by its tag (D1, D2, ...) where it is applied below.
#
# D1 (2026-10-13) Q: Are the doses in the lookup tables mg/m2 per cycle, and is
#    cumulative dose = per-cycle dose x number of cycles?
#    A: Yes.
# D2 (2026-10-13) Q: Is a cycle count of 999 "unknown" (dose then missing)?
#    A: Yes.
# D3 (2026-10-13) Q: Should non-doxorubicin anthracyclines (epirubicin,
#    daunorubicin, mitoxantrone) be converted with literature conversion
#    factors? A: Yes; propose factors with verified citations and check that
#    the converted doses are reasonable.  -> factors PENDING (see below).
# D4 (2026-10-13) Q: Day of month is in the export but not in the codebook.
#    Use exact dates? A: No, day is unreliable; use mid-month (day 15).
# D5 (2026-10-13) Q: Which treatment counts as exposure? A: Treatment given
#    before the start of follow-up (5 years after HL diagnosis); treatment
#    after that is handled as a time-varying exposure. -> This script keeps
#    the start date of every course so that later scripts can apply D5.

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(readxl)
library(lubridate)

# ---- 1. read the raw export ----------------------------------------------------

# The export is semicolon-delimited (see 01_clean-data.R). All columns are
# read as character on purpose: the chemotherapy codes have different
# missing-value codes per variable (e.g. regimen code 99 is a real regimen,
# "CCNU / VP-16", and 777 means "other chemotherapy"), so the blanket
# "set 99/777/999 to NA in every numeric column" used in 01_clean-data.R
# would destroy real information here. Each variable is recoded explicitly
# below, following the codebook.
raw <- read_delim(
  raw_file,
  delim = ";",
  col_types = cols(.default = col_character()),
  locale = locale(decimal_mark = ".", grouping_mark = ","),
  na = c("", "NA") # only true blanks are missing at this stage
)

# Lower-case names so that e.g. "Smn2_site" and "smn2_site" are the same
# (the codebook and the export are not consistent in capitalisation).
names(raw) <- tolower(names(raw))

# ---- 2. helper functions ---------------------------------------------------------

# Values that the codebook / data use for "unknown" in free-entry fields.
# "onbekend" is Dutch for "unknown" and occurs in the export.
unknown_text <- c("onbekend", "Onbekend", "ONBEKEND")

# Mid-month date from month and year columns (D4). The day is always 15.
# Returns NA when the month or year is missing/unknown, when the year is an
# implausible placeholder (the dummy data contain year "1"), or when the
# month is not 1-12. Missing month with a known year is NOT imputed here;
# that is a separate decision for the cleaning script.
mid_month_date <- function(month, year) {
  m <- suppressWarnings(as.integer(ifelse(month %in% unknown_text, NA, month)))
  y <- suppressWarnings(as.integer(ifelse(year %in% unknown_text, NA, year)))
  m[!m %in% 1:12] <- NA
  y[!is.na(y) & (y < 1900 | y > 2100)] <- NA # placeholder years such as 1
  make_date(y, m, 15L)
}

# Treatment yes/no flags (ctprim, ctfup, ctfup2). Codebook: 0 = no,
# 1 = yes, 9 = unknown. Anything else is set to NA and reported in the
# checks below (the dummy data code ctfup as 1/2, which does not match the
# codebook; on the real data this must be checked).
recode_yes_no <- function(x) {
  x <- suppressWarnings(as.integer(x))
  case_when(
    x == 1 ~ "yes",
    x == 0 ~ "no",
    x == 9 ~ "unknown",
    TRUE ~ NA_character_
  )
}

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
    # 0 cycles is kept as 0 (it would mean the regimen was planned but not
    # given) and is listed in the checks.
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
  mutate(code = code_from_text(trt)) |>
  select(code, doxo_flag = doxo, doxo_per_cycle = dose)
procarb_lu <- procarb_lu |>
  mutate(code = code_from_text(`trt-full.name`)) |>
  select(code, procarb_flag = procarbazin, procarb_per_cycle = dose)

# Lookup rows whose text did not match any code. On 2026-10-13 these were
# "BEAC ..." and "Pro-MACE ..." (doxorubicin table; text differs slightly
# from chem_drugs). Pro-MACE contains doxorubicin, so its code (105) is
# added by hand in the PENDING list below.
stopifnot(is.data.frame(doxo_lu))
unmatched_lookup <- c(
  doxo = sum(is.na(doxo_lu$code)),
  procarb = sum(is.na(procarb_lu$code))
)

crosswalk <- chem_drugs |>
  select(code, drug, desc) |>
  left_join(filter(doxo_lu, !is.na(code)), by = "code") |>
  left_join(filter(procarb_lu, !is.na(code)), by = "code")

# Anthracycline / anthraquinone in the regimen, and which one. Used to apply
# the doxorubicin-equivalence factor (D3). Assigned by code from the
# codebook's drug-coding table, not by text search, so it can be reviewed.
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

# D3: factor to convert 1 mg/m2 of the drug into mg/m2 doxorubicin.
# Doxorubicin = 1 by definition. All others are PENDING the literature
# review and the project leader's choice; NA means "dose unknown" for now.
equivalence_factor <- tribble(
  ~anthracycline, ~factor_to_doxo, ~source,
  "doxorubicin",  1,               "definition",
  "daunorubicin", NA_real_,        "PENDING",
  "epirubicin",   NA_real_,        "PENDING",
  "mitoxantrone", NA_real_,        "PENDING",
  "losoxantrone", NA_real_,        "PENDING"
)

# PENDING: per-cycle doses missing from, or questionable in, the lookups.
# NA = not yet decided. These override the lookup values for these codes
# only, and each needs the project leader's sign-off before use.
#   70  VCR + bleomycin + Adriablastine: not in doxorubicin lookup
#   86  Stanford V: not in lookup; it is a 12-week schedule, so the meaning
#       of "1 cycle" must be agreed first
#   105 Pro-MACE: in lookup (25 mg/m2) but text did not match the code
#   225 R-CHVmP-VB: not in lookup
#   61, 94 MOPP/ABV(D) alternating: lookup gives the full doxorubicin AND
#       full procarbazine dose per cycle; if "cycles" counts MOPP and ABV(D)
#       cycles together, each drug is only given in half of them
#   98  ChlVPP/ABV: procarbazine flag says "No" but dose says 1000
#   71  CCNU + Velbe + Endoxan + Natulan: contains procarbazine, not in
#       procarbazine lookup
#   Non-doxorubicin anthracycline regimens (9, 39, 83, 100, 109, 110, 223,
#   224, 26, 38): lookup has dose 0 or nothing; drug dose per cycle needed
pending_overrides <- tribble(
  ~code, ~drug_per_cycle_override, ~procarb_per_cycle_override,
  70,  NA_real_, NA_real_,
  86,  NA_real_, NA_real_,
  105, NA_real_, NA_real_,
  225, NA_real_, NA_real_,
  71,  NA_real_, NA_real_
)

crosswalk <- crosswalk |>
  left_join(anthracycline_by_code, by = "code") |>
  left_join(equivalence_factor, by = "anthracycline") |>
  mutate(
    # Per-cycle dose of the anthracycline itself (mg/m2 of that drug).
    # For doxorubicin regimens this is the lookup value. For the other
    # anthracyclines the lookup holds 0 (or nothing), which would wrongly
    # mean "no anthracycline", so it is set to NA until decided.
    anthra_per_cycle = case_when(
      is.na(anthracycline) ~ 0, # regimen has no anthracycline
      anthracycline == "doxorubicin" ~ doxo_per_cycle,
      TRUE ~ NA_real_ # PENDING (D3)
    ),
    doxo_eq_per_cycle = anthra_per_cycle * factor_to_doxo,
    doxo_eq_per_cycle = if_else(is.na(anthracycline), 0, doxo_eq_per_cycle),
    # Procarbazine: lookup value if the regimen is in the procarbazine table
    # with flag "Yes"; 0 if listed with "No"; NA if the regimen is not in
    # the table at all (unknown whether it contains procarbazine).
    procarb_per_cycle = case_when(
      procarb_flag == "Yes" ~ procarb_per_cycle,
      procarb_flag == "No" ~ 0,
      TRUE ~ NA_real_
    )
  ) |>
  # Codes with an open question get NA until decided (PENDING list).
  mutate(
    doxo_eq_per_cycle = if_else(code %in% pending_overrides$code &
      !is.na(anthracycline), NA_real_, doxo_eq_per_cycle),
    procarb_per_cycle = if_else(code %in% c(71, 61, 94, 98), NA_real_,
      procarb_per_cycle),
    doxo_eq_per_cycle = if_else(code %in% c(61, 94), NA_real_,
      doxo_eq_per_cycle)
  )

# ---- 5. dose per slot ------------------------------------------------------------

slots_long <- slots_long |>
  left_join(
    crosswalk |> select(code, anthracycline, doxo_eq_per_cycle, procarb_per_cycle),
    by = c("regimen_code" = "code")
  ) |>
  mutate(
    # D1: cumulative dose for the slot = per-cycle dose x number of cycles.
    # It is NA when the regimen is unknown/other, the regimen's dose is
    # PENDING, or the number of cycles is unknown (D2). A regimen without
    # the drug gives 0 even when the cycle count is unknown, because the
    # dose is then 0 regardless of the number of cycles.
    doxo_eq_dose = case_when(
      regimen_status != "coded" ~ NA_real_,
      doxo_eq_per_cycle == 0 ~ 0,
      TRUE ~ doxo_eq_per_cycle * cycles
    ),
    procarb_dose = case_when(
      regimen_status != "coded" ~ NA_real_,
      procarb_per_cycle == 0 ~ 0,
      TRUE ~ procarb_per_cycle * cycles
    )
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
    # Sum over slots. If ANY slot is NA the course total is unknown (NA):
    # adding only the known slots would under-estimate the dose. The sum of
    # the known slots is kept separately as a lower bound for checking.
    doxo_eq_dose = if (anyNA(doxo_eq_dose)) NA_real_ else sum(doxo_eq_dose),
    doxo_eq_dose_known_part = sum(doxo_eq_dose, na.rm = TRUE),
    procarb_dose = if (anyNA(procarb_dose)) NA_real_ else sum(procarb_dose),
    procarb_dose_known_part = sum(procarb_dose, na.rm = TRUE),
    any_anthracycline = any(!is.na(anthracycline)),
    any_procarbazine = any(procarb_per_cycle > 0, na.rm = TRUE),
    .groups = "drop"
  )

doses_course <- course_flags |>
  left_join(doses_course, by = c("researchid", "course")) |>
  mutate(
    n_slots = coalesce(n_slots, 0L),
    # No chemotherapy in this course -> dose 0 (not missing).
    doxo_eq_dose = if_else(ct_given == "no" & n_slots == 0, 0, doxo_eq_dose),
    procarb_dose = if_else(ct_given == "no" & n_slots == 0, 0, procarb_dose)
  )

# ---- 7. checks (printed; nothing is changed here) -------------------------------

cat("\n== Lookup rows not matched to a regimen code ==\n")
print(unmatched_lookup)

cat("\n== Course flag vs regimen slots (codebook: 0/1/9) ==\n")
print(count(doses_course, course, ct_given, has_slots = n_slots > 0))

cat("\n== Slot regimen status ==\n")
print(count(slots_long, course, regimen_status))

cat("\n== Slots with 0 cycles ==\n")
print(nrow(filter(slots_long, cycles == 0)))

cat("\n== Slots whose dose is NA, by reason ==\n")
print(
  slots_long |>
    filter(is.na(doxo_eq_dose) | is.na(procarb_dose)) |>
    mutate(reason = case_when(
      regimen_status != "coded" ~ regimen_status,
      is.na(cycles) ~ "cycles unknown",
      TRUE ~ "regimen dose PENDING"
    )) |>
    count(reason)
)

cat("\n== Cumulative doses per course (mg/m2), where known ==\n")
print(
  doses_course |>
    group_by(course) |>
    summarise(
      n = n(),
      doxo_known = sum(!is.na(doxo_eq_dose)),
      doxo_median = median(doxo_eq_dose[doxo_eq_dose > 0], na.rm = TRUE),
      doxo_max = suppressWarnings(max(doxo_eq_dose, na.rm = TRUE)),
      procarb_known = sum(!is.na(procarb_dose)),
      procarb_median = median(procarb_dose[procarb_dose > 0], na.rm = TRUE),
      procarb_max = suppressWarnings(max(procarb_dose, na.rm = TRUE))
    )
)

cat("\n== Per-regimen doses: doxorubicin-equivalent (mg/m2) ==\n")
print(
  slots_long |>
    filter(regimen_status == "coded", !is.na(anthracycline)) |>
    group_by(regimen_code, anthracycline, doxo_eq_per_cycle) |>
    summarise(n = n(), cycles_med = median(cycles, na.rm = TRUE),
              cycles_max = suppressWarnings(max(cycles, na.rm = TRUE)),
              dose_max = suppressWarnings(max(doxo_eq_dose, na.rm = TRUE)),
              .groups = "drop"),
  n = Inf
)

# ---- 8. save ----------------------------------------------------------------------

saveRDS(slots_long, file.path(out_dir, "chemo_slots_long.Rds"))
saveRDS(doses_course, file.path(out_dir, "chemo_doses_course.Rds"))
