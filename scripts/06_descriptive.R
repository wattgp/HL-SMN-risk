# 06_descriptive.R
# SAP part A: descriptive analysis.
#   Table 1  patient, HL and treatment characteristics of the analysis
#            cohort, overall and by diagnosis era (gtsummary)
#   Table 2  comprehensive table of ALL invasive SMNs during follow-up by
#            site group (every group kept, however small; decision C11),
#            with the >= 10-case threshold for own plots/models marked (C12)
#   Table 2b all recorded SMNs during follow-up by behaviour category
#            (in situ and benign kept separately; decision C6)
#
# Output: output/<dummy|real>/06_table1.html, 06_table2_smn_sites.html,
#         06_table2b_smn_behaviour.html (+ .Rds of the underlying tables)
#
# Run after 05:  source(here::here("scripts", "06_descriptive.R"))

# ---- decision log ------------------------------------------------------------
# SAP A (2026-10-13): descriptive table with all variables relevant to the
#    study of long-term HL survivors; continuous where appropriate, with
#    interpretable categories (age groups C15; diagnosis eras C3).
# Q5 (2026-10-14): every table carries footnotes with all variable
#    definitions and decisions, with citations (scripts/footnotes.R).
# PROPOSED (not yet agreed): HL histology groups from the ICD-O-3
#    morphology (pc_morph): nodular sclerosis 9663-9667; mixed cellularity
#    9652; lymphocyte-rich 9651; lymphocyte-depleted 9653-9655; nodular
#    lymphocyte-predominant 9659; classical HL, not otherwise specified 9650;
#    other / unknown otherwise.
# PROPOSED: Table 1 is stratified by diagnosis era (treatment changed over
#    time, the main interest for ISORED), with an overall column.

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(gtsummary)
library(gt)
source(here::here("scripts", "footnotes.R"))

res_dir <- here("output", if (use_dummy) "dummy" else "real")
dir.create(res_dir, recursive = TRUE, showWarnings = FALSE)

pat <- readRDS(file.path(out_dir, "analysis_patients.Rds"))
smn_long <- readRDS(file.path(out_dir, "smn_long.Rds"))

yn01 <- function(x) factor(x, levels = c(1, 0), labels = c("Yes", "No"))
yn_chr <- function(x) factor(x, levels = c("yes", "no", "unknown"),
                             labels = c("Yes", "No", "Unknown"))

# ---- 1. Table 1 -------------------------------------------------------------------

t1_data <- pat |>
  mutate(
    sex = factor(sex, levels = c("female", "male", "other"),
                 labels = c("Female", "Male", "Other")) |> droplevels(),
    era = droplevels(era),
    hl_histology = case_when(
      hl_morph %in% 9663:9667 ~ "Nodular sclerosis",
      hl_morph == 9652 ~ "Mixed cellularity",
      hl_morph == 9651 ~ "Lymphocyte-rich",
      hl_morph %in% 9653:9655 ~ "Lymphocyte-depleted",
      hl_morph == 9659 ~ "Nodular lymphocyte-predominant",
      hl_morph == 9650 ~ "Classical HL, NOS",
      TRUE ~ "Other / unknown"
    ) |> factor(levels = c("Nodular sclerosis", "Mixed cellularity", "Lymphocyte-rich",
                           "Lymphocyte-depleted", "Nodular lymphocyte-predominant",
                           "Classical HL, NOS", "Other / unknown")),
    smoke_ever = yn_chr(smoke_ever),
    relapse = yn_chr(relapse),
    doxo_any = yn_chr(doxo_any),
    epirubicin_any = yn_chr(epirubicin_any),
    other_anthra_any = yn_chr(other_anthra_any),
    procarb_any = yn_chr(procarb_any),
    rt_any = yn01(rt_any),
    rt_mediastinal = yn01(rt_mediastinal),
    rt_supra = yn01(rt_supra),
    rt_infra = yn01(rt_infra),
    rt_pelvic = yn01(rt_pelvic),
    ovarian_damage = yn01(ovarian_damage),
    treatment_during_fup = factor(treatment_during_fup, c(TRUE, FALSE), c("Yes", "No")),
    outcome_any = factor(status_any, 0:2, c("Censored (alive, no SMN)", "Invasive SMN",
                                            "Died without SMN"))
  ) |>
  select(
    era, sex, age_dx, age_dx_group, age_dx_aya, hl_histology, smoke_ever, bmi_dx,
    doxo_any, doxo_dose, doxo_cat, doxo_cat_fine, epirubicin_any, other_anthra_any,
    procarb_any, procarb_dose, procarb_cat,
    rt_any, rt_technique, rt_cat_cb, rt_supra, rt_infra, rt_mediastinal, rt_pelvic,
    ovarian_damage, relapse, treatment_during_fup,
    time_any, outcome_any
  )

table1 <- t1_data |>
  tbl_summary(
    by = era,
    label = list(
      sex ~ "Sex", age_dx ~ "Age at HL diagnosis, years",
      age_dx_group ~ "Age at HL diagnosis (groups)", age_dx_aya ~ "Age at HL diagnosis (AYA)",
      hl_histology ~ "HL histology", smoke_ever ~ "Ever smoked", bmi_dx ~ "BMI at diagnosis",
      doxo_any ~ "Doxorubicin", doxo_dose ~ "Cumulative doxorubicin dose, mg/m²",
      doxo_cat ~ "Doxorubicin dose category, mg/m²",
      doxo_cat_fine ~ "Doxorubicin dose category (fine), mg/m²",
      epirubicin_any ~ "Epirubicin", other_anthra_any ~ "Other anthracycline / anthraquinone",
      procarb_any ~ "Procarbazine", procarb_dose ~ "Cumulative procarbazine dose, mg/m²",
      procarb_cat ~ "Procarbazine dose category, g/m²",
      rt_any ~ "Radiotherapy", rt_technique ~ "RT technique (field flags)",
      rt_cat_cb ~ "RT category (codebook)", rt_supra ~ "Supradiaphragmatic RT",
      rt_infra ~ "Infradiaphragmatic / mid-body RT", rt_mediastinal ~ "Mediastinal RT",
      rt_pelvic ~ "Pelvic RT", ovarian_damage ~ "Ovarian damage (pelvic RT or procarbazine >4.2 g/m²)",
      relapse ~ "HL relapse", treatment_during_fup ~ "Treatment during follow-up",
      time_any ~ "Follow-up from 5 years after diagnosis, years",
      outcome_any ~ "Status at end of follow-up"
    ),
    type = list(c(age_dx, bmi_dx, doxo_dose, procarb_dose, time_any) ~ "continuous"),
    statistic = list(all_continuous() ~ "{median} ({p25}–{p75})",
                     all_categorical() ~ "{n} ({p}%)"),
    missing = "ifany", missing_text = "Missing"
  ) |>
  add_overall(last = FALSE) |>
  modify_header(label ~ "**Characteristic**") |>
  modify_spanning_header(all_stat_cols(stat_0 = FALSE) ~ "**Era of HL diagnosis**") |>
  modify_caption("**Table 1.** Characteristics of 5-year survivors of Hodgkin lymphoma, by era of diagnosis") |>
  bold_labels() |>
  add_variable_footnotes() # Q5: every variable definition and decision

table1_gt <- as_gt(table1) |>
  tab_source_note(fn_cohort) |>
  tab_source_note("Missing / Unknown values are shown separately and are not imputed in this table.") |>
  tab_source_note(fn_refs_used(names(t1_data)))

# ---- 2. Table 2: all invasive SMNs by site group ---------------------------------

smn_fu <- smn_long |>
  filter(researchid %in% pat$researchid, counts_site_smn,
         smn_timing == "during follow-up") |>
  left_join(pat |> select(researchid, sex, date_birth), by = "researchid") |>
  mutate(age_smn = lubridate::time_length(lubridate::interval(date_birth, date_smn), "years"))

fmt_med <- function(x) {
  if (all(is.na(x))) return("–")
  q <- quantile(x, c(0.5, 0.25, 0.75), na.rm = TRUE)
  sprintf("%.1f (%.1f–%.1f)", q[1], q[2], q[3])
}

table2_data <- smn_fu |>
  group_by(site_group) |>
  summarise(
    smns = n(),
    patients = n_distinct(researchid),
    women = n_distinct(researchid[sex == "female"]),
    men = n_distinct(researchid[sex == "male"]),
    years_since_dx = fmt_med(years_since_dx),
    age_at_smn = fmt_med(age_smn),
    .groups = "drop"
  ) |>
  mutate(own_analysis = if_else(patients >= min_cases_model, "Yes", "No")) |>
  arrange(desc(patients))

table2 <- table2_data |>
  gt() |>
  cols_label(
    site_group = "SMN site group", smns = "Invasive SMNs", patients = "Patients",
    women = "Women", men = "Men",
    years_since_dx = "Years since HL diagnosis, median (IQR)",
    age_at_smn = "Age at SMN, median (IQR)",
    own_analysis = paste0("≥", min_cases_model, " patients (own plots/models)")
  ) |>
  tab_header(title = "Table 2. Invasive subsequent malignant neoplasms during follow-up, by site group") |>
  tab_source_note(paste(
    "Invasive = ICD-O-3 behaviour 3 or 9. Every SMN during follow-up is counted;",
    "'Patients' counts patients with at least one SMN of that site. Non-melanoma",
    "skin cancer is shown as its own site but is not part of 'any SMN'.")) |>
  tab_source_note(paste(
    "Site groups (decisions C7, C11): haematological, melanoma, mesothelioma, Kaposi and",
    "sarcoma by ICD-O-3 morphology first, all other tumours by topography, based on the",
    "SEER site recode and the site groups of Schaapveld 2015. Non-melanoma skin cancer =",
    "skin (C44) with morphology 8000-8110 (decision P8). A second HL (9650-9667) is not",
    "counted as an SMN (P6). Topographies recorded without subsite get a site group from",
    "the 3-character code (C19). Every site group is shown, however small (C11); sites",
    "with fewer than", min_cases_model, "patients are not analysed on their own (C12).")) |>
  tab_source_note(fn_cohort) |>
  tab_source_note(paste0("References: ", fn_refs[["Schaapveld2015"]], "; ", fn_refs[["SEER"]]))

# ---- 3. Table 2b: SMNs by behaviour category -------------------------------------

table2b_data <- smn_long |>
  filter(researchid %in% pat$researchid, smn_timing == "during follow-up") |>
  count(behav_cat, name = "smns") |>
  arrange(desc(smns))
table2b <- table2b_data |>
  gt() |>
  cols_label(behav_cat = "Behaviour (ICD-O-3)", smns = "SMNs during follow-up") |>
  tab_header(title = "Table 2b. All recorded SMNs during follow-up, by behaviour") |>
  tab_source_note(paste(
    "ICD-O-3 behaviour code of each recorded SMN. Analyses count behaviour 3 (invasive) and",
    "9 (malignant, primary or metastatic unknown) as invasive SMNs (decision C18); in situ",
    "(2) and benign (0) are kept as separate categories for future analyses (decision C6).")) |>
  tab_source_note(fn_cohort)

# ---- 4. save -----------------------------------------------------------------------

gtsave(table1_gt, file.path(res_dir, "06_table1.html"))
gtsave(table2, file.path(res_dir, "06_table2_smn_sites.html"))
gtsave(table2b, file.path(res_dir, "06_table2b_smn_behaviour.html"))
saveRDS(list(table1 = table1, table2 = table2_data, table2b = table2b_data),
        file.path(res_dir, "06_descriptive.Rds"))

cat("\nTables written to", res_dir, "(data:", if (use_dummy) "DUMMY" else "REAL", ")\n")
cat("Sites with >=", min_cases_model, "patients:",
    paste(table2_data$site_group[table2_data$own_analysis == "Yes"], collapse = "; "), "\n")
