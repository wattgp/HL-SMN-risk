# make_dummy_dataset.R
# Builds a synthetic version of the ResearchDB export with realistic values: same
# column names, column types and format (semicolon-delimited) as the Power BI
# export, but every row is generated at random. Use it to develop and test code
# (e.g. scripts/01_clean-data.R) without touching patient data.
#
# How values are generated, and what is (not) taken from the real data:
# - Coded columns (sex, behaviour, treatment flags, missing codes 99/888/...):
#   drawn from codes that occur in at least k_min patients, with rounded
#   proportions. Rare codes are never used.
# - Continuous columns: drawn from the 5th-95th percentile range (interpolated,
#   so no extreme or exact individual values are reproduced).
# - Text columns: common categories only (>= k_min patients); rare/free text is
#   replaced by generic placeholders or random characters in a common pattern.
# - Dates (d_/m_/y_ columns): generated per patient so they are consistent:
#   birth -> diagnosis (age 15-60) -> treatment -> SMN1..7 -> last contact/death.
#   SMN columns are only filled for patients who have that SMN.
# - Missingness: each column's share of blanks, rounded to 5%.
# No row of the dummy file corresponds to a real patient, and the row count is
# fixed (n_rows), not taken from the real export.
#
# Reads secure_data/ResearchDB_Export_from-Power-BI.csv and writes
# secure_data/DUMMY_research_dataset.csv (both git-ignored). This script
# contains no data and is safe to commit.
#
# Run from the project:  source(here::here("scripts", "make_dummy_dataset.R"))

library(readr)
library(here)

set.seed(20261012)

n_rows <- 500 # fixed, unrelated to the size of the real export
k_min <- 10 # a value/pattern must occur in >= k_min patients to be used
miss_codes <- c(99, 777, 888, 999, 9998, 9999) # as recoded in 01_clean-data.R
end_obs <- as.Date("2024-06-30") # end of observation for generated dates

src <- here("secure_data", "ResearchDB_Export_from-Power-BI.csv")
out <- here("secure_data", "DUMMY_research_dataset.csv")
loc <- locale(decimal_mark = ".", grouping_mark = ",")

# ---- read real export (profiled below, never copied) --------------------------

real <- read_delim(src, delim = ";", locale = loc, col_names = TRUE,
                   guess_max = Inf, # all rows; the default 1000 mistypes columns
                   show_col_types = FALSE)
col_class <- vapply(real, function(x) class(x)[1], character(1))

# ---- helpers ----------------------------------------------------------------

round_to <- function(p, step = 0.05) round(p / step) * step

# Values occurring in >= k_min patients, with rounded proportions (names = values)
frequent <- function(v) {
  tab <- table(v)
  tab <- tab[tab >= k_min]
  if (!length(tab)) return(NULL)
  round(prop.table(tab), 2) + 0.001
}
draw <- function(freq, n) sample(names(freq), n, replace = TRUE, prob = freq)

# Apply the real column's (rounded) missingness, keeping a few values so readr
# can still infer the type
set_missing <- function(out, x) {
  out[runif(length(out)) < round_to(mean(is.na(x)))] <- NA
  if (sum(!is.na(out)) < 3) out[sample(length(out), 3)] <- na.omit(out)[1]
  out
}

random_text <- function(n) sprintf("tekst_%02d", sample(1:20, n, replace = TRUE))

# Fill a pattern like "A999" with random letters/digits
fill_pattern <- function(tmpl) {
  vapply(strsplit(tmpl, ""), function(ch) {
    ch[ch == "A"] <- sample(LETTERS, sum(ch == "A"), replace = TRUE)
    ch[ch == "9"] <- sample(0:9, sum(ch == "9"), replace = TRUE)
    paste(ch, collapse = "")
  }, character(1))
}

gen_numeric <- function(x, n) {
  v <- x[!is.na(x)]
  if (length(v) < k_min) {
    vals <- round(runif(n, 1, 100)) # too few values to profile safely
  } else {
    is_int <- all(v == round(v))
    freq <- frequent(v)
    tab <- table(v)
    covered <- sum(tab[tab >= k_min]) / length(v)
    if (is_int && length(tab) <= 200 && covered >= 0.5) {
      vals <- as.numeric(draw(freq, n)) # coded / categorical
    } else {
      vals <- quantile(v, runif(n, 0.05, 0.95), names = FALSE, type = 7)
      vals <- if (is_int) round(vals) else round(vals, 2)
    }
  }
  set_missing(vals, x)
}

gen_character <- function(x, n) {
  v <- x[!is.na(x)]
  if (length(v) < k_min) return(set_missing(random_text(n), x))
  num <- suppressWarnings(as.numeric(sub(",", ".", v, fixed = TRUE)))

  if (mean(!is.na(num)) >= 0.8) {
    # numbers stored as text (e.g. decimal commas, or a few text codes)
    vals <- gen_numeric(num[!is.na(num)], n)
    vals <- as.character(vals)
    if (mean(grepl(",", v)) > 0.2) vals <- sub(".", ",", vals, fixed = TRUE)
    txt_freq <- frequent(v[is.na(num)])
    is_txt <- runif(n) < round_to(mean(is.na(num)))
    vals[is_txt] <- if (is.null(txt_freq)) "onbekend" else draw(txt_freq, sum(is_txt))
    return(set_missing(vals, x))
  }

  freq <- frequent(v)
  covered <- if (is.null(freq)) 0 else mean(v %in% names(freq))
  vals <- character(n)
  is_cat <- runif(n) < covered
  if (any(is_cat)) vals[is_cat] <- draw(freq, sum(is_cat))
  # remaining (rare / free-text) values: common letter-digit pattern, else placeholder
  rest <- v[!v %in% names(freq)]
  tmpl_freq <- frequent(gsub("[0-9]", "9", gsub("[A-Za-z]", "A", rest)))
  vals[!is_cat] <- if (is.null(tmpl_freq)) random_text(sum(!is_cat)) else
    fill_pattern(draw(tmpl_freq, sum(!is_cat)))
  set_missing(vals, x)
}

gen_column <- function(x, n) {
  if (is.numeric(x)) gen_numeric(x, n) else gen_character(x, n)
}

# ---- generate every column independently --------------------------------------

dummy <- as.data.frame(lapply(real, gen_column, n = n_rows), check.names = FALSE)

dummy$ResearchID <- sprintf("DUMMY%05d", seq_len(n_rows))

# ---- consistent dates per patient ----------------------------------------------

rand_between <- function(from, to) {
  span <- pmax(as.numeric(to - from), 0)
  from + floor(runif(length(from)) * (span + 1))
}
years <- function(y) round(y * 365.25)
present_rate <- function(col) 1 - round_to(mean(is.na(real[[col]])))

# Write a Date vector into d_/m_/y_<stem>, injecting the real column's
# common missing/unknown codes (e.g. 99) at their rounded rate
put_date <- function(df, stem, date) {
  parts <- list(d = format(date, "%d"), m = format(date, "%m"), y = format(date, "%Y"))
  for (p in names(parts)) {
    col <- paste0(p, "_", stem)
    if (!col %in% names(df)) next
    vals <- as.numeric(parts[[p]])
    rv <- real[[col]][!is.na(real[[col]])]
    codes <- frequent(rv[rv %in% c(miss_codes, as.character(miss_codes))])
    if (!is.null(codes)) {
      share <- round_to(mean(rv %in% names(codes)))
      hit <- !is.na(vals) & runif(length(vals)) < share
      vals[hit] <- as.numeric(draw(codes, sum(hit)))
    }
    df[[col]] <- if (is.character(df[[col]])) as.character(vals) else vals
  }
  df
}

n <- n_rows
ddx <- rand_between(rep(as.Date("1965-01-01"), n), rep(as.Date("2012-12-31"), n))
dob <- ddx - years(runif(n, 15, 60))

with_rate <- function(date, col) replace(date, runif(n) >= present_rate(col), NA)
ct_prim <- with_rate(ddx + sample(0:60, n, replace = TRUE), "y_ctprim")
rt_prim <- with_rate(ddx + sample(30:180, n, replace = TRUE), "y_rtprim")
recur <- with_rate(ddx + years(runif(n, 0.5, 5)), "y_recur")
ct_fup <- with_rate(ddx + years(runif(n, 1, 10)), "y_ctfup")
ct_fup2 <- with_rate(ct_fup + years(runif(n, 1, 5)), "y_ctfup2")
rt_fup <- with_rate(ddx + years(runif(n, 1, 10)), "y_rtfup")
rt_fup2 <- with_rate(rt_fup + years(runif(n, 1, 5)), "y_rtfup2")

# last contact; deceased patients (livedead == 1) die between diagnosis and then
lcontact <- pmin(ddx + years(runif(n, 2, 40)), end_obs)
dead <- !is.na(dummy$livedead) & dummy$livedead == 1
death <- lcontact
death[dead] <- rand_between(ddx[dead] + years(1), lcontact[dead])
lcontact[dead] <- death[dead]

# second malignancies: SMN k only if SMN k-1; dates in order before last contact
smn_cols <- function(k) grep(paste0("^smn", k, "_"), names(dummy), value = TRUE)
has_prev <- rep(TRUE, n)
prev_date <- ddx + years(1)
prev_rate <- 1
for (k in 1:7) {
  rate_k <- present_rate(paste0("y_smn", k))
  has_k <- has_prev & runif(n) < min(1, rate_k / max(prev_rate, 1e-9))
  date_k <- rand_between(prev_date, lcontact)
  date_k[!has_k] <- NA
  dummy <- put_date(dummy, paste0("smn", k), date_k)

  for (col in smn_cols(k)) {
    # profile site/morph/behav pooled over SMN1-7, so rare later SMNs are safe
    suffix <- sub(paste0("^smn", k), "", col)
    pooled <- unlist(lapply(1:7, function(j) {
      cj <- paste0("smn", j, suffix)
      if (cj %in% names(real)) as.character(real[[cj]][!is.na(real[[cj]])])
    }))
    freq <- frequent(pooled)
    vals <- if (is.null(freq)) random_text(n) else draw(freq, n)
    vals[!has_k] <- NA
    if (sum(!is.na(vals)) < 3) vals[sample(n, 3)] <- na.omit(vals)[1]
    dummy[[col]] <- if (is.numeric(real[[col]])) as.numeric(vals) else vals
  }
  has_prev <- has_k
  prev_date <- pmax(prev_date, date_k, na.rm = TRUE)
  prev_rate <- rate_k
}

dummy <- put_date(dummy, "birth", dob)
dummy <- put_date(dummy, "diagnose", ddx)
dummy <- put_date(dummy, "ctprim", ct_prim)
dummy <- put_date(dummy, "rtprim", rt_prim)
dummy <- put_date(dummy, "recur", recur)
dummy <- put_date(dummy, "ctfup", ct_fup)
dummy <- put_date(dummy, "ctfup2", ct_fup2)
dummy <- put_date(dummy, "rtfup", rt_fup)
dummy <- put_date(dummy, "rtfup2", rt_fup2)
dummy <- put_date(dummy, "lcontact", lcontact)
dummy <- put_date(dummy, "livedead", death)

# ---- keep every column's type as in the real export -----------------------------

for (col in names(dummy)) {
  x <- dummy[[col]]
  if (all(is.na(x))) {
    x[sample(n, 3)] <- if (col_class[[col]] == "character") "tekst_01" else 1
  }
  if (col_class[[col]] == "character" &&
      !anyNA(suppressWarnings(as.numeric(na.omit(x))))) {
    x[sample(which(!is.na(x)), 1)] <- "onbekend" # keep the column read as text
  }
  dummy[[col]] <- x
}

rm(real) # real values are not used beyond this point
write_delim(dummy, out, delim = ";", na = "")

# ---- check: re-reading the dummy gives the same names and types ---------------

check <- read_delim(out, delim = ";", locale = loc, col_names = TRUE,
                    guess_max = Inf, show_col_types = FALSE)
check_class <- vapply(check, function(x) class(x)[1], character(1))

stopifnot(identical(names(check_class), names(col_class)))
mismatch <- which(check_class != col_class)
if (length(mismatch)) {
  print(data.frame(column = names(col_class)[mismatch],
                   real = col_class[mismatch], dummy = check_class[mismatch]))
  stop("Column types differ between the real export and the dummy file.")
}
message("Wrote ", out, ": ", n_rows, " rows, ", length(col_class),
        " columns; names and types match the real export.")
