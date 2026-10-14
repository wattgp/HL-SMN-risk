# data_manager_queries.R
# Writes one CSV per data query in docs/data-manager-queries.md (file names
# start with the query number) listing the
# ResearchIDs (and the relevant recorded values) that the data manager needs
# to look up. Run AFTER run_all.R. Output goes to the git-ignored folder
#   secure_data/intermediate[/dummy]/data_manager_queries/
# so patient-level lists are never committed. Share them only through the
# secure channel agreed for this project.
#
# Run from the project:  source(here::here("scripts", "data_manager_queries.R"))

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(readr)

q_dir <- file.path(out_dir, "data_manager_queries")
dir.create(q_dir, recursive = TRUE, showWarnings = FALSE)

pat <- readRDS(file.path(out_dir, "patients_all.Rds"))
smn <- readRDS(file.path(out_dir, "smn_long.Rds"))
slots <- readRDS(file.path(out_dir, "chemo_slots_long.Rds"))
doses <- readRDS(file.path(out_dir, "chemo_doses_course.Rds"))
review <- readRDS(file.path(out_dir, "chemo_dose_review.Rds"))
timing <- readRDS(file.path(out_dir, "course_timing.Rds"))
rt <- readRDS(file.path(out_dir, "rt_fields_course.Rds"))
cohort_ids <- readRDS(file.path(out_dir, "analytic_cohort.Rds"))$researchid

# The raw export WITH the duplicated rows (read_raw() removes them).
raw_all <- read_delim(raw_file, delim = ";",
                      col_types = cols(.default = col_character()),
                      na = c("", "NA"))
names(raw_all) <- tolower(names(raw_all))

write_q <- function(df, name) {
  f <- file.path(q_dir, paste0(name, ".csv"))
  write_csv(df, f, na = "")
  cat(sprintf("%-45s %5d rows -> %s\n", name, nrow(df), f))
}

# Q1 Duplicated ResearchIDs: all rows, with the columns that identify the
# source record.
dup_ids <- raw_all$researchid[duplicated(raw_all$researchid)]
write_q(raw_all |> filter(researchid %in% dup_ids) |>
          select(researchid, r_regel, beternr, volgnr, bron, statusnr, zkh,
                 m_diagnose, y_diagnose) |>
          arrange(researchid, volgnr),
        "Q1_duplicated_researchids")

# Q2 Regimen codes not in chem_drugs.xlsx (code 0 is treated as an empty
# slot and is not listed).
write_q(slots |> filter(regimen_status == "code not in chem_drugs") |>
          select(researchid, course, slot, regimen_code, cycles),
        "Q2_unknown_regimen_codes")

# Q3 SMNs without a behaviour code (analytic cohort, site and date during
# follow-up first).
write_q(smn |> filter(behav_cat == "unknown", researchid %in% cohort_ids) |>
          select(researchid, smn_number, topo_raw, morph, date_smn, smn_timing, site_group) |>
          arrange(desc(!is.na(topo_raw) & smn_timing == "during follow-up")),
        "Q3_smn_without_behaviour")

# Q11 Topography without subsite, or not a valid ICD-O code.
write_q(smn |> filter(!is.na(topo_raw), is.na(topo)) |>
          select(researchid, smn_number, topo_raw, morph, behav, date_smn),
        "Q11_topography_no_subsite_or_invalid")

# Q5 Date inconsistencies.
write_q(pat |> filter(data_after_death %in% TRUE) |>
          select(researchid, vital, date_vs, date_last_data, last_data_source),
        "Q5a_data_after_death")
write_q(timing |> filter(window == "after end of observation (W2)") |>
          select(researchid, treatment, course, date_course),
        "Q5b_course_after_death")
write_q(timing |>
          filter(grepl("treated as primary", date_source)) |>
          select(researchid, treatment, course, date_recorded),
        "Q5c_primary_course_5y_after_diagnosis")
write_q(timing |>
          filter(course != "prim", date_source == "assumed before follow-up (W1)",
                 (treatment == "chemotherapy" & given == "chemotherapy recorded") |
                   (treatment == "radiotherapy" & given == "1")) |>
          select(researchid, treatment, course),
        "Q5d_relapse_course_without_date")
write_q(pat |> filter(lc_moved_to_smn %in% TRUE) |>
          select(researchid, date_lc_recorded, date_lc),
        "Q5e_smn_after_last_contact")
write_q(pat |> filter(researchid %in% cohort_ids, last_data_source == "vital status") |>
          select(researchid, date_lc_recorded, date_vs, vital),
        "Q4_vital_status_after_last_contact")

# Q6 Implausible cycle counts / doses (plausibility review list from 02),
# with the regimen slots of the primary course.
write_q(review |>
          left_join(slots |> filter(course == "prim") |>
                      select(researchid, slot, regimen_code, cycles), by = "researchid"),
        "Q6_implausible_cycles_or_doses")

# Q7 Chemotherapy yes/no flag disagrees with the recorded regimens.
write_q(doses |>
          filter((ct_given %in% "no" & n_slots > 0) |
                   (ct_given %in% "yes" & n_slots == 0)) |>
          select(researchid, course, ct_given, n_slots),
        "Q7_chemo_flag_vs_regimens")

# Q8 rtcatprim = "no RT" while the other primary RT variables show RT.
write_q(rt |> filter(course == "prim", rt_cat_cb %in% "no RT", rt_given %in% 1L) |>
          select(researchid, rt_cat_cb, rt_supra_cb, rt_mid_cb, rt_infra_cb, rt_technique),
        "Q8_rtcat_no_rt_but_rt_given")

# Q9 Involved-node flag recorded together with named regional fields
# (primary course).
write_q(rt |> filter(course == "prim", invnode_with_regional) |>
          select(researchid, invnode, neck, supraclav, infraclav, axilla,
                 mediast_any, lung, paraaortic, spleen, iliac, inguinal),
        "Q9_invnode_with_regional_fields")

# Q12 Hospital code "0".
write_q(raw_all |> filter(zkh %in% "0", !researchid %in% dup_ids) |> select(researchid, zkh),
        "Q12_hospital_code_0")

# Q13 Missing core data.
write_q(bind_rows(
  pat |> filter(is.na(year_dx)) |> transmute(researchid, missing = "HL diagnosis year"),
  pat |> filter(is.na(vital)) |> transmute(researchid, missing = "vital status"),
  pat |> filter(exclusion %in% "end of follow-up unknown") |>
    transmute(researchid, missing = "end of follow-up (no dated information)"),
  pat |> filter(any_smn_undated) |> transmute(researchid, missing = "date of an invasive SMN")
), "Q13_missing_core_data")

cat("\nData:", if (use_dummy) "DUMMY" else "REAL", "| folder:", q_dir, "\n")
