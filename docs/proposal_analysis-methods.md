# Proposal: analysis methods (SAP parts B–E, imputation)

HL-SMN-risk project, branch `sap-analysis`. Drafted 2026-10-14 for review by G. Watt (project leader).
Status: **DECIDED 2026-10-14** (decision log below). Implementation in progress.

## Decision log

| Date | Question | Decision (G. Watt) |
|---|---|---|
| 2026-10-14 | Q0 data-quality hold | **DQ1 and DQ2 held out** for now. |
| 2026-10-14 | Q1 missing data | **M1 complete-case, M2 MICE and M3 SMC-FCS run in parallel**, compared for both the descriptive and the analytic results. |
| 2026-10-14 | Q2 cumulative incidence | **B1** (Aalen–Johansen + Gray's test), **B3** (attained age) and **B4** (restricted mean time lost). **B5** (SIR/AER against registry rates): **to do later**. |
| 2026-10-14 | Q3 models | **C1** (Poisson / piecewise), **C2** (cause-specific Cox with time-varying coefficients) and **C3** (pseudo-observations at 15 and 25 years) **in parallel** for comparison. Time windows 5–14 / 15–24 / ≥ 25 years since diagnosis agreed. |
| 2026-10-14 | Q4 ML for breast cancer | Horizon 25 years since diagnosis and a 25% held-out test set agreed. The test set is a **random, proportional split balanced within diagnosis eras** (stratified by era and outcome). Variables: as proposed, plus **height and weight separately if available** (they are not: the export has only BMI and overweight yes/no at diagnosis and at end of follow-up, so BMI at diagnosis is used), plus **another SMN diagnosed before the breast cancer** (time-varying). Methods: **primary = penalised (lasso / elastic net) model; secondary = random survival forests with variable importance.** |
| 2026-10-14 | Q6 covariates in all models | **Every model adjusts for age at diagnosis and year of diagnosis.** Any other covariate needs a justification: it either **improves model prediction** or **confounds the primary association of interest (RT and SMN risk)**. |
| 2026-10-14 | Q6a covariate criteria | Approved: candidates prespecified from the literature; kept if they change the RT estimate by >= 10% (confounding; Mickey & Greenland 1989) or lower the AIC (prediction). The ~10 events-per-parameter rule may be **relaxed somewhat for important covariates**. |
| 2026-10-14 | Q6b effect modification vs adjustment | **Kept strictly separate, effect modification FIRST:** does the RT association differ within categories of the modifier (stratum-specific estimates), and is there an interaction (likelihood-ratio test)? Only then confounding. Presented following Knol & VanderWeele 2012. |
| 2026-10-14 | Q6c year (and age) of diagnosis | Fitted **linear**; a smooth curve (natural spline, 3 df) is used only if it improves the fit significantly (likelihood-ratio test). |
| 2026-10-14 | Q6d chemotherapy | In the main RT analysis, chemotherapy is examined first as a **potential effect modifier**, then as a **confounder**. When it is in a model as a confounder, **its effect estimate is reported** — this holds for **every** covariate in a final model. |
| 2026-10-14 | Q6e small sites (10–19 SMNs) | RT as **binary** (organ in field vs not, or any RT) and **Firth-penalised** estimation (Firth 1993; Heinze & Schemper 2001). |
| 2026-10-14 | MD1–MD5 model details (`09_models.R`) | MD1 RT variable per site: **approved**. MD2: **all stratum-specific RT estimates (95% CI) are reported regardless of the interaction p-value; the interaction is kept in the main model only if p < 0.05.** MD3 chemotherapy coding: **approved**. MD4: **no parameter limit; a covariate or interaction is excluded if it creates sparse cells** (fewer than 3 SMNs in any RT × covariate cell, or a non-estimable estimate). MD5 (no model if < 5 SMNs in the complete cases): **approved**. |
| 2026-10-14 | T1–T6 multiple testing (section 6) | **T1 approved:** confirmatory = RT association for any invasive SMN, breast cancer (women) and lung cancer at α = 0.05; everything else exploratory. **T2a:** implement the 1-df trend test only if the risk increases monotonically across organ-exposure categories (the script prints a reminder when it does). **T2b approved:** effect modification limited to **age at diagnosis (AYA 15–39 vs 40–50), doxorubicin and era**; the earlier modifiers (procarbazine, ovarian damage, smoking, time since diagnosis) are kept as additional analyses for future use and do not enter the model. **T3 approved:** FDR q-values for the overall RT associations, the main interaction tests and all Gray's tests. |
| 2026-10-14 | Q7 extra plots | **Cumulative incidence of breast cancer by RT field exposure** added: by breast organ exposure (0/1/2) and by RT technique (`08_cumulative-incidence.R`, K4). |
| 2026-10-14 | Q5 figures and tables | Agreed. **All descriptive and analytic tables carry footnotes with every variable definition and decision, with citations where needed.** |


References were checked against OpenAlex (title, year and DOI match).

---

## 0. Analysis dataset and data-quality hold (`05_analysis-data.R`)

You decided that observations with key outstanding questions can be excluded for now. **Proposed definition of "key":** a question that leaves a patient's **outcome or follow-up time** uncertain.

| Hold | Data query | Real data (11:11 run) |
|---|---|---|
| DQ1 | Data dated after the death date | 26 patients (cohort share to be printed) |
| DQ2 | SMN during follow-up without a behaviour code | 10 SMNs |

Not held out: questions about **exposure** details. These are already handled by agreed rules (caps, W1, PRIM, D14, REG); the remaining missing exposure is analysed as missing data (section 1). The 25 duplicated IDs are already excluded (C13).

**Q0.** Do you agree with DQ1 and DQ2 as the hold?

---

## 1. Missing data: imputation options (SAP: list before code)

Missing values for the main baseline exposures in the real data (check 7.2, before the latest fixes) are small: doxorubicin dose 3.0%, procarbazine dose 2.5%, RT technique 1.1%, ovarian damage 3.0%, organ exposure ≤ 4.3% per site. Smoking ever is unknown for more patients (Table 1 will show the number); it is only used in the lung-cancer models.

| Option | What it does | Assumption | For / against |
|---|---|---|---|
| **M1 Complete-case** | Drop patients with any missing model variable | Missingness does not depend on the outcome given the covariates | Simple and transparent; loses ≤ about 5% of patients here. Unbiased for regression if missingness depends only on covariates. |
| **M2 Multiple imputation by chained equations (MICE)** | Imputes each missing variable from the others, including the outcome (event indicator and Nelson–Aalen cumulative hazard), with m ≈ 20 data sets, pooled with Rubin's rules (White et al. 2011) | Missing at random (MAR) | Uses all patients; the standard choice. Needs the `mice` package (not yet installed). The imputation model must include the outcome and time. |
| **M3 Substantive-model-compatible imputation (SMC-FCS)** | Like M2, but imputes compatibly with the analysis model, e.g. Cox or competing risks (Bartlett et al. 2015) | MAR | Better than M2 when the model has interactions or non-linear terms (e.g. dose × time). Package `smcfcs`. |
| **M4 Missing-indicator category** ("unknown" as its own level) | Keeps everyone; unknown = separate category | – | Biased in general for regression; acceptable **only** for descriptive tables (already used there). |
| **M5 Bounds for lower-bound doses** | Patients whose total dose is a lower bound (W4) excluded, or put in the next category up | – | A sensitivity check for dose-response, not imputation. |

**Recommendation:** **M1 as the main analysis**, given the low missingness. **M2 as a sensitivity analysis** for the main dose-response models, and M3 if the final models contain interactions. Smoking: listwise deletion, as already decided (Q-RT3b).

**Q1.** Which option(s)?

---

## 2. Part B: cumulative incidence of SMNs

All patients enter follow-up at exactly 5 years after diagnosis, so the cumulative incidence is **conditional on 5-year survival**. It is shown on a "years since HL diagnosis" axis that starts at 5. Death without SMN is the competing event (SAP).

| Option | Estimand | Assumptions | For / against |
|---|---|---|---|
| **B1 Aalen–Johansen cumulative incidence** + **Gray's test** for group comparison (Gray 1988) | Probability of an SMN by time t, with death as a competing risk | Independent censoring; no proportional-hazards assumption | The standard non-parametric estimate. Directly answers "how many survivors develop an SMN". Already implemented in the old code (`tidycmprsk`). |
| B2 1 − Kaplan–Meier (death treated as censoring) | Hypothetical risk if nobody died | Death independent of SMN risk (unrealistic) | **Overestimates** risk; not recommended except as a contrast. |
| B3 Cumulative incidence by **attained age** (age as the time scale, delayed entry at age at 5-year survival) | Risk by age | Same as B1 | Useful for age-related cancers (breast); helps comparison across eras with different ages. A sensitivity / complementary view. |
| B4 Restricted mean time lost (RMTL) to SMN, up to e.g. 20 years (Andersen 2013) | Expected years of SMN-free life lost by time τ | None about hazards | One-number summary by group; easy to compare; less familiar to readers. |
| B5 Standardised incidence ratio (SIR) and absolute excess risk (AER) vs the general population | Excess over expected | Needs Netherlands Cancer Registry reference rates by age, sex and calendar year | The usual metric in the HL survivor literature (Schaapveld 2015). **Not in the SAP**, and needs external rates. |

**Recommendation:** **B1** for all plots (SAP E.1: overall, by era, by sex, by AYA vs 40–50), with Gray's test. **B3** for breast cancer as a complement. B5 only if you want it and NKR rates are available.

**Q2.** Which options?

---

## 3. Part C: multivariable models (non-proportional hazards)

The SAP expects proportional hazards **not** to hold over up to 28 years of follow-up and asks for non-parametric approaches. The study is **etiologic**, so the cause-specific hazard is the natural target for treatment effects (Lau et al. 2009; Austin et al. 2016). Subdistribution (Fine–Gray) models are for prediction of absolute risk.

| Option | Estimand | Handles non-proportional hazards by | For / against |
|---|---|---|---|
| **C1 Poisson regression on split person-time** (piecewise-constant cause-specific hazard) | Rate ratio by exposure, **within time windows** (e.g. 5–14, 15–24, ≥ 25 years since diagnosis) and by attained age | Exposure × time-window interactions | The **standard in radiation epidemiology**, which suits ISORED. Easily includes the time-varying exposure, attained age and era; gives rate ratios and excess rates. Equivalent to a piecewise Cox model. |
| C2 Cause-specific **Cox** with time-varying coefficients (step functions or splines in time) | Hazard ratio as a function of time | Exposure × f(time) | Semi-parametric; familiar. Same information as C1 but less natural for excess-rate reporting. |
| **C3 Pseudo-observation regression of the cumulative incidence** at fixed horizons (e.g. 15 and 25 years since diagnosis) (Andersen & Perme 2010) | **Risk difference / risk ratio** of having an SMN by year t | No hazard assumption at all | Directly answers "how much higher is the absolute risk after exposure X by year 25". Non-parametric in time. Needs `eventglm` or similar (not yet installed). |
| C4 RMTL regression (Andersen et al. 2004, via pseudo-observations) | Difference in years lost to SMN by τ | No hazard assumption | A good summary, but less familiar. |
| C5 Fine–Gray subdistribution model with time-varying effects (Fine & Gray 1999) | Subdistribution hazard ratio | Exposure × time | For prediction, not etiology; hard to interpret. **Not recommended** as the main analysis. |
| C6 Flexible parametric (Royston–Parmar) with time-dependent effects (Royston & Parmar 2002) | Smooth hazard and cumulative incidence | Spline × exposure | Parametric (splines); good for smooth curves; not "non-parametric". |

**Recommendation:**
- **Main: C1 (Poisson / piecewise).** Rate ratios for the RT organ exposure (0/1/2), doxorubicin and procarbazine dose, by time since diagnosis.
  - Adjusted for sex (where relevant), age at diagnosis, attained age and era.
  - Prespecified interactions: breast × ovarian damage, lung × smoking, GI × procarbazine.
  - Time-varying exposure from `exposure_tv`.
- **Complement: C3 (pseudo-observations).** Absolute risk differences at 15 and 25 years since diagnosis, for interpretability.
- **Covariates per site** are limited by the number of events (the ≥ 10 threshold, C12). I will propose a covariate set for each site before fitting.
- **Sensitivity analyses** (README list): C17-LC, binary organ exposure, era as a dose surrogate, codebook RT categories (R7), doxorubicin-equivalent, fine doxorubicin categories, S-CT98, and adjustment for another SMN as a time-varying covariate (P5).

**Q3.** Which option(s) for the main and complementary analysis? Do you agree with the time windows 5–14 / 15–24 / ≥ 25 years since diagnosis?

---

## 4. Part D: exploratory machine learning for breast cancer

| Aspect | Proposal |
|---|---|
| Population | Women in the analysis cohort |
| Outcome | Invasive breast cancer by **25 years since diagnosis** (or a shorter horizon), death as a competing risk |
| Data split | **Held-out test set** of 25%, stratified on the outcome (or temporal: diagnosed 2005+ as the test set). Tuning by **nested cross-validation** on the training set only |
| Candidate variables | Age at diagnosis, era, histology, smoking, BMI, all RT field groups and organ exposures, technique, doxorubicin / procarbazine dose, ovarian damage, relapse, treatment during follow-up |
| Methods | (a) Penalised (lasso / elastic net) cause-specific Cox model, interpretable; (b) random survival forests for competing risks (Ishwaran et al. 2014), with variable importance; (c) the same variables in an unpenalised model as a reference |
| Evaluation | Time-dependent AUC, Brier score and calibration of the cumulative incidence on the test set only |
| Caveat | About 109 breast cancers in all women (fewer after the split) is **small** for ML (Riley et al. 2020). Results are exploratory and hypothesis-generating; the lasso is likely to be as good as the forest. |
| Packages | `glmnet`, `randomForestSRC`, `riskRegression` (not yet installed; to add to renv) |

**Q4.** Agree with the design? Which horizon, and a random or temporal test set?

---

## 5. Part E: figures and tables

- **E.1 Cumulative incidence plots** (B1) for every SMN site with **≥ 10 cases** (C12):
  - overall;
  - by era (1989–94 / 1995–2004 / 2005+);
  - by sex (non-sex-specific sites);
  - by age group: AYA 15–39 vs 40–50 (C16).
- **E.2 Model tables** in `gtsummary` with JNCI conventions: rate ratios (95% CI), number of events, person-years, and footnotes on adjustment.
- The descriptive tables (Table 1 by era; Table 2, all SMN sites; Table 2b, behaviour) are already drafted in `06_descriptive.R`.

---

## 6. Multiple testing (PROPOSAL, 2026-10-14; options for the project leader)

The current design runs roughly **90 model tests**: about 16 outcomes × (2 spline tests + 3–4 interaction tests + the RT association). There are also about **50 Gray's tests** in the cumulative-incidence plots. At α = 0.05, about 7 "significant" results are expected by chance alone.

| Option | What it does | For | Against |
|---|---|---|---|
| **T1 Prespecified hierarchy** | Declare a small set of **confirmatory** hypotheses: the RT association for any SMN, breast cancer (women) and lung cancer. Everything else is **exploratory** and labelled as such. | Standard; keeps the main conclusions clean; no loss of power for the key questions | Needs a firm choice now, before seeing results |
| **T2 Fewer tests by design** | (a) Test organ exposure as a **1-df trend** (0 → 1 → 2) instead of 2-df category contrasts. (b) Test effect modification only for modifiers with a **biological rationale per site** (e.g. not doxorubicin for thyroid). (c) Use **one global test** of RT heterogeneity across time windows (already 1 LR test). | Fewer and more focused tests; more power | (b) narrows the "chemotherapy as a modifier for every site" decision (Q6d) |
| **T3 False discovery rate (FDR)** (Benjamini & Hochberg 1995) | Report, next to each p-value, a **q-value** controlling the expected share of false positives. Families: (i) all site-specific RT associations; (ii) all interaction tests; (iii) all Gray's tests. | Widely accepted for many site-specific results; keeps reasonable power | Needs a definition of the families; q-values are less familiar to clinicians |
| **T4 Family-wise correction** (Holm 1979) | Holm–Bonferroni within the same families: controls the chance of *any* false positive | Strict; simple | Very conservative with ~16 sites; real effects in small sites will be missed |
| **T5 Shrinkage of site-specific estimates** (semi-Bayes / empirical Bayes; Greenland & Robins 1991) | Pull the 15 site-specific RT estimates toward their common mean, more so for imprecise (small) sites | Addresses the problem at its root (unstable estimates from small sites), not just the p-values; well suited to many related site estimates | More complex to explain; needs a prior variance (choice) |
| **T6 Estimation instead of testing** (Rothman 1990) | Report effect sizes with 95% CIs; no significance thresholds, and no "significant" labels for exploratory results | Accepted epidemiological position; avoids dichotomising | Does not satisfy reviewers who expect a correction |

**Recommendation:** combine **T1 + T2(a) + T3 + T6**:
- three confirmatory RT associations (any SMN, breast, lung) at α = 0.05;
- organ exposure tested as a 1-df trend;
- all other results presented as exploratory estimates with 95% CIs, with **FDR q-values** within the families of site-specific RT associations and of interaction tests.

**T5** (shrinkage) as a sensitivity analysis for the site-specific RT estimates, if wanted.

## References

- Gray RJ. A class of K-sample tests for comparing the cumulative incidence of a competing risk. Ann Stat 1988. doi:10.1214/aos/1176350951
- Fine JP, Gray RJ. A proportional hazards model for the subdistribution of a competing risk. J Am Stat Assoc 1999. doi:10.1080/01621459.1999.10474144
- Lau B, Cole SR, Gange SJ. Competing risk regression models for epidemiologic data. Am J Epidemiol 2009. doi:10.1093/aje/kwp107
- Austin PC, Lee DS, Fine JP. Introduction to the analysis of survival data in the presence of competing risks. Circulation 2016. doi:10.1161/CIRCULATIONAHA.115.017719
- Andersen PK, Hansen MG, Klein JP. Regression analysis of restricted mean survival time based on pseudo-observations. Lifetime Data Anal 2004. doi:10.1007/s10985-004-4771-0
- Andersen PK, Perme MP. Pseudo-observations in survival analysis. Stat Methods Med Res 2010. doi:10.1177/0962280209105020
- Andersen PK. Decomposition of number of life years lost according to causes of death. Stat Med 2013. doi:10.1002/sim.5903
- White IR, Royston P, Wood AM. Multiple imputation using chained equations: issues and guidance for practice. Stat Med 2011. doi:10.1002/sim.4067
- Bartlett JW, Seaman SR, White IR, Carpenter JR. Multiple imputation of covariates by fully conditional specification: accommodating the substantive model. Stat Methods Med Res 2015. doi:10.1177/0962280214521348
- Benjamini Y, Hochberg Y. Controlling the false discovery rate: a practical and powerful approach to multiple testing. J R Stat Soc B 1995. doi:10.1111/j.2517-6161.1995.tb02031.x
- Holm S. A simple sequentially rejective multiple test procedure. Scand J Stat 1979. (JSTOR doi:10.2307/4615733)
- Rothman KJ. No adjustments are needed for multiple comparisons. Epidemiology 1990. doi:10.1097/00001648-199001000-00010
- Greenland S, Robins JM. Empirical-Bayes adjustments for multiple comparisons are sometimes useful. Epidemiology 1991. doi:10.1097/00001648-199107000-00002
- Knol MJ, VanderWeele TJ. Recommendations for presenting analyses of effect modification and interaction. Int J Epidemiol 2012. doi:10.1093/ije/dyr218
- Mickey RM, Greenland S. The impact of confounder selection criteria on effect estimation. Am J Epidemiol 1989. doi:10.1093/oxfordjournals.aje.a115101
- Firth D. Bias reduction of maximum likelihood estimates. Biometrika 1993. doi:10.1093/biomet/80.1.27
- Heinze G, Schemper M. A solution to the problem of monotone likelihood in Cox regression. Biometrics 2001. doi:10.1111/j.0006-341X.2001.00114.x
- Royston P, Parmar MKB. Flexible parametric proportional-hazards and proportional-odds models for censored survival data. Stat Med 2002. doi:10.1002/sim.1203
- Ishwaran H, Gerds TA, Kogalur UB, et al. Random survival forests for competing risks. Biostatistics 2014. doi:10.1093/biostatistics/kxu010
- Riley RD, Ensor J, Snell KIE, et al. Calculating the sample size required for developing a clinical prediction model. BMJ 2020. doi:10.1136/bmj.m441
