# run_all.R
# Runs the data-preparation pipeline (01 -> 04) in order and saves everything
# each script prints (checks, OK:/ACTION: advice, messages, errors) to a
# time-stamped log file per script, while still showing it in the console.
#
# Logs go next to the data they describe, inside the git-ignored secure_data/
# folder, so real-data results are never committed:
#   dummy data: secure_data/intermediate/dummy/logs/
#   real data:  secure_data/intermediate/logs/
# The data used is set by use_dummy in 00_config.R.
#
# Run from the project:  source(here::here("scripts", "run_all.R"))

source(here::here("scripts", "00_config.R"))

pipeline <- c("01_clean-data", "02_chemo-doses", "03_rt-exposure", "04_exposure-window")

log_dir <- file.path(out_dir, "logs")
dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
stamp <- format(Sys.time(), "%Y-%m-%d_%H%M")
data_label <- if (use_dummy) "dummy" else "real"

for (s in pipeline) {
  log_file <- file.path(log_dir, paste0(stamp, "_", s, ".log"))
  con <- file(log_file, open = "wt")
  # Console output goes to the log AND the console (split = TRUE). Messages
  # and warnings can only go to one place, so they go to the log; a short
  # line is printed to the console at the end of each script instead.
  sink(con, split = TRUE)
  sink(con, type = "message")
  cat("#", s, "| data:", data_label, "| started", format(Sys.time()), "\n")
  ok <- tryCatch(
    {
      source(here::here("scripts", paste0(s, ".R")), local = new.env())
      TRUE
    },
    error = function(e) {
      message("ERROR in ", s, ": ", conditionMessage(e))
      FALSE
    },
    finally = {
      cat("#", s, "| finished", format(Sys.time()), "\n")
      sink(type = "message")
      sink()
      close(con)
    }
  )
  cat(if (ok) "done:  " else "FAILED:", s, "->", log_file, "\n")
  # Stop at the first failure: later scripts would use outdated output.
  if (!ok) break
}
