
---
  
  ## 1️⃣  Packages & Setup ---------------------------------------------------------

# --------------------------------------------------------------
#  Packages ----------------------------------------------------
# --------------------------------------------------------------
# Install once (uncomment if you do not have them yet)
# install.packages(c("tidyverse", "magrittr"))

library(tidyverse)   # dplyr, tidyr, ggplot2, etc.


library(here)


# --------------------------------------------------------------
#  USER SETTINGS ------------------------------------------------
# --------------------------------------------------------------
# Name of the data file (CSV, RDS, Stata .dta, etc.)
# Change this to the path where your dataset lives.

here::i_am("scripts/SMN-risk.qmd")
infile = readRDS(here::here("secure_data","intermediate","full_dataset_basic_cleaning.Rds"))
outfile <- "ct_fup2_processed.rds" # where the cleaned data will be saved

#
# Instead of writing hundreds of `replace …` statements we keep **lookup tables** that map a regimen code → drug → dose (mg/m²).  
# Add or change rows in these tables whenever a new regimen appears.

```r
# --------------------------------------------------------------
#  Doxorubicin regimens (code → dose in mg/m²)
# --------------------------------------------------------------
#   * Most doxorubicin‑containing regimens use 25 mg/m² per unit
#   * CAVE‑CEC (code 777) is a high‑dose regimen → 80 mg/m²
#   * If you discover other regimens with a different dose, just add a row.
# --------------------------------------------------------------
dox_lookup <- tribble(
  ~code, ~dose_mg2,
  777,   80,            # CAVE‑CEC (high‑dose)
  
  # ---- add more codes below ----
  #  123,  25,          # example: code 123 = doxorubicin 25 mg/m²
  #  456,  30,          # example: code 456 = doxorubicin 30 mg/m²
  #  ...
)

# --------------------------------------------------------------
#  Epirubicin regimens (code → dose in mg/m²)
# --------------------------------------------------------------
epi_lookup <- tribble(
  ~code, ~dose_mg2,
  200,   30,            # example: code 200 = epirubicin 30 mg/m²
  # ---- add more codes below ----
  #  250,  35,          # example: code 250 = epirubicin 35 mg/m²
  #  ...
)
```

---
  
  ## 3️⃣  Create “dose‑per‑cycle” columns -------------------------------------

We will work in *long* format (one row per patient‑cycle) because it makes the assignment logic much cleaner and avoids creating 14 separate wide columns manually.  
After the calculations we pivot back to wide so you end up with exactly the same layout as in Stata (`doxodosefup21 … doxodosefup27`, `epidosefup21 … epidosefup27`).

```r
# --------------------------------------------------------------
#  1.  Bring the data to long format (one row per patient‑cycle)
# --------------------------------------------------------------
df_long <- df %>%
  # Keep only the columns we need for the dose calculation.
  # The pattern `c[1-7]ctfup2` and `n[1-7]ctfup2` selects all cycles.
  select(patid, id, ctfup2,
         matches("^c[1-7]ctfup2$"),
         matches("^n[1-7]ctfup2$")) %>%
  # Reshape to long: each cycle becomes a row
  pivot_longer(
    cols = -c(patid, id, ctfup2),
    names_to = c(".value", "cycle"),
    names_pattern = "([cn])([1-7])ctfup2"
  ) %>%
  # Convert the character cycle number to integer (1‑7)
  mutate(cycle = as.integer(cycle))

# Inspect the first few rows (optional)
# head(df_long)
```

Resulting `df_long` now looks like:
  
  | patid | id   | ctfup2 | c   | n   | cycle |
  |------|------|--------|-----|-----|-------|
  | …    | …    | 1      | 777 | 1   | 1     |
  | …    | …    | 1      | 777 | 2   | 2     |
  | …    | …    | 1      | 200 | 1   | 3     |
  | …    | …    | 0      | NA  | NA  | 4     |
  | …    | …    | …      | …   | …   | …     |
  
  * `c`  – regimen code for that cycle (character; may be `NA` or `"999"`).  
* `n`  – numeric factor for that cycle (the “dose‑units” column in Stata, e.g. `n1ctfup2`).  

---
  
  ## 4️⃣  Clean the raw code columns -----------------------------------------

The Stata code treated **missing** or **`999`** as “invalid” and set the resulting dose to `.` (Stata’s missing).  
We do the same by converting those values to `NA` *before* we compute any dose.

```r
df_long <- df_long %>%
  mutate(
    # Convert "999" (or any non‑numeric string) to NA
    n = na_if(as.numeric(n), 999),
    # Convert missing regimen codes (empty string, "NA", or "999") to NA
    c = na_if(c, "999")
  )
```

> **Why `as.numeric(n)`?**  
  > In the original Stata data `n*ctfup2` is numeric, but when the file is read into R as CSV the column may be character (especially if the file contains `"999"`). Converting to numeric forces `"999"` → `999` (numeric) which we then turn into `NA`.

---
  
  ## 5️⃣  Compute *dose per cycle* for **doxorubicin** -------------------------

```r
# --------------------------------------------------------------
#  Doxorubicin dose per cycle (mg/m²)
# --------------------------------------------------------------
df_long <- df_long %>%
  # Start with a missing dose (will stay NA if the regimen does NOT contain doxorubicin)
  mutate(dox_cycle_dose = NA_real_) %>%
  
  # -----------------------------------------------------------------
#  1)  High‑dose CAVE‑CEC (code 777) → 80 mg/m²
# -----------------------------------------------------------------
mutate(dox_cycle_dose = if_else(
  c == "777" & !is.na(n), 80 * n, dox_cycle_dose
)) %>%
  
  # -----------------------------------------------------------------
#  2)  All other doxorubicin‑containing regimens that you have
#      explicitly listed in `dox_lookup`.
# -----------------------------------------------------------------
left_join(dox_lookup, by = c("c" = "code")) %>%
  mutate(dox_cycle_dose = if_else(
    !is.na(dose_mg2) & !is.na(n), dose_mg2 * n, dox_cycle_dose
  )) %>%
  
  # -----------------------------------------------------------------
#  3)  (Optional) Default dose for *any* doxorubicin regimen that
#      you have NOT listed above.
#      Uncomment the line below if you want **all** doxorubicin‑containing
#      regimens to receive a default of 25 mg/m².
# -----------------------------------------------------------------
# mutate(dox_cycle_dose = if_else(
#   is.na(dox_cycle_dose) & !is.na(c) & !is.na(n), 25 * n, dox_cycle_dose
# )) %>%

# Remove the temporary `dose_mg2` column that came from the join
select(-dose_mg2)
```

Explanation:
  
  | Step | What it does |
  |------|--------------|
  | **1)** | Directly assigns `80 mg/m² × n` to every row where the regimen code equals `"777"` (CAVE‑CEC). |
  | **2)** | Joins the lookup table (`dox_lookup`) on the regimen code. If a match is found, we multiply the listed `dose_mg2` by `n`. |
  | **3)** | (commented out) Gives a *fallback* dose of 25 mg/m² for any doxorubicin regimen not in the lookup table. |
  
  > **Important:**  
  > If a cycle has `c == NA` (i.e., the patient did not receive any regimen that cycle) the `if_else` statements keep `dox_cycle_dose` as `NA`. This mirrors the Stata behavior where no dose is recorded for that cycle.

---
  
  ## 6️⃣  Compute *dose per cycle* for **epirubicin** -------------------------

```r
# --------------------------------------------------------------
#  Epirubicin dose per cycle (mg/m²)
# --------------------------------------------------------------
df_long <- df_long %>%
  mutate(epi_cycle_dose = NA_real_) %>%
  left_join(epi_lookup, by = c("c" = "code")) %>%
  mutate(epi_cycle_dose = if_else(
    !is.na(dose_mg2) & !is.na(n), dose_mg2 * n, epi_cycle_dose
  )) %>%
  # Remove the temporary `dose_mg2` column created by the join
  select(-dose_mg2)
```

---
  
  ## 6️⃣  Return to wide format (Stata‑like layout) -------------------------

Now each patient will have **seven rows** (one per cycle).  
We pivot back to wide so the final data set contains the same columns that the Stata script produced (`doxodosefup21 … doxodosefup27`, `epidosefup21 … epidosefup27`).

```r
df_wide <- df_long %>%
  # Keep only the columns we actually need in the final data set
  select(patid, id, ctfup2, cycle,
         dox_cycle_dose, epi_cycle_dose) %>%
  
  # Pivot to wide: each cycle becomes its own column
  pivot_wider(
    names_from = cycle,
    values_from = c(dox_cycle_dose, epi_cycle_dose),
    names_glue = "{.value}fup{cycle}"
  ) %>%
  # Rename columns to match the Stata naming convention exactly
  rename(
    doxodosefup21 = dox_cycle_dose_fup1,
    doxodosefup22 = dox_cycle_dose_fup2,
    doxodosefup23 = dox_cycle_dose_fup3,
    doxodosefup24 = dox_cycle_dose_fup4,
    doxodosefup25 = dox_cycle_dose_fup5,
    doxodosefup26 = dox_cycle_dose_fup6,
    doxodosefup27 = dox_cycle_dose_fup7,
    epidosefup21 = epi_cycle_dose_fup1,
    epidosefup22 = epi_cycle_dose_fup2,
    epidosefup23 = epi_cycle_dose_fup3,
    epidosefup24 = epi_cycle_dose_fup4,
    epidosefup25 = epi_cycle_dose_fup5,
    epidosefup26 = epi_cycle_dose_fup6,
    epidosefup27 = epi_cycle_dose_fup7
  )

# --------------------------------------------------------------
#  Add the original wide columns back (the ones that were NOT
#  part of the dose calculation) so the final data set contains
#  everything you started with, plus the new dose columns.
# --------------------------------------------------------------
df_processed <- df %>%
  left_join(
    df_wide %>%
      select(patid,
             starts_with("doxodosefup"),
             starts_with("epidosefup")),
    by = "patid"
  )
```

Now `df_processed` has **exactly** the same column names that the Stata script produced:
  
  ```
doxodosefup21, doxodosefup22, …, doxodosefup27,
epidosefup21, epidosefup22, …, epidosefup27,
```

All values are numeric (`NA` where the dose is missing, otherwise the computed mg/m²).

---
  
  ## 7️⃣  (Optional) Create *total* dose per patient -------------------------

If you need a summary of the total doxorubicin or epirubicin dose a patient received across all cycles, it is just a simple `rowwise` sum of the per‑cycle columns.

```r
df_processed <- df_processed %>%
  rowwise() %>%
  mutate(
    total_dox_mg2 = sum(c_across(starts_with("doxodosefup")), na.rm = TRUE),
    total_epi_mg2 = sum(c_across(starts_with("epidosefup")), na.rm = TRUE)
  ) %>%
  ungroup()
```

* `total_dox_mg2` – total doxorubicin dose (mg/m²) summed over all cycles (ignores missing cycles).  
* `total_epi_mg2` – total epirubicin dose (mg/m²).

---
  
  ## 8️⃣  Save the cleaned data ----------------------------------------------

```r
# --------------------------------------------------------------
#  Save the processed data frame (RDS keeps the data types intact)
# --------------------------------------------------------------
saveRDS(df_processed, outfile)

# If you need a CSV again:
# write_csv(df_processed, "ct_fup2_processed.csv")
```

---
  
  ## 9️⃣  Quick sanity‑check plots (optional) ------------------------------

```r
# --------------------------------------------------------------
#  Distribution of total doxorubicin dose (just to see if it looks OK)
# --------------------------------------------------------------
df_processed %>%
  ggplot(aes(x = total_dox_mg2)) +
  geom_histogram(binwidth = 25, fill = "steelblue", colour = "white") +
  labs(title = "Total Doxorubicin Dose (mg/m²) per Patient",
       x = "Total dose (mg/m²)",
       y = "Number of patients")
```

---
  
  ## 10️⃣  What to do next? -----------------------------------------------------

* **Add more regimen codes** – simply extend `dox_lookup` or `epi_lookup`.  
* **Validate** – compare a handful of patients against the original Stata output to ensure the numbers match.  
* **Integrate** – the processed data set (`df_processed`) now contains the dose columns you need for downstream analyses (e.g., survival modeling, toxicity assessment, etc.).  

If you encounter any specific quirks in your original file (different column names, different missing‑value codes, etc.) just adjust the `select()` / `matches()` patterns in the *long* reshaping step.

---
  
  ## 🎉  Summary --------------------------------------------------------------

| Step | What we did |
  |------|--------------|
  | 1️⃣   | Loaded data (CSV/ Stata) |
  | 2️⃣   | Built lookup tables for regimen → dose |
  | 3️⃣   | Reshaped to long (patient‑cycle) |
  | 4️⃣   | Cleaned `n` and `c` columns (`999` → `NA`) |
  | 5️⃣   | Assigned doxorubicin dose per cycle (including high‑dose CAVE‑CEC) |
  | 6️⃣   | Assigned epirubicin dose per cycle |
  | 7️⃣   | Pivoted back to wide, producing columns `doxodosefup21 … doxodosefup27` and `epidosefup21 … epidosefup27` |
  | 8️⃣   | (Optional) Summed total dose per patient |
  | 9️⃣   | Saved the processed data set |
  
  You now have a **clean, reproducible** version of the original Stata script, but written in R with far less repetitive code.  

Feel free to adapt the lookup tables, column names, or file formats to match your exact environment.

---
  
  ### 🙋‍♂️  Need more help?
  
  * If you run into a *specific* error (e.g., columns not found, type conversion problems) paste the error message and a small excerpt of your data (first few rows) and I can help you adjust the code.  
* If you prefer a `data.table` version (often faster on huge data sets), let me know – the same logic can be expressed in just a few lines of `data.table` syntax.

Happy analyzing! 🎉