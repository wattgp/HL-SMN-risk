# 00_config.R
# Shared settings for the numbered analysis scripts (01_, 02_, ...). Every
# script sources this file first so that ONE switch decides whether the whole
# pipeline runs on the synthetic (dummy) data or on the real ResearchDB export.
#
# Run from the project (Watt-HL-SMN.Rproj); scripts call it with:
#   source(here::here("scripts", "00_config.R"))

library(here)

# ---- dummy vs real data -----------------------------------------------------

# TRUE  = synthetic data made by scripts/make_dummy_dataset.R. All code is
#         developed and checked on this file (SAP: "You do not have access to
#         any other data").
# FALSE = the real export. Only the project leader (G. Watt) flips this, after
#         reviewing the code, to produce the final results.
use_dummy <- FALSE

# Safety override for code testing: if the environment variable
# HLSMN_FORCE_DUMMY is set (to anything), the dummy data are used whatever
# the line above says. It can only force the dummy data, never the real data.
# (Used by Claude when testing code, so a test can never touch the real data.)
if (nzchar(Sys.getenv("HLSMN_FORCE_DUMMY"))) use_dummy <- TRUE

# Raw input file. The real export is read-only and is never modified.
raw_file <- if (use_dummy) {
  here("secure_data", "DUMMY_research_dataset.csv")
} else {
  here("secure_data", "ResearchDB_Export_from-Power-BI.csv")
}

# Derived data go to a separate folder for dummy runs, so dummy and real
# intermediate files can never be mixed up.
out_dir <- if (use_dummy) {
  here("secure_data", "intermediate", "dummy")
} else {
  here("secure_data", "intermediate")
}
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# Lookup tables used to convert chemotherapy regimens to doses (mg/m2 per
# cycle). File names are taken exactly as they are on disk.
lookup_files <- list(
  chem_drugs   = here("secure_data", "chem_drugs.xlsx"),
  doxorubicin  = here("secure_data", "Doxorubicin-dosages-for-available-treatments.xlsx"),
  procarbazine = here("secure_data", "Procarbazine-dosages-for available-treatments.xlsx")
)

# ---- reading the raw export (shared by all scripts) ---------------------------------

# C13 (2026-10-14) Q: The real export has 25 ResearchIDs on more than one row
#    (23 x 2 rows, 2 x 3 rows; 6,681 rows, 6,654 distinct IDs). The rows come
#    from different source datasets (bron: validatie / basis ontw / uitbr
#    ontw), usually a different hospital, and differ in clinical content
#    (diagnosis month, HL morphology, last contact, RT/CT dates, SMN dates).
#    Which row to use? A: For now, EXCLUDE ALL ROWS of these patients
#    (option C). To do: ask the data manager which record is authoritative;
#    revisit (options were: keep the validatie row; merge rows).
#
# read_raw() reads the export with every column as character (each variable
# is recoded explicitly in the scripts, from the codebook), lower-cases the
# column names (the export mixes capitalisation, e.g. "Smn2_site"), and
# removes ALL rows of any ResearchID that occurs more than once (C13). The
# removed IDs are returned as attribute "duplicate_ids" so that
# 01_clean-data.R can count them in the exclusion flow.
read_raw <- function(file = raw_file) {
  raw <- readr::read_delim(
    file,
    delim = ";",
    col_types = readr::cols(.default = readr::col_character()),
    locale = readr::locale(decimal_mark = ".", grouping_mark = ","),
    na = c("", "NA") # only true blanks are missing at this stage
  )
  names(raw) <- tolower(names(raw))
  stopifnot(!anyNA(raw$researchid)) # every row must have an ID
  dup_ids <- unique(raw$researchid[duplicated(raw$researchid)])
  out <- raw[!raw$researchid %in% dup_ids, ]
  attr(out, "duplicate_ids") <- dup_ids
  attr(out, "duplicate_rows") <- sum(raw$researchid %in% dup_ids)
  if (length(dup_ids) > 0) {
    message(
      "read_raw(): removed ", attr(out, "duplicate_rows"), " rows of ",
      length(dup_ids), " ResearchIDs that occur more than once (C13)."
    )
  }
  out
}

# ---- case-count thresholds for site-specific analyses ------------------------------

# C12 (2026-10-14) Q: Minimum number of invasive SMNs of a site for it to get
#    its own cumulative incidence plot and its own model? The SAP said > 20
#    cases for plots and >= 50 for models (Objective 2).
#    A: >= 10 for BOTH plots and models (project leader's decision; this is a
#    deliberate change from the SAP). Sites below the threshold are still
#    kept in the data and in the comprehensive SMN table.
#    Note for the modelling stage: with as few as 10 events, models for a
#    site can only support very few parameters, so covariates for small
#    sites must be chosen sparingly (to be agreed per site).
min_cases_plot <- 10
min_cases_model <- 10

# ---- dose categories (decision D11 / Q-CT5 / Q-CT6 in 02_chemo-doses.R) ----------

# Input: cumulative dose in mg/m2 (NA stays NA). Neppelenbroek 2024 cut-offs.
# Doxorubicin, primary: 0 / 1-200 / >200 mg/m2.
doxo_cat <- function(mg) {
  cut(mg, c(-Inf, 0, 200, Inf), labels = c("0", "1-200", ">200"))
}
# Doxorubicin, sensitivity (finer split): 0 / 1-200 / 201-349 / >=350 mg/m2
# (Neppelenbroek's top category was 350-700; any higher value also falls in
# the top category).
doxo_cat_fine <- function(mg) {
  cut(mg, c(-Inf, 0, 200, 349, Inf), labels = c("0", "1-200", "201-349", ">=350"))
}
# Procarbazine: 0 / <=4.2 / 4.3-8.4 / >8.4 g/m2.
procarb_cat <- function(mg) {
  cut(mg / 1000, c(-Inf, 0, 4.2, 8.4, Inf),
    labels = c("0", "<=4.2", "4.3-8.4", ">8.4")
  )
}
# "High" procarbazine for the breast-cancer ovarian-damage modifier
# (decision Q-RT3a): > 4.2 g/m2.
procarb_high_mg <- 4200
