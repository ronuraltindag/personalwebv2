# EC 282: Introduction to Econometrics
# Handout 4: Estimation, Hypothesis Testing & Confidence Intervals
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

library(ggplot2)
library(scales)

set.seed(282)
options(scipen = 999)

# =============================================================================
# PART 1: THE DATA
# =============================================================================

# -----------------------------------------------------------------------------
# 1A. CREATE POPULATION OF MONTHLY RENTS
# Normal distribution -- realistic for student rents
# -----------------------------------------------------------------------------

N <- 30000
population <- data.frame(
  id = 1:N,
  rent = round(rnorm(N, mean = 950, sd = 300), 2)
)
pop_mean <- mean(population$rent)  # True mu_Y (pretend we don't know this)
pop_sd   <- sd(population$rent)

cat("=== POPULATION PARAMETERS (unknown in practice) ===\n")
cat("Population mean (mu_Y):", round(pop_mean, 2), "\n")
cat("Population SD (sigma_Y):", round(pop_sd, 2), "\n")

# -----------------------------------------------------------------------------
# 1B. DRAW A RANDOM SAMPLE
# -----------------------------------------------------------------------------

n <- 50
our_sample <- sample(population$rent, n)

y_bar <- mean(our_sample)
s_y   <- sd(our_sample)
se    <- s_y / sqrt(n)

cat("\n=== SAMPLE STATISTICS ===\n")
cat("Sample size (n):", n, "\n")
cat("Sample mean (Y_bar):", round(y_bar, 2), "\n")
cat("Sample SD (S_Y):", round(s_y, 2), "\n")
cat("Standard error SE[Y_bar]:", round(se, 2), "\n")

# =============================================================================
# PART 2: ESTIMATORS AND THEIR PROPERTIES
# =============================================================================

# -----------------------------------------------------------------------------
# 2A. COMPARING SAMPLE MEAN AND SAMPLE MEDIAN
# -----------------------------------------------------------------------------

cat("\n=== COMPARING ESTIMATORS ===\n")

n_sims <- 10000

means   <- replicate(n_sims, mean(sample(population$rent, 50)))
medians <- replicate(n_sims, median(sample(population$rent, 50)))

cat("--- Sample Mean ---\n")
cat("E[Y_bar] ~=", round(mean(means), 2), "\n")
cat("Var(Y_bar) ~=", round(var(means), 2), "\n")

cat("\n--- Sample Median ---\n")
cat("E[Median] ~=", round(mean(medians), 2), "\n")
cat("Var(Median) ~=", round(var(medians), 2), "\n")

cat("\nPopulation mean:", round(pop_mean, 2), "\n")
cat("Variance ratio (Median/Mean):", round(var(medians) / var(means), 3), "\n")
cat("Theoretical ratio (pi/2):", round(pi/2, 3), "\n")

# Visualize the two sampling distributions side by side
comp_data <- data.frame(
  value = c(means, medians),
  estimator = rep(c("Sample Mean", "Sample Median"), each = n_sims)
)

ggplot(comp_data, aes(x = value, fill = estimator)) +
  geom_histogram(bins = 50, alpha = 0.6, position = "identity",
                 color = "white") +
  geom_vline(xintercept = pop_mean, linetype = "dashed", color = "red") +
  labs(title = "Sampling Distributions: Mean vs. Median (n = 50)",
       subtitle = "Both unbiased, but the mean has smaller variance (more efficient)",
       x = "Estimate of mu_Y", y = "Count",
       fill = "Estimator") +
  theme_minimal() +
  theme(legend.position = "bottom")

# -----------------------------------------------------------------------------
# 2B. CONSISTENCY: SAMPLING DISTRIBUTIONS FOR INCREASING N
# -----------------------------------------------------------------------------

cat("\n=== CONSISTENCY OF THE SAMPLE MEAN ===\n")

sample_sizes <- c(10, 50, 200, 1000, 5000)

consistency <- data.frame(
  n = rep(sample_sizes, each = 500),
  y_bar = unlist(lapply(sample_sizes, function(n) {
    replicate(500, mean(sample(population$rent, n)))
  }))
)

ggplot(consistency, aes(x = y_bar)) +
  geom_histogram(bins = 40, fill = "steelblue",
                 color = "white", alpha = 0.7) +
  geom_vline(xintercept = pop_mean, color = "red",
             linetype = "dashed") +
  facet_wrap(~ paste("n =", n), scales = "free_y") +
  labs(title = "Consistency: Sampling Distribution of Y-bar",
       subtitle = "As n grows, Y-bar concentrates around mu_Y",
       x = "Sample Mean", y = "Count") +
  theme_minimal()

# =============================================================================
# PART 3: HYPOTHESIS TESTING
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. ONE-SAMPLE TEST: HAS AVERAGE RENT INCREASED BEYOND $900?
# -----------------------------------------------------------------------------

cat("\n=== HYPOTHESIS TEST: H0: mu_Y = 900 ===\n")

mu_0 <- 900

# t-statistic
t_stat <- (y_bar - mu_0) / se
cat("Y_bar:", round(y_bar, 2), "\n")
cat("SE[Y_bar]:", round(se, 2), "\n")
cat("t-statistic:", round(t_stat, 4), "\n")

# Two-sided p-value
p_two <- 2 * pnorm(-abs(t_stat))
cat("\nTwo-sided p-value:", round(p_two, 4), "\n")

# One-sided p-value (H_A: mu > 900)
p_one <- 1 - pnorm(t_stat)
cat("One-sided p-value:", round(p_one, 4), "\n")

# Decision
cat("\n--- Decision at alpha = 0.05 ---\n")
cat("Two-sided: ", ifelse(p_two < 0.05, "REJECT H0", "FAIL TO REJECT H0"), "\n")
cat("One-sided: ", ifelse(p_one < 0.05, "REJECT H0", "FAIL TO REJECT H0"), "\n")

cat("\n--- Decision at alpha = 0.01 ---\n")
cat("Two-sided: ", ifelse(p_two < 0.01, "REJECT H0", "FAIL TO REJECT H0"), "\n")
cat("One-sided: ", ifelse(p_one < 0.01, "REJECT H0", "FAIL TO REJECT H0"), "\n")

# -----------------------------------------------------------------------------
# 3B. VISUALIZE THE TEST
# -----------------------------------------------------------------------------

x_seq <- seq(-4, 4, length.out = 300)
df <- data.frame(x = x_seq, y = dnorm(x_seq))

ggplot(df, aes(x = x, y = y)) +
  geom_line(linewidth = 1) +
  geom_area(data = subset(df, x <= -1.96),
            fill = "red", alpha = 0.3) +
  geom_area(data = subset(df, x >= 1.96),
            fill = "red", alpha = 0.3) +
  geom_vline(xintercept = t_stat, color = "blue",
             linetype = "dashed", linewidth = 1) +
  annotate("text", x = t_stat + 0.3, y = 0.35,
           label = paste("t =", round(t_stat, 2)),
           color = "blue", hjust = 0) +
  labs(title = "Standard Normal Distribution Under H0",
       subtitle = "Red = rejection region (alpha = 0.05, two-sided)",
       x = "Z", y = "Density") +
  theme_minimal()

# =============================================================================
# PART 4: TYPE I AND TYPE II ERRORS
# =============================================================================

# -----------------------------------------------------------------------------
# 4A. SIMULATE TYPE I ERROR RATE
# -----------------------------------------------------------------------------

cat("\n=== TYPE I ERROR SIMULATION ===\n")

pop_null <- rnorm(N, mean = 900, sd = 300)

rejections <- replicate(10000, {
  samp <- sample(pop_null, 50)
  t <- (mean(samp) - 900) / (sd(samp) / sqrt(50))
  abs(t) > 1.96
})

cat("Type I error rate (simulated):", mean(rejections), "\n")
cat("Nominal alpha:", 0.05, "\n")

# =============================================================================
# PART 5: CONFIDENCE INTERVALS
# =============================================================================

# -----------------------------------------------------------------------------
# 5A. CONSTRUCT CONFIDENCE INTERVALS
# -----------------------------------------------------------------------------

cat("\n=== CONFIDENCE INTERVALS ===\n")

# 90% CI
ci90_l <- y_bar - 1.65 * se
ci90_u <- y_bar + 1.65 * se
cat("90% CI: [", round(ci90_l, 2), ",", round(ci90_u, 2), "]\n")

# 95% CI
ci_lower <- y_bar - 1.96 * se
ci_upper <- y_bar + 1.96 * se
cat("95% CI: [", round(ci_lower, 2), ",", round(ci_upper, 2), "]\n")

# 99% CI
ci99_l <- y_bar - 2.576 * se
ci99_u <- y_bar + 2.576 * se
cat("99% CI: [", round(ci99_l, 2), ",", round(ci99_u, 2), "]\n")

cat("\nTrue population mean:", round(pop_mean, 2), "\n")
cat("Does 95% CI contain mu_Y?",
    ci_lower <= pop_mean & pop_mean <= ci_upper, "\n")

# -----------------------------------------------------------------------------
# 5B. COVERAGE SIMULATION: 100 CONFIDENCE INTERVALS
# -----------------------------------------------------------------------------

cat("\n=== COVERAGE SIMULATION ===\n")

ci_data <- do.call(rbind, lapply(1:100, function(i) {
  samp <- sample(population$rent, 50)
  m <- mean(samp)
  s <- sd(samp) / sqrt(50)
  data.frame(
    sample = i, y_bar = m,
    lower = m - 1.96 * s, upper = m + 1.96 * s,
    covers = (m - 1.96 * s <= pop_mean) &
             (pop_mean <= m + 1.96 * s)
  )
}))

cat("Coverage rate:", mean(ci_data$covers), "\n")

ggplot(ci_data, aes(x = sample, y = y_bar, color = covers)) +
  geom_point(size = 1.5) +
  geom_errorbar(aes(ymin = lower, ymax = upper), width = 0.3) +
  geom_hline(yintercept = pop_mean, linetype = "dashed",
             color = "black") +
  scale_color_manual(values = c("TRUE" = "steelblue",
                                "FALSE" = "red")) +
  labs(title = "95% Confidence Intervals from 100 Samples",
       subtitle = "Red intervals miss the true mean",
       x = "Sample Number", y = "Rent ($)",
       color = "Contains mu") +
  theme_minimal() +
  theme(legend.position = "bottom")

# =============================================================================
# PART 6: CONNECTION BETWEEN CI AND HYPOTHESIS TEST
# =============================================================================

cat("\n=== CI-HYPOTHESIS TEST CONNECTION ===\n")

# Test H0: mu = 900 using CI
cat("95% CI: [", round(ci_lower, 2), ",", round(ci_upper, 2), "]\n")
cat("Is 900 inside CI?", ci_lower <= 900 & 900 <= ci_upper, "\n")
cat("Reject H0: mu = 900?", !(ci_lower <= 900 & 900 <= ci_upper), "\n")

# Test H0: mu = 950 using CI
cat("\nIs 950 inside CI?", ci_lower <= 950 & 950 <= ci_upper, "\n")
t_950 <- (y_bar - 950) / se
p_950 <- 2 * pnorm(-abs(t_950))
cat("t-stat (H0: mu = 950):", round(t_950, 4), "\n")
cat("p-value:", round(p_950, 4), "\n")
cat("Reject H0: mu = 950?", p_950 < 0.05, "\n")

# =============================================================================
# PART 7: COMPARING TWO GROUPS
# =============================================================================

# -----------------------------------------------------------------------------
# 7A. CREATE TWO POPULATIONS AND DRAW SAMPLES
# -----------------------------------------------------------------------------

cat("\n=== TWO-SAMPLE COMPARISON ===\n")

off_campus <- rnorm(15000, mean = 1020, sd = 280)
adjacent   <- rnorm(15000, mean = 950, sd = 250)

n1 <- 60; n2 <- 55
samp1 <- sample(off_campus, n1)
samp2 <- sample(adjacent, n2)

y_bar1 <- mean(samp1);  s1 <- sd(samp1)
y_bar2 <- mean(samp2);  s2 <- sd(samp2)
diff   <- y_bar1 - y_bar2
se_diff <- sqrt(s1^2/n1 + s2^2/n2)

cat("Off-campus:  Y_bar1 =", round(y_bar1, 2),
    " S1 =", round(s1, 2), " n1 =", n1, "\n")
cat("Adjacent:    Y_bar2 =", round(y_bar2, 2),
    " S2 =", round(s2, 2), " n2 =", n2, "\n")
cat("Difference:  ", round(diff, 2), "\n")
cat("SE(diff):    ", round(se_diff, 2), "\n")

# -----------------------------------------------------------------------------
# 7B. TWO-SAMPLE HYPOTHESIS TEST
# -----------------------------------------------------------------------------

t_diff <- diff / se_diff
p_diff <- 2 * pnorm(-abs(t_diff))

cat("\nt-statistic:", round(t_diff, 4), "\n")
cat("p-value:", round(p_diff, 4), "\n")
cat("Decision (alpha = 0.05):",
    ifelse(p_diff < 0.05, "REJECT H0", "FAIL TO REJECT H0"), "\n")

# -----------------------------------------------------------------------------
# 7C. CONFIDENCE INTERVAL FOR DIFFERENCE IN MEANS
# -----------------------------------------------------------------------------

ci_diff_l <- diff - 1.96 * se_diff
ci_diff_u <- diff + 1.96 * se_diff

cat("\n95% CI for difference: [", round(ci_diff_l, 2), ",",
    round(ci_diff_u, 2), "]\n")
cat("Does CI contain 0?", ci_diff_l <= 0 & 0 <= ci_diff_u, "\n")

cat("\n=== END OF HANDOUT 4 CODE ===\n")
