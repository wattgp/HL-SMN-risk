# 04_exposure-window.R
# Joins the cleaned cohort (01), chemotherapy doses (02) and RT exposure (03)
# and places every treatment course in time relative to the start of
# follow-up (5 years after HL diagnosis):
#   - courses BEFORE the start of follow-up form the fixed (baseline)
#     exposure;
#   - courses DURING follow-up update the exposure from their start date
#     onwards (time-varying exposure; decision D5).
# It also matches sarcoma and skin SMNs to the RT fields by body region.
#
# Output (in out_dir from 00_config.R), analytic cohort only:
#   exposure_baseline.Rds   one row per patient: exposure at the start of
#                           follow-up (doses, categories, yes/no, RT
#                           technique, organ exposure per site, ovarian
#                           damage), plus flags for courses during follow-up
#   exposure_tv.Rds         one row per patient x exposure change: the
#                           cumulative exposure from time tstart (years since
#                           start of follow-up) onwards. tstart = 0 is the
#                           baseline. Use with survival::tmerge(tdc()) in the
#                           analysis.
#   course_timing.Rds       one row per patient x treatment course: date used,
#                           how it was obtained, and its window
#   smn_field_match.Rds     sarcoma / skin SMNs with the RT exposure of the
#                           body region where they arose (descriptive)
#
# Run after 01-03:  source(here::here("scripts", "04_exposure-window.R"))

# ---- decision log ------------------------------------------------------------
# Decisions taken earlier and applied here:
# D5 (2026-10-13) Treatment before the start of follow-up is the fixed
#    exposure; treatment after it is time-varying.
# R1 (2026-10-14) Organ exposure 0/1/2; RT technique; mediastinal RT.
# R2 (2026-10-14) Field-to-organ mapping (DRAFT, Berthe to approve);
#    sarcoma / skin SMNs matched to fields by topography where possible.
# R3 (2026-10-14) Ovarian damage = pelvic RT OR procarbazine > 4.2 g/m2.
# D6-D11 (2026-10-14) Doxorubicin dose (primary), epirubicin and other
#    anthracycline yes/no, doxorubicin-equivalent and S-CT98 sensitivity
#    doses, Neppelenbroek categories (00_config.R).
#
# W3 (2026-10-14) Q: Latency lag? A (revised the same day): NO general lag;
#    follow-up starts at 5 years after diagnosis as planned. Instead, a
#    2-YEAR LAG applies to treatment courses that START DURING FOLLOW-UP: such
#    a course counts as exposure only from 2 years after its start date, so
#    follow-up treatment received within 2 years before an SMN diagnosis does
#    not count. Courses before the start of follow-up are baseline exposure
#    without a lag. A course whose lagged date falls after the end of
#    observation never counts.
# W4 (2026-10-14) Q: Combining several courses? A: Doses are summed. If the
#    PRIMARY course dose is known but a later course's dose is unknown, the
#    total is the sum of the KNOWN doses (it is NOT set to unknown) and a
#    flag (<dose>_incomplete) marks that the true total may be higher. If the
#    primary course dose is unknown, the total is unknown. (Organ exposure:
#    highest level over courses; RT technique: largest volume; yes/no: "yes"
#    if any course is yes - as proposed.)
#
# R7 (2026-10-14) Q: Parallel analysis with the export's own RT categories
#    (rtcat, rtsupra, rtmid, rtinfra, rtneck, rtmed; defined with radiation
#    oncologists): primary course only? A: No: use the primary AND follow-up
#    courses. They follow the same windows as all other exposure (baseline
#    before follow-up; courses during follow-up time-varying with the 2-year
#    lag). Combination rules (section 3), APPROVED as proposed 2026-10-14:
#    - rtsupra: full mantle > incomplete mantle > "RT, field unknown" > none
#    - rtneck: full mantle > neck > supraclavicular only > unknown > none
#    - rtmid, rtinfra, rtmed: yes > unknown > none
#    - rtcat is RE-DERIVED from the combined components with the codebook
#      definitions (1 incomplete mantle only, 2 incomplete mantle +
#      infra/mid, 3 full mantle only, 4 full mantle + infra/mid, 5 infra/mid
#      only, 6 other RT, 9 field unknown). The re-derivation is checked
#      against the recorded rtcatprim for patients with primary RT only
#      (check 7.4); if agreement is poor, revisit with the project leader.
# CAP (2026-10-14) Q: Very high cumulative doses in the real data (e.g.
#    procarbazine up to 28 g/m2 from 20 recorded MOPP cycles)? A: For the
#    CONTINUOUS dose variables, cap the dose at a reasonable clinical
#    threshold; the categorical variables use the uncapped dose (the top
#    category absorbs extreme values). Cap values (section 0), CONFIRMED by
#    the project leader 2026-10-14: doxorubicin 550 mg/m2 (commonly cited maximum lifetime
#    cumulative doxorubicin dose) and procarbazine 11,200 mg/m2 (8 cycles of
#    MOPP, the longest standard procarbazine-containing schedule).
# PRIM (2026-10-14) Q: Primary courses recorded 5+ years after diagnosis
#    (12 chemotherapy, 7 RT in the real data)? A: Primary treatment is
#    always within the first 5 years after diagnosis; trust the diagnosis
#    date. Primary courses are ALWAYS baseline exposure, never time-varying
#    (date_source flags those whose recorded date was 5+ years later).
# W1 (2026-10-14) Q: Course with no start date? A: Approved. Primary course:
#    assumed given at HL diagnosis (before follow-up). Follow-up course: the
#    HL relapse date if known; otherwise assumed before the start of
#    follow-up. Flagged in course_timing (date_source).
# W2 (2026-10-14) Q: Course starting after the end of observation? A: That
#    is additional follow-up: the end of follow-up is the last date of ANY
#    data, including treatment course dates (C17 in 01_clean-data.R). So a
#    recorded course can no longer fall after the end of observation; the
#    "after end of observation" window remains only as a safety check.
# REG (2026-10-14) Q: Drug status "unknown" from the regimen codes while
#    the export's own anthrac / procarbazine column says "no"? A: Trust the
#    export's "no": unknown -> "no" and an unknown dose -> 0 (section 4-5,
#    resolve_with_registry). Derived "yes"/"no" are never changed.
# R2a (2026-10-14) Q: Sarcomas / melanomas that arose in an organ (e.g.
#    breast angiosarcoma, C50) could not be matched to a body region. A: Use
#    the organ mapping of that organ (section 6).
# W5 (2026-10-14) Q: Sarcoma / skin body-region matching? A: Descriptive
#    only: it shows how many of these SMNs arose in or next to an RT field.
#    Cohort models for sarcoma and skin use any RT and RT technique.

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(purrr)
library(lubridate)

# ---- 0. settings -----------------------------------------------------------------

w1_missing_fup_date <- "relapse_date_else_baseline" # W1
w3_lag_fup_treatment_years <- 2                      # W3: lag for courses starting during follow-up
cap_doxo_mg <- 550        # CAP: continuous doxorubicin (and doxorubicin-equivalent) dose
cap_procarb_mg <- 11200   # CAP: continuous procarbazine dose

# ---- 1. inputs -------------------------------------------------------------------

cohort <- readRDS(file.path(out_dir, "analytic_cohort.Rds"))
chemo <- readRDS(file.path(out_dir, "chemo_doses_course.Rds"))
rt_fields <- readRDS(file.path(out_dir, "rt_fields_course.Rds"))
rt_organ <- readRDS(file.path(out_dir, "rt_organ_course.Rds"))
smn_long <- readRDS(file.path(out_dir, "smn_long.Rds"))
registry <- readRDS(file.path(out_dir, "chemo_registry_flags.Rds"))

years_between <- function(from, to) time_length(interval(from, to), "years")

key <- cohort |>
  select(researchid, date_dx, date_fup_start, date_end_obs, date_recur)

# RT courses with the organ exposure per site as columns (organ_breast, ...).
rt_input <- rt_fields |>
  left_join(
    rt_organ |> select(researchid, course, site, organ_exposure) |>
      pivot_wider(names_from = site, values_from = organ_exposure,
                  names_prefix = "organ_"),
    by = c("researchid", "course")
  )
organ_cols <- grep("^organ_", names(rt_input), value = TRUE)
dose_vars <- c("doxo_dose", "doxo_eq_feijen_dose", "doxo_eq_cog_dose",
               "procarb_dose", "procarb_dose_s98")

# ---- 2. date of each course and its window (W1, W2, W3) ---------------------------

# A course's date: its recorded start date; if missing, W1. Applied in the
# same way to chemotherapy and RT courses. The window is decided by the
# course date itself; a course starting during follow-up counts only from
# lag_years after its start (W3).
place_course <- function(df, date_col, lag_years) {
  df |>
    inner_join(key, by = "researchid") |>
    mutate(
      date_recorded = .data[[date_col]],
      date_course = case_when(
        !is.na(date_recorded) ~ date_recorded,
        course == "prim" ~ date_dx,
        w1_missing_fup_date == "relapse_date_else_baseline" & !is.na(date_recur) ~ date_recur,
        TRUE ~ date_dx # assumed before the start of follow-up (W1)
      ),
      date_source = case_when(
        course == "prim" & !is.na(date_recorded) & date_recorded >= date_fup_start ~
          "recorded >= 5 years after diagnosis; treated as primary (PRIM)",
        !is.na(date_recorded) ~ "recorded",
        course == "prim" ~ "assumed at HL diagnosis (W1)",
        !is.na(date_recur) ~ "HL relapse date (W1)",
        TRUE ~ "assumed before follow-up (W1)"
      ),
      # W3: no lag before the start of follow-up; a course starting during
      # follow-up counts from its start date + lag_years.
      date_effective = if_else(
        course == "prim" | date_course < date_fup_start, date_course,
        date_course %m+% days(round(lag_years * 365.25))
      ),
      window = case_when(
        # PRIM: the primary course is ALWAYS baseline exposure, even if its
        # recorded date is 5+ years after diagnosis (the diagnosis date is
        # trusted; such a course date is taken to be wrong).
        course == "prim" ~ "baseline",
        date_course < date_fup_start ~ "baseline",
        date_course > date_end_obs ~ "after end of observation (W2)",
        date_effective > date_end_obs ~ "during follow-up, lagged past end of observation (W3)",
        TRUE ~ "during follow-up"
      ),
      t_change = if_else(window == "during follow-up",
                         years_between(date_fup_start, date_effective), NA_real_)
    )
}

# ---- 3. combining courses (W4) -----------------------------------------------------

# W4: total dose over courses. Primary course dose unknown -> total unknown.
# Primary known -> sum of the known course doses; a later course with an
# unknown dose does not make the total unknown but sets the "incomplete"
# flag (the true total may be higher).
dose_total <- function(dose, course) {
  if (anyNA(dose[course == "prim"])) return(NA_real_)
  sum(dose, na.rm = TRUE)
}
dose_incomplete <- function(dose, course) {
  !anyNA(dose[course == "prim"]) & anyNA(dose[course != "prim"])
}
yes_no_any <- function(x) {
  if (any(x == "yes", na.rm = TRUE)) return("yes")
  if (any(x == "unknown" | is.na(x))) return("unknown")
  "no"
}
# 0/1 flags: 1 if any 1; NA if any unknown; else 0.
flag_any <- function(x) {
  if (any(x %in% 1L)) return(1L)
  if (anyNA(x)) return(NA_integer_)
  0L
}
# Organ exposure 0/1/2: highest level; unknown only matters if it could be
# higher than what is known.
organ_max <- function(x) {
  if (any(x %in% 2L)) return(2L)
  if (anyNA(x)) return(NA_integer_)
  max(x, 0L)
}
# RT technique: largest volume (W4).
technique_levels <- c("no RT", "RT, technique unknown", "involved node",
                      "regional field (presumed involved field)",
                      "mantle / extended field")
technique_max <- function(x) {
  r <- match(as.character(x), technique_levels)
  if (any(r >= 3, na.rm = TRUE)) return(technique_levels[max(r, na.rm = TRUE)])
  if (anyNA(r)) return(NA_character_)
  technique_levels[max(r)]
}

# R7: combine the codebook category codes over courses. Each helper takes
# the course codes and returns one code: the highest-ranked known value;
# NA only if no course has a known value.
cb_combine <- function(x, order_high_to_low) {
  for (code in order_high_to_low) if (any(x %in% code)) return(as.integer(code))
  NA_integer_
}
cb_supra <- function(x) cb_combine(x, c(2, 1, 9, 0))    # full > incomplete > unknown > none
cb_neck  <- function(x) cb_combine(x, c(3, 2, 1, 9, 0)) # mantle > neck > supraclav > unknown > none
cb_yes   <- function(x) cb_combine(x, c(1, 9, 0))       # yes > unknown > none
# rtcat re-derived from the combined components (codebook definitions).
cb_cat <- function(supra, mid, infra, any_other6) {
  below <- mid %in% 1L | infra %in% 1L
  case_when(
    supra %in% 2L & below ~ 4L,
    supra %in% 2L ~ 3L,
    supra %in% 1L & below ~ 2L,
    supra %in% 1L ~ 1L,
    supra %in% 0L & below ~ 5L,
    any_other6 ~ 6L,
    supra %in% 9L | mid %in% 9L | infra %in% 9L ~ 9L,
    supra %in% 0L & mid %in% 0L & infra %in% 0L ~ 0L,
    TRUE ~ NA_integer_
  )
}
cb_labels <- list(
  rt_cat_cb = c("no RT", "incomplete mantle, supra only",
                "incomplete mantle + infra/mid-body", "full mantle only",
                "full mantle + infra/mid-body", "infra/mid-body only", "other RT",
                "RT, field unknown"),
  rt_supra_cb = c("none", "incomplete mantle", "full mantle", "RT, field unknown"),
  rt_mid_cb = c("none", "mid-body (para-aortic/spleen)", "RT, field unknown"),
  rt_infra_cb = c("none", "infradiaphragmatic", "RT, field unknown"),
  rt_neck_cb = c("none", "supraclavicular only", "neck", "full mantle", "RT, field unknown"),
  rt_med_cb = c("none", "mediastinal", "RT, field unknown")
)
cb_codes <- list(rt_cat_cb = c(0:6, 9), rt_supra_cb = c(0, 1, 2, 9),
                 rt_mid_cb = c(0, 1, 9), rt_infra_cb = c(0, 1, 9),
                 rt_neck_cb = c(0, 1, 2, 3, 9), rt_med_cb = c(0, 1, 9))

summarise_chemo <- function(df) {
  df |>
    summarise(
      # The "incomplete" flags MUST come before the totals: summarise()
      # evaluates in order, so after the totals line doxo_dose etc. hold the
      # one-number total instead of the per-course doses.
      across(all_of(dose_vars), ~ dose_incomplete(.x, course),
             .names = "{.col}_incomplete"),
      across(all_of(dose_vars), ~ dose_total(.x, course)),
      doxo_any = yes_no_any(doxo_any),
      epirubicin_any = yes_no_any(epirubicin_any),
      other_anthra_any = yes_no_any(other_anthra_any),
      procarb_any = yes_no_any(procarb_any),
      .groups = "drop"
    )
}
summarise_rt <- function(df) {
  df |>
    summarise(
      rt_any = flag_any(rt_given),
      rt_technique = technique_max(rt_technique),
      rt_mediastinal = flag_any(rt_mediastinal),
      rt_pelvic = flag_any(rt_pelvic),
      rt_supra = flag_any(rt_supra),
      rt_infra = flag_any(rt_infra),
      across(all_of(organ_cols), organ_max),
      # R7: codebook categories combined over the courses in the window.
      rtsupra_cb_code = cb_supra(rtsupra_code),
      rtmid_cb_code = cb_yes(rtmid_code),
      rtinfra_cb_code = cb_yes(rtinfra_code),
      rtneck_cb_code = cb_neck(rtneck_code),
      rtmed_cb_code = cb_yes(rtmed_code),
      rtcat_any6 = any(rtcat_code %in% 6L),
      .groups = "drop"
    ) |>
    mutate(rtcat_cb_code = cb_cat(rtsupra_cb_code, rtmid_cb_code,
                                  rtinfra_cb_code, rtcat_any6)) |>
    select(-rtcat_any6)
}

# Derived variables from the summed exposure: categories and ovarian damage.
add_derived <- function(df) {
  df |>
    mutate(
      doxo_cat = doxo_cat(doxo_dose),
      doxo_cat_fine = doxo_cat_fine(doxo_dose),
      # Continuous doses for models are CAPPED (decision CAP); categories
      # below use the uncapped dose. *_capped flags which values were capped.
      doxo_dose_capped = pmin(doxo_dose, cap_doxo_mg),
      doxo_was_capped = doxo_dose > cap_doxo_mg,
      doxo_per100 = doxo_dose_capped / 100, # continuous, per 100 mg/m2
      doxo_eq_feijen_dose_capped = pmin(doxo_eq_feijen_dose, cap_doxo_mg),
      doxo_eq_cog_dose_capped = pmin(doxo_eq_cog_dose, cap_doxo_mg),
      procarb_dose_capped = pmin(procarb_dose, cap_procarb_mg),
      procarb_was_capped = procarb_dose > cap_procarb_mg,
      procarb_per1000 = procarb_dose_capped / 1000, # continuous, per g/m2
      procarb_dose_s98_capped = pmin(procarb_dose_s98, cap_procarb_mg),
      procarb_cat = procarb_cat(procarb_dose),
      procarb_cat_s98 = procarb_cat(procarb_dose_s98),
      # R3: ovarian damage = pelvic RT OR procarbazine > 4.2 g/m2.
      ovarian_damage = case_when(
        rt_pelvic %in% 1L | procarb_dose > procarb_high_mg ~ 1L,
        rt_pelvic %in% 0L & procarb_dose <= procarb_high_mg ~ 0L,
        TRUE ~ NA_integer_
      ),
      rt_cat_cb = factor(rtcat_cb_code, cb_codes$rt_cat_cb, cb_labels$rt_cat_cb),
      rt_supra_cb = factor(rtsupra_cb_code, cb_codes$rt_supra_cb, cb_labels$rt_supra_cb),
      rt_mid_cb = factor(rtmid_cb_code, cb_codes$rt_mid_cb, cb_labels$rt_mid_cb),
      rt_infra_cb = factor(rtinfra_cb_code, cb_codes$rt_infra_cb, cb_labels$rt_infra_cb),
      rt_neck_cb = factor(rtneck_cb_code, cb_codes$rt_neck_cb, cb_labels$rt_neck_cb),
      rt_med_cb = factor(rtmed_cb_code, cb_codes$rt_med_cb, cb_labels$rt_med_cb),
      rt_technique = factor(rt_technique, levels = c(
        "no RT", "mantle / extended field",
        "regional field (presumed involved field)", "involved node",
        "RT, technique unknown"
      ))
    )
}

# REG (2026-10-14): the export's own "ever treated" columns (anthrac,
# procarbazine) are trusted when they say "no". A drug status that is
# "unknown" from the regimen codes (e.g. an unknown regimen) then becomes
# "no", and the matching dose that is unknown becomes 0 (no such drug ever
# given, so it adds nothing). A "yes" or "no" derived from the regimens is
# never changed. anthrac = ANY anthracycline, so it resolves doxorubicin,
# epirubicin and other anthracyclines.
resolve_with_registry <- function(df) {
  df |>
    left_join(registry |> select(researchid, anthrac_registry, procarb_registry),
              by = "researchid") |>
    mutate(
      no_anthra = anthrac_registry %in% "no",
      no_procarb = procarb_registry %in% "no",
      across(c(doxo_any, epirubicin_any, other_anthra_any),
             ~ if_else(no_anthra & .x == "unknown", "no", .x)),
      across(c(doxo_dose, doxo_eq_feijen_dose, doxo_eq_cog_dose),
             ~ if_else(no_anthra & is.na(.x), 0, .x)),
      across(c(doxo_dose_incomplete, doxo_eq_feijen_dose_incomplete,
               doxo_eq_cog_dose_incomplete),
             ~ if_else(no_anthra, FALSE, .x)),
      procarb_any = if_else(no_procarb & procarb_any == "unknown", "no", procarb_any),
      across(c(procarb_dose, procarb_dose_s98), ~ if_else(no_procarb & is.na(.x), 0, .x)),
      across(c(procarb_dose_incomplete, procarb_dose_s98_incomplete),
             ~ if_else(no_procarb, FALSE, .x))
    ) |>
    select(-no_anthra, -no_procarb, -anthrac_registry, -procarb_registry)
}

# ---- 4-5. baseline and time-varying exposure for a given lag (D5, W3) --------------

build_exposure <- function(lag_years) {
  chemo_t <- place_course(chemo, "ct_start", lag_years)
  rt_t <- place_course(rt_input, "rt_start", lag_years)

  course_timing <- bind_rows(
    chemo_t |> transmute(researchid, treatment = "chemotherapy", course,
                         given = ct_course_status, date_recorded, date_course,
                         date_source, window, t_change),
    rt_t |> transmute(researchid, treatment = "radiotherapy", course,
                      given = as.character(rt_given), date_recorded, date_course,
                      date_source, window, t_change)
  )

  # -- 4. baseline (fixed) exposure: courses in the "baseline" window. Every
  # cohort member has a primary-course row in both tables, so every patient
  # gets a baseline row.
  base_chemo <- chemo_t |> filter(window == "baseline") |>
    group_by(researchid) |> summarise_chemo()
  base_rt <- rt_t |> filter(window == "baseline") |>
    group_by(researchid) |> summarise_rt()

  # Any treatment course given during follow-up (description / sensitivity).
  tv_flags <- course_timing |>
    filter(window == "during follow-up",
           (treatment == "chemotherapy" & given == "chemotherapy recorded") |
             (treatment == "radiotherapy" & given == "1")) |>
    group_by(researchid) |>
    summarise(treatment_during_fup = TRUE,
              first_tv_change = min(t_change), .groups = "drop")

  baseline <- cohort |>
    select(researchid) |>
    left_join(base_chemo, by = "researchid") |>
    left_join(base_rt, by = "researchid") |>
    resolve_with_registry() |> # REG
    add_derived() |>
    left_join(tv_flags, by = "researchid") |>
    left_join(registry, by = "researchid") |>
    mutate(treatment_during_fup = coalesce(treatment_during_fup, FALSE))
  stopifnot(nrow(baseline) == nrow(cohort))

  # -- 5. time-varying exposure. Change points = dates (+ lag) of courses
  # during follow-up that were (or may have been) given; courses not given
  # ("no chemotherapy", "no relapse", "no relapse chemotherapy", RT = 0)
  # cannot change the exposure. At each change point the exposure is
  # recomputed from ALL courses up to that point.
  change_points <- course_timing |>
    filter(window == "during follow-up",
           !given %in% c("no chemotherapy", "no relapse",
                         "no relapse chemotherapy", "0")) |>
    distinct(researchid, t_change)

  at_change <- function(df_t, summarise_fun) {
    if (nrow(change_points) == 0) return(NULL)
    change_points |>
      inner_join(df_t |> filter(window %in% c("baseline", "during follow-up")),
                 by = "researchid", relationship = "many-to-many") |>
      filter(window == "baseline" | t_change.y <= t_change.x) |>
      rename(tstart = t_change.x) |>
      group_by(researchid, tstart) |>
      summarise_fun()
  }
  tv_chemo <- at_change(chemo_t, summarise_chemo)
  tv_rt <- at_change(rt_t, summarise_rt)

  tv <- bind_rows(
    baseline |>
      select(researchid, any_of(names(base_chemo)), any_of(names(base_rt))) |>
      mutate(tstart = 0),
    if (!is.null(tv_chemo)) full_join(tv_chemo, tv_rt, by = c("researchid", "tstart"))
  ) |>
    # A change point may come from only chemo or only RT; carry the other
    # treatment's last value forward within the patient.
    arrange(researchid, tstart) |>
    group_by(researchid) |>
    fill(-c(researchid, tstart), .direction = "down") |>
    ungroup() |>
    resolve_with_registry() |> # REG
    add_derived() |>
    relocate(researchid, tstart)

  list(course_timing = course_timing, baseline = baseline, tv = tv,
       rt_t = rt_t)
}

main <- build_exposure(w3_lag_fup_treatment_years)

course_timing <- main$course_timing
exposure_baseline <- main$baseline
exposure_tv <- main$tv
rt_t <- main$rt_t # used for the body-region matching below

# ---- 6. sarcoma / skin SMNs matched to RT fields by body region (R2, W5) -------

# Body region (01_clean-data.R, section 6) -> RT field groups that put the
# region in field (2) or bordering a field (1). DRAFT, to be reviewed by
# Berthe together with the organ mapping in 03_rt-exposure.R.
region_map <- tribble(
  ~body_region,                 ~in_field,                                                                  ~bordering,
  "head / neck",                c("neck", "mantle"),                                                        c("supraclav"),
  "upper limb / shoulder",      c("axilla", "mantle"),                                                      c("supraclav", "infraclav"),
  "lower limb / hip",           c("inguinal", "iliac", "invy"),                                             character(0),
  "thorax / chest wall",        c("mantle", "mediast_any", "lung", "axilla", "infraclav"),                  c("supraclav"),
  "trunk (skin)",               c("mantle", "mediast_any", "lung", "axilla", "paraaortic", "spleen", "invy", "abdomen"), character(0),
  "abdomen / retroperitoneum",  c("paraaortic", "spleen", "splenhil", "invy", "abdomen"),                   c("mediast_low"),
  "pelvis",                     c("invy", "iliac", "inguinal", "abdomen"),                                  c("paraaortic"),
  "spine",                      c("mantle", "mediast_any", "paraaortic", "invy", "neck"),                    character(0)
)

region_exposure <- function(fields_df, in_field, bordering) {
  in_yes <- rowSums(as.matrix(fields_df[in_field]) == 1L, na.rm = TRUE) > 0
  bd_yes <- if (length(bordering)) {
    rowSums(as.matrix(fields_df[bordering]) == 1L, na.rm = TRUE) > 0
  } else rep(FALSE, nrow(fields_df))
  case_when(
    fields_df$rt_given %in% 0L ~ 0L,
    in_yes ~ 2L,
    bd_yes ~ 1L,
    fields_df$rt_given %in% 1L ~ 0L,
    TRUE ~ NA_integer_
  )
}

# R2a (2026-10-14): a sarcoma or melanoma that arose IN AN ORGAN (e.g. a
# breast angiosarcoma, C50) is matched with that ORGAN's exposure from the
# field-to-organ mapping (03_rt-exposure.R), instead of a body region.
organ_from_topo <- function(topo3, topo_num) {
  case_when(
    topo3 == "C50" ~ "breast",
    topo3 == "C34" ~ "lung",
    topo3 == "C73" ~ "thyroid",
    topo3 == "C15" ~ "oesophagus",
    topo3 == "C16" ~ "stomach",
    topo3 == "C25" ~ "pancreas",
    topo3 %in% c("C18", "C19", "C20") ~ "colorectum",
    topo3 %in% c("C53", "C61", "C67") ~ "pelvic_organs",
    (!is.na(topo_num) & topo_num <= 14) | topo3 %in% c("C30", "C31", "C32") ~ "head_neck",
    TRUE ~ NA_character_
  )
}

smn_bt <- smn_long |>
  filter(researchid %in% cohort$researchid, rt_site == "by_topography",
         counts_site_smn, smn_timing == "during follow-up") |>
  mutate(
    organ = organ_from_topo(topo3, topo_num),
    match_method = case_when(
      !is.na(organ) ~ "organ (R2a)",
      !is.na(body_region) & body_region != "other / unspecified" ~ "body region (R2)",
      TRUE ~ "not matchable (location unspecified)"
    )
  )

smn_keys <- c("researchid", "smn_number", "site_group", "topo", "body_region",
              "organ", "match_method", "date_smn")

smn_field_match <- smn_bt |>
  select(all_of(smn_keys)) |>
  left_join(rt_t |> select(researchid, course, date_effective, rt_given,
                           any_of(c("mantle", "invy", "abdomen", "neck", "supraclav",
                                    "infraclav", "axilla", "mediast_any", "mediast_low",
                                    "lung", "paraaortic", "spleen", "splenhil",
                                    "iliac", "inguinal")),
                           all_of(organ_cols)),
            by = "researchid", relationship = "many-to-many") |>
  # Only RT courses given before the SMN.
  filter(date_effective < date_smn) |>
  left_join(region_map, by = "body_region")

smn_field_match <- smn_field_match |>
  mutate(region_exposure = pmap_int(list(row_number()), function(i) {
    r <- smn_field_match[i, ]
    if (r$match_method == "organ (R2a)") {
      return(as.integer(r[[paste0("organ_", r$organ)]]))
    }
    if (r$match_method == "body region (R2)") {
      return(region_exposure(r, smn_field_match$in_field[[i]],
                             smn_field_match$bordering[[i]]))
    }
    NA_integer_
  })) |>
  group_by(across(all_of(smn_keys))) |>
  summarise(region_exposure = organ_max(region_exposure), .groups = "drop")

# SMNs with no RT course before them still need a row.
smn_field_match <- smn_bt |>
  select(all_of(smn_keys)) |>
  left_join(smn_field_match, by = smn_keys) |>
  mutate(region_exposure_3 = factor(region_exposure, levels = 0:2,
                                    labels = c("not irradiated", "bordering field", "in field")),
         # X1 (2026-10-14): analyses use in field vs not in field.
         region_exposure = factor(if_else(region_exposure == 2, "in field", "not in field"),
                                  levels = c("not in field", "in field")))

# ---- 7. checks with advice for action (printed; nothing is changed here) -------

# Each check prints a table and then one or more lines starting with
# "OK:" (nothing to do) or "ACTION:" (what to look at, and what to do). The
# thresholds below decide when a check asks for action; they are rules of
# thumb for review, not analysis decisions.
pct <- function(x, n) if (n == 0) 0 else round(100 * x / n, 1)
advise <- function(needs_action, action, ok) {
  cat(if (needs_action) paste("ACTION:", action) else paste("OK:", ok), "\n")
}
threshold_pct <- 5 # % missing / disagreeing above which a check asks for action

# -- 7.1 Course dates (W1, W2) --
cat("\n== 7.1 Course dates: how obtained, and window (W1-W3) ==\n")
print(count(course_timing, treatment, course, date_source, window), n = Inf)
given_courses <- course_timing |>
  filter((treatment == "chemotherapy" & given == "chemotherapy recorded") |
           (treatment == "radiotherapy" & given == "1"))
n_fup_assumed <- sum(given_courses$course != "prim" &
                       given_courses$date_source == "assumed before follow-up (W1)")
advise(n_fup_assumed > 0,
       paste0(n_fup_assumed, " relapse treatment course(s) were GIVEN but have no date and no ",
              "relapse date; they are assumed to be before follow-up (W1). If relapse ",
              "treatment more than 5 years after diagnosis is plausible for these ",
              "patients, look up the dates in the source records; otherwise note the ",
              "number in the methods."),
       "every relapse course that was given has a recorded or relapse date.")
n_prim_late <- sum(grepl("treated as primary", course_timing$date_source))
advise(n_prim_late > 0,
       paste0(n_prim_late, " primary course(s) have a recorded date 5+ years after ",
              "diagnosis; they are treated as baseline primary treatment (PRIM). ",
              "Their recorded dates are probably wrong: correct them in the source ",
              "if possible, and report the number in the methods."),
       "no primary course is dated 5+ years after diagnosis.")
n_after_end <- sum(course_timing$window == "after end of observation (W2)")
advise(n_after_end > 0,
       paste0(n_after_end, " course(s) start after the end of observation. Because follow-up ",
              "runs to the last date of any data (C17), this can only happen for patients ",
              "who died: the course is dated after the death date. Check these dates ",
              "(course_timing.Rds, window = 'after end of observation (W2)') against ",
              "the source and correct the date or the death date."),
       "no course starts after the end of observation.")

# -- 7.2 Baseline exposure and missingness --
cat("\n== 7.2 Baseline exposure ==\n")
print(count(exposure_baseline, doxo_cat))
print(count(exposure_baseline, procarb_cat))
print(count(exposure_baseline, rt_technique))
print(count(exposure_baseline, ovarian_damage))
n_base <- nrow(exposure_baseline)
miss <- c(
  doxorubicin_dose = sum(is.na(exposure_baseline$doxo_dose)),
  procarbazine_dose = sum(is.na(exposure_baseline$procarb_dose)),
  rt_technique = sum(is.na(exposure_baseline$rt_technique)),
  ovarian_damage = sum(is.na(exposure_baseline$ovarian_damage))
)
cat("Missing (n, %):\n")
print(data.frame(n = miss, pct = sapply(miss, pct, n = n_base)))
advise(any(sapply(miss, pct, n = n_base) > threshold_pct),
       paste0("more than ", threshold_pct, "% missing for: ",
              paste(names(miss)[sapply(miss, pct, n = n_base) > threshold_pct], collapse = ", "),
              ". The SAP requires a list of imputation approaches BEFORE any ",
              "imputation code: send these percentages to the project leader. To see ",
              "why doses are missing, read the 02_chemo-doses.R check 'Slots whose ",
              "doxorubicin or procarbazine dose is NA, by reason'."),
       paste0("missingness is at most ", threshold_pct, "% for the main exposures."))

# -- 7.3 W4 incomplete totals --
cat("\n== 7.3 W4: baseline totals that may be higher (a later course dose unknown) ==\n")
incompl <- colSums(exposure_baseline[paste0(dose_vars, "_incomplete")], na.rm = TRUE)
print(incompl)
advise(any(incompl > 0),
       paste0(max(incompl), " patient(s) have a total dose that is a LOWER BOUND (primary ",
              "dose known, a later course unknown; W4). They may be put in too low a ",
              "dose category. Report the number, and plan a sensitivity analysis ",
              "excluding them (agree with the project leader)."),
       "no baseline total is a lower bound.")

# -- 7.3b CAP: continuous doses capped --
cat("\n== 7.3b CAP: baseline doses above the cap (continuous variables capped) ==\n")
n_cap_d <- sum(exposure_baseline$doxo_was_capped, na.rm = TRUE)
n_cap_p <- sum(exposure_baseline$procarb_was_capped, na.rm = TRUE)
cat("doxorubicin >", cap_doxo_mg, "mg/m2:", n_cap_d,
    "| procarbazine >", cap_procarb_mg, "mg/m2:", n_cap_p, "\n")
advise(n_cap_d + n_cap_p > 0,
       paste0(n_cap_d + n_cap_p, " baseline dose(s) were capped for the continuous ",
              "variables. Most are probably recording errors in the number of cycles: ",
              "review them with chemo_dose_review.Rds (02_chemo-doses.R) and the ",
              "source records; report the number capped in the methods."),
       "no baseline dose exceeds the caps.")

# -- 7.4 R7: re-derived codebook rtcat vs recorded rtcatprim --
cat("\n== 7.4 R7: re-derived rtcat vs recorded rtcatprim (patients whose only baseline RT course is primary) ==\n")
prim_only <- course_timing |>
  filter(treatment == "radiotherapy", window == "baseline", given == "1") |>
  count(researchid) |> filter(n == 1) |> pull(researchid)
r7 <- exposure_baseline |>
  filter(researchid %in% prim_only) |>
  select(researchid, rt_cat_cb) |>
  left_join(rt_fields |> filter(course == "prim") |>
              select(researchid, rt_cat_recorded = rt_cat_cb), by = "researchid") |>
  mutate(agree = as.character(rt_cat_cb) == as.character(rt_cat_recorded))
print(count(r7, agree))
n_disagree <- sum(!r7$agree, na.rm = TRUE)
advise(pct(n_disagree, nrow(r7)) > threshold_pct,
       paste0(pct(n_disagree, nrow(r7)), "% of single-course patients have a re-derived rtcat ",
              "that differs from the radiation oncologists' rtcatprim. The radiation ",
              "oncologists probably used rules beyond the codebook definitions. Look ",
              "at the cross-table below, then either adjust cb_cat() in section 3 or ",
              "use the recorded rtcat for patients with one course; decide with the ",
              "project leader."),
       paste0("the re-derived rtcat agrees with rtcatprim for ",
              100 - pct(n_disagree, nrow(r7)), "% of single-course patients."))
if (n_disagree > 0) {
  print(count(filter(r7, !agree), rt_cat_recorded, rt_cat_cb), n = Inf)
}

# -- 7.5 Baseline organ exposure --
cat("\n== 7.5 Baseline organ exposure (0/1/2) ==\n")
organ_tab <- exposure_baseline |>
  select(researchid, all_of(organ_cols)) |>
  pivot_longer(-researchid, names_to = "site", values_to = "exposure") |>
  count(site, exposure) |>
  pivot_wider(names_from = exposure, values_from = n, names_prefix = "exp_", values_fill = 0)
print(organ_tab)
organ_miss <- organ_tab |>
  mutate(pct_na = pct(if ("exp_NA" %in% names(organ_tab)) exp_NA else 0, n_base))
advise(any(organ_miss$pct_na > threshold_pct),
       paste0("organ exposure is unknown for more than ", threshold_pct, "% of patients for: ",
              paste(organ_miss$site[organ_miss$pct_na > threshold_pct], collapse = ", "),
              ". Unknown means a relevant field flag is 9/missing or RT was given with ",
              "no field recorded. Check the 03_rt-exposure.R tables 'RT technique per ",
              "course' and 'Free-text field names'; include these in the imputation ",
              "options for the project leader."),
       paste0("organ exposure is unknown for at most ", threshold_pct, "% of patients for every site."))
cat("REMINDER: the field-to-organ mapping is a DRAFT until Berthe approves it (R2).\n")

# -- 7.6 Time-varying exposure --
cat("\n== 7.6 Time-varying exposure (tstart > 0; 2-year lag, W3) ==\n")
n_tv_pat <- n_distinct(exposure_tv$researchid[exposure_tv$tstart > 0])
cat(sum(exposure_tv$tstart > 0), "change points in", n_tv_pat, "patients\n")
advise(n_tv_pat < 10,
       paste0("only ", n_tv_pat, " patient(s) have exposure that changes during follow-up. ",
              "Time-varying models will differ little from baseline-only models; tell ",
              "the project leader, who may prefer baseline exposure in the main models ",
              "with the time-varying version as a check."),
       paste0(n_tv_pat, " patients have exposure that changes during follow-up; use ",
              "exposure_tv.Rds in the models (survival::tmerge with tdc())."))

# -- 7.7 Sarcoma / skin body-region matching --
cat("\n== 7.7 Sarcoma / skin SMNs by body-region RT exposure (W5, descriptive) ==\n")
print(count(smn_field_match, site_group, match_method, region_exposure), n = Inf)
n_region_unknown <- sum(is.na(smn_field_match$region_exposure))
advise(n_region_unknown > 0,
       paste0(n_region_unknown, " sarcoma/skin SMN(s) could not be matched to a field: the ",
              "topography is unspecified (e.g. C44.9, C49.9) or no RT field information ",
              "exists. List them with smn_field_match.Rds (region_exposure NA, ",
              "body_region) and decide whether the topography can be refined from ",
              "the source; otherwise report them as 'location unknown'."),
       "every sarcoma/skin SMN was matched to a body region.")
cat("REMINDER: the body-region mapping is a DRAFT until Berthe approves it (R2).\n")

# ---- 8. save ----------------------------------------------------------------------

saveRDS(exposure_baseline, file.path(out_dir, "exposure_baseline.Rds"))
saveRDS(exposure_tv, file.path(out_dir, "exposure_tv.Rds"))
saveRDS(course_timing, file.path(out_dir, "course_timing.Rds"))
saveRDS(smn_field_match, file.path(out_dir, "smn_field_match.Rds"))


