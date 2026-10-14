# Proposal: treatment exposure definitions (radiotherapy organ exposure, anthracycline and procarbazine dose)

HL-SMN-risk project, branch `sap-analysis`. Drafted 2026-10-13 for review by G. Watt (project leader).
Status: **PROPOSAL, partly decided.** Decisions are recorded in the decision log below and will also be logged in the scripts' decision logs. Anything not in the decision log is not yet implemented.

All references were checked against PubMed, OpenAlex or Europe PMC; DOIs are given. Statements marked *(unverified)* could not be checked against the primary source.

---

## Decision log

| Date | Question | Decision (G. Watt) |
|---|---|---|
| 2026-10-14 | Q-RT1: primary RT exposure | **Approved.** Organ exposure has 3 levels: 0 = not irradiated, 1 = organ bordering a field, 2 = organ in field. **Addition:** also create variables for broad trends in HL radiotherapy technique: mediastinal vs involved field vs involved node. See section 1, "RT technique variables", for feasibility. |
| 2026-10-14 | X1 (supersedes the 3-level primary exposure of Q-RT1) | **In all analyses, organ exposure is in field vs not in field**; "bordering field" is combined with "not irradiated". The 3-level variable is kept in the data. |
| 2026-10-14 | Q-RT1a: RT technique variable | **Approved as proposed.** The first group is mantle / extended field (not "mediastinal"). The label "regional field (presumed involved field)" is accepted. `rt_mediastinal` is kept as a separate yes/no variable. |
| 2026-10-14 | Q-CT1: primary anthracycline exposure | **Option A.** Cumulative doxorubicin dose (mg/m²); epirubicin as a separate yes/no; mitoxantrone/daunorubicin as a separate "other anthracycline/anthraquinone" yes/no. Option B (doxorubicin-equivalent, Feijen 2019 / IGHG ratios; COG ratios as a further check) is the sensitivity analysis. |
| 2026-10-14 | Q-CT5 (cut-offs only) | **Neppelenbroek 2024 [C7] cut-offs.** Doxorubicin: 0 / 1–200 / >200 mg/m², plus continuous per 100 mg/m². Procarbazine: 0 / ≤4.2 / 4.3–8.4 / >8.4 g/m². The plausibility flags in Q-CT5 are still open. |
| 2026-10-14 | Q-CT2: procarbazine | **Cumulative procarbazine dose (mg/m²)**, with no conversion of other alkylating agents. CED was not requested and is not computed unless asked for later. |
| 2026-10-14 | Q-CT5 (plausibility flags) | **Approved.** Records are listed for review if doxorubicin > 450 mg/m² or procarbazine > 12 g/m² without relapse treatment, or if ABVD cycles > 8. |
| 2026-10-14 | Yes/no treatment variables | **Keep doxorubicin yes/no and procarbazine yes/no** alongside the doses. Two sources are kept and compared: (1) derived from the regimen codes (`doxo_any`, `procarb_any`; "unknown" when the regimen is unknown) and (2) the registry flags `anthrac` and `procarbazine` (0/1/9). Note that `anthrac` covers all anthracyclines, not only doxorubicin. |
| 2026-10-14 | Q-CT3: lookup corrections | **Existing lookup numbers are kept unchanged** for codes 58 (COPP), 69 (ChlVPP), 61 and 94 (MOPP/ABV(D) alternating, full per-cycle doses), 98 (ChlVPP/ABV, procarbazine dose 1000 is used despite flag "No") and 105 (Pro-MACE, doxorubicin 25; only the text-to-code match is fixed). **Code 83 (EBVP): epirubicin 70 mg/m² per cycle**, following Neppelenbroek 2024 [C7]. This is used in the doxorubicin-equivalent sensitivity analysis; under option A, epirubicin is yes/no. **Left missing:** 223/224 (CNOP, CNOP-R), 70, 86 (Stanford V), 109 (EBVD), 225 (R-CHVmP-VB), 71. Their per-cycle doses stay NA, so cumulative dose is NA for patients who received them, while yes/no exposure is still derived from the regimen. |
| 2026-10-14 | Code 98 (ChlVPP/ABV) procarbazine | Confirmed: it contains procarbazine; the primary dose stays **1000 mg/m² per cycle**. **Sensitivity analysis S-CT98 added** with 700 mg/m² per cycle (section 3), because the published hybrid schedules give 560–700 and 1000 could not be verified. |
| 2026-10-14 | Q-RT2: field-to-organ mapping | **Approved as a draft; proceed with the analysis.** **To be shared with Berthe for approval** before the mapping is final. Sarcoma and skin SMNs: **match each tumour to the irradiated fields using its topography code where possible** (e.g. trunk skin C44.5 vs mantle field); otherwise use any RT. |
| 2026-10-14 | Q-RT3: effect modifiers | **Approved**, with one change: breast-cancer **ovarian damage = pelvic RT (inverted Y or iliac) OR high procarbazine dose** (either one, not both). Lung × smoking and stomach/pancreas/colorectum × procarbazine as proposed. |
| 2026-10-14 | Q-RT4: prescribed RT dose | **Not included for now.** No Maraldo-based organ doses; era remains the dose surrogate in sensitivity analysis (b). |
| 2026-10-14 | "Any SMN" definition | **Non-melanoma skin cancer excluded** from "any SMN" (kept as its own site). **Unknown primary site (C80.9) included in "any SMN" only if invasive** (behaviour 3). |
| 2026-10-14 | Q-CT6: finer doxorubicin categories | **Added as a sensitivity analysis:** 0 / 1–200 / 201–349 / 350–700 mg/m² (Neppelenbroek 2024 [C7]). Primary cut-offs unchanged (0 / 1–200 / >200, plus per 100 mg/m²). Used where case numbers allow (breast cancer as a minimum). |
| 2026-10-14 | Q-RT3a: "high procarbazine" (ovarian damage) | **> 4.2 g/m²** (≥ 4.3 g/m², Schaapveld 2015). |
| 2026-10-14 | Q-RT3b: unknown smoking status | **Listwise deletion** in the lung × smoking models. |
| 2026-10-14 | Use of recorded RT doses (`rt*_dosistot`, `rt*_dose1–5`, boost fields) | **Descriptive only:** a table of prescribed dose by RT technique and diagnosis era, plus how complete dose recording is by era and hospital, in the RT exposure script (`03_rt-exposure.R`). Not used in models (consistent with Q-RT4). |
| 2026-10-14 | Follow-up chemotherapy flag missing, no regimen recorded | If **no relapse recorded** (`recur` = 0): code as **"no relapse"**. If a **relapse is recorded** (`recur` = 1): code as **"no relapse chemotherapy"**. Both give dose 0 and drug "no" for that course. If `recur` is missing, the course stays "unknown". Implemented in `02_chemo-doses.R` as `ct_course_status` (D13). |

---

## 1. Radiotherapy: exposure of the organ at risk

### What the data allow

- **Available for everyone treated with RT:** field flags per course (primary, follow-up, second follow-up), e.g. mantle, mediastinum (upper/lower), axilla, neck, supraclavicular, infraclavicular, lung, para-aortic, spleen, splenic hilum, inverted Y, iliac, inguinal, full abdomen. Also derived groups (supra-/infradiaphragmatic, mid-body, `rtcatprim`).
- **Almost never available:** prescribed dose (`rtprim_dosistot`, about 5% of patients) and dose per field (under 1%). Organ doses are not available.
- **Not available:** where the SMN lay relative to the field, and SMN laterality. Laterality-specific flags (left/right axilla, lung, iliac) can only be used as "either side".

### How published studies do it

| Approach | Used by | Usable here? |
|---|---|---|
| (i) Field-based flag: organ in field yes/no, or field group comparisons (e.g. mantle vs mediastinal only) | Dutch cohort: Schaapveld 2015 [1], De Bruin 2009 [2], van Eggermond 2017 [3]; CCSS "chest/neck/abdominal RT" [5,6] | **Yes** |
| (ii) Ordinal: in field / field edge / out of field | Diallo 2009 [8]: 12% of solid SMNs arose inside the target volume, 66% in the beam-bordering region, 22% more than 5 cm away | Partly. Tumour location is unknown, but the *organ* can be classed as in the field or bordering it |
| (iii) Typical organ dose by field combination, as % of prescribed dose | Maraldo 2015 [10] (supradiaphragmatic fields and spleen only); used in this cohort for mean lung dose by Roshani 2026 [11] | Only if prescribed dose can be obtained (see Q-RT4) |
| (iv) Prescribed dose categories | Travis 2005 [21], Bhatia 1996 [22], Swerdlow 2012 [23] | No (dose about 95% missing) |

**Limitations**
- No study has validated field flags against reconstructed organ dose for SMN risk.
- The misclassification is probably non-differential, so it biases towards the null.
- Field flags mix dose with irradiated volume.

### Proposal

**Primary exposure (all sites): 3-level organ exposure, built from the field flags.**
- *0 = not irradiated*: no field covering or bordering the organ.
- *1 = organ bordering the field (edge)*: only fields adjacent to the organ.
- *2 = organ in field*: at least one field that covers the organ.

Each SMN site's exposure is derived from the courses given **before the start of follow-up**. RT given after that point enters as a time-varying exposure (decision D5). Laterality is collapsed to "either side".

Proposed field-to-organ mapping. This is my synthesis of the evidence; no published mapping table exists for adult HL.

| SMN site | In field (2) | Bordering (1) | Evidence |
|---|---|---|---|
| Female breast | mantle, axilla, mediastinum (any), infraclavicular, lung | neck, supraclavicular | Strong: dose-response [24–27]; axilla matters in this cohort [1,2] |
| Lung | mantle, mediastinum (any), lung, axilla, infraclavicular | supraclavicular, neck | Strong [28,29,11] |
| Thyroid | neck, supraclavicular, mantle | upper mediastinum | Strong in children, but non-linear: peak about 20 Gy, falling above that [34,35]; low risk if treated over age 35 [36] |
| Oesophagus | mediastinum (any), mantle | neck, supraclavicular; para-aortic/spleen (gastro-oesophageal junction) | Moderate [33] |
| Stomach | para-aortic, spleen, splenic hilum, inverted Y, full abdomen | lower mediastinum, mantle (cardia) | Strong; strong procarbazine interaction [30,31] |
| Pancreas | para-aortic, spleen, splenic hilum, inverted Y, full abdomen | lower mediastinum | Moderate [32] |
| Colorectum | inverted Y, para-aortic, iliac, inguinal, full abdomen | spleen (splenic flexure) | Strong [3,14] |
| Bladder, prostate, cervix | inverted Y, iliac, inguinal, full abdomen | para-aortic | Weak [37] |
| Head and neck (oral, salivary) | neck, mantle | supraclavicular | Weak in HL; CCSS salivary dose-response [40] |
| Leukaemia / MDS | Not organ-specific: use any RT and RT volume (supra + infra) | | Chemotherapy dominates [38,39] |
| NHL | Not radiation-site-specific: any RT | | No established field association |
| Sarcoma, melanoma, non-melanoma skin | Any RT / volume. Mapping to a field needs the tumour topography (e.g. trunk skin C44.5 vs mantle), which is available, so it could be done per case if wanted | | Bone/soft-tissue sarcoma and BCC dose-response in CCSS [40,41]; melanoma not established |

**Effect modifiers to include in site-specific models** (prespecified, from the literature):
- Breast: **ovarian damage**, defined as pelvic RT (inverted Y or iliac) **or** high procarbazine dose (decision Q-RT3, 2026-10-14). Both are markers of ovarian dose / early menopause [23,26]. "High" = > 4.2 g/m² (i.e. ≥ 4.3 g/m², the premature-menopause threshold in Schaapveld 2015 [1]) (decision Q-RT3a, 2026-10-14).
- Lung: smoking (`smoke_ever`) [28]. Patients with unknown smoking status are excluded from these models (listwise deletion; decision Q-RT3b, 2026-10-14).
- Stomach, pancreas, colorectum: procarbazine dose [30,32,14].

**Sensitivity analyses**
- (a) Binary version: in field (2) vs not (0 + 1).
- (b) Treatment era as a dose surrogate. Prescribed doses fell over 1989–2013, from 36–40 Gy extended fields to 20–30 Gy involved field/node [42–48]. The actual Dutch dose distribution by era is not documented in what I found.
- (c) If prescribed dose can be obtained (Q-RT4): typical relative organ dose from Maraldo 2015 for supradiaphragmatic organs (breast, lung, thyroid, oesophagus).

### RT technique variables (added 2026-10-14, decision Q-RT1)

**Purpose:** describe the shift in HL radiotherapy over 1989–2013, from extended fields to involved field to involved node [42–48]. This is a descriptive and trend variable that sits alongside the organ-level exposure.

**Is it possible? Partly.**

| Category | How it can be derived from the export | Reliability |
|---|---|---|
| Extended field (mantle, inverted Y, subtotal/total nodal) | `mantle*` = 1, or `invy*` = 1, or `abdom*` = 1, or mantle plus para-aortic/spleen. `rtsupraprim` = 2 (full mantle) and `rtcatprim` 3/4 also identify it | Good: these fields are recorded explicitly |
| Mediastinal (as a field, without mantle) | `mediastprim` / `uppmediasprim` / `lowmediasprim` = 1 with mantle = 0 | Good as a field flag. But a mediastinal field can be part of involved-field *or* involved-node RT, so it is a **target region**, not a technique |
| Involved node (INRT) | `invnode*` = 1 is recorded directly | Moderate. It depends on how consistently centres recorded "involved node" vs naming the individual fields. It also cannot be separated from ISRT (only relevant after about 2014) |
| Involved field (IFRT) | **No explicit flag.** It can only be *presumed*: one or more regional fields (neck, supra/infraclavicular, axilla, mediastinum, lung, iliac, inguinal, para-aortic, spleen) with no mantle, inverted Y, full abdomen or involved-node flag. `rtsupraprim` = 1 ("incomplete mantle") partly overlaps | Weak. Disease extent at diagnosis is not in the export, so we cannot check that the fields matched the involved regions. "Regional field(s), presumed involved field" is the honest label |

**Proposed variables** (per course and combined over courses before the start of follow-up):
- `rt_technique`: no RT / extended field / regional field (presumed IFRT) / involved node / RT, technique unknown (`rt*` = 1 but no usable field flags, or field code 9).
  - Hierarchy if several apply: extended > regional > involved node. This classifies by the *largest* volume given.
- `rt_mediastinal`: mediastinum irradiated yes/no, across all techniques. It answers "mediastinal RT" separately from technique, because a mediastinal field can occur within any technique.
- Cross-tabulated against diagnosis era (1989–1994 / 1995–2004 / 2005+) in the descriptive table to show the trend.

**Checks on the real data before use:**
- How often `invnode*` = 1 together with named regional fields (double recording).
- Agreement between `rtcatprim` / `rtsupraprim` and the individual field flags.
- Distribution of `rt_technique` by era. Extended field should fall and involved node should rise after about 2006 (EORTC H10 era [47]).

---

## 2. Chemotherapy: anthracyclines

### Key finding

- Every published doxorubicin-equivalence ratio was derived for **cardiotoxicity** (Feijen 2015, 2019; IGHG 2025) or from haematological-toxicity substitution rules (COG). None was derived for second cancers.
- The large SMN studies model each agent separately:
  - Wang 2023 [C6]: doxorubicin and daunorubicin doses modelled separately, epirubicin as yes/no.
  - Neppelenbroek 2024 [C7], this Dutch HL cohort: doxorubicin dose, with epirubicin yes/no because 89% received 6 × EBVP. Epirubicin HR 0.8 (0.4–1.5).

| Drug | Feijen 2019 / IGHG 2025 (cardiac) | COG LTFU (as cited by Koskela 2025; primary PDF unverified) |
|---|---|---|
| Daunorubicin | 0.6 (IGHG recommends ~0.6) | 0.5 |
| Epirubicin | 0.8 (IGHG: no recommendation, evidence inconclusive) | 0.67 |
| Mitoxantrone | 10.5 (IGHG recommends) | 10 (older protocols: 4) |
| Idarubicin | not estimable | 5 |

The mitoxantrone factor has a large effect: CNOP × 6 = 60 mg/m² mitoxantrone, which is 630 mg/m² doxorubicin-equivalent at 10.5 versus 240 at 4.

### Options

- **A (recommended).**
  - Primary exposure: cumulative **doxorubicin** dose (mg/m²).
  - **Epirubicin** as a separate yes/no.
  - Mitoxantrone and daunorubicin as a separate "other anthracycline/anthraquinone" yes/no, which is rare.
  - Why: same as the precedent in this cohort (Neppelenbroek 2024), so no cardiac-derived ratio is used for a cancer outcome.
  - Sensitivity analysis: option B.
- **B.** A single doxorubicin-equivalent dose using Feijen 2019 / IGHG ratios (daunorubicin 0.6, epirubicin 0.8, mitoxantrone 10.5). Sensitivity analysis with COG ratios (0.5 / 0.67 / 10, and 4 for mitoxantrone). This follows the SAP wording literally. The limitation must be stated: the ratios are cardiotoxicity-based.

**Cut-offs (doxorubicin):**
- Proposed: 0 / 1–200 / >200 mg/m², and continuous per 100 mg/m². This matches Neppelenbroek 2024 [C7]; >200 is also the IGHG surveillance threshold [C13].
- Alternatives: 0 / <100 / 100–199 / 200–299 / 300–399 / ≥400 (Wang 2023 [C6]); 0 / 1–249 / ≥250 (Ehrhardt 2019 [C11]).

## 3. Chemotherapy: procarbazine

- No study was found that converts other alkylating agents to "procarbazine equivalents".
- Dutch HL papers use the **cumulative procarbazine dose** itself [C7, 1].
- **Proposal:**
  - Cumulative procarbazine dose (mg/m²), categorised 0 / ≤4.2 / 4.3–8.4 / >8.4 g/m², following Neppelenbroek 2024 [C7]. The 4.3 g/m² threshold relates to premature menopause [1].
  - The variable is named "cumulative procarbazine dose".
- **Optional, for all alkylating agents:** cyclophosphamide-equivalent dose (CED; Green 2014 [C18]). It already includes procarbazine (factor 0.857), nitrogen mustard, chlorambucil, CCNU, BCNU, melphalan and others, but not dacarbazine. *(Not requested, decision Q-CT2.)*

**Sensitivity analysis S-CT98 (added 2026-10-14): ChlVPP/ABV procarbazine dose.**
- **Primary:** code 98 (ChlVPP/ABV) uses the lookup value of **1000 mg/m² per cycle** (decision Q-CT3).
- **Sensitivity:** **700 mg/m² per cycle**, the likely hybrid schedule.
- **Why:**
  - In hybrid ChlVPP regimens, the ChlVPP part is given on days 1–7 only, with ABV-type drugs on day 8. ChlVPP/ABVVP gives procarbazine 80 mg/m² on days 1–7, i.e. 560 per cycle.
  - Full ChlVPP is 100 mg/m² on days 1–14 (1400 per cycle) [C23].
  - No ChlVPP/ABV-specific schedule was found, so 1000 could not be verified.
  - At 6 cycles the choice moves patients across the 4.2 g/m² cut-off: 1000 gives 6.0 g/m² (4.3–8.4), 700 gives 4.2 g/m² (≤4.2).
- **Implementation:** `02_chemo-doses.R` computes both `procarb_dose` (primary) and `procarb_dose_s98` (sensitivity). Re-run procarbazine-dependent models with the sensitivity version.
- **Report:** the number of patients who received code 98, and how many change procarbazine category. If none change category, state this and do not present the sensitivity models.

## 4. Lookup table corrections (per-cycle doses, mg/m²)

| Code | Regimen | Lookup now | Proposed | Basis |
|---|---|---|---|---|
| 58 | COPP | procarbazine 1000 | **1400** | 100 mg/m² d1–14 (Green 2014 Table I [C18]) |
| 69 | ChlVPP (CHOPP) | procarbazine 1000 | **1400** | 100 mg/m² d1–14 (McElwain 1977 [C23]); unless 1000 deliberately reflects a daily cap |
| 61 | MOPP/ABVD alternating | doxorubicin 50 + procarbazine 1400 per cycle | **25 + 700** if "cycles" counts MOPP and ABVD cycles together | Each drug is given in half of the cycles |
| 94 | MOPP/ABV alternating | doxorubicin 50 + procarbazine 1400 | same question as 61 | |
| 98 | ChlVPP/ABV | procarbazine flag "No", dose 1000 | flag "Yes"; dose to confirm (hybrid: 700?) | Inconsistent lookup row |
| 105 | Pro-MACE | doxorubicin 25 (text did not match code) | 25 | Fix the text match only |
| 83 | EBVP | — | **epirubicin 70** | 6 × EBVP = 420 (Neppelenbroek 2024 [C7]) |
| 223/224 | CNOP(-R) | — | **mitoxantrone 10** | Sonneveld 1990 [C26] |
| 70 | VCR + bleomycin + Adriablastine | missing | needs local protocol | |
| 86 | Stanford V | missing | needs a definition of "1 cycle" (12-week schedule) | |
| 109 | EBVD | missing | needs local protocol | |
| 225 | R-CHVmP-VB | missing | needs local protocol | |
| 71 | CCNU + Velbe + Endoxan + Natulan | missing (procarbazine) | needs local protocol | |

Verified as consistent with published schedules: ABVD 50, BEACOPP baseline 25/700, BEACOPP escalated 35/700, MOPP/ABV hybrid 35/700, OPPA 80/1500, MOPP 1400, LOPP 1000. OEPA 80 and CHOP 50 are standard but were not text-verified.

**Plausibility checks after conversion:**
- Expected first-line totals: ABVD 2–8 cycles = 100–400 mg/m² doxorubicin; BEACOPP escalated 4–8 = 140–280; MOPP/ABV 6–8 = 210–280; MOPP × 6 = 8.4 g/m² procarbazine.
- Records will be listed for review if doxorubicin is over 450 mg/m² or procarbazine is over 12 g/m² without relapse treatment, or if ABVD cycles exceed 8. An ABVD count above 8 could mean day-1 and day-15 doses were recorded as separate cycles.

---

## Questions for the project leader

- ~~**Q-RT1.** Approve the 3-level organ exposure (none / bordering / in field) as the primary RT exposure, with the binary version as a sensitivity analysis?~~ **Decided 2026-10-14** (see decision log).
- ~~**Q-RT1a.** RT technique variable: did "mediastinal" mean mantle / extended field, and is the "regional field (presumed involved field)" label acceptable?~~ **Decided 2026-10-14** (see decision log).
- ~~**Q-RT2.** Approve the field-to-organ mapping table?~~ **Decided 2026-10-14: approved as draft; share with Berthe for approval** (see decision log).
- ~~**Q-RT3.** Approve the prespecified effect modifiers?~~ **Decided 2026-10-14: approved; ovarian damage = pelvic RT OR high procarbazine** (see decision log).
- ~~**Q-RT3a.** Define "high procarbazine" as > 4.2 g/m²?~~ **Decided 2026-10-14: yes.**
- ~~**Q-RT3b.** Lung × smoking: unknown smoking status?~~ **Decided 2026-10-14: listwise deletion.**
- ~~**Q-RT4.** Can the prescribed dose be obtained?~~ **Decided 2026-10-14: do not include prescribed dose for now.**
- ~~**Q-CT1.** Option A (doxorubicin + epirubicin flag) or B (doxorubicin-equivalent with Feijen ratios) as the primary anthracycline exposure?~~ **Decided 2026-10-14: option A** (see decision log).
- ~~**Q-CT2.** Procarbazine as its own cumulative dose (no conversion)? Also compute CED?~~ **Decided 2026-10-14: cumulative procarbazine dose; no CED** (see decision log).
- ~~**Q-CT3.** Accept the lookup corrections? How are "cycles" counted for alternating MOPP/ABV(D)?~~ **Decided 2026-10-14: keep existing numbers; EBVP epirubicin 70; others missing** (see decision log).
- ~~**Q-CT4.** Who can supply local protocol doses for codes 70, 86, 109, 225 and 71?~~ **Resolved 2026-10-14 by Q-CT3: left missing.**
- ~~**Q-CT5.** Approve the cut-offs and the plausibility flags?~~ **Decided 2026-10-14** (see decision log).
- ~~**Open from earlier:** exclude non-melanoma skin cancer and unknown primary (C80.9) from "any SMN"?~~ **Decided 2026-10-14** (see decision log).
- ~~**Q-CT6.** Add Neppelenbroek's finer doxorubicin split as a sensitivity analysis?~~ **Decided 2026-10-14: yes** (see decision log).

---

## References

### Radiotherapy
1. Schaapveld M, et al. Second cancer risk up to 40 years after treatment for Hodgkin's lymphoma. N Engl J Med 2015. doi:10.1056/NEJMoa1505949
2. De Bruin ML, et al. Breast cancer risk in female survivors of Hodgkin's lymphoma: lower risk after smaller radiation volumes. J Clin Oncol 2009. doi:10.1200/JCO.2008.19.9174
3. van Eggermond AM, et al. Infradiaphragmatic irradiation and high procarbazine doses increase colorectal cancer risk in Hodgkin lymphoma survivors. Br J Cancer 2017. doi:10.1038/bjc.2017.177
4. de Vries S, et al. Risk of male breast cancer after Hodgkin lymphoma. Blood 2023. doi:10.1182/blood.2023020940
5. Holmqvist AS, et al. Risk of solid subsequent malignant neoplasms after childhood Hodgkin lymphoma. Cancer 2019. doi:10.1002/cncr.31807
6. Moskowitz CS, et al. Breast cancer after chest radiation therapy for childhood cancer. J Clin Oncol 2014. doi:10.1200/JCO.2013.54.4601
7. Hodgson DC, et al. Long-term solid cancer risk among 5-year survivors of Hodgkin's lymphoma. J Clin Oncol 2007. doi:10.1200/JCO.2006.09.0936
8. Diallo I, et al. Frequency distribution of second solid cancer locations in relation to the irradiated volume. Int J Radiat Oncol Biol Phys 2009. doi:10.1016/j.ijrobp.2009.01.040
9. Journy N, et al. Volume effects of radiotherapy on the risk of second primary cancers: a systematic review. Radiother Oncol 2019. doi:10.1016/j.radonc.2018.09.017
10. Maraldo MV, et al. A new method to estimate doses to the normal tissues after past extended and involved field radiotherapy for Hodgkin lymphoma. Radiother Oncol 2015. doi:10.1016/j.radonc.2015.01.008
11. Roshani S, et al. Predicting long-term absolute risk of lung cancer in patients with Hodgkin lymphoma. J Natl Cancer Inst 2026. doi:10.1093/jnci/djag090
12. Stovall M, et al. Dose reconstruction for therapeutic and diagnostic radiation exposures. Radiat Res 2006. doi:10.1667/RR3525.1
13. Howell RM, et al. Adaptations to a generalized radiation dose reconstruction methodology. Radiat Res 2019. doi:10.1667/RR15201.1
14. Geurts YM, et al. Association of radiation and procarbazine dose with risk of colorectal cancer among survivors of Hodgkin lymphoma. JAMA Oncol 2023. doi:10.1001/jamaoncol.2022.7153
15. Maraldo MV, et al. Cardiovascular disease after treatment for Hodgkin's lymphoma: nine EORTC-LYSA trials. Lancet Haematol 2015. doi:10.1016/S2352-3026(15)00153-2
16. Koh ES, et al. A comparison of mantle versus involved-field radiotherapy for Hodgkin's lymphoma. Radiat Oncol 2007. doi:10.1186/1748-717X-2-13
17. Hodgson DC, et al. Individualized estimates of second cancer risks after contemporary radiation therapy for Hodgkin lymphoma. Cancer 2007. doi:10.1002/cncr.23081
18. Zhou R, et al. Normal tissue doses for Hodgkin lymphoma: CCSS vs recent COG trials. Int J Radiat Oncol Biol Phys 2016. doi:10.1016/j.ijrobp.2016.01.053
19. Roberti S, et al. Radiation doses to the breast and predicted breast cancer risk among Hodgkin lymphoma patients treated with modern radiotherapy. Int J Radiat Oncol Biol Phys 2025. doi:10.1016/j.ijrobp.2024.12.016
20. Maraldo MV, et al. Estimated risk of cardiovascular disease and secondary cancers with modern highly conformal radiotherapy for early-stage mediastinal Hodgkin lymphoma. Ann Oncol 2013. doi:10.1093/annonc/mdt156
21. Travis LB, et al. Cumulative absolute breast cancer risk for young women treated for Hodgkin lymphoma. J Natl Cancer Inst 2005. doi:10.1093/jnci/dji290
22. Bhatia S, et al. Breast cancer and other second neoplasms after childhood Hodgkin's disease. N Engl J Med 1996. doi:10.1056/NEJM199603213341201
23. Swerdlow AJ, et al. Breast cancer risk after supradiaphragmatic radiotherapy for Hodgkin's lymphoma in England and Wales. J Clin Oncol 2012. doi:10.1200/JCO.2011.38.8835
24. Travis LB, et al. Breast cancer following radiotherapy and chemotherapy among young women with Hodgkin disease. JAMA 2003. doi:10.1001/jama.290.4.465
25. van Leeuwen FE, et al. Roles of radiation dose, chemotherapy, and hormonal factors in breast cancer following Hodgkin's disease. J Natl Cancer Inst 2003. doi:10.1093/jnci/95.13.971
26. Krul IM, et al. Breast cancer risk after radiation therapy for Hodgkin lymphoma: influence of gonadal hormone exposure. Int J Radiat Oncol Biol Phys 2017. doi:10.1016/j.ijrobp.2017.07.016
27. Inskip PD, et al. Radiation dose and breast cancer risk in the Childhood Cancer Survivor Study. J Clin Oncol 2009. doi:10.1200/JCO.2008.20.7738
28. Gilbert ES, et al. Lung cancer after treatment for Hodgkin's disease: focus on radiation effects. Radiat Res 2003. doi:10.1667/0033-7587(2003)159[0161:LCATFH]2.0.CO;2
29. Travis LB, et al. Lung cancer following chemotherapy and radiotherapy for Hodgkin's disease. J Natl Cancer Inst 2002. doi:10.1093/jnci/94.3.182
30. Morton LM, et al. Stomach cancer risk after treatment for Hodgkin lymphoma. J Clin Oncol 2013. doi:10.1200/JCO.2013.50.6832
31. Gilbert ES, et al. Stomach cancer following Hodgkin lymphoma, testicular cancer and cervical cancer: a pooled analysis. Radiat Res 2017. doi:10.1667/RR14453.1
32. Dores GM, et al. Pancreatic cancer risk after treatment of Hodgkin lymphoma. Ann Oncol 2014. doi:10.1093/annonc/mdu287
33. Morton LM, et al. Risk of esophageal cancer following radiotherapy for Hodgkin lymphoma. Haematologica 2014. doi:10.3324/haematol.2014.108258
34. Sigurdson AJ, et al. Primary thyroid cancer after a first tumour in childhood (CCSS). Lancet 2005. doi:10.1016/S0140-6736(05)66695-0
35. Bhatti P, et al. Risk of second primary thyroid cancer after radiotherapy for a childhood cancer (CCSS update). Radiat Res 2010. doi:10.1667/RR2240.1
36. Michaelson EM, et al. Thyroid malignancies in survivors of Hodgkin lymphoma. Int J Radiat Oncol Biol Phys 2014. doi:10.1016/j.ijrobp.2013.11.237
37. Dores GM, et al. Second malignant neoplasms among long-term survivors of Hodgkin's disease. J Clin Oncol 2002. doi:10.1200/JCO.2002.09.038
38. Kaldor JM, et al. Leukemia following Hodgkin's disease. N Engl J Med 1990. doi:10.1056/NEJM199001043220102
39. Allodji RS, et al. Role of radiotherapy and chemotherapy in leukemia risk after childhood cancer. Int J Cancer 2021. doi:10.1002/ijc.33361
40. Inskip PD, et al. Radiation-related new primary solid cancers in the CCSS: comparative radiation dose response. Int J Radiat Oncol Biol Phys 2016. doi:10.1016/j.ijrobp.2015.11.046
41. Watt TC, et al. Radiation-related risk of basal cell carcinoma (CCSS). J Natl Cancer Inst 2012. doi:10.1093/jnci/djs298
42. Dühmke E, et al. Low-dose radiation is sufficient for the noninvolved extended-field treatment (GHSG HD4). J Clin Oncol 2001. doi:10.1200/JCO.2001.19.11.2905
43. Noordijk EM, et al. Combined-modality therapy for clinical stage I or II Hodgkin's lymphoma: EORTC H7. J Clin Oncol 2006. doi:10.1200/JCO.2005.05.2746
44. Fermé C, et al. Chemotherapy plus involved-field radiation in early-stage Hodgkin's disease (H8). N Engl J Med 2007. doi:10.1056/NEJMoa064601
45. Engert A, et al. Reduced treatment intensity in patients with early-stage Hodgkin's lymphoma (HD10). N Engl J Med 2010. doi:10.1056/NEJMoa1000067
46. Eich HT, et al. Intensified chemotherapy and dose-reduced involved-field radiotherapy (HD11). J Clin Oncol 2010. doi:10.1200/JCO.2010.29.8018
47. André MPE, et al. Early PET response-adapted treatment (EORTC/LYSA/FIL H10). J Clin Oncol 2017. doi:10.1200/JCO.2016.68.6394
48. Specht L, et al. Modern radiation therapy for Hodgkin lymphoma: ILROG field and dose guidelines. Int J Radiat Oncol Biol Phys 2014. doi:10.1016/j.ijrobp.2013.05.005

### Chemotherapy
- C1. Feijen EAM, et al. Equivalence ratio for daunorubicin to doxorubicin in relation to late heart failure in survivors of childhood cancer. J Clin Oncol 2015. doi:10.1200/JCO.2015.61.5187
- C2. Feijen EAM, et al. Derivation of anthracycline and anthraquinone equivalence ratios to doxorubicin for late-onset cardiotoxicity. JAMA Oncol 2019. doi:10.1001/jamaoncol.2018.6634
- C3. Kouwenberg TW, et al. IGHG recommendations for anthracycline and anthraquinone cardiac dysfunction equivalence ratios. JACC CardioOncol 2025. doi:10.1016/j.jaccao.2025.05.009
- C4. Koskela M, et al. Influence of therapy exposures on specific late morbidities in aging male survivors of childhood cancer. Int J Cancer 2025. doi:10.1002/ijc.35247
- C5. Children's Oncology Group. Long-Term Follow-Up Guidelines v5.0/v6.0. *(unverified: primary PDF not retrievable)*
- C6. Wang Y, et al. Subsequent female breast cancer risk associated with anthracycline chemotherapy for childhood cancer. Nat Med 2023. doi:10.1038/s41591-023-02514-1
- C7. Neppelenbroek SIM, et al. Doxorubicin exposure and breast cancer risk in survivors of adolescent and adult Hodgkin lymphoma. J Clin Oncol 2024. doi:10.1200/JCO.23.01386
- C8. Teepen JC, et al. Long-term risk of subsequent malignant neoplasms after treatment of childhood cancer in the DCOG LATER cohort. J Clin Oncol 2017. doi:10.1200/JCO.2016.71.6902
- C9. Turcotte LM, et al. Chemotherapy and risk of subsequent malignant neoplasms in the CCSS cohort. J Clin Oncol 2019. doi:10.1200/JCO.19.00129
- C10. Henderson TO, et al. Breast cancer risk in childhood cancer survivors without a history of chest radiotherapy. J Clin Oncol 2016. doi:10.1200/JCO.2015.62.3314
- C11. Ehrhardt MJ, et al. Subsequent breast cancer in female childhood cancer survivors in SJLIFE. J Clin Oncol 2019. doi:10.1200/JCO.18.01099
- C12. Veiga LH, et al. Breast cancer risk after childhood cancer: radiation dose to the breast and anthracycline use (CCSS). JAMA Pediatr 2019. doi:10.1001/jamapediatrics.2019.3807
- C13. Mulder RL, et al. IGHG recommendations for breast cancer surveillance after anthracyclines. JCO Oncol Pract 2026. doi:10.1200/OP-25-01017
- C16. Morton LM, et al. Stomach cancer risk after treatment for Hodgkin lymphoma. J Clin Oncol 2013. doi:10.1200/JCO.2013.50.6832
- C17. Dores GM, et al. Pancreatic cancer risk after treatment of Hodgkin lymphoma. Ann Oncol 2014. doi:10.1093/annonc/mdu287
- C18. Green DM, et al. The cyclophosphamide equivalent dose as an approach for quantifying alkylating agent exposure. Pediatr Blood Cancer 2014. doi:10.1002/pbc.24679
- C19. Tucker MA, et al. Bone sarcomas linked to radiotherapy and chemotherapy in children. N Engl J Med 1987. doi:10.1056/NEJM198709033171002
- C20. Diehl V, et al. Standard and increased-dose BEACOPP compared with COPP-ABVD. N Engl J Med 2003. doi:10.1056/NEJMoa022473
- C21. Klimo P, Connors JM. MOPP/ABV hybrid program. J Clin Oncol 1985. doi:10.1200/JCO.1985.3.9.1174
- C22. Bonadonna G, et al. Combination chemotherapy of Hodgkin's disease with ABVD versus MOPP. Cancer 1975. doi:10.1002/1097-0142(197507)36:1<252::AID-CNCR2820360128>3.0.CO;2-7
- C23. McElwain TJ, et al. A combination of chlorambucil, vinblastine, procarbazine and prednisolone (ChlVPP). Br J Cancer 1977. doi:10.1038/bjc.1977.187
- C24. Schellong G, et al. High cure rates and reduced long-term toxicity in pediatric Hodgkin's disease (DAL-HD-90). J Clin Oncol 1999. doi:10.1200/JCO.1999.17.12.3736
- C26. Sonneveld P, Michiels JJ. Full dose chemotherapy in elderly patients with non-Hodgkin's lymphoma: a mitoxantrone-containing regimen (CNOP). Br J Cancer 1990. doi:10.1038/bjc.1990.238
