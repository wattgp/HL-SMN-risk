# 01_clean-data.R
# Reads the raw ResearchDB export, applies basic cleaning (missing-value codes,
# names), derives dates, SMN outcomes and competing-risk follow-up variables,
# restricts to the analytic cohort, and saves the derived datasets to
# secure_data/intermediate/. The raw export is never modified.
#
# Run from the project (Watt-HL-SMN.Rproj):  source(here::here("scripts", "01_clean-data.R"))
# Then render scripts/SMN-risk.qmd, which reads the derived data only.

library(tidyverse)
library(janitor)
library(lubridate)
library(stringr)

library(here)
here::i_am("scripts/01_clean-data.R")

# ---- read raw data ----------------------------------------------------------

dta0 <- readr::read_csv(
  here("secure_data", "2024-12-12", "ResearchDB_Export_from-Power-BI.csv"),
  locale = locale(decimal_mark = ".", grouping_mark = ","),
  col_names = TRUE
)

dta1 <- dta0 %>% mutate_if(
  is.logical, as.character
)

# readr::problems(dta1) # no more problems

# skimr::skim(dta1)

# 97 are missing d_livedead

# naniar::miss_var_summary(dta1)

# 100% missing for c6ctprim (6th cycle primary chemo), etc.

# janitor::get_dupes(dta1, ResearchID) # none

# normalize headers

basic_input_clean <- dta1 %>%
  janitor::clean_names() %>%
  mutate(
    #    across(                   # 777 indicates "other" chemotherapy and
    #      where(is.character),    # must be dealt with separately
    #      ~ na_if(., c("777")
    #      )
    #    ),
    across(
      where(is.character),
      ~ na_if(., "888")
    ),
    across(
      where(is.character),
      ~ na_if(., "999")
    ),
    across(
      where(is.character),
      ~ na_if(., "")
    ),
    across(
      where(is.double),
      ~ na_if(., 777)
    ),
    across(
      where(is.double),
      ~ na_if(., 888)
    ),
    across(
      where(is.double),
      ~ na_if(., 99)
    ),
    across(
      where(is.double),
      ~ na_if(., 999)
    ),
    across(
      where(is.double),
      ~ na_if(., 9999)
    ),
    across(
      where(is.double),
      ~ na_if(., 9998)
    )
  ) ## make sure the chemotherapy variables are the correct class


if (interactive()) {
  View(basic_input_clean[, grepl("/^777$/", basic_input_clean)]) # none left
}
# View(dta2[,grepl("/^888$/",dta2)]) # none left
# View(dta2[,grepl("/^999$/",dta2)]) # none left
# View(dta2[,grepl(" ",dta2)]) # none left

saveRDS(basic_input_clean, here::here("secure_data", "intermediate", "full_dataset_basic_cleaning.Rds"))

# ---- prepare outcome variables ----------------------------------------------

# dictionary for 2nd cancer sites

smn_morphs <- unique(c(
  unique(dta0$smn1_morph), unique(dta0$smn2_morph),
  unique(dta0$smn3_morph), unique(dta0$smn4_morph),
  unique(dta0$smn5_morph), unique(dta0$smn6_morph),
  unique(dta0$smn7_morph)
))
# write.csv(smn_morphs, here("output","intermediate-files","smn_morphs_list.csv"), row.names = F)

dta3 <- basic_input_clean %>%
  mutate(
    # recode y_livedead 9999 and 9998 as na
    # note - y_lcontact is the most recent date to which SMN would be known. So
    # censoring should happen no later than that date.
  ) %>%
  tidyr::unite(
    # create date variables

    dob, c(d_birth, m_birth, y_birth),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    ddx, c(d_diagnose, m_diagnose, y_diagnose),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn1, c(d_smn1, m_smn1, y_smn1),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn2, c(d_smn2, m_smn2, y_smn2),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn3, c(d_smn3, m_smn3, y_smn3),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn4, c(d_smn4, m_smn4, y_smn4),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn5, c(d_smn5, m_smn5, y_smn5),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn6, c(d_smn6, m_smn6, y_smn6),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_smn7, c(d_smn7, m_smn7, y_smn7),
    sep = "-", remove = F
  ) %>%
  mutate(
    dob = lubridate::parse_date_time(dob, "dmy"),
    ddx = lubridate::parse_date_time(ddx, "dmy"),
    date_smn1 = lubridate::parse_date_time(d0_smn1, "dmy"),
    date_smn2 = lubridate::parse_date_time(d0_smn2, "dmy"),
    date_smn3 = lubridate::parse_date_time(d0_smn3, "dmy"),
    date_smn4 = lubridate::parse_date_time(d0_smn4, "dmy"),
    date_smn5 = lubridate::parse_date_time(d0_smn5, "dmy"),
    date_smn6 = lubridate::parse_date_time(d0_smn6, "dmy"),
    date_smn7 = lubridate::parse_date_time(d0_smn7, "dmy"),

    # age

    age_dx = as.numeric(ddx - dob) / 365.25,

    # indicator for malignant only

    smn1_mal = ifelse(smn1_behav %in% c(3, 6, 9), 1, 0),
    smn2_mal = ifelse(smn2_behav %in% c(3, 6, 9), 1, 0),
    smn3_mal = ifelse(smn3_behav %in% c(3, 6, 9), 1, 0),
    smn4_mal = ifelse(smn4_behav %in% c(3, 6, 9), 1, 0),
    smn5_mal = ifelse(smn5_behav %in% c(3, 6, 9), 1, 0),
    smn6_mal = ifelse(smn6_behav %in% c(3, 6, 9), 1, 0),
    smn7_mal = ifelse(smn7_behav %in% c(3, 6, 9), 1, 0),

    # date of first malignant smn

    date_1st_inv = case_when(
      smn1_mal == 1 ~ date_smn1,
      smn1_mal == 0 & smn2_mal == 1 ~ date_smn2,
      smn1_mal == 0 & smn2_mal == 0 &
        smn3_mal == 1 ~ date_smn3,
      smn1_mal == 0 & smn2_mal == 0 &
        smn3_mal == 0 & smn4_mal == 1 ~ date_smn4,
      smn1_mal == 0 & smn2_mal == 0 &
        smn3_mal == 0 & smn4_mal == 0 &
        smn5_mal == 1 ~ date_smn5,
      smn1_mal == 0 & smn2_mal == 0 &
        smn3_mal == 0 & smn4_mal == 0 &
        smn5_mal == 0 & smn6_mal == 1 ~ date_smn6,
      smn1_mal == 0 & smn2_mal == 0 &
        smn3_mal == 0 & smn4_mal == 0 &
        smn5_mal == 0 & smn6_mal == 0 &
        smn7_mal == 1 ~ date_smn7
    ),

    # categories for SMN site

    # first, make numeric vars
    across(
      .cols = contains("_site"),
      .fns = ~ as.numeric(stringr::str_remove(., "C")),
      .names = "{.col}_num"
    ),
    # then label them
    across(
      .cols = contains("_num"),
      .fns = ~ case_when(
        (. < 150) | (. >= 300 & . < 338) | (. == 760) ~ "Head and neck",
        . == 15 | (. >= 150 & . < 160) | (. == 339) ~ "Esophagus/Trachea",
        (. >= 160 & . < 220) | (. >= 480 & . < 490) | . == 762 ~ "Gastrointestinal tract",
        . == 22 | (. >= 220 & . < 250) ~ "Liver/IHD/Biliary tract",
        . == 34 | (. >= 340 & . < 349) ~ "Lung/Bronchus",
        (. >= 379 & . < 399) | . == 761 ~ "Other intrathoracic",
        (. >= 410 & . < 419) | (. >= 490 & . < 500) ~ "Sarcoma",
        . == 77 | (. >= 770 & . < 800) ~ "Lymphoma",
        . == 42 | (. >= 420 & . < 424) ~ "Hematological",
        (. == 421) ~ "Hodgkin",
        . == 44 | (. >= 440 & . < 470) ~ "Skin",
        . == 72 | (. >= 470 & . < 479) | (. >= 690 & . <= 729) ~ "Brain and Nervous System", # including 1 choroid (eye) cancer
        . == 50 | (. >= 500 & . < 510) ~ "Breast",
        (. >= 510 & . <= 529) | (. == 579) ~ "Vulva/vagina",
        . == 53 | (. >= 530 & . < 540) ~ "Cervix",
        . == 54 | (. >= 540 & . < 560) ~ "Uterus",
        (. >= 569 & . <= 570) | (. == 589) ~ "Ovary/Fallopian tube", # note includes 1 placenta
        . == 619 ~ "Prostate",
        . == 62 | (. >= 60 & . < 619) | (. >= 620 & . < 639) ~ "Other male genital",
        . > 640 & . < 690 ~ "Urinary tract", # including kidney
        . == 73 | (. >= 730 & . < 740) ~ "Thyroid",
        (. >= 740 & . < 760) ~ "Other endocrine",
        # no cases for 762 769 (other undefined)
        #*
        #*
        #*
      ),
      .names = "{col}_sitename"
    ),
    site_1st_inv = case_when(
      is.na(date_1st_inv) ~ NA_character_,
      date_1st_inv == date_smn1 ~ smn1_site_num_sitename,
      date_1st_inv == date_smn2 ~ smn2_site_num_sitename,
      date_1st_inv == date_smn3 ~ smn3_site_num_sitename,
      date_1st_inv == date_smn4 ~ smn4_site_num_sitename,
      date_1st_inv == date_smn5 ~ smn5_site_num_sitename,
      date_1st_inv == date_smn6 ~ smn6_site_num_sitename,
      date_1st_inv == date_smn7 ~ smn7_site_num_sitename
    ),

    # primary cancer groupings
    # - if needed, later
  )

# create time to event variables

dta4 <- dta3 %>%
  # Note 1: time to first INVASIVE cancer; do not censor at in situ; death as competing risk; censor at other
  # Note 2: Follow-up time *starts* 5 years after diagnosis


  tidyr::unite(
    d0_lc, c(d_lcontact, m_lcontact, y_lcontact),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_livedead, c(d_livedead, m_livedead, y_livedead),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_chemo_start, c(d_ctprim, m_ctprim, y_ctprim),
    sep = "-", remove = F
  ) %>%
  tidyr::unite(
    d0_rt_start, c(d_rtprim, m_rtprim, y_rtprim),
    sep = "-", remove = F
  ) %>%
  mutate(
    date_lc = lubridate::parse_date_time(d0_lc, "dmy"),
    date_livedead = lubridate::parse_date_time(d0_livedead, "dmy"),
    date_chemo_start = lubridate::parse_date_time(d0_chemo_start, "dmy"),
    date_rt_start = lubridate::parse_date_time(d0_rt_start, "dmy"),
    # find minimum of invasive, death, or lfy
    # 1st, calcuate time to invasive SMN, if any

    rx_start = pmin(date_chemo_start, date_rt_start, na.rm = T), # 520 missing both
    # use ddx instead

    fup_start = ddx %m+% years(5), # NOTE!!! add 5 years to ddx to start follow-up

    # TODO: check units -- /86400 assumes the difference is in seconds, but
    # date-time differences are usually in days; ftime_breast below divides by
    # 365.25 only. See README 'Open issues'.
    ftime_inv_smn = as.numeric(date_1st_inv - fup_start) / 86400 / 365.25, # ouptut in seconds so divid by secs in day then days in year
    # note: NA if no SMN

    # latest follow-up Date

    date_max_fu = pmax(date_livedead, date_lc, date_1st_inv, na.rm = T),

    # 2nd, calculate time to death, if deceased

    livedead_rec = case_when(
      livedead == 0 ~ 0,
      livedead == 1 ~ 1,
      livedead == 2 ~ 1, # recoded `moved abroad' as `alive'
      livedead == 99 ~ NA_real_
    ),
    ftime_livedead = as.numeric(date_livedead - fup_start) / 365.25 / 86400, # output in seconds so divide by days in year and seconds in day

    # 3rd, calculate time to last contact

    ftime_lc = as.numeric(date_lc - fup_start) / 365.25 / 86400,

    # calculate longest follow-up time (really only for tbl1)

    ftime_max = as.numeric(date_max_fu - fup_start) / 365.25 / 86400,

    # 4th, bring it all together,

    cmpr_inv = case_when(
      # group A - both dead and SMN

      !is.na(ftime_inv_smn) & livedead_rec == 1 & (ftime_inv_smn <= ftime_livedead) ~ 1, # event
      !is.na(ftime_inv_smn) & livedead_rec == 1 & (ftime_inv_smn > ftime_livedead) ~ 2, # CR

      # group B - SMN but alive

      !is.na(ftime_inv_smn) & livedead_rec == 0 ~ 1, # event

      # group C - SMN but vital status unknown

      !is.na(ftime_inv_smn) & is.na(livedead_rec) == 1 ~ 1, # event

      # group D - no SMN and dead

      is.na(ftime_inv_smn) & livedead_rec == 1 & date_livedead <= date_lc ~ 2, # CR
      is.na(ftime_inv_smn) & livedead_rec == 1 & date_livedead > date_lc ~ 0, # censored before death

      # group E, no SMN, no death

      is.na(ftime_inv_smn) & livedead_rec == 0 ~ 0, # censor (at last follow-up; next var)

      # group F, both missing

      is.na(ftime_inv_smn) & is.na(livedead_rec) ~ NA_real_,
    ),
    ftime_cmpr_inv = case_when(
      cmpr_inv == 1 ~ ftime_inv_smn,
      cmpr_inv == 2 ~ ftime_livedead,
      cmpr_inv == 0 ~ pmin(ftime_livedead, ftime_lc)
    ),

    # exclude 139 that have missing l_contact

    ###
    # create competing risks variable for time to first SMN (any)
    ###

    # find minimum of SMN( invasive or in situ), death, or lfy
    # 1st, calcuate time to invasive SMN, if any

    ftime_any_smn = as.numeric(date_smn1 - fup_start) / 86400 / 365.25,

    # 2nd, calculate time to death, if deceased

    # ftime_vital = as.numeric(d_livedead - ddx)/86400/365.25,

    # 3rd, calculate time to last contact

    # ftime_lc = as.numeric(d_lc - ddx)/86400/365.25,

    # 4th, bring it all together,

    cmpr_any = case_when(
      # group A - both dead and SMN
      !is.na(ftime_any_smn) & livedead_rec == 1 & (ftime_any_smn <= ftime_livedead) ~ 1, # event
      !is.na(ftime_any_smn) & livedead_rec == 1 & (ftime_any_smn > ftime_livedead) ~ 2, # CR

      # group B - SMN but alive

      !is.na(ftime_any_smn) & livedead_rec == 0 ~ 1, # event

      # group C - SMN but vital status unknown

      !is.na(ftime_any_smn) & is.na(livedead_rec) == 1 ~ 1, # event

      # group D - no SMN and dead

      is.na(ftime_any_smn) & livedead_rec == 1 & date_livedead <= date_lc ~ 2, # CR
      is.na(ftime_any_smn) & livedead_rec == 1 & date_livedead > date_lc ~ 0, # censored before death

      # group E, no SMN, no death

      is.na(ftime_any_smn) & livedead_rec == 0 ~ 0, # censor (at last follow-up; next var)

      # group F, both missing

      is.na(ftime_any_smn) & is.na(livedead_rec) ~ NA_real_,
    ),
    ftime_cmpr_any = case_when(
      cmpr_any == 1 ~ ftime_any_smn,
      cmpr_any == 2 ~ ftime_livedead,
      cmpr_any == 0 ~ pmin(ftime_livedead, ftime_lc)
    ),

    ###
    # create competing risks variable for time to FIRST BREAST CANCER
    ###

    # do not censor at other invasive; simply adjust for in model

    # find minimum of breast cancer, death, or lfy

    # indicator for breast or no

    breast_1st_inv_ind = case_when(
      site_1st_inv == "Breast" ~ 1,
      site_1st_inv != "Breast" ~ 0 # includes na
    ),
    date_breast_1st_inv = case_when(
      breast_1st_inv_ind == 1 ~ date_1st_inv,
      breast_1st_inv_ind != 0 ~ NA_POSIXct_
    ),

    # adjustment variable for nonbreast
    # analysis A: adjust for dx of other cancer
    # analysis B: censor at diagnosis of non-breast inv. (primary analysis)

    nonbreast_1st_inv_ind = case_when(
      site_1st_inv != "Breast" & !is.na(site_1st_inv) ~ 1, # nonbreast
      site_1st_inv == "Breast" | is.na(site_1st_inv) ~ 0 # other, inc. na
    ),
    ftime_breast = as.numeric(date_breast_1st_inv - fup_start) / 365.25,

    # 2nd, calculate time to death, if deceased

    livedead_rec = case_when(
      livedead == 0 ~ 0,
      livedead == 1 ~ 1,
      livedead == 2 ~ 1,
      livedead == 99 ~ NA_real_
    ),

    # 3rd, calculate time to last contact

    # 4th, bring it all together,

    cmpr_breast = case_when( # factor for censor/event/cr

      # group A - both dead and breast SMN
      !is.na(ftime_breast) & livedead_rec == 1 & (ftime_breast <= ftime_livedead) ~ 1, # event
      !is.na(ftime_breast) & livedead_rec == 1 & (ftime_breast > ftime_livedead) ~ 2, # CR

      # group B - SMN but alive

      !is.na(ftime_breast) & livedead_rec == 0 ~ 1, # event

      # group C - SMN but vital status unknown

      !is.na(ftime_breast) & is.na(livedead_rec) == 1 ~ 1, # event

      # group D - no SMN and dead

      is.na(ftime_breast) & livedead_rec == 1 & date_livedead <= date_lc ~ 2, # CR
      is.na(ftime_breast) & livedead_rec == 1 & date_livedead > date_lc ~ 0, # censored before death (last contact was before death)

      # group E, no SMN, no death

      is.na(ftime_breast) & livedead_rec == 0 ~ 0, # censor (at last follow-up; next var)

      # group F, both missing

      is.na(ftime_breast) & is.na(livedead_rec) ~ NA_real_,
    ),
    ftime_cmpr_breast = case_when(
      cmpr_breast == 1 ~ ftime_breast,
      cmpr_breast == 2 ~ ftime_livedead,
      cmpr_breast == 0 ~ pmin(ftime_livedead, ftime_lc)
    ),

    ##### Prostate

    # indicator for prostate or no

    prostate_1st_inv_ind = case_when(
      site_1st_inv == "Prostate" ~ 1,
      site_1st_inv != "Prostate" | is.na(site_1st_inv) ~ 0
    ),
    date_prostate_1st_inv = case_when(
      prostate_1st_inv_ind == 1 ~ date_1st_inv,
      prostate_1st_inv_ind != 0 ~ NA_Date_
    ),

    # adjustment variable for nonbreast

    nonprostate_1st_inv_ind = case_when(
      site_1st_inv != "Prostate" & !is.na(site_1st_inv) ~ 1, # nonprostate
      site_1st_inv == "Prostate" | is.na(site_1st_inv) ~ 0 # other, inc. na
    ),
    ftime_prostate = as.numeric(date_prostate_1st_inv - fup_start) / 86400 / 365.25,

    # 2nd, calculate time to death, if deceased

    # 3rd, calculate time to last contact


    # 4th, bring it all together,

    cmpr_prostate = case_when( # factor for censor/event/cr

      # group A - both dead and breast SMN
      !is.na(ftime_prostate) & livedead_rec == 1 & (ftime_prostate <= ftime_livedead) ~ 1, # event
      !is.na(ftime_prostate) & livedead_rec == 1 & (ftime_prostate > ftime_livedead) ~ 2, # CR

      # group B - SMN but alive

      !is.na(ftime_prostate) & livedead_rec == 0 ~ 1, # event

      # group C - SMN but vital status unknown

      !is.na(ftime_prostate) & is.na(livedead_rec) == 1 ~ 1, # event

      # group D - no SMN and dead

      is.na(ftime_prostate) & livedead_rec == 1 & date_livedead <= date_lc ~ 2, # CR
      is.na(ftime_prostate) & livedead_rec == 1 & date_livedead > date_lc ~ 0, # censored before death (last contact was before death)

      # group E, no SMN, no death

      is.na(ftime_prostate) & livedead_rec == 0 ~ 0, # censor (at last follow-up; next var)

      # group F, both missing

      is.na(ftime_prostate) & is.na(livedead_rec) ~ NA_real_,
    ),
    ftime_cmpr_prostate = case_when(
      cmpr_prostate == 1 ~ ftime_prostate,
      cmpr_prostate == 2 ~ ftime_livedead,
      cmpr_prostate == 0 ~ pmin(ftime_livedead, ftime_lc)
    ),


    # any smn

    any_smn = ifelse(!is.na(smn1_site), 1, 0),

    # any invasive smn

    any_inv_smn = ifelse(
      smn1_mal == 1 | smn2_mal == 1 | smn3_mal == 1 | smn4_mal == 1 | smn5_mal == 1 |
        smn6_mal == 1 | smn7_mal == 1, 1, 0
    ),


    # number of invasive and any SMNs

    sumind_smn1 = ifelse(as.numeric(date_smn1) >= as.numeric(fup_start), 1, 0),
    sumind_smn2 = ifelse(as.numeric(date_smn2) >= as.numeric(fup_start), 1, 0),
    sumind_smn3 = ifelse(as.numeric(date_smn3) >= as.numeric(fup_start), 1, 0),
    sumind_smn4 = ifelse(as.numeric(date_smn4) >= as.numeric(fup_start), 1, 0),
    sumind_smn5 = ifelse(as.numeric(date_smn5) >= as.numeric(fup_start), 1, 0),
    sumind_smn6 = ifelse(as.numeric(date_smn6) >= as.numeric(fup_start), 1, 0),
    sumind_smn7 = ifelse(as.numeric(date_smn7) >= as.numeric(fup_start), 1, 0),
    # indicator for any smn (invasive or not)
    any_smn = ifelse(sumind_smn1 == 1 | sumind_smn2 == 1 | sumind_smn3 == 1 | sumind_smn4 == 1 | sumind_smn5 == 1 | sumind_smn6 == 1 | sumind_smn7 == 1, 1, 0),
    # sum of smns
    num_smn = rowSums(
      cbind(
        sumind_smn1, sumind_smn2, sumind_smn3, sumind_smn4, sumind_smn5,
        sumind_smn6, sumind_smn7
      ),
      na.rm = T
    ),
    ###  2024-11-13
    # now do the same conditional on inv
    ####
    sumind_inv_smn1 = ifelse(smn1_mal == 1 & (as.numeric(date_smn1) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn2 = ifelse(smn2_mal == 1 & (as.numeric(date_smn2) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn3 = ifelse(smn3_mal == 1 & (as.numeric(date_smn3) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn4 = ifelse(smn4_mal == 1 & (as.numeric(date_smn4) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn5 = ifelse(smn5_mal == 1 & (as.numeric(date_smn5) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn6 = ifelse(smn6_mal == 1 & (as.numeric(date_smn6) >= as.numeric(fup_start)), 1, 0),
    sumind_inv_smn7 = ifelse(smn7_mal == 1 & (as.numeric(date_smn7) >= as.numeric(fup_start)), 1, 0),
    # indicator for any invasive smn
    any_inv_smn = ifelse(sumind_inv_smn1 == 1 | sumind_inv_smn2 == 1 | sumind_inv_smn3 == 1 | sumind_inv_smn4 == 1 | sumind_inv_smn5 == 1 | sumind_inv_smn6 == 1 | sumind_inv_smn7 == 1, 1, 0),
    # sum of invasive smns
    num_inv_smn = rowSums(
      cbind(
        sumind_inv_smn1, sumind_inv_smn2, sumind_inv_smn3, sumind_inv_smn4, sumind_inv_smn5,
        sumind_inv_smn6, sumind_inv_smn7
      ),
      na.rm = T
    ),

    # other variables
    smk_evr_rec = case_when(
      smoke_ever == 0 ~ 0,
      smoke_ever == 1 ~ 1,
      smoke_ever == 99 ~ NA_real_
    )
  )


# write.csv(neg_fut, "./output/to-check_smn_date.csv", quote = F, na = "", row.names = F)


# subset to 1989 and later
# filter out those that had smn before fup_start
dta5 <- dta4 %>% filter(
  y_diagnose >= 1989,
  ftime_cmpr_inv > 0,
  age_dx >= 15 & age_dx <= 50 # as per NEJM paper, limit age
)

dtaf <- dta5

# check follow-up variables by eye (interactive sessions only)
if (interactive()) {
  View(
    dtaf %>% select(
      c(
        fup_start,
        date_livedead,
        date_1st_inv,
        date_lc,
        date_smn1,
        date_max_fu,
        ftime_livedead,
        ftime_lc,
        ftime_inv_smn,
        ftime_cmpr_inv,
        ftime_max,
        cmpr_inv,
        cmpr_breast,
        ftime_breast,
        cmpr_prostate,
        ftime_prostate
      )
    )
  )
}

# ---- save derived datasets --------------------------------------------------

saveRDS(dta4, here::here("secure_data", "intermediate", "full_dataset_derived.Rds")) # all patients
saveRDS(dtaf, here::here("secure_data", "intermediate", "analytic_cohort.Rds")) # 1989+, age 15-50, at risk at fup_start

message("Saved ", nrow(dta4), " rows (all patients) and ", nrow(dtaf), " rows (analytic cohort) to secure_data/intermediate/")
