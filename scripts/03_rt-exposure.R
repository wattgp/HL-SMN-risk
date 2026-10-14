# 03_rt-exposure.R
# Derives radiotherapy (RT) exposure variables from the recorded RT field
# flags, for the primary RT course and up to two follow-up (relapse) courses:
#   - organ exposure per SMN site: 0 = not irradiated, 1 = organ bordering a
#     field, 2 = organ in field (field-to-organ mapping, section 4)
#   - rt_technique: no RT / mantle or extended field / regional field
#     (presumed involved field) / involved node / RT, technique unknown
#   - rt_mediastinal: mediastinum irradiated yes/no
#   - rt_pelvic: pelvic RT (inverted Y or iliac) yes/no, used for the breast
#     cancer "ovarian damage" effect modifier
#   - supra-/infradiaphragmatic RT yes/no
# and describes the (rarely recorded) prescribed RT doses (section 7).
#
# Output (in out_dir from 00_config.R):
#   rt_fields_course.Rds    one row per patient x course: course start date,
#                           RT given, field groups, technique, mediastinal,
#                           pelvic, supra/infra
#   rt_organ_course.Rds     one row per patient x course x SMN site: organ
#                           exposure 0/1/2 (NA = unknown)
#   rt_dose_description.Rds the dose description tables (section 7)
#
# As for chemotherapy (02_chemo-doses.R), this script keeps every course's
# start date; the exposure window (before start of follow-up, then time-
# varying; D5) is applied in a later script once follow-up start is known.
#
# The field-to-organ mapping is a DRAFT (Q-RT2): it must be approved by
# Berthe before results are reported.
#
# Full rationale and references: docs/proposal_exposure-definitions.md
#
# Run from the project:  source(here::here("scripts", "03_rt-exposure.R"))

# ---- decision log ------------------------------------------------------------
# Questions put to the project leader (G. Watt) and the answers given.
#
# D4 (2026-10-13) Day of month is unreliable: use mid-month (day 15).
#    (Same decision as in 02_chemo-doses.R.)
# D5 (2026-10-13) Exposure = treatment before the start of follow-up (5 years
#    after HL diagnosis); later treatment is time-varying. -> course start
#    dates are kept here; the window is applied later.
# R1 (2026-10-14, Q-RT1) Q: Primary RT exposure? A: Organ exposure in 3
#    levels (0 none / 1 bordering / 2 in field); binary (2 vs 0+1) as a
#    sensitivity analysis. Also create variables for broad trends in RT
#    technique.
# R1a (2026-10-14, Q-RT1a) Q: Technique categories? A: no RT / mantle or
#    extended field / regional field (presumed involved field) / involved
#    node / unknown. Mediastinal RT is a separate yes/no variable.
# R2 (2026-10-14, Q-RT2) Q: Field-to-organ mapping? A: Approved as a DRAFT;
#    proceed. To be shared with Berthe for approval. Sarcoma and skin SMNs:
#    match each tumour to the fields by its topography code where possible
#    (done in the outcome script, which has the topography).
# R3 (2026-10-14, Q-RT3/Q-RT3a) Q: Effect modifiers? A: Approved. Breast
#    cancer "ovarian damage" = pelvic RT (inverted Y or iliac) OR procarbazine
#    > 4.2 g/m2. -> rt_pelvic is made here; the procarbazine part comes from
#    02_chemo-doses.R.
# R4 (2026-10-14, Q-RT4) Q: Use prescribed RT dose? A: Not for now. The
#    recorded doses are described only (R5).
# R5 (2026-10-14) Q: How to use rt*_dosistot / rt*_dose1-5? A: Describe the
#    recorded doses against RT technique and era in a table; not in models.
# R6 (2026-10-13) Diagnosis eras: 1989-1994, 1995-2004, 2005-latest.
# R7 (2026-10-14) Q: Use the RT categories already in the export
#    (rtsupra, rtmid, rtinfra, rtneck, rtmed, rtcat per course)? A: Yes.
#    They were defined with radiation oncologists and are kept, unchanged,
#    as a PARALLEL classification (variables *_cb, section 3b), for a
#    parallel analysis next to the field-flag-based variables.
# R8 (2026-10-14) Q: Use the free-text field names recorded with the doses
#    (rtprim_field1-5, rtfup2_field1-3, *_surdos_fields)? A: Yes:
#    incorporate them into the field classification by hand (mapping table,
#    section 2a). The values seen in the real data on 2026-10-14 were:
#    mediastinum; neck L+R; other; paraaortal + spleen; axilla L; neck L;
#    neck R; paraaortal; spleen; supraclavicular L+R; axilla L+R; axilla R;
#    axilla R + mediastinum; inguinal L; lower mediastinum; lung L; lung R;
#    supraclavicular L; upper mediastinum.
# R8a (2026-10-14) Real data: the boost-field text often lists several
#    fields separated by commas; each item is now mapped on its own. Three
#    terms were added: "inguinal R", "lung L+R", and "middle mediastinum"
#    (no flag of its own -> the mediastinum flag, part unspecified).
# R9 (2026-10-14) Q: The involved-node flag is usually recorded TOGETHER
#    with named regional fields (1,275 primary courses in the real data);
#    does invnode mean the involved-node technique or "the involved nodes
#    were irradiated"? A: Cannot be determined; use the approach with the
#    fewest assumptions: classify by the named fields that were recorded
#    (unchanged: regional field wins over the involved-node flag; R1a), and
#    keep the involved-node flag itself as a separate variable (invnode)
#    so it can be described next to rt_technique.
# T1 (2026-10-14) Q: Text names a field whose flag is 0 or unknown? A: The
#    TEXT OVERRIDES the flag (option b): a field named in the free text sets
#    that field flag to 1, whether the flag was 0 or unknown (a field
#    recorded with its own dose is strong evidence it was irradiated). The
#    number of overridden 0 flags is printed. A named field also means RT
#    was given in that course when rt<course> is unknown.

source(here::here("scripts", "00_config.R"))

library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(purrr)
library(lubridate)

# ---- 1. read the raw export ----------------------------------------------------

# Every column is read as character and recoded explicitly (see
# 02_chemo-doses.R). Patients with a duplicated ResearchID are removed (C13
# in 00_config.R).
raw <- read_raw()

unknown_text <- c("onbekend", "Onbekend", "ONBEKEND")

# Mid-month date (D4); NA for unknown/placeholder month or year.
mid_month_date <- function(month, year) {
  m <- suppressWarnings(as.integer(ifelse(month %in% unknown_text, NA, month)))
  y <- suppressWarnings(as.integer(ifelse(year %in% unknown_text, NA, year)))
  m[!m %in% 1:12] <- NA
  y[!is.na(y) & (y < 1900 | y > 2100)] <- NA
  make_date(y, m, 15L)
}

# Field flags are coded 0 = no, 1 = yes, 9 = unknown (codebook). Returned as
# integer 0/1 with NA for 9 or anything else.
flag01 <- function(x) {
  x <- suppressWarnings(as.integer(x))
  case_when(x == 1L ~ 1L, x == 0L ~ 0L, TRUE ~ NA_integer_)
}

# Combine several flags (e.g. left / right / side unspecified) into one:
# 1 if any is 1; otherwise NA if any is unknown; otherwise 0. Laterality is
# collapsed because SMN laterality is not recorded (proposal, section 1).
any01 <- function(...) {
  m <- cbind(...)
  out <- ifelse(rowSums(m == 1L, na.rm = TRUE) > 0, 1L,
                ifelse(rowSums(is.na(m)) > 0, NA_integer_, 0L))
  as.integer(out)
}

# ---- 2a. free-text field names -> field flags (R8) --------------------------------

# T1 (decided 2026-10-14): "text_overrides" = a field named in the text sets
# the flag to 1 whether it was 0 or unknown. ("fill_unknown_only" would only
# fill unknown flags.)
t1_text_rule <- "text_overrides"

# Free-text columns per course. The first follow-up course has only the
# boost ("surdosage") field text.
text_cols <- list(
  prim = c(paste0("rtprim_field", 1:5), "rtprim_surdos_fields"),
  fup  = c("rtfup_surdos_fields"),
  fup2 = c(paste0("rtfup2_field", 1:3), "rtfup2_surdos_fields")
)

# Hand-made mapping (R8): free text (lower case, single spaces) -> the field
# flag stems it names (stem + course suffix = export column, e.g. "laxil" ->
# laxilprim). Side is kept where the text gives it; "L+R" sets both sides.
field_text_map <- tribble(
  ~text,                     ~stems,
  "mediastinum",             c("mediast"),
  "upper mediastinum",       c("uppmedias"),
  "lower mediastinum",       c("lowmedias"),
  "neck l",                  c("lneck"),
  "neck r",                  c("rneck"),
  "neck l+r",                c("lneck", "rneck"),
  "supraclavicular l",       c("lsupra"),
  "supraclavicular r",       c("rsupra"),
  "supraclavicular l+r",     c("lsupra", "rsupra"),
  "axilla l",                c("laxil"),
  "axilla r",                c("raxil"),
  "axilla l+r",              c("laxil", "raxil"),
  "axilla r + mediastinum",  c("raxil", "mediast"),
  "lung l",                  c("llung"),
  "lung r",                  c("rlung"),
  "paraaortal",              c("paraa"),
  "spleen",                  c("spleen"),
  "paraaortal + spleen",     c("paraa", "spleen"),
  "inguinal l",              c("lingui"),
  "inguinal r",              c("ringui"),                 # R8a
  "lung l+r",                c("llung", "rlung"),         # R8a
  "middle mediastinum",      c("mediast"),                # R8a: no own flag -> mediastinum, part unspecified
  "other",                   c("other")
)

text_long <- imap_dfr(text_cols, function(cols, crs) {
  cols <- intersect(cols, names(raw))
  if (!length(cols)) return(NULL)
  raw |>
    select(researchid, all_of(cols)) |>
    pivot_longer(-researchid, names_to = "text_col", values_to = "text_raw") |>
    filter(!is.na(text_raw), str_trim(text_raw) != "") |>
    mutate(course = crs,
           text = str_squish(str_to_lower(text_raw)),
           text = str_replace_all(text, "\\s*\\+\\s*", " + "),
           text = str_replace_all(text, "l \\+ r", "l+r")) |>
    # R8a: an entry can list several fields separated by commas, e.g.
    # "neck l, neck r, mediastinum": each item is mapped on its own.
    separate_rows(text, sep = ",") |>
    mutate(text = str_squish(text)) |>
    filter(text != "")
})
if (is.null(text_long)) {
  text_long <- tibble(researchid = character(), text_col = character(),
                      text_raw = character(), course = character(), text = character())
}

# Field flags named in the text: one row per patient x course x stem.
text_named <- text_long |>
  inner_join(field_text_map, by = "text") |>
  select(researchid, course, stems) |>
  unnest(stems) |>
  distinct(researchid, course, stem = stems)
text_keys <- paste(text_named$researchid, text_named$course, text_named$stem)

# Courses with any free-text field (mapped or not): RT was given.
text_course_keys <- unique(paste(text_long$researchid, text_long$course))

# Unmapped text values, to add to the mapping table by hand.
text_unmapped <- text_long |>
  anti_join(field_text_map, by = "text") |>
  count(text, sort = TRUE)

# ---- 2. field groups per course --------------------------------------------------

# Each course has the same set of field flags with a suffix: "prim", "fup",
# "fup2" (e.g. mantleprim, mantlefup, mantlefup2). A field group combines the
# left / right / side-unspecified flags of one anatomical region.
courses <- c("prim", "fup", "fup2")

# Field flag for one stem and course, with the free text applied (R8, T1).
col <- function(stem, course) {
  nm <- paste0(stem, course)
  f <- if (nm %in% names(raw)) flag01(raw[[nm]]) else rep(NA_integer_, nrow(raw))
  named <- paste(raw$researchid, course, stem) %in% text_keys
  if (t1_text_rule == "text_overrides") {
    f[named] <- 1L
  } else {
    f[named & is.na(f)] <- 1L
  }
  f
}

field_groups_for <- function(course) {
  c_ <- course
  tibble(
    researchid = raw$researchid,
    course = c_,
    # RT given in this course (0/1/9 -> 0/1/NA)
    rt_given = flag01(raw[[paste0("rt", c_)]]),
    # R8: a free-text field for this course means RT was given.
    rt_given_text = paste(raw$researchid, c_) %in% text_course_keys,
    rt_start = mid_month_date(raw[[paste0("m_rt", c_)]], raw[[paste0("y_rt", c_)]]),
    mantle      = col("mantle", c_),
    invy        = col("invy", c_),       # inverted Y
    invnode     = col("invnode", c_),    # involved node
    abdomen     = col("abdom", c_),      # full abdominal field
    neck        = any01(col("lneck", c_), col("rneck", c_), col("nneck", c_)),
    supraclav   = any01(col("lsupra", c_), col("rsupra", c_), col("nsupra", c_)),
    infraclav   = any01(col("linfra", c_), col("rinfra", c_), col("ninfra", c_)),
    axilla      = any01(col("laxil", c_), col("raxil", c_), col("naxil", c_)),
    mediast_any = any01(col("mediast", c_), col("uppmedias", c_), col("lowmedias", c_)),
    mediast_upp = col("uppmedias", c_),
    mediast_gen = col("mediast", c_),    # "mediastinum", part not specified
    mediast_low = col("lowmedias", c_),
    lung        = any01(col("llung", c_), col("rlung", c_), col("nlung", c_)),
    paraaortic  = col("paraa", c_),
    spleen      = col("spleen", c_),
    splenhil    = col("splenhil", c_),   # splenic hilum
    iliac       = any01(col("liliac", c_), col("riliac", c_), col("niliac", c_)),
    inguinal    = any01(col("lingui", c_), col("ringui", c_), col("ningui", c_)),
    other       = col("other", c_),
    # Derived codes already in the export (codebook):
    #   rtsupra: 0 none, 1 incomplete mantle, 2 full mantle, 9 RT field unknown
    #   rtinfra / rtmid: 0 none, 1 yes, 9 RT field unknown
    rtsupra_code = suppressWarnings(as.integer(raw[[paste0("rtsupra", c_)]])),
    rtinfra_code = suppressWarnings(as.integer(raw[[paste0("rtinfra", c_)]])),
    rtmid_code   = suppressWarnings(as.integer(raw[[paste0("rtmid", c_)]])),
    #   rtneck: 0 none, 1 supraclavicular only, 2 neck, 3 full mantle, 9 unknown
    #   rtmed: 0 none, 1 mediastinal, 9 unknown
    #   rtcat: 0-6 (see section 3b), 9 RT field unknown
    rtneck_code  = suppressWarnings(as.integer(raw[[paste0("rtneck", c_)]])),
    rtmed_code   = suppressWarnings(as.integer(raw[[paste0("rtmed", c_)]])),
    rtcat_code   = suppressWarnings(as.integer(raw[[paste0("rtcat", c_)]]))
  ) |>
    mutate(rt_given = if_else(is.na(rt_given) & rt_given_text, 1L, rt_given))
}

fields <- map_dfr(courses, field_groups_for)

field_group_names <- c("mantle", "invy", "invnode", "abdomen", "neck",
                       "supraclav", "infraclav", "axilla", "mediast_any",
                       "lung", "paraaortic", "spleen", "splenhil", "iliac",
                       "inguinal", "other")

# ---- 3. technique, mediastinal, pelvic, supra/infra --------------------------------

# A course is "not given" when rt_given = 0. When rt_given is unknown but at
# least one field flag is 1, RT was evidently given, so rt_given is set to 1.
fields <- fields |>
  mutate(
    any_field_yes = rowSums(across(all_of(field_group_names), ~ .x == 1L), na.rm = TRUE) > 0,
    rt_given = if_else(is.na(rt_given) & any_field_yes, 1L, rt_given)
  )

regional_groups <- c("neck", "supraclav", "infraclav", "axilla", "mediast_any",
                     "lung", "paraaortic", "spleen", "splenhil", "iliac",
                     "inguinal")

fields <- fields |>
  mutate(
    # R1a: hierarchy by the largest volume given in the course:
    #   extended > regional > involved node.
    # Extended field = mantle, inverted Y, full abdomen, or the derived code
    # "full mantlefield" (rtsupra = 2).
    is_extended = (mantle %in% 1L) | (invy %in% 1L) | (abdomen %in% 1L) |
      (rtsupra_code %in% 2L),
    is_regional = rowSums(across(all_of(regional_groups), ~ .x == 1L), na.rm = TRUE) > 0,
    is_invnode = invnode %in% 1L,
    rt_technique = case_when(
      rt_given %in% 0L ~ "no RT",
      is_extended ~ "mantle / extended field",
      is_regional ~ "regional field (presumed involved field)",
      is_invnode ~ "involved node",
      rt_given %in% 1L ~ "RT, technique unknown", # incl. "other" field only
      TRUE ~ NA_character_ # RT given unknown and no field recorded
    ),
    rt_technique = factor(rt_technique, levels = c(
      "no RT", "mantle / extended field",
      "regional field (presumed involved field)", "involved node",
      "RT, technique unknown"
    )),
    # Double recording check: involved node AND named regional fields.
    invnode_with_regional = is_invnode & is_regional,
    # R1a: mediastinal RT. A mantle field always includes the mediastinum.
    rt_mediastinal = case_when(
      rt_given %in% 0L ~ 0L,
      mediast_any %in% 1L | mantle %in% 1L ~ 1L,
      is.na(mediast_any) | is.na(mantle) ~ NA_integer_,
      TRUE ~ 0L
    ),
    # R3: pelvic RT = inverted Y or iliac field.
    rt_pelvic = case_when(
      rt_given %in% 0L ~ 0L,
      invy %in% 1L | iliac %in% 1L ~ 1L,
      is.na(invy) | is.na(iliac) ~ NA_integer_,
      TRUE ~ 0L
    ),
    # Supra-/infradiaphragmatic RT from the export's derived codes.
    # 9 ("RT, field unknown") -> NA.
    rt_supra = case_when(rt_given %in% 0L ~ 0L,
                         rtsupra_code %in% c(1L, 2L) ~ 1L,
                         rtsupra_code %in% 0L ~ 0L,
                         TRUE ~ NA_integer_),
    rt_infra = case_when(rt_given %in% 0L ~ 0L,
                         rtinfra_code %in% 1L | rtmid_code %in% 1L ~ 1L,
                         rtinfra_code %in% 0L & rtmid_code %in% 0L ~ 0L,
                         TRUE ~ NA_integer_)
  )

# ---- 3b. codebook RT categories, unchanged (R7, parallel classification) -------

# The export's own categories, defined with radiation oncologists, as
# labelled factors. Code 9 ("radiotherapy, but field unknown") is kept as its
# own level, not set to missing; codes outside the codebook -> NA.
cb_factor <- function(x, codes, labels) {
  factor(x, levels = codes, labels = labels)
}
fields <- fields |>
  mutate(
    rt_cat_cb = cb_factor(rtcat_code, c(0:6, 9), c(
      "no RT", "incomplete mantle, supra only",
      "incomplete mantle + infra/mid-body", "full mantle only",
      "full mantle + infra/mid-body", "infra/mid-body only", "other RT",
      "RT, field unknown")),
    rt_supra_cb = cb_factor(rtsupra_code, c(0, 1, 2, 9), c(
      "none", "incomplete mantle", "full mantle", "RT, field unknown")),
    rt_mid_cb = cb_factor(rtmid_code, c(0, 1, 9), c(
      "none", "mid-body (para-aortic/spleen)", "RT, field unknown")),
    rt_infra_cb = cb_factor(rtinfra_code, c(0, 1, 9), c(
      "none", "infradiaphragmatic", "RT, field unknown")),
    rt_neck_cb = cb_factor(rtneck_code, c(0, 1, 2, 3, 9), c(
      "none", "supraclavicular only", "neck", "full mantle", "RT, field unknown")),
    rt_med_cb = cb_factor(rtmed_code, c(0, 1, 9), c(
      "none", "mediastinal", "RT, field unknown"))
  )

# ---- 4. field-to-organ mapping (R2, DRAFT pending Berthe's approval) -----------

# One row per SMN site group. in_field / bordering list the field groups from
# section 2. This is the table in docs/proposal_exposure-definitions.md,
# section 1, written out field by field. Notes for the review:
#   - "mediastinum (any)" = generic, upper or lower mediastinum field.
#   - Thyroid "bordering" uses the upper mediastinum; a mediastinum field of
#     unspecified extent (mediast_gen) is also counted as bordering, because
#     it normally includes the upper mediastinum.
#   - Stomach and pancreas "bordering" use the LOWER mediastinum only (cardia /
#     upper abdomen), as in the table.
#   - Leukaemia/MDS, NHL, sarcoma, melanoma and skin are not organ-specific
#     here (any RT / RT volume); sarcoma and skin will be matched to fields by
#     tumour topography in the outcome script (R2).
organ_map <- tribble(
  ~site,          ~in_field,                                                         ~bordering,
  "breast",       c("mantle", "axilla", "mediast_any", "infraclav", "lung"),        c("neck", "supraclav"),
  "lung",         c("mantle", "mediast_any", "lung", "axilla", "infraclav"),        c("supraclav", "neck"),
  "thyroid",      c("neck", "supraclav", "mantle"),                                 c("mediast_upp", "mediast_gen"),
  "oesophagus",   c("mediast_any", "mantle"),                                       c("neck", "supraclav", "paraaortic", "spleen"),
  "stomach",      c("paraaortic", "spleen", "splenhil", "invy", "abdomen"),         c("mediast_low", "mantle"),
  "pancreas",     c("paraaortic", "spleen", "splenhil", "invy", "abdomen"),         c("mediast_low"),
  "colorectum",   c("invy", "paraaortic", "iliac", "inguinal", "abdomen"),          c("spleen"),
  "pelvic_organs",c("invy", "iliac", "inguinal", "abdomen"),                        c("paraaortic"), # bladder, prostate, cervix
  "head_neck",    c("neck", "mantle"),                                              c("supraclav")
)

# Organ exposure for one site and one course:
#   no RT in the course                       -> 0
#   any in-field group = 1                    -> 2
#   else any bordering group = 1              -> 1
#   else any relevant group unknown, or RT given but technique unknown -> NA
#   else                                      -> 0
organ_exposure <- function(df, in_field, bordering) {
  in_yes  <- rowSums(as.matrix(df[in_field]) == 1L, na.rm = TRUE) > 0
  bd_yes  <- rowSums(as.matrix(df[bordering]) == 1L, na.rm = TRUE) > 0
  any_unk <- rowSums(is.na(as.matrix(df[c(in_field, bordering)]))) > 0
  case_when(
    df$rt_given %in% 0L ~ 0L,
    in_yes ~ 2L,
    bd_yes ~ 1L,
    any_unk ~ NA_integer_,
    df$rt_technique %in% "RT, technique unknown" ~ NA_integer_,
    is.na(df$rt_given) ~ NA_integer_,
    TRUE ~ 0L
  )
}

rt_organ <- pmap_dfr(organ_map, function(site, in_field, bordering) {
  fields |>
    transmute(researchid, course, rt_start, site = site,
              organ_exposure = organ_exposure(fields, in_field, bordering))
})

# ---- 5. checks (printed; nothing is changed here) -------------------------------

cat("\n== RT given per course (0/1/NA) ==\n")
print(count(fields, course, rt_given))

cat("\n== RT technique per course ==\n")
print(count(fields, course, rt_technique))

cat("\n== Involved node recorded together with named regional fields ==\n")
print(count(fields, course, invnode_with_regional))

cat("\n== Technique vs the export's derived codes (primary course) ==\n")
print(count(filter(fields, course == "prim"), rt_technique, rtsupra_code))

cat("\n== Free-text field names (R8) ==\n")
cat("free-text entries:", nrow(text_long), "| mapped:",
    nrow(semi_join(text_long, field_text_map, by = "text")), "\n")
cat("Unmapped values (add to field_text_map by hand):\n")
print(text_unmapped, n = Inf)
# Disagreement: text names a field whose flag is recorded as 0 (T1).
recorded_flag <- function(id, crs, stem) {
  nm <- paste0(stem, crs)
  if (!nm %in% names(raw)) return(NA_integer_)
  flag01(raw[[nm]][match(id, raw$researchid)])
}
text_disagree <- text_named |>
  mutate(flag_recorded = unlist(pmap(list(researchid, course, stem), recorded_flag)) %||%
           integer(0))
cat("Text-named fields whose flag is: 1 =", sum(text_disagree$flag_recorded %in% 1L),
    "| unknown (set to 1, T1) =", sum(is.na(text_disagree$flag_recorded)),
    "| 0 (overridden to 1, T1) =", sum(text_disagree$flag_recorded %in% 0L), "\n")

cat("\n== Codebook category (rt_cat_cb) vs field-flag technique, primary course (R7) ==\n")
print(count(filter(fields, course == "prim"), rt_cat_cb, rt_technique), n = Inf)

cat("\n== Organ exposure, primary course ==\n")
print(
  rt_organ |>
    filter(course == "prim") |>
    count(site, organ_exposure) |>
    pivot_wider(names_from = organ_exposure, values_from = n,
                names_prefix = "exp_", values_fill = 0)
)

# ---- 6. diagnosis era (R6) -------------------------------------------------------

diag <- tibble(
  researchid = raw$researchid,
  zkh = raw$zkh, # hospital
  y_diagnose = suppressWarnings(as.integer(ifelse(raw$y_diagnose %in% unknown_text,
                                                  NA, raw$y_diagnose)))
) |>
  mutate(era = cut(y_diagnose, c(-Inf, 1988, 1994, 2004, Inf),
                   labels = c("before 1989", "1989-1994", "1995-2004", "2005-latest")))

# ---- 7. description of recorded RT doses (R5; descriptive only) -----------------

# Total prescribed dose (Gy) per course, and doses per field (primary and
# second follow-up courses have field-level doses; the first follow-up course
# has the total only). Non-numeric values -> NA.
num <- function(x) suppressWarnings(as.numeric(ifelse(x %in% unknown_text, NA, x)))
dose <- bind_rows(
  tibble(researchid = raw$researchid, course = "prim",
         dose_total = num(raw$rtprim_dosistot),
         boost_total = num(raw$rtprim_surdos_dosistot),
         n_field_doses = rowSums(!is.na(sapply(paste0("rtprim_dose", 1:5),
                                               function(v) num(raw[[v]]))))),
  tibble(researchid = raw$researchid, course = "fup",
         dose_total = num(raw$rtfup_dosistot),
         boost_total = num(raw$rtfup_surdos_dosistot),
         n_field_doses = 0),
  tibble(researchid = raw$researchid, course = "fup2",
         dose_total = num(raw$rtfup2_dosistot),
         boost_total = num(raw$rtfup2_surdos_dosistot),
         n_field_doses = rowSums(!is.na(sapply(paste0("rtfup2_dose", 1:3),
                                               function(v) num(raw[[v]])))))
)

dose_desc_input <- fields |>
  select(researchid, course, rt_given, rt_technique) |>
  left_join(dose, by = c("researchid", "course")) |>
  left_join(diag, by = "researchid") |>
  filter(rt_given %in% 1L)

# Table A: prescribed total dose by RT technique and era (primary course).
# Shows whether the dose fell over time and by technique as expected (e.g.
# 36-40 Gy extended field early; 20-30 Gy involved field / node later).
dose_by_technique_era <- dose_desc_input |>
  filter(course == "prim") |>
  group_by(rt_technique, era) |>
  summarise(
    n_rt = n(),
    n_dose_recorded = sum(!is.na(dose_total)),
    pct_recorded = round(100 * n_dose_recorded / n_rt, 1),
    dose_median = median(dose_total, na.rm = TRUE),
    dose_q1 = quantile(dose_total, 0.25, na.rm = TRUE, names = FALSE),
    dose_q3 = quantile(dose_total, 0.75, na.rm = TRUE, names = FALSE),
    dose_min = suppressWarnings(min(dose_total, na.rm = TRUE)),
    dose_max = suppressWarnings(max(dose_total, na.rm = TRUE)),
    n_boost = sum(!is.na(boost_total)),
    .groups = "drop"
  ) |>
  mutate(across(c(dose_min, dose_max), ~ if_else(is.finite(.x), .x, NA_real_)))

# Table B: completeness of dose recording by era and by hospital (primary
# course). If recording depends strongly on hospital or era, the patients
# with a recorded dose are not representative (proposal, use 2).
dose_completeness_era <- dose_desc_input |>
  filter(course == "prim") |>
  group_by(era) |>
  summarise(n_rt = n(), n_dose_recorded = sum(!is.na(dose_total)),
            pct_recorded = round(100 * n_dose_recorded / n_rt, 1),
            .groups = "drop")
dose_completeness_hosp <- dose_desc_input |>
  filter(course == "prim") |>
  group_by(zkh) |>
  summarise(n_rt = n(), n_dose_recorded = sum(!is.na(dose_total)),
            pct_recorded = round(100 * n_dose_recorded / n_rt, 1),
            .groups = "drop") |>
  arrange(desc(pct_recorded))

# Table C: the free-text field names that go with the field-level doses
# (rtprim_field1-5), tabulated so they can be mapped to field types later if
# the prescribed dose is ever used (R4). Free text: counts only.
field_text <- raw |>
  select(researchid, starts_with("rtprim_field")) |>
  pivot_longer(-researchid, values_to = "field_text") |>
  filter(!is.na(field_text)) |>
  count(field_text, sort = TRUE)

cat("\n== Table A: prescribed total dose (Gy) by RT technique and era, primary course ==\n")
print(dose_by_technique_era, n = Inf, width = Inf)
cat("\n== Table B1: dose recording by era ==\n")
print(dose_completeness_era)
cat("\n== Table B2: dose recording by hospital ==\n")
print(dose_completeness_hosp, n = Inf)
cat("\n== Table C: free-text field names with field-level doses ==\n")
print(field_text, n = 30)

# ---- 8. save ----------------------------------------------------------------------

saveRDS(
  fields |> select(researchid, course, rt_given, rt_start, all_of(field_group_names),
                   mediast_upp, mediast_gen, mediast_low, rt_technique,
                   invnode_with_regional, rt_mediastinal, rt_pelvic, rt_supra, rt_infra,
                   rt_cat_cb, rt_supra_cb, rt_mid_cb, rt_infra_cb, rt_neck_cb, rt_med_cb,
                   rtcat_code, rtsupra_code, rtmid_code, rtinfra_code, rtneck_code, rtmed_code),
  file.path(out_dir, "rt_fields_course.Rds")
)
saveRDS(rt_organ, file.path(out_dir, "rt_organ_course.Rds"))
saveRDS(
  list(by_technique_era = dose_by_technique_era,
       completeness_era = dose_completeness_era,
       completeness_hospital = dose_completeness_hosp,
       field_text = field_text,
       field_text_unmapped = text_unmapped),
  file.path(out_dir, "rt_dose_description.Rds")
)
