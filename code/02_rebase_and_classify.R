# 02_rebase_and_classify.R
# Purpose: put the 2025-26 age figures on the same comparator as
#          2024-25 (35 to 44), so the two years can be compared.
# Method:  a relative likelihood (RL) is a ratio of rates with a common
#          comparator. Dividing each RL by the new comparator's RL
#          cancels the old comparator:
#          (rate_g / rate_old) / (rate_new / rate_old) = rate_g / rate_new

source("code/01_load_and_check.R")

# ---- Function: change the comparator group ----
rebase <- function(df, new_comparator) {
  base <- df[df$group == new_comparator, ]
  stopifnot(nrow(base) == 1)            # the new comparator must exist once
  df$referral_rl <- df$referral_rl / base$referral_rl
  df$outcome_rl  <- df$outcome_rl  / base$outcome_rl
  df
}

# ---- Rebase 2025-26 age groups onto 35 to 44 ----
age_2526 <- subset(disparities, year == "2025-26" & characteristic == "age")
age_2526_rebased <- rebase(age_2526, "35 to 44")

# Check: the new comparator must now equal 1 on both measures
new_comp <- age_2526_rebased[age_2526_rebased$group == "35 to 44", ]
stopifnot(new_comp$referral_rl == 1, new_comp$outcome_rl == 1)

age_2526_rebased[, c("group", "referral_rl", "outcome_rl")]

# ---- Compare 2024-25 with rebased 2025-26, same comparator ----
age_2425 <- subset(disparities, year == "2024-25" & characteristic == "age")

comparison <- merge(
  age_2425[, c("group", "referral_rl", "outcome_rl")],
  age_2526_rebased[, c("group", "referral_rl", "outcome_rl")],
  by = "group",
  suffixes = c("_2425", "_2526")
)

# DWP's four-fifths rule: outside 0.80-1.25 counts as "notable".
# Record the direction too, so a reversal (higher -> lower) is caught.
classify <- function(rl) {
  ifelse(rl > 1.25, "notably higher",
         ifelse(rl < 0.80, "notably lower", "not notable"))
}

comparison$referral_class_2425 <- classify(comparison$referral_rl_2425)
comparison$referral_class_2526 <- classify(comparison$referral_rl_2526)
comparison$class_changed <- comparison$referral_class_2425 !=
  comparison$referral_class_2526

# Round for presentation: inputs were published to 2 decimal places
num_cols <- sapply(comparison, is.numeric)
comparison[num_cols] <- round(comparison[num_cols], 2)

comparison

# ---- Save the result ----
write.csv(comparison, "output/age_comparison_rebased.csv", row.names = FALSE)