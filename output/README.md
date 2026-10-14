# output/

Tables and figures written by the analysis scripts (06 onwards):

- `output/real/`: results from the real data
- `output/dummy/`: test results from the synthetic dummy data

**Nothing in this folder is committed to git** (see `.gitignore`), except this README. Real-data results contain aggregate patient data. They stay on the analysis server and are shared only through the project's agreed secure channels. To reproduce them, run `source(here::here("scripts", "run_all.R"))` with `use_dummy <- FALSE` in `scripts/00_config.R`.
