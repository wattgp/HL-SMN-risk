# 08_cumulative-incidence.R
# SAP part B (decision Q2, 2026-10-14):
#   B1 Aalen-Johansen cumulative incidence of invasive SMN, death without SMN
#      as the competing event; groups compared with Gray's test (Gray 1988).
#      Plots (SAP E.1) for any SMN and every site with >= min_cases_plot
#      patients with an SMN (C12): overall, by era, by sex (sites not
#      sex-specific), by age group (AYA 15-39 vs 40-50; C16).
#   B3 Cumulative incidence by ATTAINED AGE (age as the time scale, with
#      delayed entry at the age at the start of follow-up) for any SMN and
#      breast cancer.
#   B4 Restricted mean time lost (RMTL) to SMN up to 25 years after
#      diagnosis (Andersen 2013), by group, with bootstrap CIs.
#   B5 SIR / AER against population rates: TO DO LATER (needs NKR rates).
# Sensitivity C17-LC: the cumulative-incidence table is repeated with
# follow-up ending at last contact.
#
# Output: output/<dummy|real>/08_*.png (plots) and 08_*.html (tables).
#
# Run after 05:  source(here::here("scripts", "08_cumulative-incidence.R"))

# ---- decision log ------------------------------------------------------------
# Q2 (2026-10-14) B1, B3 and B4; B5 later.
# C12 (2026-10-14) Own plots for sites with >= 10 patients with an SMN.
# SAP (2026-10-13) Sex-specific cancers are restricted to the appropriate
#    sex: breast, cervix, corpus uteri, ovary, other female genital (women);
#    prostate, testis, other male genital (men).
# PROPOSED (not yet agreed):
# K1 Time axis: years since HL diagnosis, starting at 5 (everyone enters at
#    exactly 5 years, so the curves are conditional on 5-year survival).
#    Table time points: 10, 15, 20 and 25 years since diagnosis.
# K2 B3 attained age: shown from age 25 (younger ages have too few
#    patients at risk for a stable estimate); left truncation at the age at
#    the start of follow-up.
# K4 (2026-10-14, project leader) Add cumulative incidence plots for breast
#    cancer stratified by RT field exposure: by breast organ exposure
#    (0/1/2) and by RT technique.
# T3 (2026-10-14) FDR q-values for all Gray's tests (08_gray_tests.html).
# E2 (2026-10-14) Dichotomised era (1989-1999 / 2000-latest) in all plots.
# S1 (2026-10-14) Sex "other" not included in the plots.
# X1 (2026-10-14) Organ exposure: "bordering field" and "not irradiated"
#    collapsed into "not in field" in ALL analyses.
# K5 (2026-10-14) Breast by RT technique: no RT and unknown technique left
#    out; regional field and involved node collapsed into "limited".
# K6 (2026-10-14) Curves drawn only while >= 10 patients are at risk (no
#    jump at the last time point); plots only.
# K7 (2026-10-14) Risk tables show number at risk and cumulative SMNs.
# K8 (2026-10-14) Same axis limits on every cumulative-incidence plot.
# K3 B4 RMTL horizon: 25 years since diagnosis (20 years of follow-up),
#    matching the 25-year horizon of C3 and the ML analysis; 95% CI from
#    200 bootstrap samples (patients resampled).

source(here::here("scripts", "00_config.R"))
source(here::here("scripts", "footnotes.R"))

library(dplyr)
library(tidyr)
library(purrr)
library(survival)
library(tidycmprsk)
library(ggsurvfit)
library(ggplot2)
library(gt)

set.seed(20261014)
res_dir <- here("output", if (use_dummy) "dummy" else "real")
dir.create(res_dir, recursive = TRUE, showWarnings = FALSE)

pat <- readRDS(file.path(out_dir, "analysis_patients.Rds"))
site_long <- readRDS(file.path(out_dir, "analysis_site_long.Rds"))

entry_years <- 5                 # K1: everyone enters 5 years after diagnosis
table_years_dx <- c(10, 15, 20, 25)
rmtl_tau_dx <- 25                # K3
n_boot <- if (use_dummy) 50 else 200
female_sites <- c("Breast", "Cervix", "Corpus uteri", "Ovary", "Other female genital")
male_sites <- c("Prostate", "Testis", "Other male genital")

# ---- 1. analysis data per outcome ---------------------------------------------------

# S1: patients with sex "other" are not included in the plots.
pat <- pat |> filter(!is.na(sex_analysis))

grp_vars <- pat |>
  transmute(researchid, sex = droplevels(sex_analysis),
            era = droplevels(era2),            # E2: dichotomised era
            age_group = age_dx_aya, age_dx, date_birth, date_fup_start,
            # K4 / X1: breast RT exposure, bordering and not irradiated
            # COLLAPSED (2026-10-14): in field vs not in field.
            breast_rt = factor(if_else(organ_breast == 2, "2 In field", "1 Not in field"),
                               levels = c("1 Not in field", "2 In field")),
            # K5 (2026-10-14): RT technique for the breast plots without
            # "no RT" and without "technique unknown"; regional field and
            # involved node collapsed into "limited". Numbered labels keep a
            # logical order (the plots sort strata alphabetically).
            rt_technique = factor(case_when(
              rt_technique == "mantle / extended field" ~ "2 Mantle / extended",
              rt_technique %in% c("regional field (presumed involved field)", "involved node") ~
                "1 Limited",
              TRUE ~ NA_character_),
              levels = c("1 Limited", "2 Mantle / extended")))

status_factor <- function(s) factor(s, levels = 0:2, labels = c("censored", "SMN", "death"))

outcome_data <- function(site = NULL, lc = FALSE) {
  if (is.null(site)) {
    d <- pat |> transmute(researchid,
                          status = if (lc) status_any_lc else status_any,
                          time = if (lc) time_any_lc else time_any)
  } else {
    d <- site_long |> filter(site_group == site, researchid %in% pat$researchid) |>
      transmute(researchid, status = if (lc) status_lc else status,
                time = if (lc) time_lc else time)
  }
  d <- d |> left_join(grp_vars, by = "researchid") |>
    filter(!is.na(status), !is.na(time)) |>
    mutate(status = status_factor(status))
  if (!is.null(site) && site %in% female_sites) d <- filter(d, sex == "female")
  if (!is.null(site) && site %in% male_sites) d <- filter(d, sex == "male")
  d
}

# Sites with >= min_cases_plot patients with an SMN (C12).
site_counts <- site_long |> filter(status == 1L) |> count(site_group, name = "n_smn")
plot_sites <- site_counts$site_group[site_counts$n_smn >= min_cases_plot]
outcomes <- c("Any invasive SMN", plot_sites)

# ---- 2. B1: Aalen-Johansen + Gray's test -------------------------------------------

fit_ci <- function(d, by = NULL) {
  f <- if (is.null(by)) Surv(time, status) ~ 1 else
    as.formula(paste("Surv(time, status) ~", by))
  cuminc(f, data = d)
}

gray_p <- function(fit) {
  g <- tryCatch(glance(fit), error = function(e) NULL)
  if (is.null(g) || !"p.value_1" %in% names(g)) return(NA_real_)
  g$p.value_1
}

# K6 (2026-10-14): the curves stopped "shooting up" at the last time point,
# where a single event among very few patients still at risk makes a large
# jump. Each curve (each stratum) is drawn only while at least
# min_at_risk patients are at risk: patients are censored at the time the
# risk set falls below that number. FOR THE PLOTS ONLY; Gray's tests and the
# tables use all follow-up.
min_at_risk <- 10
truncate_strata <- function(d, by = NULL) {
  grp <- if (is.null(by)) rep("all", nrow(d)) else as.character(d[[by]])
  d |>
    mutate(.g = grp) |>
    group_by(.g) |>
    mutate(.t_end = if (n() >= min_at_risk) sort(time, decreasing = TRUE)[min_at_risk] else min(time),
           status = if_else(time > .t_end, factor("censored", levels(status)), status),
           time = pmin(time, .t_end)) |>
    ungroup() |>
    select(-.g, -.t_end)
}

plot_ci <- function(fit, title, by_label = NULL, p = NA, x_up, y_up) {
  sub <- if (!is.na(p)) sprintf("Gray's test p = %s (q-values for all Gray's tests: 08_gray_tests.html)",
                                format.pval(p, digits = 2, eps = 0.001)) else NULL
  # One palette for lines AND bands, keyed by stratum name (otherwise the
  # bands get their own palette when some strata have no band).
  td <- tidy(fit)
  lv <- if ("strata" %in% names(td)) sort(unique(td$strata)) else NULL
  pal_scales <- if (length(lv) > 1) {
    pal <- setNames(scales::hue_pal()(length(lv)), lv)
    list(scale_colour_manual(values = pal), scale_fill_manual(values = pal))
  } else list()
  ggcuminc(fit, outcome = "SMN") +
    add_confidence_interval() +
    pal_scales +
    # K7 (2026-10-14): risk table with the number at risk and the
    # cumulative number of SMNs at each time.
    add_risktable(risktable_stats = "{n.risk} ({cum.event})",
                  stats_label = "At risk (cumulative SMNs)") +
    # K8 (2026-10-14): the SAME axis limits on every plot.
    scale_x_continuous(name = "Years since HL diagnosis",
                       breaks = seq(0, x_up, 5), labels = function(x) x + entry_years,
                       limits = c(0, x_up), expand = expansion(mult = c(0.06, 0.07))) +
    scale_y_continuous(name = "Cumulative incidence", labels = scales::percent,
                       limits = c(0, y_up)) +
    labs(title = title, subtitle = sub, colour = by_label) +
    guides(fill = "none") + # one legend (colour); bands share the colours
    theme_minimal(base_size = 11) +
    theme(plot.caption = element_text(hjust = 0, size = 8))
}

strata <- list(overall = NULL, era = "era", sex = "sex", age = "age_group")
strata_label <- c(era = "Era of diagnosis", sex = "Sex", age = "Age at diagnosis")

# Pass 1: every plot is fitted first (on truncated data) so that common axis
# limits can be set (K8); Gray's test on the full data.
plot_specs <- list()
gray_results <- list()
add_spec <- function(d, by, outcome, title, by_label, file, caption = NULL, gray_by) {
  fit <- tryCatch(fit_ci(truncate_strata(d, by), by), error = function(e) NULL)
  if (is.null(fit)) {
    cat("ACTION: cumulative incidence failed for", outcome, "/", file, "\n")
    return(invisible())
  }
  p <- if (is.null(by)) NA else gray_p(tryCatch(fit_ci(d, by), error = function(e) NULL))
  gray_results[[length(gray_results) + 1]] <<- tibble(outcome = outcome, by = gray_by, gray_p = p)
  plot_specs[[length(plot_specs) + 1]] <<- list(fit = fit, title = title, by_label = by_label,
                                                p = p, file = file, caption = caption)
}

for (o in outcomes) {
  d <- outcome_data(if (o == "Any invasive SMN") NULL else o)
  for (s in names(strata)) {
    by <- strata[[s]]
    if (s == "sex" && o %in% c(female_sites, male_sites)) next
    if (!is.null(by) && n_distinct(d[[by]], na.rm = TRUE) < 2) next
    add_spec(d, by, o,
             title = paste0(o, if (!is.null(by)) paste(" by", tolower(strata_label[[s]]))),
             by_label = if (!is.null(by)) strata_label[[s]],
             file = paste0("08_ci_", gsub("[^A-Za-z0-9]+", "-", tolower(o)), "_", s, ".png"),
             gray_by = s)
  }
}
# K4: breast cancer (women) by RT field exposure (X1: in field vs not) and by
# RT technique (K5: limited vs mantle / extended, irradiated women only).
if ("Breast" %in% outcomes) {
  d <- outcome_data("Breast")
  caps <- c(
    breast_rt = paste(
      "Breast in field: mantle, axilla, mediastinum, infraclavicular or lung field (field-to-organ",
      "mapping, decision R2, draft pending approval); 'not in field' combines bordering fields",
      "(neck or supraclavicular only) and no breast irradiation (X1). Unknown exposure not shown."),
    rt_technique = paste(
      "Irradiated women only; women without RT or with an unknown technique are not shown (K5).",
      "Limited = regional field (presumed involved field) or involved node; mantle / extended =",
      "mantle, inverted Y or full abdomen; largest field given (decision R1a)."))
  for (by in c("breast_rt", "rt_technique")) {
    db <- d |> filter(!is.na(.data[[by]])) |> mutate(across(all_of(by), droplevels))
    if (n_distinct(db[[by]]) < 2) next
    lab <- c(breast_rt = "Breast RT exposure", rt_technique = "RT technique")[[by]]
    add_spec(db, by, "Breast", title = paste0("Breast cancer (women) by ", lab), by_label = lab,
             file = paste0("08_ci_breast_", by, ".png"),
             caption = paste(strwrap(caps[[by]], 110), collapse = "\n"), gray_by = by)
  }
}

# Pass 2: common axis limits (K8) and the plots.
all_tidy <- map_dfr(plot_specs, ~ tidy(.x$fit) |> filter(outcome == "SMN"))
x_up <- ceiling(max(all_tidy$time, na.rm = TRUE) / 5) * 5
y_up <- min(1, ceiling(max(all_tidy$conf.high, na.rm = TRUE) * 10) / 10)
cat("Common axes (K8): years since diagnosis 5 to", x_up + entry_years,
    "| cumulative incidence 0 to", y_up, "\n")
for (sp in plot_specs) {
  g <- plot_ci(sp$fit, sp$title, sp$by_label, sp$p, x_up = x_up, y_up = y_up)
  if (!is.null(sp$caption)) g <- g + labs(caption = sp$caption)
  ggsave(file.path(res_dir, sp$file), g, width = 9, height = 6.5, dpi = 200, bg = "white")
}
gray_results <- bind_rows(gray_results) |>
  # T3 (2026-10-14): FDR q-values (Benjamini & Hochberg 1995) across all
  # Gray's tests in this script (one family).
  mutate(gray_q = p.adjust(gray_p, method = "BH"))

# Table: cumulative incidence (95% CI) at 10/15/20/25 years since diagnosis,
# overall, main follow-up rule and C17-LC.
ci_at <- function(d, label, rule) {
  fit <- fit_ci(d)
  tidy(fit, times = table_years_dx - entry_years) |>
    filter(outcome == "SMN") |>
    transmute(outcome = label, rule = rule, years_since_dx = time + entry_years,
              ci = sprintf("%.1f (%.1f–%.1f)", 100 * estimate, 100 * conf.low, 100 * conf.high),
              n_risk = n.risk)
}
ci_table_data <- map_dfr(outcomes, function(o) {
  site <- if (o == "Any invasive SMN") NULL else o
  bind_rows(ci_at(outcome_data(site), o, "Main (last date of any data)"),
            ci_at(outcome_data(site, lc = TRUE), o, "Sensitivity C17-LC (last contact)"))
})
ci_table <- ci_table_data |>
  select(-n_risk) |>
  pivot_wider(names_from = years_since_dx, values_from = ci, names_prefix = "y") |>
  gt(groupname_col = "outcome") |>
  cols_label(rule = "Follow-up rule", y10 = "10 years", y15 = "15 years",
             y20 = "20 years", y25 = "25 years") |>
  tab_spanner("Cumulative incidence, % (95% CI), by years since HL diagnosis",
              columns = starts_with("y")) |>
  tab_header(title = "Table 3. Cumulative incidence of invasive SMN among 5-year survivors of HL") |>
  tab_source_note(paste(
    "Aalen-Johansen estimator with death without SMN as the competing event (B1); follow-up",
    "starts 5 years after diagnosis, so all estimates are conditional on 5-year survival.",
    "Site-specific: first invasive SMN of that site, whether or not another SMN came first",
    "(decision P5). Sex-specific sites restricted to that sex (SAP). Sites shown: >=",
    min_cases_plot, "patients with an SMN (C12).")) |>
  tab_source_note(fn_variables[["time_any"]]) |>
  tab_source_note(fn_variables[["outcome_any"]]) |>
  tab_source_note(fn_cohort) |>
  tab_source_note(paste0("References: ", fn_refs[["Schaapveld2015"]],
                         "; Gray RJ. Ann Stat 1988. doi:10.1214/aos/1176350951"))

# ---- 3. B3: attained age (left truncation) -----------------------------------------

age_data <- function(d) {
  d |> mutate(age_entry = lubridate::time_length(lubridate::interval(date_birth, date_fup_start), "years"),
              age_exit = age_entry + time) |>
    filter(age_exit > age_entry)
}
b3_outcomes <- intersect(c("Any invasive SMN", "Breast"), outcomes)
b3_plots <- map(b3_outcomes, function(o) {
  d <- age_data(outcome_data(if (o == "Any invasive SMN") NULL else o))
  fit <- survfit(Surv(age_entry, age_exit, status) ~ 1, data = d, id = researchid)
  st <- which(fit$states == "SMN")
  df <- tibble(age = fit$time, ci = fit$pstate[, st],
               lo = fit$lower[, st], hi = fit$upper[, st], n_risk = fit$n.risk[, 1]) |>
    filter(age >= 25, n_risk >= min_at_risk) # K2; K6: only while >= 10 at risk
  ggplot(df, aes(age, ci)) +
    geom_ribbon(aes(ymin = lo, ymax = hi), alpha = 0.2) +
    geom_step() +
    scale_y_continuous("Cumulative incidence", labels = scales::percent) +
    labs(x = "Attained age (years)",
         title = paste0(o, ": cumulative incidence by attained age"),
         subtitle = "Aalen-Johansen with delayed entry at the age at the start of follow-up (B3)") +
    theme_minimal(base_size = 11)
})
walk2(b3_plots, b3_outcomes, function(g, o) {
  ggsave(file.path(res_dir, paste0("08_ci-age_", gsub("[^A-Za-z0-9]+", "-", tolower(o)), ".png")),
         g, width = 8, height = 5, dpi = 200, bg = "white")
})

# ---- 4. B4: restricted mean time lost (RMTL) ----------------------------------------

# RMTL(tau) = area under the cumulative incidence of SMN from the start of
# follow-up to tau (years lost to SMN per patient, on average; Andersen 2013).
rmtl <- function(d, tau) {
  # No SMN in this (bootstrap) sample: no time lost to SMN.
  if (!any(d$status == "SMN")) return(0)
  fit <- survfit(Surv(time, status) ~ 1, data = d, id = researchid)
  st <- which(fit$states == "SMN")
  t <- c(0, fit$time[fit$time <= tau], tau)
  ci <- c(0, fit$pstate[fit$time <= tau, st])
  sum(diff(t) * ci)
}
rmtl_boot <- function(d, tau) {
  est <- rmtl(d, tau)
  bs <- replicate(n_boot, rmtl(d[sample(nrow(d), replace = TRUE), ] |>
                                 mutate(researchid = row_number()), tau))
  tibble(rmtl = est, lo = quantile(bs, 0.025), hi = quantile(bs, 0.975))
}
tau <- rmtl_tau_dx - entry_years
rmtl_data <- map_dfr(intersect(c("Any invasive SMN", "Breast", "Lung"), outcomes), function(o) {
  d <- outcome_data(if (o == "Any invasive SMN") NULL else o)
  groups <- list(Overall = list(by = NULL), era = list(by = "era"),
                 sex = list(by = "sex"), age = list(by = "age_group"))
  map_dfr(names(groups), function(gname) {
    by <- groups[[gname]]$by
    if (gname == "sex" && o %in% c(female_sites, male_sites)) return(NULL)
    if (is.null(by)) return(rmtl_boot(d, tau) |> mutate(outcome = o, group = "Overall", level = "All"))
    map_dfr(split(d, d[[by]], drop = TRUE), ~ rmtl_boot(.x, tau), .id = "level") |>
      mutate(outcome = o, group = strata_label[[gname]])
  })
}) |>
  mutate(rmtl = sprintf("%.2f (%.2f–%.2f)", rmtl, lo, hi)) |>
  select(outcome, group, level, rmtl)
rmtl_table <- rmtl_data |>
  gt(groupname_col = "outcome") |>
  cols_label(group = "", level = "", rmtl = paste0("Years lost to SMN by ", rmtl_tau_dx,
                                                   " years after diagnosis (95% CI)")) |>
  tab_header(title = "Table 4. Restricted mean time lost (RMTL) to invasive SMN") |>
  tab_source_note(paste(
    "RMTL = area under the cumulative incidence of SMN from the start of follow-up (5 years",
    "after diagnosis) to", rmtl_tau_dx, "years after diagnosis: the average number of",
    "SMN-free years lost per survivor in that period (B4; Andersen 2013). 95% CI from",
    n_boot, "bootstrap samples. Death without SMN is a competing event.")) |>
  tab_source_note(fn_cohort) |>
  tab_source_note("References: Andersen PK. Decomposition of number of life years lost according to causes of death. Stat Med 2013. doi:10.1002/sim.5903")

# ---- 5. save and report ------------------------------------------------------------

gtsave(ci_table, file.path(res_dir, "08_table3_cumulative-incidence.html"))
gray_results |>
  filter(!is.na(gray_p)) |>
  mutate(gray_p = signif(gray_p, 2), gray_q = signif(gray_q, 2)) |>
  gt(groupname_col = "outcome") |>
  cols_label(by = "Comparison", gray_p = "Gray's test p", gray_q = "q (FDR)") |>
  tab_header(title = "Gray's tests for all cumulative-incidence comparisons, with FDR q-values") |>
  tab_source_note(paste(
    "q-values control the false discovery rate across all Gray's tests in this table",
    "(Benjamini & Hochberg 1995; decision T3). Comparisons are exploratory except where the",
    "outcome is confirmatory (any invasive SMN, breast, lung; T1).")) |>
  tab_source_note("References: Gray RJ. Ann Stat 1988. doi:10.1214/aos/1176350951; Benjamini Y, Hochberg Y. J R Stat Soc B 1995. doi:10.1111/j.2517-6161.1995.tb02031.x") |>
  gtsave(file.path(res_dir, "08_gray_tests.html"))
gtsave(rmtl_table, file.path(res_dir, "08_table4_rmtl.html"))
saveRDS(list(ci = ci_table_data, gray = gray_results, rmtl = rmtl_data),
        file.path(res_dir, "08_cumulative-incidence.Rds"))

cat("\n== Outcomes plotted (>=", min_cases_plot, "patients with SMN) ==\n")
print(site_counts |> arrange(desc(n_smn)) |> mutate(plotted = site_group %in% plot_sites), n = Inf)
cat("\n== Gray's test p-values ==\n")
print(gray_results, n = Inf)
cat("\nNOTE: B5 (SIR / AER against NKR population rates) is planned for later.\n")
cat("Plots and tables written to", res_dir, "\n")
