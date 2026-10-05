# Paths shared by the cleaning script and the report.
# Raw data stays read-only in secure_data/<export date>/; cleaned data is
# written to secure_data/derived/. Neither location is inside the repo.

if (dir.exists("U://HL/SMN-risk/secure_data")) {
  # tries Windows MDW version first
  secure_dir <- "U://HL/SMN-risk/secure_data"
} else {
  # then reads Mac Volumes
  secure_dir <- "/Volumes/g.watt/HL/SMN-risk/secure_data"
}

raw_file     <- file.path(secure_dir, "2024-12-12", "ResearchDB_Export_from-Power-BI.csv")
derived_dir  <- file.path(secure_dir, "derived")
derived_full <- file.path(derived_dir, "smn_derived_full.rds")     # all patients, derived vars
derived_anly <- file.path(derived_dir, "smn_analytic_cohort.rds")  # 1989+, at risk at fup_start
