# 09_models.R
# SAP part C: multivariable models of SMN risk, with RADIOTHERAPY as the
# primary exposure. For "any SMN" and each site with MORE THAN 15 invasive
# SMNs (min_cases_model = 16 in 00_config.R; decision C12a).
#
# Workflow per outcome (decisions Q6, Q6a-e; 2026-10-14):
#   0. Base model: RT + age at diagnosis + year of diagnosis (both linear;
#      a natural spline with 3 df only if a likelihood-ratio test says it
#      fits significantly better).
#   1. EFFECT MODIFICATION first: for each prespecified modifier (including
#      chemotherapy and time since diagnosis), the RT estimate WITHIN each
#      category of the modifier and a likelihood-ratio test of the
#      interaction. A modifier with p < em_p stays in the model as an
#      interaction (Knol & VanderWeele 2012).
#   2. CONFOUNDING next: each prespecified candidate is kept if it changes
#      an RT estimate by >= 10% (Mickey & Greenland 1989) or lowers the AIC
#      (prediction). Effect estimates of EVERY covariate in the final model
#      are reported.
#   3. Final model, fitted with three methods in parallel (Q3):
#      C1 Poisson regression on person-time split by time since diagnosis
#         (5-14, 15-24, >=25 years): rate ratios;
#      C2 cause-specific Cox model (time-varying RT effect by window if
#         effect modification by time was found): hazard ratios;
#      C3 pseudo-observation regression of the cumulative incidence at 15
#         and 25 years since diagnosis: risk differences.
#      Small sites (< 20 SMNs): RT binary and Firth-penalised C1/C2 (Q6e).
#   4. Missing data (Q1): the selection uses the complete cases (M1); the
#      final model is also fitted on the MICE (M2) and SMC-FCS (M3) data
#      with baseline exposure, pooled with Rubin's rules, for comparison.
#
# Output: output/<dummy|real>/09_<outcome>.html (selection + final models,
#         with footnotes) and 09_summary_rt.html (RT estimates across
#         methods C1-C3 and missing-data approaches M1-M3).
#
# Run after 05 and 07:  source(here::here("scripts", "09_models.R"))

# ---- decision log ------------------------------------------------------------
# Q3 (2026-10-14) C1, C2, C3 in parallel; windows 5-14 / 15-24 / >=25 years.
# Q6 (2026-10-14) All models: age and year of diagnosis. Other covariates
#    only if they improve prediction or confound RT-SMN.
# Q6a Prespecified candidates; >=10% change-in-estimate or lower AIC; the
#    events-per-parameter rule may be relaxed for important covariates.
# Q6b Effect modification first, then confounding.
# Q6c Age / year linear; spline (3 df) only if LR test significant.
# Q6d Chemotherapy: effect modifier first, then confounder; estimates of
#    all covariates reported.
# Q6e Sites with 10-19 SMNs: binary RT, Firth-penalised estimation.
# P5 (2026-10-14) Site-specific models account for another SMN diagnosed
#    earlier during follow-up (time-varying indicator, reported).
# D5 / W3 Treatment during follow-up: time-varying (2-year lag), in C1/C2
#    under M1. C3 and the M2/M3 fits use baseline exposure (I5).
# PROPOSED (not yet agreed):
# MD1 Primary RT variable: organ exposure 0/1/2 for organ sites (binary in
#     field vs not for small sites); RT volume (none / extended / limited)
#     for any SMN; any RT (yes/no) for sites without an organ mapping.
# C12a (2026-10-14) Multivariable models only for sites with > 15 invasive
#    SMNs (min_cases_model = 16). All site-specific analyses count invasive
#    SMNs only (behaviour 3 or 9; from 01_clean-data.R).
# EM-B (2026-10-14) Additional effect-modification analysis for breast
#    cancer in AYA women (< 40): anthracycline receipt, ovarian failure
#    (proxy: ovarian damage), smoking (section 4c).
# X1 (2026-10-14) Organ exposure collapsed to in field vs not in field
#    (bordering + not irradiated) in ALL analyses; replaces the 3-level
#    exposure of MD1 (the T2a trend test therefore no longer applies).
# E2 (2026-10-14) Dichotomised era (1989-1999 / 2000-latest) as the era
#    effect modifier.
# A2 (2026-10-14) Age (or year) not in a model twice: if age group (era) is
#    kept as an effect modifier, it replaces continuous age (year).
# S1 (2026-10-14) Sex "other" excluded from analyses using sex.
# R-REF (2026-10-14) Model tables show the reference category of every
#    categorical covariate.
# T1 (2026-10-14) Confirmatory: the RT association for any invasive SMN,
#    breast cancer (women) and lung cancer, at alpha = 0.05; all other
#    outcomes are exploratory.
# T2a (2026-10-14) Trend test (1 df) over organ exposure: to implement only
#    if the risk increases monotonically across categories; the script
#    prints a REMINDER when it does.
# T2b (2026-10-14) Effect modification limited to age at diagnosis (AYA),
#    doxorubicin and era; the earlier modifiers (procarbazine, ovarian
#    damage, smoking, time since diagnosis) are kept as ADDITIONAL analyses
#    for future use and do not enter the model.
# T3 (2026-10-14) q-values (Benjamini-Hochberg FDR) for the overall RT
#    associations and for the main interaction tests (and Gray's tests in 08).
# MD1-MD5 reviewed by the project leader 2026-10-14:
# MD1 (APPROVED) RT variable per site as described above.
# MD2 (DECIDED) ALL stratum-specific RT estimates (95% CI) are reported for
#     every prespecified modifier, whatever the interaction p-value. The
#     interaction is kept in the main (final) model only if p < 0.05.
# MD3 (APPROVED) Chemotherapy as a modifier: doxorubicin yes/no and
#     procarbazine yes/no; as a confounder: dose categories (procarbazine
#     0 / <=4.2 / >4.2 g/m2) for sites with >= 50 SMNs, yes/no otherwise.
# MD4 (REVISED) No limit on the number of parameters. Instead a candidate
#     confounder is NOT added if it creates SPARSE CELLS: fewer than
#     sparse_min SMNs in any cell of RT category x candidate category, or a
#     non-estimable (infinite) estimate. The same sparse-cell rule applies to
#     effect modifiers (stratum / interaction not estimable).
# MD5 (APPROVED) No model if fewer than 5 SMNs remain in the complete cases.

source(here::here("scripts", "00_config.R"))
source(here::here("scripts", "footnotes.R"))

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(purrr)
  library(survival)
  library(splines)
  library(brglm2)
  library(coxphf)
  library(eventglm)
  library(gt)
})

set.seed(20261014)
res_dir <- here("output", if (use_dummy) "dummy" else "real")
dir.create(res_dir, recursive = TRUE, showWarnings = FALSE)

em_p <- 0.05                    # MD2
cie <- 0.10                     # Q6a
spline_p <- 0.05                # Q6c
window_cuts_fu <- c(10, 20)     # windows since diagnosis 5-14 / 15-24 / >=25 (follow-up starts at 5)
c3_horizons_dx <- c(15, 25)
small_site <- 20                # Q6e: < 20 SMNs = small
sparse_min <- 3                 # MD4 (revised): minimum SMNs per RT x covariate cell
confirmatory_outcomes <- c("Any invasive SMN", "Breast", "Lung") # T1
min_events_cc <- 5              # MD5: minimum SMNs in the complete cases to fit a model
entry_years <- 5

female_sites <- c("Breast", "Cervix", "Corpus uteri", "Ovary", "Other female genital")
male_sites <- c("Prostate", "Testis", "Other male genital")
organ_of_site <- c(Breast = "breast", Lung = "lung", Thyroid = "thyroid",
                   Oesophagus = "oesophagus", Stomach = "stomach", Pancreas = "pancreas",
                   Colorectum = "colorectum", "Head and neck" = "head_neck",
                   Bladder = "pelvic_organs", Prostate = "pelvic_organs", Cervix = "pelvic_organs")

# Prespecified candidates beyond the chemotherapy variables (Q6a; see the
# literature table in docs/proposal_analysis-methods.md).
site_modifiers <- list(Breast = "ovarian_damage", Lung = "smoke_ever")
site_confounders <- list(Breast = "ovarian_damage", Lung = "smoke_ever")

pat <- readRDS(file.path(out_dir, "analysis_patients.Rds"))
site_long <- readRDS(file.path(out_dir, "analysis_site_long.Rds"))
tv <- readRDS(file.path(out_dir, "analysis_tv.Rds"))
imp_m2 <- readRDS(file.path(out_dir, "imp_m2_mice.Rds"))
imp_m3 <- tryCatch(readRDS(file.path(out_dir, "imp_m3_smcfcs.Rds")), error = function(e) NULL)

# ---- 1. variables ------------------------------------------------------------------

yn <- function(x) factor(if_else(x %in% c("yes", "no"), x, NA_character_), levels = c("no", "yes"))
prep_exposure <- function(d) {
  d |> mutate(
    rt_any_f = factor(rt_any, levels = 0:1, labels = c("no", "yes")),
    rt_volume = factor(case_when(
      rt_technique == "no RT" ~ "none",
      rt_technique == "mantle / extended field" ~ "extended",
      rt_technique %in% c("regional field (presumed involved field)", "involved node") ~ "limited",
      TRUE ~ NA_character_), levels = c("none", "limited", "extended")),
    doxo_any_f = yn(doxo_any), procarb_any_f = yn(procarb_any),
    # Any anthracycline (doxorubicin, epirubicin or other anthracycline /
    # anthraquinone): yes if any is yes, no if all are no (EM-B).
    anthra_any_f = factor(case_when(
      doxo_any %in% "yes" | epirubicin_any %in% "yes" | other_anthra_any %in% "yes" ~ "yes",
      doxo_any %in% "no" & epirubicin_any %in% "no" & other_anthra_any %in% "no" ~ "no"),
      levels = c("no", "yes")),
    doxo_cat_f = factor(as.character(doxo_cat), levels = c("0", "1-200", ">200")),
    procarb_cat3 = factor(case_when(
      procarb_cat == "0" ~ "0", procarb_cat == "<=4.2" ~ "<=4.2",
      procarb_cat %in% c("4.3-8.4", ">8.4", ">4.2") ~ ">4.2"), levels = c("0", "<=4.2", ">4.2")),
    ovarian_damage = factor(ovarian_damage, levels = 0:1, labels = c("no", "yes")),
    across(starts_with("organ_"), ~ factor(.x, levels = 0:2,
                                           labels = c("not irradiated", "bordering field", "in field")),
           .names = "{.col}_f"),
    across(starts_with("organ_") & !ends_with("_f"),
           ~ factor(if_else(.x == 2, "in field", "not in field (bordering or not irradiated)"),
                    levels = c("not in field (bordering or not irradiated)", "in field")),
           .names = "{.col}_bin")
  )
}
pat_raw <- pat # unprepared copy, used to rebuild the imputed datasets
prep_pat <- function(d) {
  d |>
    # Year of diagnosis centred at 2000 (numerical stability; the rate ratio
    # per year is unchanged).
    mutate(year_dx = as.numeric(year_dx) - 2000,
           sex = sex_analysis,                     # S1: sex "other" -> NA
           era = droplevels(era), era2 = droplevels(era2), # E2
           age_dx_aya = droplevels(age_dx_aya),
           smoke_ever = yn(smoke_ever)) |>
    prep_exposure()
}
pat <- prep_pat(pat)
tv <- prep_exposure(tv)

# ---- 2. per-outcome data: counting process with windows and time-varying RT ------

# Long data in time since the START OF FOLLOW-UP (0 = 5 years after
# diagnosis): intervals split at time-varying exposure changes (tv) and at the
# window cut points; event = SMN of this outcome in the interval;
# cause-specific (death censors).
build_long <- function(outcome, tv_vars) {
  if (outcome == "Any invasive SMN") {
    base <- pat |> transmute(researchid, time = time_any, status = status_any,
                             time_other_smn = NA_real_)
  } else {
    base <- site_long |> filter(site_group == outcome) |>
      transmute(researchid, time, status, time_other_smn)
  }
  base <- base |> filter(!is.na(time), time > 0) |>
    left_join(pat |> select(researchid, sex, age_dx, year_dx, smoke_ever, era2, age_dx_aya),
              by = "researchid")
  if (outcome %in% female_sites) base <- filter(base, sex == "female")
  if (outcome %in% male_sites) base <- filter(base, sex == "male")
  base <- base |> mutate(event = as.integer(status == 1L), id = researchid)

  d <- tmerge(as.data.frame(base), as.data.frame(base), id = id,
              ev = event(time, event))
  tv_sel <- tv |> filter(researchid %in% base$researchid) |>
    select(id = researchid, tstart, all_of(tv_vars)) |> as.data.frame()
  # tmerge() evaluates its arguments non-standardly, so the call is built
  # as text: one tdc() per time-varying variable.
  tv_call <- sprintf("tmerge(d, tv_sel, id = id, %s)",
                     paste0(tv_vars, " = tdc(tstart, ", tv_vars, ")", collapse = ", "))
  d <- eval(parse(text = tv_call))
  if (outcome != "Any invasive SMN") {
    d <- tmerge(d, as.data.frame(base |> filter(!is.na(time_other_smn))), id = id,
                other_smn = tdc(time_other_smn))
    d$other_smn <- factor(ifelse(is.na(d$other_smn), 0, d$other_smn), 0:1, c("no", "yes"))
  }
  d <- survSplit(Surv(tstart, tstop, ev) ~ ., data = d, cut = window_cuts_fu,
                 episode = "window_i")
  d$window <- factor(d$window_i, 1:3, c("5-14", "15-24", ">=25"))
  d$pt <- d$tstop - d$tstart
  d
}

# ---- 3. model helpers --------------------------------------------------------------

rhs_of <- function(terms) paste(terms, collapse = " + ")
fit_c1 <- function(d, terms, firth = FALSE) {
  # The window (time since diagnosis) is the piecewise baseline; it is left
  # out when the data hold a single window (stratified fits by window).
  w <- if (n_distinct(d$window) > 1) "window" else NULL
  f <- as.formula(paste("ev ~", rhs_of(c(terms, w)), "+ offset(log(pt))"))
  if (firth) glm(f, family = poisson, data = d, method = "brglmFit") else
    glm(f, family = poisson, data = d)
}
fit_c2 <- function(d, terms, firth = FALSE) {
  f <- as.formula(paste("Surv(tstart, tstop, ev) ~", rhs_of(terms)))
  if (firth) coxphf(f, data = d) else coxph(f, data = d)
}
loglik <- function(m) if (inherits(m, "glm")) as.numeric(logLik(m)) else m$loglik[2]
lr_test <- function(m0, m1) {
  df <- length(coef(m1)) - length(coef(m0))
  stat <- 2 * (loglik(m1) - loglik(m0))
  if (df <= 0) return(NA_real_)
  pchisq(stat, df, lower.tail = FALSE)
}
# A model is "degenerate" when a category combination has (almost) no
# events: coefficients run off to +/- infinity (monotone likelihood /
# separation). Such estimates are not interpretable; they are flagged, and
# an interaction from a degenerate model is NOT kept.
degenerate <- function(m) {
  b <- coef(m)
  v <- tryCatch(if (inherits(m, "coxphf")) m$var else vcov(m), error = function(e) NULL)
  se <- if (is.null(v)) rep(Inf, length(b)) else sqrt(diag(as.matrix(v)))
  # Only covariate terms: the intercept and the window baseline are not
  # covariate effects.
  keep <- !names(b) %in% "(Intercept)" & !startsWith(names(b), "window")
  b <- b[keep]; se <- se[keep]
  any(!is.finite(b)) || any(abs(b) > 8, na.rm = TRUE) || any(!is.finite(se)) || any(se > 20, na.rm = TRUE)
}
rt_coefs <- function(m, rt) {
  b <- coef(m)
  b[startsWith(names(b), rt) & !grepl(":", names(b))]
}
est_table <- function(m, scale_label) {
  b <- coef(m)
  v <- if (inherits(m, "coxphf")) m$var else vcov(m)
  se <- sqrt(diag(as.matrix(v)))
  keep <- !names(b) %in% "(Intercept)" & !startsWith(names(b), "window")
  tibble(term = names(b)[keep],
         est = sprintf("%.2f (%.2f–%.2f)", exp(b[keep]),
                       exp(b[keep] - 1.96 * se[keep]), exp(b[keep] + 1.96 * se[keep])),
         scale = scale_label)
}

# ---- 4. selection and final models per outcome ------------------------------------

outcome_counts <- bind_rows(
  tibble(site_group = "Any invasive SMN", n_smn = sum(pat$status_any == 1L, na.rm = TRUE)),
  site_long |> filter(status == 1L) |> count(site_group, name = "n_smn")
)
model_outcomes <- outcome_counts |> filter(n_smn >= min_cases_model)

run_outcome <- function(outcome, n_smn) {
  small <- n_smn < small_site && outcome != "Any invasive SMN"
  organ <- organ_of_site[outcome]
  # X1 (2026-10-14): organ exposure is ALWAYS in field vs not in field
  # (bordering and not irradiated collapsed), for every site size.
  rt <- if (outcome == "Any invasive SMN") "rt_volume" else if (!is.na(organ)) {
    paste0("organ_", organ, "_bin")
  } else "rt_any_f"
  big <- n_smn >= 50
  chemo_conf <- if (big) c("doxo_cat_f", "procarb_cat3") else c("doxo_any_f", "procarb_any_f")
  # T2b: the MAIN effect-modification analysis (used for the model) is
  # limited to age at diagnosis (AYA 15-39 vs 40-50), doxorubicin and era.
  # The earlier modifiers are still analysed and reported as ADDITIONAL
  # (kept for future use; not used to build the model).
  main_modifiers <- c("age_dx_aya", "doxo_any_f", "era2") # E2: dichotomised era
  additional_modifiers <- unique(c("procarb_any_f", site_modifiers[[outcome]], "window"))
  modifiers <- unique(c(main_modifiers, setdiff(additional_modifiers, "window")))
  confounders <- unique(c(chemo_conf, site_confounders[[outcome]],
                          if (!outcome %in% c(female_sites, male_sites)) "sex"))
  tv_vars <- unique(c(rt, "doxo_any_f", "procarb_any_f", chemo_conf, "ovarian_damage"))
  d <- build_long(outcome, intersect(tv_vars, names(tv)))
  # Complete cases for ALL candidate variables, so that every compared model
  # uses the same patients (M1).
  needed <- unique(c(rt, "age_dx", "year_dx", modifiers, confounders))
  d <- d[complete.cases(d[, intersect(needed, names(d))]), ]
  # Too few events left after removing incomplete cases: no model.
  if (sum(d$ev) < min_events_cc) {
    cat("ACTION:", outcome, "has only", sum(d$ev), "SMN(s) in the complete cases (of", n_smn,
        "); no model fitted. Check which candidate variables are missing (07 comparison).\n")
    return(NULL)
  }
  adj <- c("age_dx", "year_dx", if (outcome != "Any invasive SMN") "other_smn")
  firth <- small

  # 0. base model + spline tests (Q6c)
  base_terms <- c(rt, adj)
  m0 <- fit_c1(d, base_terms, firth)
  spline_tests <- map_dfr(c("age_dx", "year_dx"), function(v) {
    m_s <- fit_c1(d, c(setdiff(base_terms, v), paste0("ns(", v, ", df = 3)")), firth)
    p <- lr_test(m0, m_s)
    tibble(variable = v, lr_p = p, use_spline = !is.na(p) && p < spline_p)
  })
  for (v in spline_tests$variable[spline_tests$use_spline]) {
    adj[adj == v] <- paste0("ns(", v, ", df = 3)")
  }
  base_terms <- c(rt, adj)
  m0 <- fit_c1(d, base_terms, firth)

  # 1. effect modification FIRST (Q6b): stratum-specific RT estimates and LR
  #    test of the interaction; time since diagnosis (window) included.
  em <- map_dfr(c(main_modifiers, additional_modifiers), function(mv) {
    if (n_distinct(d[[mv]], na.rm = TRUE) < 2) return(NULL)
    terms_main <- unique(c(base_terms, if (mv != "window") mv))
    m_main <- fit_c1(d, terms_main, firth)
    m_int <- tryCatch(fit_c1(d, c(terms_main, paste0(rt, ":", mv)), firth),
                      error = function(e) NULL)
    tab_em <- tapply(d$ev, list(d[[rt]], d[[mv]]), sum); tab_em[is.na(tab_em)] <- 0
    sparse <- (!is.null(m_int) && degenerate(m_int)) || min(tab_em) < sparse_min
    p <- if (is.null(m_int) || sparse) NA_real_ else lr_test(m_main, m_int)
    strata <- map_dfr(levels(factor(d[[mv]])), function(lv) {
      ds <- d[d[[mv]] == lv, ]
      if (sum(ds$ev) < 3) return(tibble(level = lv, rt_estimate = "too few events"))
      ms <- tryCatch(fit_c1(ds, base_terms, firth), error = function(e) NULL)
      if (is.null(ms)) return(tibble(level = lv, rt_estimate = "not estimable"))
      if (degenerate(ms)) return(tibble(level = lv, rt_estimate = "not estimable (sparse categories)"))
      b <- rt_coefs(ms, rt)
      v <- if (inherits(ms, "coxphf")) ms$var else vcov(ms)
      se <- sqrt(diag(as.matrix(v)))[names(b)]
      tibble(level = lv, rt_estimate = paste(
        sprintf("%s %.2f (%.2f\u2013%.2f)", sub(rt, "", names(b)), exp(b),
                exp(b - 1.96 * se), exp(b + 1.96 * se)), collapse = "; "))
    })
    strata |> mutate(modifier = mv, interaction_p = p,
                     set = if (mv %in% main_modifiers) "main (T2b)" else "additional (future use)",
                     note = if (sparse) "interaction not testable: sparse categories" else NA_character_,
                     .before = 1)
  })
  # Only the MAIN modifiers (T2b) can enter the model.
  modifiers_kept <- em |> filter(set == "main (T2b)") |> distinct(modifier, interaction_p) |>
    filter(!is.na(interaction_p), interaction_p < em_p) |> pull(modifier)
  # A2 (2026-10-14): age (and year) must not enter twice. If age group
  # (AYA) is kept as a modifier, it replaces continuous age in the model;
  # likewise the dichotomised era replaces continuous year of diagnosis.
  drop_cont <- c(if ("age_dx_aya" %in% modifiers_kept) "age_dx",
                 if ("era2" %in% modifiers_kept) "year_dx")
  if (length(drop_cont)) {
    base_terms <- base_terms[!vapply(base_terms, function(t)
      any(vapply(drop_cont, function(v) grepl(v, t, fixed = TRUE), logical(1))), logical(1))]
  }

  # 2. confounding NEXT (Q6a): change-in-estimate (on the RT log rate ratio)
  #    or lower AIC, among candidates that are not modifiers.
  # (paste0() with an empty vector would return "rt:", so guard it.)
  cur_terms <- c(base_terms, setdiff(modifiers_kept, "window"),
                 if (length(modifiers_kept)) paste0(rt, ":", modifiers_kept))
  m_cur <- fit_c1(d, cur_terms, firth)
  b_ref <- rt_coefs(m_cur, rt)
  # MD4 (revised): fewest SMNs in any RT x candidate cell.
  min_cell <- function(cv) {
    tab <- tapply(d$ev, list(d[[rt]], d[[cv]]), sum)
    tab[is.na(tab)] <- 0
    min(tab)
  }
  conf <- map_dfr(setdiff(confounders, modifiers_kept), function(cv) {
    mc <- min_cell(cv)
    if (mc < sparse_min) {
      return(tibble(candidate = cv, pct_change = NA, delta_aic = NA, kept = FALSE,
                    note = paste0("not added: sparse cells (fewest SMNs in an RT x ", cv,
                                  " cell = ", mc, " < ", sparse_min, "; MD4)")))
    }
    m_c <- tryCatch(fit_c1(d, c(cur_terms, cv), firth), error = function(e) NULL)
    if (is.null(m_c) || degenerate(m_c)) {
      return(tibble(candidate = cv, pct_change = NA, delta_aic = NA, kept = FALSE,
                    note = "not estimable (sparse categories)"))
    }
    b_c <- rt_coefs(m_c, rt)
    pct <- max(abs(b_c - b_ref) / pmax(abs(b_ref), 1e-8))
    tibble(candidate = cv, pct_change = round(100 * pct, 1),
           delta_aic = round(AIC(m_c) - AIC(m_cur), 1),
           kept = pct >= cie || (AIC(m_c) - AIC(m_cur)) < 0, note = NA_character_)
  })
  conf_kept <- conf$candidate[conf$kept]
  final_terms <- c(cur_terms, conf_kept)

  # 3. final models C1, C2, C3 (M1)
  c1 <- fit_c1(d, final_terms, firth)
  if (degenerate(c1)) {
    cat("ACTION:", outcome, "- the final model has non-estimable (infinite) terms from sparse",
        "categories; interpret only the finite estimates and consider merging categories",
        "or Firth estimation; discuss with the project leader.\n")
  }
  c2_terms <- sub(":window$", ":strata(window)", final_terms) # time-varying RT effect by window
  c2 <- tryCatch(fit_c2(d, c2_terms, firth), error = function(e) NULL)
  # C3: baseline exposure, one row per patient (I5)
  base_pat <- d |> group_by(id) |> slice(1) |> ungroup() |>
    left_join(pat |> select(id = researchid, any_of(c("time_any", "status_any"))), by = "id")
  c3 <- map_dfr(c3_horizons_dx, function(h) {
    pd <- if (outcome == "Any invasive SMN") {
      pat |> transmute(id = researchid, time = time_any, status = status_any)
    } else {
      site_long |> filter(site_group == outcome) |> transmute(id = researchid, time, status)
    }
    pd <- pd |> inner_join(base_pat |> select(id, all_of(setdiff(all.vars(as.formula(paste("~", rhs_of(final_terms)))), "window"))),
                           by = "id") |>
      mutate(status = factor(status, 0:2, c("censored", "SMN", "death")))
    terms3 <- final_terms[!grepl("window", final_terms)]
    m3 <- tryCatch(
      cumincglm(as.formula(paste("Surv(time, status) ~", rhs_of(terms3))),
                time = h - entry_years, cause = "SMN", link = "identity", data = as.data.frame(pd)),
      error = function(e) NULL)
    if (is.null(m3)) return(tibble(horizon = h, term = NA_character_, est = "not estimable"))
    b <- coef(m3); se <- suppressWarnings(sqrt(diag(vcov(m3))))
    keep <- names(b) != "(Intercept)"
    tibble(horizon = h, term = names(b)[keep],
           est = if_else(is.finite(se[keep]),
                         sprintf("%+.1f%% (%+.1f to %+.1f)", 100 * b[keep],
                                 100 * (b[keep] - 1.96 * se[keep]), 100 * (b[keep] + 1.96 * se[keep])),
                         sprintf("%+.1f%% (CI not estimable)", 100 * b[keep])))
  })

  # 4. M2 / M3: final model with baseline exposure on imputed data, pooled
  pool_rubin <- function(fits) {
    fits <- compact(fits)
    if (!length(fits)) return(NULL)
    B <- do.call(rbind, map(fits, coef)); V <- map(fits, vcov)
    qbar <- colMeans(B); ubar <- Reduce(`+`, V) / length(V)
    bvar <- cov(B); tvar <- ubar + (1 + 1 / nrow(B)) * bvar
    tibble(term = names(qbar), b = qbar, se = sqrt(diag(tvar)))
  }
  fit_imputed <- function(imps) {
    if (is.null(imps)) return(NULL)
    imp_cols <- c("doxo_cat", "procarb_cat", "rt_technique", "ovarian_damage", "smoke_ever",
                  grep("^organ_", names(imps[[1]]), value = TRUE))
    fits <- map(imps, function(di) {
      # Start from the analysis patients and overwrite only the imputed
      # columns, so every other variable is exactly as in the M1 analysis.
      di <- di |> select(researchid, any_of(imp_cols)) |>
        mutate(across(any_of(c("doxo_cat", "procarb_cat", "rt_technique")), as.character),
               across(starts_with("organ_"), ~ as.integer(as.character(.x))),
               smoke_ever = as.character(smoke_ever))
      base <- pat_raw |> filter(researchid %in% di$researchid) |>
        select(-any_of(setdiff(names(di), "researchid"))) |>
        left_join(di, by = "researchid") |>
        mutate(doxo_any = if_else(doxo_cat == "0", "no", "yes"),
               procarb_any = if_else(procarb_cat == "0", "no", "yes"),
               rt_any = as.integer(rt_technique != "no RT"))
      base <- prep_pat(base)
      if (outcome != "Any invasive SMN") {
        base <- base |> select(-status_any, -time_any) |>
          inner_join(site_long |> filter(site_group == outcome) |>
                       transmute(researchid, time_any = time, status_any = status), by = "researchid")
      }
      if (outcome %in% female_sites) base <- filter(base, sex == "female")
      if (outcome %in% male_sites) base <- filter(base, sex == "male")
      base <- base |> mutate(ev = as.integer(status_any == 1L), tstart = 0, tstop = time_any,
                             id = researchid, other_smn = factor("no", levels = c("no", "yes"))) |>
        filter(tstop > 0)
      dl <- survSplit(Surv(tstart, tstop, ev) ~ ., data = as.data.frame(base), cut = window_cuts_fu,
                      episode = "window_i")
      dl$window <- factor(dl$window_i, 1:3, c("5-14", "15-24", ">=25")); dl$pt <- dl$tstop - dl$tstart
      # Same estimation as the complete-case fit (Firth for small sites, Q6e).
      tryCatch(fit_c1(dl, setdiff(final_terms, "other_smn"), firth = firth),
               error = function(e) { cat("  imputed fit failed:", conditionMessage(e), "\n"); NULL })
    })
    pool_rubin(fits)
  }
  rt_pooled <- function(p, label) {
    if (is.null(p)) return(tibble(approach = label, term = NA_character_, est = "not available"))
    p |> filter(startsWith(term, rt), !grepl(":", term)) |>
      transmute(approach = label, term,
                est = sprintf("%.2f (%.2f–%.2f)", exp(b), exp(b - 1.96 * se), exp(b + 1.96 * se)))
  }
  # Overall RT association: LR test of all RT terms (incl. interactions)
  # in the final C1 model (used for T1 and the q-values, T3).
  terms_no_rt <- final_terms[!grepl(rt, final_terms, fixed = TRUE)]
  p_rt <- tryCatch(lr_test(fit_c1(d, terms_no_rt, firth), c1), error = function(e) NA_real_)
  # T2a reminder: monotonic increase across the organ-exposure categories?
  b_rt <- rt_coefs(c1, rt)
  monotonic <- grepl("_f$", rt) && length(b_rt) == 2 && all(is.finite(b_rt)) &&
    b_rt[1] > 0 && b_rt[2] > b_rt[1]
  if (monotonic) {
    cat("REMINDER (T2a):", outcome, "- the RT rate ratios increase monotonically across",
        "not irradiated < bordering < in field. Consider implementing the 1-df trend test",
        "(T2a); discuss with the project leader.\n")
  }
  m1_rt <- est_table(c1, "RR") |> filter(startsWith(term, rt), !grepl(":", term)) |>
    transmute(approach = "M1 complete case (time-varying exposure)", term, est)
  mi_rt <- bind_rows(m1_rt,
                     rt_pooled(fit_imputed(imp_m2), "M2 MICE (baseline exposure)"),
                     rt_pooled(fit_imputed(imp_m3), "M3 SMC-FCS (baseline exposure)"))

  # Reference categories of the factors in the final model (R-REF): one
  # row "reference" per factor in the model tables.
  final_vars <- unique(gsub("^ns\\(|, df = 3\\)$", "", unlist(strsplit(final_terms, ":", fixed = TRUE))))
  factor_refs <- unlist(lapply(final_vars, function(v) {
    if (v %in% names(d) && is.factor(d[[v]])) setNames(levels(droplevels(d[[v]]))[1], v) else NULL
  }))
  list(outcome = outcome, n_smn = n_smn, rt = rt, firth = firth, n_rows = nrow(d),
       factor_refs = factor_refs,
       p_rt = p_rt, confirmatory = outcome %in% confirmatory_outcomes, monotonic = monotonic,
       n_patients = n_distinct(d$id), events = sum(d$ev),
       spline_tests = spline_tests, em = em, modifiers_kept = modifiers_kept,
       conf = conf, final_terms = final_terms,
       c1 = est_table(c1, "Rate ratio (C1)"),
       c2 = if (is.null(c2)) NULL else est_table(c2, "Hazard ratio (C2)"),
       c3 = c3, mi = mi_rt)
}

results <- pmap(model_outcomes, function(site_group, n_smn) {
  cat("\n== Modelling:", site_group, "(", n_smn, "SMNs ) ==\n")
  tryCatch(run_outcome(site_group, n_smn),
           error = function(e) {
             cat("ACTION: model for", site_group, "failed:", conditionMessage(e), "\n")
             NULL
           })
})
results <- compact(results)

# ---- 4b. multiple testing: q-values (T3, Benjamini & Hochberg 1995) ----------------
# Family (i): the overall RT association of every outcome modelled.
# Family (ii): the interaction tests of the MAIN effect modifiers (T2b).
# T1: the confirmatory outcomes are judged at alpha = 0.05 without
# adjustment; their q-values are shown for completeness.
if (length(results)) {
  p_rt_all <- map_dbl(results, "p_rt")
  q_rt_all <- p.adjust(p_rt_all, method = "BH")
  for (i in seq_along(results)) results[[i]]$q_rt <- q_rt_all[i]
  em_main <- map_dfr(results, function(r) {
    r$em |> filter(set == "main (T2b)") |> distinct(modifier, interaction_p) |>
      mutate(outcome = r$outcome)
  })
  em_main$interaction_q <- p.adjust(em_main$interaction_p, method = "BH")
  for (i in seq_along(results)) {
    results[[i]]$em <- results[[i]]$em |>
      left_join(em_main |> filter(outcome == results[[i]]$outcome) |>
                  select(modifier, interaction_q), by = "modifier")
  }
}

# ---- 4c. additional effect modification: breast cancer in AYA women (EM-B) --------

# EM-B (2026-10-14, project leader): an ADDITIONAL effect-modification
# analysis for subsequent (invasive) breast cancer, restricted to women
# diagnosed with HL before age 40 (AYA, 15-39). Effect modifiers:
#   - anthracycline receipt (any anthracycline: doxorubicin, epirubicin or
#     other anthracycline / anthraquinone; yes / no);
#   - ovarian failure: NOT recorded in the export; the proxy is "ovarian
#     damage" = pelvic RT or cumulative procarbazine > 4.2 g/m2 (decision
#     R3; Swerdlow 2012, Krul 2017, Schaapveld 2015);
#   - smoking (ever).
# For each modifier separately (patients with a known value): the breast
# RT rate ratio (in field vs not, C1) within each category, and a likelihood-
# ratio test of the interaction. Adjusted for age and year of diagnosis and
# an earlier other SMN, as in the main models. Firth estimation if fewer
# than 20 SMNs. q-values within this family of 3 tests. Does NOT change the
# main model.
em_breast_aya <- NULL
if ("Breast" %in% site_long$site_group) {
  em_mods <- c(anthra_any_f = "Anthracycline receipt", ovarian_damage = "Ovarian failure (proxy: ovarian damage)",
               smoke_ever = "Ever smoked")
  rt_b <- "organ_breast_bin"
  db <- build_long("Breast", intersect(c(rt_b, "anthra_any_f", "ovarian_damage"), names(tv)))
  db <- db[db$age_dx_aya %in% "AYA 15-39", ]
  em_breast_aya <- imap_dfr(em_mods, function(lab, mv) {
    dm <- db[complete.cases(db[, c(rt_b, "age_dx", "year_dx", mv)]), ]
    firth_b <- sum(dm$ev) < small_site
    terms_b <- c(rt_b, "age_dx", "year_dx", "other_smn")
    if (sum(dm$ev) < min_events_cc) {
      return(tibble(modifier = lab, level = NA_character_, smns = sum(dm$ev),
                    rt_estimate = "too few events", interaction_p = NA_real_, note = NA_character_))
    }
    m_main <- fit_c1(dm, c(terms_b, mv), firth_b)
    m_int <- tryCatch(fit_c1(dm, c(terms_b, mv, paste0(rt_b, ":", mv)), firth_b), error = function(e) NULL)
    tab <- tapply(dm$ev, list(dm[[rt_b]], dm[[mv]]), sum); tab[is.na(tab)] <- 0
    sparse <- is.null(m_int) || degenerate(m_int) || min(tab) < sparse_min
    p <- if (sparse) NA_real_ else lr_test(m_main, m_int)
    map_dfr(levels(droplevels(factor(dm[[mv]]))), function(lv) {
      ds <- dm[dm[[mv]] == lv, ]
      est <- if (sum(ds$ev) < 3) "too few events" else {
        ms <- tryCatch(fit_c1(ds, terms_b, sum(ds$ev) < small_site), error = function(e) NULL)
        if (is.null(ms) || degenerate(ms)) "not estimable (sparse categories)" else {
          b <- rt_coefs(ms, rt_b)
          v <- if (inherits(ms, "coxphf")) ms$var else vcov(ms)
          se <- sqrt(diag(as.matrix(v)))[names(b)]
          sprintf("%.2f (%.2f\u2013%.2f)", exp(b), exp(b - 1.96 * se), exp(b + 1.96 * se))
        }
      }
      tibble(modifier = lab, level = paste0(lab, ": ", lv), smns = sum(ds$ev),
             rt_estimate = est, interaction_p = p,
             note = if (sparse) "interaction not testable: sparse cells" else
               if (firth_b) "Firth-penalised" else NA_character_)
    })
  })
  em_q <- em_breast_aya |> distinct(modifier, interaction_p) |>
    mutate(interaction_q = p.adjust(interaction_p, method = "BH"))
  em_breast_aya <- em_breast_aya |> left_join(em_q, by = c("modifier", "interaction_p"))
}

# ---- 5. tables with footnotes (Q5) ------------------------------------------------

# Readable labels for model terms (internal variable names -> table text).
pretty_term <- function(x) {
  organ_names <- c(breast = "breast", lung = "lung", thyroid = "thyroid", oesophagus = "oesophagus",
                   stomach = "stomach", pancreas = "pancreas", colorectum = "colorectum",
                   pelvic_organs = "pelvic organs", head_neck = "head and neck")
  out <- x
  for (o in names(organ_names)) {
    out <- sub(paste0("organ_", o, "_bin"), paste0("RT exposure of the ", organ_names[[o]], ": "), out)
    out <- sub(paste0("organ_", o, "_f"), paste0("RT exposure of the ", organ_names[[o]], ": "), out)
  }
  repl <- c("rt_volume" = "RT volume: ", "rt_any_f" = "Any RT: ",
            "doxo_any_f" = "Doxorubicin: ", "procarb_any_f" = "Procarbazine: ",
            "doxo_cat_f" = "Doxorubicin dose (mg/m²): ", "procarb_cat3" = "Procarbazine dose (g/m²): ",
            "smoke_ever" = "Ever smoked: ", "ovarian_damage" = "Ovarian damage: ",
            "other_smn" = "Earlier other SMN: ", "sexmale" = "Sex: male", "^sex$" = "Sex",
            "^age_dx$" = "Age at diagnosis (per year)", "^year_dx$" = "Year of diagnosis (per year)",
            "^window$" = "Time since diagnosis (window)",
            "ns\\(age_dx, df = 3\\)" = "Age at diagnosis, spline basis ",
            "ns\\(year_dx, df = 3\\)" = "Year of diagnosis, spline basis ",
            "age_dx_aya" = "Age at diagnosis: ", "era2" = "Era of diagnosis: ",
            "^sexfemale$" = "Sex: female")
  for (k in names(repl)) out <- sub(k, repl[[k]], out)
  out <- gsub(":", " × ", sub(": $", "", out), fixed = TRUE)
  gsub(" ×  ", ": ", out, fixed = TRUE)
}

method_note <- paste(
  "Workflow (decisions Q6a-e): (0) base model with RT, age at diagnosis (per year) and year of diagnosis (per calendar year, centred at 2000)",
  "(linear; natural spline with 3 df only if a likelihood-ratio test was significant);",
  "(1) EFFECT MODIFICATION first: RT estimate (95% CI) within categories of each modifier, shown",
  "whatever the p-value, and a likelihood-ratio test of the interaction; only the MAIN modifiers",
  "(age at diagnosis AYA 15-39 vs 40-50, doxorubicin, era; T2b) can enter the model, if p <", em_p,
  "(MD2); additional modifiers (procarbazine, site-specific, time since diagnosis) are reported",
  "for future use (Knol & VanderWeele 2012);",
  "(2) CONFOUNDING next: candidates kept if they changed an RT estimate by >= 10% (Mickey &",
  "Greenland 1989) or lowered the AIC, unless they created sparse cells (fewer than", sparse_min,
  "SMNs in any RT x covariate cell; such candidates and interactions are not added). C1: Poisson regression on person-time split by time since",
  "diagnosis (rate ratios); C2: cause-specific Cox model (hazard ratios); C3: pseudo-observation",
  "regression of the cumulative incidence (risk differences, percentage points). Sites with fewer",
  "than", small_site, "SMNs: binary RT and Firth-penalised estimation (Firth 1993; Heinze &",
  "Schemper 2001). Treatment during follow-up enters C1/C2 as time-varying exposure from 2 years",
  "after its start (W3); C3 and the imputed analyses use baseline exposure. Site-specific models",
  "adjust for another SMN earlier in follow-up (time-varying; P5).")
method_refs <- paste(
  "References: Knol MJ, VanderWeele TJ. Int J Epidemiol 2012. doi:10.1093/ije/dyr218;",
  "Mickey RM, Greenland S. Am J Epidemiol 1989. doi:10.1093/oxfordjournals.aje.a115101;",
  "Firth D. Biometrika 1993. doi:10.1093/biomet/80.1.27; Heinze G, Schemper M. Biometrics 2001.",
  "doi:10.1111/j.0006-341X.2001.00114.x; Andersen PK, Perme MP. Stat Methods Med Res 2010.",
  "doi:10.1177/0962280209105020;", fn_refs[["Schaapveld2015"]])
term_notes <- unique(na.omit(unlist(map(results, ~ c(.x$rt, .x$final_terms)))))
var_note <- paste(
  "Variable definitions: RT exposure of the organ = in field vs not in field (not in field",
  "combines bordering a field and not irradiated; decision X1; field-to-organ mapping, draft R2);",
  "era of diagnosis 1989-1999 vs 2000-latest (E2); RT volume none / limited (regional field or",
  "involved node) / extended (mantle, inverted Y, full abdomen); doxorubicin and procarbazine as",
  "in Table 1 (Neppelenbroek 2024 categories); ovarian damage = pelvic RT or procarbazine >4.2 g/m2.")

for (r in results) {
  slug <- gsub("[^A-Za-z0-9]+", "-", tolower(r$outcome))
  header <- paste0(r$outcome, ": ", r$events, " SMNs in ", r$n_patients,
                   " patients (complete cases); primary RT variable: ", r$rt,
                   if (r$firth) "; Firth-penalised" else "",
                   ". Overall RT association: p = ", signif(r$p_rt, 2),
                   ", q = ", signif(r$q_rt, 2),
                   if (r$confirmatory) " (CONFIRMATORY, alpha 0.05; T1)" else " (exploratory)")
  em_tab <- if (is.null(r$em) || !nrow(r$em)) NULL else
    r$em |> mutate(interaction_p = signif(interaction_p, 2), interaction_q = signif(interaction_q, 2),
                   # Category labels name the modifier (e.g. "Doxorubicin: yes").
                   level = paste0(pretty_term(modifier), ": ", level),
                   modifier = paste0(pretty_term(modifier), " [", set, "]")) |>
      select(modifier, level, rt_estimate, interaction_p, interaction_q, note) |>
      gt(groupname_col = "modifier") |>
      cols_label(level = "Category of modifier", interaction_p = "Interaction p (LR test)",
                 interaction_q = "q (FDR, main modifiers)",
                 rt_estimate = "RT rate ratio (95% CI) within category (C1)", note = "Note") |>
      tab_header(title = paste("Step 1. Effect modification:", r$outcome))
  conf_tab <- if (is.null(r$conf) || !nrow(r$conf)) NULL else
    r$conf |> mutate(candidate = pretty_term(candidate)) |> gt() |>
      cols_label(candidate = "Candidate confounder", pct_change = "Change in RT estimate (%)",
                 delta_aic = "ΔAIC", kept = "Kept", note = "Note") |>
      tab_header(title = paste("Step 2. Confounding:", r$outcome))
  final <- bind_rows(r$c1, r$c2) |>
    pivot_wider(names_from = scale, values_from = est)
  c3w <- r$c3 |> mutate(horizon = paste0("Risk difference at ", horizon, " y (C3)")) |>
    pivot_wider(names_from = horizon, values_from = est)
  final <- final |> full_join(c3w, by = "term")
  # R-REF: a "reference" row for each factor, placed before its other levels.
  ref_rows <- tibble(term = paste0(names(r$factor_refs), r$factor_refs))
  for (cc in setdiff(names(final), "term")) {
    ref_rows[[cc]] <- if (grepl("Risk difference", cc)) "0 (reference)" else "1.00 (reference)"
  }
  final <- bind_rows(final, ref_rows) |>
    mutate(.var = vapply(term, function(t) {
      hit <- names(r$factor_refs)[startsWith(t, names(r$factor_refs)) & !grepl(":", t, fixed = TRUE)]
      if (length(hit)) hit[1] else t
    }, character(1)),
    .ord = match(.var, unique(c(names(r$factor_refs), .var))),
    .is_ref = grepl("reference", .data[[names(final)[2]]])) |>
    arrange(.ord, desc(.is_ref)) |>
    select(-.var, -.ord, -.is_ref) |>
    mutate(term = pretty_term(term))
  final_tab <- final |> gt() |>
    tab_header(title = paste("Final model:", r$outcome), subtitle = header) |>
    tab_source_note(paste("Effect estimates (95% CI) of EVERY covariate in the final model (Q6d);",
                          "for each categorical covariate the reference category is shown (1.00, or 0",
                          "for risk differences). A spline of age or year (only if it improved the",
                          "fit) is shown per basis column.")) |>
    tab_source_note(method_note) |> tab_source_note(var_note) |>
    tab_source_note(fn_cohort) |> tab_source_note(method_refs)
  mi_tab <- r$mi |> mutate(term = pretty_term(term)) |> gt() |>
    cols_label(approach = "Missing-data approach", term = "RT term", est = "Rate ratio (95% CI), C1") |>
    tab_header(title = paste("Missing-data comparison (M1 / M2 / M3):", r$outcome))
  html <- paste(c(
    if (!is.null(em_tab)) as_raw_html(em_tab),
    if (!is.null(conf_tab)) as_raw_html(conf_tab),
    as_raw_html(final_tab), as_raw_html(mi_tab)), collapse = "<br>")
  writeLines(html, file.path(res_dir, paste0("09_", slug, ".html")))
}

summary_rt <- map_dfr(results, function(r) {
  bind_rows(
    r$c1 |> filter(startsWith(term, r$rt), !grepl(":", term)) |> mutate(method = "C1 rate ratio"),
    if (!is.null(r$c2)) r$c2 |> filter(startsWith(term, r$rt), !grepl(":", term)) |> mutate(method = "C2 hazard ratio"),
    r$c3 |> filter(startsWith(term, r$rt)) |> mutate(method = paste0("C3 risk difference ", horizon, " y")) |> select(-horizon),
    r$mi |> filter(!startsWith(approach, "M1")) |> transmute(term, est, method = approach)
  ) |> mutate(outcome = r$outcome, .before = 1, term = pretty_term(term)) |> select(outcome, method, term, est)
})
pq_table <- map_dfr(results, function(r) tibble(
  outcome = r$outcome, analysis = if (r$confirmatory) "Confirmatory (T1)" else "Exploratory",
  rt_variable = pretty_term(r$rt), smns = r$events,
  p = signif(r$p_rt, 2), q = signif(r$q_rt, 2)))
if (nrow(pq_table)) {
  pq_table |> arrange(desc(analysis == "Confirmatory (T1)"), p) |>
    gt() |>
    cols_label(outcome = "Outcome", analysis = "", rt_variable = "RT variable", smns = "SMNs",
               p = "p (LR test of RT)", q = "q (FDR)") |>
    tab_header(title = "Overall RT association per outcome: p-values and FDR q-values") |>
    tab_source_note(paste(
      "T1: RT associations for any invasive SMN, breast cancer (women) and lung cancer are",
      "confirmatory and judged at alpha = 0.05 without adjustment; all other outcomes are",
      "exploratory. q-values (Benjamini & Hochberg 1995) control the false discovery rate",
      "across all outcomes modelled (family i) and, in the effect-modification tables, across",
      "the interaction tests of the main modifiers (family ii). Effect sizes with 95% CI are",
      "the primary results (T6).")) |>
    tab_source_note("References: Benjamini Y, Hochberg Y. J R Stat Soc B 1995. doi:10.1111/j.2517-6161.1995.tb02031.x") |>
    gtsave(file.path(res_dir, "09_rt_pvalues_qvalues.html"))
}
if (nrow(summary_rt)) {
  summary_rt |>
    gt(groupname_col = "outcome") |>
    cols_label(method = "Method / missing-data approach", term = "RT term", est = "Estimate (95% CI)") |>
    tab_header(title = "Summary: RT estimates across methods (C1-C3) and missing-data approaches (M1-M3)") |>
    tab_source_note(method_note) |> tab_source_note(var_note) |> tab_source_note(fn_cohort) |>
    tab_source_note(method_refs) |>
    gtsave(file.path(res_dir, "09_summary_rt.html"))
}
if (!is.null(em_breast_aya) && nrow(em_breast_aya)) {
  em_breast_aya |>
    mutate(interaction_p = signif(interaction_p, 2), interaction_q = signif(interaction_q, 2)) |>
    select(modifier, level, smns, rt_estimate, interaction_p, interaction_q, note) |>
    gt(groupname_col = "modifier") |>
    cols_label(level = "Category", smns = "Breast cancers",
               rt_estimate = "Breast in field vs not: rate ratio (95% CI), C1",
               interaction_p = "Interaction p (LR test)", interaction_q = "q (FDR, 3 tests)",
               note = "Note") |>
    tab_header(title = "Additional effect-modification analysis: subsequent invasive breast cancer in women diagnosed with HL before age 40 (AYA)",
               subtitle = "Breast RT exposure (in field vs not in field) within categories of each effect modifier") |>
    tab_source_note(paste(
      "Women aged 15-39 at HL diagnosis. Each modifier analysed separately, in women with a",
      "known value. Models (C1, Poisson on person-time by time since diagnosis) adjusted for",
      "age at diagnosis, year of diagnosis and an earlier other SMN (time-varying). Breast in",
      "field: mantle, axilla, mediastinum, infraclavicular or lung field; not in field combines",
      "bordering fields and no breast irradiation (decisions R2 draft, X1). Anthracycline",
      "receipt: doxorubicin, epirubicin or other anthracycline / anthraquinone before the",
      "start of follow-up. Ovarian failure is not recorded in the export; the proxy is ovarian",
      "damage = pelvic RT (inverted Y or iliac field) or cumulative procarbazine > 4.2 g/m2",
      "(decision R3; Swerdlow 2012; Krul 2017; Schaapveld 2015). Smoking: ever smoked. Invasive",
      "breast cancer only (behaviour 3 or 9). Firth-penalised estimation when fewer than",
      small_site, "breast cancers. q-values (Benjamini & Hochberg 1995) within these 3",
      "interaction tests. ADDITIONAL analysis (EM-B); it does not change the main model.")) |>
    tab_source_note(fn_cohort) |>
    tab_source_note(paste("References:", fn_refs[["Swerdlow2012"]], ";", fn_refs[["Krul2017"]], ";",
                          fn_refs[["Schaapveld2015"]], "; Benjamini Y, Hochberg Y. J R Stat Soc B 1995.",
                          "doi:10.1111/j.2517-6161.1995.tb02031.x")) |>
    gtsave(file.path(res_dir, "09_breast_aya_effect_modification.html"))
  cat("\n== EM-B: breast cancer in AYA women ==\n")
  print(as.data.frame(em_breast_aya |> select(level, smns, rt_estimate, interaction_p, interaction_q)))
}
saveRDS(results, file.path(res_dir, "09_models.Rds"))

cat("\n== Outcomes modelled ==\n")
print(model_outcomes, n = Inf)
for (r in results) {
  cat("\n--", r$outcome, ": RT =", r$rt, "| Firth:", r$firth, "| modifiers kept:",
      paste(r$modifiers_kept, collapse = ", "), "| confounders kept:",
      paste(r$conf$candidate[r$conf$kept], collapse = ", "), "\n")
}
cat("\nTables written to", res_dir, "\n")
