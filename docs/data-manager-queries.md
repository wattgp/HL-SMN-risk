# Data queries: Hodgkin lymphoma cohort, ResearchDB export of 2024-12-12

From: G. Watt (HL-SMN-risk project). Date: 2026-10-14.

We have run our data checks on the export. Below are the points where we need your help. For each one we give what we found, how we handle it **for now**, and our question.

Counts are for the whole export (6,654 patients) unless "analytic cohort" is stated (3,118 patients: HL diagnosed 1989 or later, aged 15–50, alive and in follow-up 5 years after diagnosis).

**The ResearchIDs for each query** are in separate files (named per query below). They are only shared through our secure channel, never by e-mail.

---

## Highest priority

### Q1. Patients on more than one row
- **Found:** 25 ResearchIDs occur on more than one row: 23 on 2 rows and 2 on 3 rows, 52 rows in total.
  - The rows come from different sources: `bron` = *validatie*, *basis ontw* or *uitbr ontw*, with `volgnr` 1, 2 or 4. 23 of the 25 patients have one *validatie* row.
  - `R_regel`, `BETERnr`, `statusnr` and `AutoIDdef` differ between the rows.
  - The rows almost always differ in hospital (`zkh`; 24 of 25). They often differ in diagnosis month, HL morphology / topography / behaviour, last-contact and vital-status dates, primary RT and chemotherapy dates, and the first SMN date.
  - The diagnosis **year** is the same.
- **For now:** all 25 patients are excluded.
- **Questions:**
  1. What do `bron` (*validatie* / *basis ontw* / *uitbr ontw*) and `volgnr` mean?
  2. For these patients, which row is the correct (authoritative) record? Or should the rows be combined, for example treatment given at two hospitals?
- **File:** `Q1_duplicated_researchids.csv`

### Q2. Regimen codes not in the chemotherapy code list
- **Found:** codes **114** (7 regimen slots) and **115** (1 slot) are used in `c<k>ctprim` / `c<k>ctfup`. They are not in the codebook's drug list (`chem_drugs.xlsx`).
- **For now:** the drugs and doses of these regimens are unknown.
- **Questions:**
  1. Which regimens are 114 and 115?
  2. Do they contain doxorubicin (or another anthracycline) or procarbazine, and at what dose per cycle?
- **Also please confirm:** code **0** (52 slots) means "no regimen in this slot". We now treat it that way.
- **File:** `Q2_unknown_regimen_codes.csv`

### Q3. SMNs without a behaviour code
- **Found:** 186 recorded SMNs have no behaviour code (`smn<k>_behav`). In the analytic cohort, **10 have a site and a date during follow-up**: 4 breast, 2 haematopoietic / lymph node, and 1 each lung, pancreas, stomach and other skin.
- **For now:** these are not counted as SMNs, because only invasive SMNs count. Behaviour code 9 is counted as invasive.
- **Question:** could you look up the behaviour code for these 10 (and ideally all 186)?
- **File:** `Q3_smn_without_behaviour.csv`. The 10 cohort SMNs during follow-up are listed first.

### Q4. Is vital status ascertained further than SMNs?
- **Found:** for 510 patients in the analytic cohort, the vital-status date (`m_/y_livedead`) is later than the last-contact date (`m_/y_lcontact`). The median difference is 1.3 years (maximum 19.8), adding 1,751 person-years (4.4%) of follow-up.
- **Why it matters:** the codebook defines last contact as the date "up to which subsequent malignant neoplasms would be known". If vital status is updated separately, for example through the population register (BRP), then SMNs after the last-contact date may have been missed.
- **Questions:**
  1. How are the vital-status date and the last-contact date updated?
  2. Up to which date are SMNs complete for a patient: last contact, or (for example) a cancer-registry linkage date?
- **File:** `Q4_vital_status_after_last_contact.csv`

---

## Dates

### Q5. Date inconsistencies
| | Finding | For now | Question / file |
|---|---|---|---|
| a | **26 patients** have data (an SMN, treatment, relapse or last contact) dated **after the death date** | Follow-up ends at death | Which date is wrong? `Q5a_data_after_death.csv` |
| b | **1 RT course** (second follow-up course) starts after the death date | Ignored | Correct date? `Q5b_course_after_death.csv` |
| c | **12 chemotherapy and 7 RT primary courses** start 5 or more years after HL diagnosis | Treated as primary treatment (the diagnosis date is trusted) | Is the course date or the diagnosis date wrong? `Q5c_primary_course_5y_after_diagnosis.csv` |
| d | **6 relapse treatment courses** were given but have no start date and no relapse date | Assumed to be within 5 years of diagnosis | Can the dates be found? `Q5d_relapse_course_without_date.csv` |
| e | **69 invasive SMNs** are diagnosed after the recorded last-contact date | Last contact moved to the SMN date | Is the last-contact date out of date for these patients? `Q5e_smn_after_last_contact.csv` |

---

## Treatment

### Q6. Implausible numbers of chemotherapy cycles
- **Found:** **40 patients** have a cumulative dose outside the plausible range without relapse treatment:
  - 35 for procarbazine (>12 g/m²), 3 for doxorubicin (>450 mg/m²), and 4 with more than 8 ABVD cycles.
  - Examples of recorded cycle numbers: MOPP up to **20** cycles, ChlVPP up to **23**, single-agent procarbazine (code 29) up to **14**, and ABVD up to **15**.
- **For now:** doses in the continuous analyses are capped (doxorubicin 550, procarbazine 11,200 mg/m²).
- **Questions:**
  1. Does `n<k>ct...` always hold the number of **cycles**? Could it sometimes hold days, administrations, or half-cycles? For example, ABVD day 1 and day 15 counted as 2.
  2. Could you check these 40 patients?
- **File:** `Q6_implausible_cycles_or_doses.csv`

### Q7. Chemotherapy yes/no versus recorded regimens
- **Found:**
  - `ctprim`, `ctfup` and `ctfup2` = **no** while regimens are recorded: 4 courses each.
  - `ctprim` = **yes** without any regimen: 9 courses (`ctfup` 14, `ctfup2` 9).
  - `ctprim` = **unknown**: 33 patients.
- **For now:** a recorded regimen counts as chemotherapy given. "Yes" without a regimen is "drug unknown".
- **Question:** which is correct for these courses?
- **File:** `Q7_chemo_flag_vs_regimens.csv`

### Q8. `rtcatprim` = "no radiotherapy" while RT was given
- **Found:** **74 patients** with `rtcatprim` = 0 (no RT), while `rtprim` = 1 and the field variables show RT, e.g. a mantle field or an incomplete mantle field.
- **For now:** the field variables are used.
- **Question:** is `rtcatprim` missing or out of date for these patients?
- **File:** `Q8_rtcat_no_rt_but_rt_given.csv`

### Q9. Meaning of the "involved node" field (`invnodeprim`)
- **Found:** in **1,275 primary RT courses**, `invnodeprim` = 1 is recorded **together with** named regional fields (neck, axilla, mediastinum, …). Only 43 courses have the involved-node flag without other fields.
- **Question:** does `invnodeprim` = 1 mean the **involved-node technique (INRT)**, or that "the involved lymph nodes were irradiated" (by whatever field)?
- **File:** `Q9_invnode_with_regional_fields.csv`

### Q10. Missing dose information for some regimens
- **Found:** the dose lookup tables have no dose per cycle for these regimens:
  - **70** (VCR + bleomycin + Adriablastine)
  - **86** (Stanford V; how is "1 cycle" defined for this 12-week schedule?)
  - **109** (EBVD)
  - **223 / 224** (CNOP / CNOP-R: mitoxantrone dose)
  - **225** (R-CHVmP-VB)
  - **71** (CCNU + Velbe + Endoxan + Natulan: procarbazine dose)
- **For now:** their doses are missing.
- **Question:** are the local protocol doses per cycle available?

---

## Sites and other codes

### Q11. Topography without subsite, or invalid
- **Found:** **34 SMN topographies** are recorded without a subsite, e.g. `C50`, `C22`, `C77` (5 each), `C20`, `C44`, `C54` (3 each). One code, `C97`, is not an ICD-O topography code.
- **For now:** a site group is assigned from the 3-character code. For sarcomas and skin tumours, the location (subsite) is needed to match them to the RT fields.
- **Questions:**
  1. Can the subsite be added where it is known?
  2. What should `C97` be?
- **File:** `Q11_topography_no_subsite_or_invalid.csv`

### Q12. Hospital code "0"
- **Found:** 4 patients have `zkh` = "0".
- **Question:** which hospital?
- **File:** `Q12_hospital_code_0.csv`

### Q13. Missing core data (for information; corrections welcome)
- HL diagnosis year unknown: 39 patients
- Vital status unknown: 107 patients
- End of follow-up unknown (no last-contact or other dated information): 13 patients
- Invasive SMN with unknown date: 1 patient
- **File:** `Q13_missing_core_data.csv`
