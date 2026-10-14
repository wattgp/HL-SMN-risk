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
# W1 (2026-10-14) Q: Course with no start date? A: Approved. Primary course:
#    assumed given at HL diagnosis (before follow-up). Follow-up course: the
#    HL relapse date if known; otherwise assumed before the start of
#    follow-up. Flagged in course_timing (date_source).
# W2 (2026-10-14) Q: Course starting after the end of observation? A: That
#    is additional follow-up: the end of follow-up is the last date of ANY
#    data, including treatment course dates (C17 in 01_clean-data.R). So a
#    recorded course can no longer fall after the end of observation; the
#    "after end of observation" window remains only as a safety check.
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
        !is.na(date_recorded) ~ "recorded",
        course == "prim" ~ "assumed at HL diagnosis (W1)",
        !is.na(date_recur) ~ "HL relapse date (W1)",
        TRUE ~ "assumed before follow-up (W1)"
      ),
      # W3: no lag before the start of follow-up; a course starting during
      # follow-up counts from its start date + lag_years.
      date_effective = if_else(
        date_course < date_fup_start, date_course,
        date_course %m+% days(round(lag_years * 365.25))
      ),
      window = case_when(
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

summarise_chemo <- function(df) {
  df |>
    summarise(
      across(all_of(dose_vars), ~ dose_total(.x, course)),
      across(all_of(dose_vars), ~ dose_incomplete(.x, course),
             .names = "{.col}_incomplete"),
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
      .groups = "drop"
    )
}

# Derived variables from the summed exposure: categories and ovarian damage.
add_derived <- function(df) {
  df |>
    mutate(
      doxo_cat = doxo_cat(doxo_dose),
      doxo_cat_fine = doxo_cat_fine(doxo_dose),
      doxo_per100 = doxo_dose / 100, # continuous, per 100 mg/m2
      procarb_cat = procarb_cat(procarb_dose),
      procarb_cat_s98 = procarb_cat(procarb_dose_s98),
      # R3: ovarian damage = pelvic RT OR procarbazine > 4.2 g/m2.
      ovarian_damage = case_when(
        rt_pelvic %in% 1L | procarb_dose > procarb_high_mg ~ 1L,
        rt_pelvic %in% 0L & procarb_dose <= procarb_high_mg ~ 0L,
        TRUE ~ NA_integer_
      ),
      rt_technique = factor(rt_technique, levels = c(
        "no RT", "mantle / extended field",
        "regional field (presumed involved field)", "involved node",
        "RT, technique unknown"
      ))
    )
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

smn_bt <- smn_long |>
  filter(researchid %in% cohort$researchid, rt_site == "by_topography",
         counts_site_smn, smn_timing == "during follow-up")

smn_field_match <- smn_bt |>
  select(researchid, smn_number, site_group, topo, body_region, date_smn) |>
  left_join(rt_t |> select(researchid, course, date_effective, rt_given,
                           any_of(c("mantle", "invy", "abdomen", "neck", "supraclav",
                                    "infraclav", "axilla", "mediast_any", "mediast_low",
                                    "lung", "paraaortic", "spleen", "splenhil",
                                    "iliac", "inguinal"))),
            by = "researchid", relationship = "many-to-many") |>
  # Only RT courses given before the SMN.
  filter(date_effective < date_smn) |>
  left_join(region_map, by = "body_region")

smn_field_match <- smn_field_match |>
  mutate(region_exposure = if_else(
    is.na(body_region) | body_region == "other / unspecified" |
      map_lgl(in_field, is.null),
    NA_integer_,
    pmap_int(list(row_number()), function(i) {
      region_exposure(smn_field_match[i, ], smn_field_match$in_field[[i]],
                      smn_field_match$bordering[[i]])
    })
  )) |>
  group_by(researchid, smn_number, site_group, topo, body_region, date_smn) |>
  summarise(region_exposure = organ_max(region_exposure), .groups = "drop")

# SMNs with no RT course before them still need a row.
smn_field_match <- smn_bt |>
  select(researchid, smn_number, site_group, topo, body_region, date_smn) |>
  left_join(smn_field_match,
            by = c("researchid", "smn_number", "site_group", "topo",
                   "body_region", "date_smn")) |>
  mutate(region_exposure = factor(region_exposure, levels = 0:2,
                                  labels = c("not irradiated", "bordering field", "in field")))

# ---- 7. checks (printed; nothing is changed here) -------------------------------

cat("\n== Course dates: how obtained, and window (W1-W3) ==\n")
print(count(course_timing, treatment, course, date_source, window), n = Inf)

cat("\n== Baseline exposure ==\n")
print(count(exposure_baseline, doxo_cat))
print(count(exposure_baseline, procarb_cat))
print(count(exposure_baseline, rt_technique))
print(count(exposure_baseline, ovarian_damage))
cat("Patients with treatment during follow-up:", sum(exposure_baseline$treatment_during_fup), "\n")

cat("\n== W4: baseline totals that may be higher (a later course dose unknown) ==\n")
print(colSums(exposure_baseline[paste0(dose_vars, "_incomplete")], na.rm = TRUE))

cat("\n== Baseline organ exposure (0/1/2) ==\n")
print(
  exposure_baseline |>
    select(researchid, all_of(organ_cols)) |>
    pivot_longer(-researchid, names_to = "site", values_to = "exposure") |>
    count(site, exposure) |>
    pivot_wider(names_from = exposure, values_from = n, names_prefix = "exp_", values_fill = 0)
)

cat("\n== Time-varying rows (tstart > 0) ==\n")
cat(sum(exposure_tv$tstart > 0), "change points in",
    n_distinct(exposure_tv$researchid[exposure_tv$tstart > 0]), "patients\n")

cat("\n== Sarcoma / skin SMNs by body-region RT exposure (W5, descriptive) ==\n")
print(count(smn_field_match, site_group, region_exposure))

# ---- 8. save ----------------------------------------------------------------------

saveRDS(exposure_baseline, file.path(out_dir, "exposure_baseline.Rds"))
saveRDS(exposure_tv, file.path(out_dir, "exposure_tv.Rds"))
saveRDS(course_timing, file.path(out_dir, "course_timing.Rds"))
saveRDS(smn_field_match, file.path(out_dir, "smn_field_match.Rds"))


