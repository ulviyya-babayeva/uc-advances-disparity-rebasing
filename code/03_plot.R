# 03_plot.R
# Purpose: chart referral disparities by age, 2024-25 (published)
#          against 2025-26 (rebased to the same 35 to 44 comparator).

source("code/02_rebase_and_classify.R")

# ---- Function: draw the chart ----
draw_chart <- function(d) {
  x <- seq_len(nrow(d))
  
  # empty frame on a log scale: equal distances = equal ratios
  plot(x, d$referral_rl_2425, type = "n", log = "y",
       ylim = c(0.5, 60), xlim = c(0.5, nrow(d) + 0.5), xaxt = "n",
       xlab = "Age group",
       ylab = "Relative likelihood of referral (log scale)",
       main = "Referral disparities by age, 35 to 44 = 1")
  
  # DWP's "not notable" band (0.80 to 1.25) and the parity line
  rect(0.5, 0.80, nrow(d) + 0.5, 1.25, col = "grey90", border = NA)
  abline(h = 1, lty = 2)
  
  # the two years, side by side for each age group
  points(x - 0.12, d$referral_rl_2425, pch = 16, cex = 1.6, col = "#0072B2")
  points(x + 0.12, d$referral_rl_2526, pch = 17, cex = 1.6, col = "#D55E00")
  
  axis(1, at = x, labels = d$group)
  legend("topleft", bty = "n", pch = c(16, 17), col = c("#0072B2", "#D55E00"),
         legend = c("2024-25 (as published)", "2025-26 (rebased)"))
}

# ---- Show on screen, then save as an image ----
draw_chart(comparison)

png("output/age_referral_rebased.png", width = 2000, height = 1200, res = 200)
draw_chart(comparison)
dev.off()