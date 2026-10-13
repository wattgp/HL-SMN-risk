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
use_dummy <- TRUE

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
