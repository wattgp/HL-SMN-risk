# footnotes.R
# One shared set of footnotes for every descriptive and analytic table
# (decision Q5, 2026-10-14: "include footnotes for all variable definitions
# decisions with citations where needed"). Each entry gives the variable
# definition and the decision behind it, with the decision tag from the
# scripts' decision logs. Citations use the short keys in `fn_refs` below;
# full references are added under each table.
#
# Used by 06_descriptive.R and the analysis scripts:
#   source(here::here("scripts", "footnotes.R"))
#   add_variable_footnotes(gtsummary_table)   # per-variable footnotes
#   fn_cohort, fn_refs_used(...)              # table-level notes

# ---- references (verified against PubMed / OpenAlex unless marked) -------------
fn_refs <- c(
  Schaapveld2015 = "Schaapveld M, et al. Second cancer risk up to 40 years after treatment for Hodgkin's lymphoma. N Engl J Med 2015. doi:10.1056/NEJMoa1505949",
  Neppelenbroek2024 = "Neppelenbroek SIM, et al. Doxorubicin exposure and breast cancer risk in survivors of adolescent and adult Hodgkin lymphoma. J Clin Oncol 2024. doi:10.1200/JCO.23.01386",
  Feijen2019 = "Feijen EAM, et al. Derivation of anthracycline and anthraquinone equivalence ratios to doxorubicin for late-onset cardiotoxicity. JAMA Oncol 2019. doi:10.1001/jamaoncol.2018.6634",
  DeBruin2009 = "De Bruin ML, et al. Breast cancer risk in female survivors of Hodgkin's lymphoma: lower risk after smaller radiation volumes. J Clin Oncol 2009. doi:10.1200/JCO.2008.19.9174",
  Krul2017 = "Krul IM, et al. Breast cancer risk after radiation therapy for Hodgkin lymphoma: influence of gonadal hormone exposure. Int J Radiat Oncol Biol Phys 2017. doi:10.1016/j.ijrobp.2017.07.016",
  Swerdlow2012 = "Swerdlow AJ, et al. Breast cancer risk after supradiaphragmatic radiotherapy for Hodgkin's lymphoma in England and Wales. J Clin Oncol 2012. doi:10.1200/JCO.2011.38.8835",
  Specht2014 = "Specht L, et al. Modern radiation therapy for Hodgkin lymphoma: field and dose guidelines from the ILROG. Int J Radiat Oncol Biol Phys 2014. doi:10.1016/j.ijrobp.2013.05.005",
  SEER = "SEER Site Recode ICD-O-3 (National Cancer Institute, Surveillance, Epidemiology, and End Results Program). (Web resource; not a journal article.)"
)

# ---- cohort-level note -----------------------------------------------------------
fn_cohort <- paste(
  "Cohort: patients with Hodgkin lymphoma (HL) diagnosed in 1989 or later, aged 15-50",
  "years at diagnosis (15 <= age < 51), alive and under follow-up 5 years after diagnosis",
  "(5-year survivors; follow-up starts 5 years after diagnosis), as in Schaapveld 2015.",
  "Excluded: patients with an invasive SMN before the start of follow-up; patients whose",
  "ResearchID occurs on more than one row of the export (pending data-manager advice);",
  "an invasive SMN with an unknown date; and, pending data queries, patients with data",
  "dated after the death date or with an SMN during follow-up without a behaviour code.",
  "All dates are set to the 15th of the month (day of month unreliable); a date with a",
  "known year but unknown month is set to 1 July."
)

# ---- per-variable footnotes ------------------------------------------------------
fn_variables <- c(
  era = "Calendar period of HL diagnosis: 1989-1994, 1995-2004, 2005-latest (decision C3).",
  age_dx = "Age at HL diagnosis in years, from mid-month dates of birth and diagnosis.",
  age_dx_group = "Completed years at HL diagnosis: 15-20, 21-30, 31-40, 41-50 (decision C15).",
  age_dx_aya = "Adolescents and young adults (AYA) 15-39 vs 40-50 years at diagnosis (decision C16).",
  hl_histology = paste(
    "From the ICD-O-3 morphology of the HL diagnosis: nodular sclerosis 9663-9667; mixed",
    "cellularity 9652; lymphocyte-rich 9651; lymphocyte-depleted 9653-9655; nodular",
    "lymphocyte-predominant 9659; classical HL not otherwise specified 9650; other/unknown otherwise."),
  smoke_ever = "Any indication of smoking at any age, self-reported or in medical records (codebook). Unknown shown separately; excluded (listwise) from the lung-cancer x smoking models (decision Q-RT3b).",
  bmi_dx = "Body mass index at HL diagnosis (kg/m2); values outside 10-80 set to missing. Height and weight are not recorded separately.",
  doxo_any = paste(
    "Doxorubicin received, derived from the recorded chemotherapy regimens (codebook drug codes)",
    "in all treatment courses before the start of follow-up. 'Unknown' if a regimen was",
    "unknown; resolved to 'No' when the export's own 'ever anthracyclines' item is No (decision REG)."),
  doxo_dose = paste(
    "Cumulative doxorubicin dose (mg/m2) = dose per cycle (regimen lookup table) x number of",
    "cycles, summed over courses before the start of follow-up (decisions D1, D6). Primary",
    "treatment always counts, whatever its recorded date (PRIM). If a later course's dose is",
    "unknown, the total is a lower bound (W4). For continuous analyses the dose is capped at",
    "550 mg/m2 (decision CAP); the median (IQR) shown is uncapped. Doxorubicin only, as in",
    "Neppelenbroek 2024; other anthracyclines are shown separately."),
  doxo_cat = "Cumulative doxorubicin dose categories 0 / 1-200 / >200 mg/m2, as in Neppelenbroek 2024 (decision D11).",
  doxo_cat_fine = "Finer doxorubicin categories 0 / 1-200 / 201-349 / >=350 mg/m2 (Neppelenbroek 2024; sensitivity analysis, decision Q-CT6).",
  epirubicin_any = "Epirubicin received (regimens EBVP, EBVD, epirubicin), analysed as yes/no and not converted to doxorubicin, as in Neppelenbroek 2024 (decision D6). Equivalence ratios (Feijen 2019) are cardiotoxicity-based and used only in a sensitivity analysis.",
  other_anthra_any = "Daunorubicin, mitoxantrone or losoxantrone received (yes/no; decision D6).",
  procarb_any = "Procarbazine received, derived from the recorded regimens; resolved to 'No' when the export's own 'ever procarbazine' item is No (decision REG).",
  procarb_dose = paste(
    "Cumulative procarbazine dose (mg/m2) = dose per cycle x number of cycles, summed over",
    "courses before the start of follow-up; not converted to other alkylating agents",
    "(decision D7). Lookup values kept as recorded (decision D9); ChlVPP/ABV 1000 mg/m2 per",
    "cycle (sensitivity 700, S-CT98). Capped at 11,200 mg/m2 (8 cycles of MOPP) for",
    "continuous analyses (CAP); the median shown is uncapped."),
  procarb_cat = "Procarbazine categories 0 / <=4.2 / 4.3-8.4 / >8.4 g/m2, as in Neppelenbroek 2024; 4.3 g/m2 marks the premature-menopause threshold in Schaapveld 2015 (decision D11).",
  rt_any = "Radiotherapy in any course before the start of follow-up.",
  rt_technique = paste(
    "From the recorded RT field flags, by the largest volume given (decisions R1, R1a, R9):",
    "mantle / extended field = mantle, inverted Y, full abdomen or full mantle; regional field",
    "(presumed involved field) = named regional fields without these; involved node = only the",
    "involved-node flag. Free-text field names recorded with doses were added by hand and",
    "override the flags (R8, T1). Trends follow the move from extended to involved-field",
    "and involved-node RT (Specht 2014)."),
  rt_cat_cb = "The export's own RT category (codebook; defined with radiation oncologists), combined over courses by the codebook definitions (decision R7). Used for a parallel analysis.",
  rt_supra = "Supradiaphragmatic RT (incomplete or full mantle), from the export's derived category.",
  rt_infra = "Infradiaphragmatic or mid-body (para-aortic / spleen) RT, from the export's derived categories.",
  rt_mediastinal = "Mediastinum irradiated: mediastinum, upper or lower mediastinum field, or a mantle field (which always includes the mediastinum) (decision R1a).",
  rt_pelvic = "Pelvic RT: inverted Y or iliac field (decision R3).",
  ovarian_damage = paste(
    "Marker of ovarian damage / early menopause: pelvic RT OR cumulative procarbazine",
    ">4.2 g/m2 (decisions R3, Q-RT3a). Used as an effect modifier for breast cancer",
    "(Swerdlow 2012; Krul 2017; Schaapveld 2015)."),
  relapse = "HL relapse recorded (codebook).",
  treatment_during_fup = "Chemotherapy or RT course starting after the start of follow-up; counts as time-varying exposure from 2 years after its start (decision W3).",
  time_any = paste(
    "Years from the start of follow-up (5 years after diagnosis) to the first invasive SMN,",
    "death, or the last date of any data for the patient (last contact, vital status, SMN,",
    "relapse or treatment; decision C17). Sensitivity analysis: end at last contact (C17-LC)."),
  outcome_any = paste(
    "Invasive SMN = ICD-O-3 behaviour 3 or 9 (decision C18), excluding non-melanoma skin cancer",
    "and a second HL (decisions C8, P6), as in Schaapveld 2015. Death without SMN is a competing event.")
)

# Which reference keys each variable's footnote cites (to list under a table).
fn_var_refs <- list(
  doxo_dose = "Neppelenbroek2024", doxo_cat = "Neppelenbroek2024",
  doxo_cat_fine = "Neppelenbroek2024", epirubicin_any = c("Neppelenbroek2024", "Feijen2019"),
  procarb_cat = c("Neppelenbroek2024", "Schaapveld2015"),
  rt_technique = "Specht2014", ovarian_damage = c("Swerdlow2012", "Krul2017", "Schaapveld2015"),
  outcome_any = "Schaapveld2015"
)

# Add the per-variable footnotes to a gtsummary table (label rows only).
add_variable_footnotes <- function(tbl) {
  vars <- intersect(unique(tbl$table_body$variable), names(fn_variables))
  for (v in vars) {
    tbl <- gtsummary::modify_table_styling(
      tbl, columns = "label",
      rows = !!rlang::expr(variable == !!v & row_type == "label"),
      footnote = fn_variables[[v]]
    )
  }
  tbl
}

# The reference list for the variables in a table (plus always-cited keys).
fn_refs_used <- function(vars, always = "Schaapveld2015") {
  keys <- unique(c(always, unlist(fn_var_refs[intersect(vars, names(fn_var_refs))])))
  paste0("References: ", paste(fn_refs[keys], collapse = "; "))
}
