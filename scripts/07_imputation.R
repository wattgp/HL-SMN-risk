# 07_imputation.R
# SAP: missing data. Three approaches run IN PARALLEL so that descriptive and
# analytic results can be compared (decision Q1, 2026-10-14):
#   M1 complete-case analysis       (no imputation; models drop incomplete rows)
#   M2 multiple imputation by chained equations (MICE; White et al. 2011)
#   M3 substantive-model-compatible fully conditional specification
#      (SMC-FCS; Bartlett et al. 2015), compatible with the cause-specific
#      competing-risks model for any invasive SMN
#
# Output (in out_dir):
#   imp_m2_mice.Rds     list of m completed datasets (M2)
#   imp_m3_smcfcs.Rds   list of m completed datasets (M3)
# and output/<dummy|real>/07_imputation_comparison.html: distributions of the
# imputed variables under M1 / M2 / M3, with footnotes (decision Q5).
#
# Run after 05:  source(here::here("scripts", "07_imputation.R"))

# ---- decision log ------------------------------------------------------------
# Q1 (2026-10-14) Run M1, M2 and M3 in parallel and compare descriptive and
#    analytic results.
# PROPOSED implementation details (not yet agreed):
# I1 Variables imputed: the model exposures with missing values: doxorubicin
#    and procarbazine dose (on the CAPPED continuous scale, per 100 and per
#    1000 mg/m2; decision CAP), RT technique, pelvic RT, mediastinal RT and
#    the organ exposures (0/1/2, ordinal), BMI at diagnosis, and smoking
#    ever. Categories (doxo_cat, procarb_cat) and ovarian damage are DERIVED
#    from the imputed values in each dataset (passive), so they stay
#    consistent. (The caps lie above every category cut-off, so categories
#    from capped and uncapped doses are identical.)
# I2 M2 imputation model: all variables above plus sex, age at diagnosis,
#    era, histology, relapse, and the OUTCOME: the event indicators (SMN,
#    death) and the Nelson-Aalen cumulative hazards of SMN and of death at
#    the patient's exit time (White & Royston 2009). Methods: predictive
#    mean matching (continuous), logistic (binary), polytomous / ordered
#    logistic (categories / organ exposure).
# I3 M3 substantive model: cause-specific Cox models for any invasive SMN
#    and for death (smtype "compet"), with sex, age at diagnosis, era,
#    doxorubicin (per 100 mg/m2), procarbazine (per g/m2) and RT volume
#    (none / mantle or extended field / limited: regional field, involved
#    node or technique unknown). RT technique is grouped into these 3 levels
#    here because the sparse "involved node" level gives an infinite
#    coefficient and stops SMC-FCS; the imputed RT volume is mapped back to
#    rt_technique only where rt_technique was observed or unambiguous.
#    Only the variables of this model are imputed by M3; site-specific
#    variables (organ exposure, ovarian damage, smoking) come from M2.
# I6 Variables missing for more than 50% of patients are not imputed.
# I7 M3 imputes the dose CATEGORIES (ordinal), not the continuous doses;
#    continuous-dose models are compared under M1 and M2 only.
# I8 In M3, procarbazine has 3 levels (0 / <=4.2 / >4.2 g/m2): the >8.4
#    category is too sparse for the substantive model. Treatment contrasts
#    are used. If M3 still fails, M1 and M2 are produced and the failure is
#    reported.
# I4 m = 20 imputed datasets (m = 5 for the dummy data, to keep test runs
#    fast); seed fixed for reproducibility.
# I5 Imputation applies to BASELINE exposure; time-varying analyses use the
#    complete cases (follow-up treatment is rare: about 100 patients).

source(here::here("scripts", "00_config.R"))
source(here::here("scripts", "footnotes.R"))

library(dplyr)
library(tidyr)
library(survival)
library(mice)
library(smcfcs)
library(gt)

set.seed(20261014)
m_imp <- if (use_dummy) 5 else 20 # I4

res_dir <- here("output", if (use_dummy) "dummy" else "real")
dir.create(res_dir, recursive = TRUE, showWarnings = FALSE)

pat <- readRDS(file.path(out_dir, "analysis_patients.Rds"))

# ---- 1. imputation dataset -----------------------------------------------------

organ_cols <- grep("^organ_", names(pat), value = TRUE)

imp_data <- pat |>
  transmute(
    researchid,
    sex = factor(sex), age_dx, era = droplevels(era),
    hl_histology = factor(case_when(
      hl_morph %in% 9663:9667 ~ "NS", hl_morph == 9652 ~ "MC",
      hl_morph == 9651 ~ "LR", hl_morph %in% 9653:9655 ~ "LD",
      hl_morph == 9659 ~ "NLP", TRUE ~ "other/unknown")),
    relapse = factor(coalesce(relapse, "unknown")),
    # outcome (I2)
    status_any, time_any,
    # variables with missing values (I1)
    doxo_per100, procarb_per1000,
    rt_technique = droplevels(rt_technique),
    rt_pelvic = factor(rt_pelvic), rt_mediastinal = factor(rt_mediastinal),
    across(all_of(organ_cols), ~ factor(.x, levels = 0:2, ordered = TRUE)),
    bmi_dx,
    smoke_ever = factor(if_else(smoke_ever %in% c("yes", "no"), smoke_ever, NA_character_))
  )

# Nelson-Aalen cumulative hazards at the exit time (White & Royston 2009).
na_hazard <- function(time, event) {
  fit <- survfit(Surv(time, event) ~ 1)
  stepfun(fit$time, c(0, fit$cumhaz))(time)
}
imp_data <- imp_data |>
  mutate(
    ev_smn = as.integer(status_any == 1L), ev_death = as.integer(status_any == 2L),
    H_smn = na_hazard(time_any, ev_smn), H_death = na_hazard(time_any, ev_death)
  )

imputed_vars <- c("doxo_per100", "procarb_per1000", "rt_technique", "rt_pelvic",
                  "rt_mediastinal", organ_cols, "bmi_dx", "smoke_ever")

# I6: a variable missing for more than half of the patients is NOT imputed
# (too little information); it is reported and left missing.
pct_missing <- sapply(imp_data[imputed_vars], function(x) mean(is.na(x)))
not_imputed <- names(pct_missing)[pct_missing > 0.5]
if (length(not_imputed)) {
  cat("NOT imputed (>50% missing, I6):", paste(not_imputed, collapse = ", "), "\n")
}

# Passive derivations, applied to every completed dataset (I1).
derive <- function(d) {
  d |>
    mutate(
      doxo_cat = doxo_cat(doxo_per100 * 100),
      procarb_cat = procarb_cat(procarb_per1000 * 1000),
      ovarian_damage = case_when(
        rt_pelvic == "1" | procarb_per1000 * 1000 > procarb_high_mg ~ 1L,
        rt_pelvic == "0" & procarb_per1000 * 1000 <= procarb_high_mg ~ 0L,
        TRUE ~ NA_integer_
      )
    )
}

# ---- 2. M2: MICE -------------------------------------------------------------------

meth <- make.method(imp_data)
meth[] <- ""
meth[c("doxo_per100", "procarb_per1000", "bmi_dx")] <- "pmm"
meth[c("rt_pelvic", "rt_mediastinal", "smoke_ever")] <- "logreg"
meth["rt_technique"] <- "polyreg"
meth[organ_cols] <- "polr"
meth[!names(meth) %in% names(which(colSums(is.na(imp_data)) > 0))] <- ""
meth[not_imputed] <- ""

pred <- make.predictorMatrix(imp_data)
pred[, c("researchid", "status_any", "time_any")] <- 0 # use ev_* and H_* instead (I2)

mice_out <- mice(imp_data, m = m_imp, method = meth, predictorMatrix = pred,
                 printFlag = FALSE, seed = 20261014)
imp_m2 <- lapply(seq_len(m_imp), function(i) derive(complete(mice_out, i)))
if (!is.null(mice_out$loggedEvents)) {
  cat("\nMICE logged events (predictors removed for collinearity / constants):\n")
  print(head(as.data.frame(count(mice_out$loggedEvents, meth, out)), 20))
}

# ---- 3. M3: SMC-FCS (competing risks) ----------------------------------------------

imp_data <- imp_data |>
  mutate(rt_volume = factor(case_when(
    rt_technique == "no RT" ~ "none",
    rt_technique == "mantle / extended field" ~ "extended",
    !is.na(rt_technique) ~ "limited",
    TRUE ~ NA_character_
  ), levels = c("none", "extended", "limited")))
# I7: in M3 the doses enter as their CATEGORIES (ordinal, "podds"):
# smcfcs can only impute a continuous variable with a normal model, which
# fits badly for doses that are exactly 0 for many patients (it shifted
# patients from 0 into 1-200 in a test run). The categories are also the
# exposure scale of the categorical dose-response analyses.
imp_data <- imp_data |>
  mutate(doxo_cat_obs = factor(doxo_cat(doxo_per100 * 100), ordered = TRUE),
         # Procarbazine in 3 levels for M3 only (0 / <=4.2 / >4.2 g/m2; the
         # >8.4 category is too sparse for the substantive model, I8).
         procarb_cat_obs = factor(case_when(
           procarb_per1000 == 0 ~ "0",
           procarb_per1000 <= 4.2 ~ "<=4.2",
           procarb_per1000 > 4.2 ~ ">4.2"
         ), levels = c("0", "<=4.2", ">4.2"), ordered = TRUE))
sm_vars <- c("sex", "age_dx", "era", "doxo_cat_obs", "procarb_cat_obs", "rt_volume")
sm_rhs <- paste(sm_vars, collapse = " + ")
m3_data <- imp_data |>
  select(time_any, status_any, all_of(sm_vars)) |>
  as.data.frame()
m3_meth <- setNames(rep("", ncol(m3_data)), names(m3_data))
m3_meth[c("doxo_cat_obs", "procarb_cat_obs")] <- "podds"
m3_meth["rt_volume"] <- "mlogit"
m3_meth[!names(m3_meth) %in% names(which(colSums(is.na(m3_data)) > 0))] <- ""

# Treatment contrasts also for ordered factors (polynomial contrasts make
# sparse categories unstable in the Cox model).
op <- options(contrasts = c("contr.treatment", "contr.treatment"))
smc_out <- tryCatch(
  smcfcs(
    originaldata = m3_data, smtype = "compet",
    smformula = c(paste("Surv(time_any, status_any == 1) ~", sm_rhs),
                  paste("Surv(time_any, status_any == 2) ~", sm_rhs)),
    method = m3_meth, m = m_imp, numit = 10, rjlimit = 5000, noisy = FALSE
  ),
  error = function(e) {
    cat("ACTION: M3 (SMC-FCS) FAILED:", conditionMessage(e), "\n",
        "Usually a category with (almost) no events in the substantive model.",
        "M1 and M2 are still produced; tell the project leader before the",
        "comparison, and consider merging sparse categories (I8).\n")
    NULL
  }
)
options(op)
# Add back the other variables (site-specific ones from the matching M2
# dataset, I3) and derive the passive variables.
imp_m3 <- if (is.null(smc_out)) NULL else lapply(seq_len(m_imp), function(i) {
  d3 <- smc_out$impDatasets[[i]]
  imp_m2[[i]] |>
    mutate(rt_volume = d3$rt_volume,
           # rt_technique: observed value kept; where it was missing, M3's RT
           # volume decides "no RT" / "mantle / extended field", and the M2
           # value is kept for "limited" (which M3 does not split further).
           rt_technique = case_when(
             !is.na(imp_data$rt_technique) ~ imp_data$rt_technique,
             rt_volume == "none" ~ factor("no RT", levels = levels(rt_technique)),
             rt_volume == "extended" ~ factor("mantle / extended field", levels = levels(rt_technique)),
             TRUE ~ rt_technique
           )) |>
    derive() |>
    # I7: M3 categories replace the ones derived from M2's continuous dose;
    # M3 provides no continuous dose (doxo_per100 / procarb_per1000 = NA).
    mutate(doxo_cat = factor(d3$doxo_cat_obs, ordered = FALSE),
           procarb_cat = factor(d3$procarb_cat_obs, ordered = FALSE),
           doxo_per100 = NA_real_, procarb_per1000 = NA_real_,
           ovarian_damage = case_when(
             rt_pelvic == "1" | procarb_cat %in% ">4.2" ~ 1L,
             rt_pelvic == "0" & procarb_cat %in% c("0", "<=4.2") ~ 0L,
             TRUE ~ NA_integer_))
})

# ---- 4. descriptive comparison M1 / M2 / M3 ----------------------------------------

summ_cat <- function(d, v) {
  d |> filter(!is.na(.data[[v]])) |> count(level = as.character(.data[[v]])) |>
    mutate(pct = 100 * n / sum(n)) |> select(level, pct)
}
summ_cont <- function(d, v) {
  tibble(level = "median", pct = median(d[[v]], na.rm = TRUE))
}
compare_var <- function(v, type) {
  f <- if (type == "cat") summ_cat else summ_cont
  m1 <- f(derive(imp_data), v) |> rename(M1 = pct)
  m2 <- bind_rows(lapply(imp_m2, f, v = v)) |> group_by(level) |>
    summarise(M2 = mean(pct), .groups = "drop")
  m3 <- if (is.null(imp_m3)) tibble(level = character(), M3 = numeric()) else
    bind_rows(lapply(imp_m3, f, v = v)) |> group_by(level) |>
      summarise(M3 = mean(pct), .groups = "drop")
  m1 |> full_join(m2, by = "level") |> full_join(m3, by = "level") |>
    mutate(variable = v, n_missing = sum(is.na(derive(imp_data)[[v]])), .before = 1)
}
comparison <- bind_rows(
  compare_var("doxo_per100", "cont"), compare_var("doxo_cat", "cat"),
  compare_var("procarb_per1000", "cont"), compare_var("procarb_cat", "cat"),
  compare_var("rt_technique", "cat"), compare_var("ovarian_damage", "cat"),
  compare_var("smoke_ever", "cat"), compare_var("bmi_dx", "cont")
) |>
  mutate(across(c(M1, M2, M3), ~ round(.x, 1)))

comparison_gt <- comparison |>
  gt(groupname_col = "variable") |>
  cols_label(level = "", n_missing = "Missing (n)",
             M1 = "M1 complete case", M2 = "M2 MICE", M3 = "M3 SMC-FCS") |>
  tab_header(title = "Imputation: distribution of imputed variables under M1 / M2 / M3",
             subtitle = paste0("Percent per category, or median for continuous variables; ",
                               m_imp, " imputed datasets (averaged)")) |>
  tab_source_note(paste(
    "M1: observed values only. M2: multiple imputation by chained equations, including",
    "the outcome (event indicators and Nelson-Aalen cumulative hazards; White & Royston",
    "2009; White et al. 2011). M3: substantive-model-compatible imputation for the",
    "cause-specific competing-risks model of any invasive SMN (Bartlett et al. 2015);",
    "doses imputed as categories (ordinal model) in M3, procarbazine as 0 / <=4.2 / >4.2 g/m2,",
    "so M3 gives no continuous dose;",
    "variables not in that model are taken from M2. Doses on the capped scale",
    "(doxorubicin per 100 mg/m2, capped at 550; procarbazine per g/m2, capped at 11.2);",
    "categories and ovarian damage derived from the imputed values.")) |>
  tab_source_note(fn_cohort) |>
  tab_source_note(paste(
    "References: White IR, Royston P. Imputing missing covariate values for the Cox model.",
    "Stat Med 2009. doi:10.1002/sim.3618; White IR, Royston P, Wood AM. Multiple imputation",
    "using chained equations: issues and guidance for practice. Stat Med 2011.",
    "doi:10.1002/sim.4067; Bartlett JW, et al. Multiple imputation of covariates by fully",
    "conditional specification: accommodating the substantive model. Stat Methods Med Res",
    "2015. doi:10.1177/0962280214521348"))

# ---- 5. save -----------------------------------------------------------------------

saveRDS(imp_m2, file.path(out_dir, "imp_m2_mice.Rds"))
saveRDS(imp_m3, file.path(out_dir, "imp_m3_smcfcs.Rds"))
gtsave(comparison_gt, file.path(res_dir, "07_imputation_comparison.html"))

cat("\n== Imputation (", m_imp, "datasets ) ==\n")
print(as.data.frame(comparison), row.names = FALSE)
cat("\nOK: imputed datasets saved; compare M1/M2/M3 in", file.path(res_dir, "07_imputation_comparison.html"), "\n")
