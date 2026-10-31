# 01_load_and_check.R
# Purpose: load DWP's published disparity statistics for the
#          Universal Credit Advances model and check them.
# Author:  Ulviyya Babayeva
# Data:    data/dwp_disparities.csv, transcribed from the DWP
#          2024-25 Fairness Assessment and 2025-26 Effectiveness
#          Assessment statistical annexes.

disparities <- read.csv("data/dwp_disparities.csv")


str(disparities)
nrow(disparities)

table(disparities$year)

# ---- Checks: stop with an error if the data are not as expected ----

# 1. Twelve groups in each of the two years
stopifnot(nrow(disparities) == 24)
stopifnot(all(table(disparities$year) == 12))

# 2. No missing values, and every relative likelihood is positive
stopifnot(!anyNA(disparities$referral_rl), !anyNA(disparities$outcome_rl))
stopifnot(all(disparities$referral_rl > 0), all(disparities$outcome_rl > 0))

# 3. Exactly one comparator group (value 1 on both measures)
#    per characteristic per year: 4 characteristics x 2 years = 8
comparators <- subset(disparities, referral_rl == 1 & outcome_rl == 1)
comparators
stopifnot(nrow(comparators) == 8)

