# EC 282: Introduction to Econometrics
# Handout 3: Random Sampling & Large Sample Approximations
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

library(ggplot2)
library(scales)

set.seed(282)
options(scipen = 999)

# =============================================================================
# PART 1: POPULATION VS. SAMPLE
# =============================================================================

# -----------------------------------------------------------------------------
# 1A. CREATE A POPULATION OF WEEKLY EARNINGS
# Right-skewed distribution (realistic for earnings data)
# -----------------------------------------------------------------------------

N <- 100000
population <- data.frame(
  id = 1:N,
  earnings = round(500 + rgamma(N, shape = 2, rate = 0.01), 2)
)

# Population parameters (these are what we want to learn about)
pop_mean <- mean(population$earnings)
pop_var  <- var(population$earnings) * (N - 1) / N  # Population variance
pop_sd   <- sqrt(pop_var)

cat("=== POPULATION PARAMETERS ===\n")
cat("Population mean (mu_Y):", round(pop_mean, 2), "\n")
cat("Population variance (sigma_Y^2):", round(pop_var, 2), "\n")
cat("Population std dev (sigma_Y):", round(pop_sd, 2), "\n")

# -----------------------------------------------------------------------------
# 1B. POPULATION HISTOGRAM
# -----------------------------------------------------------------------------

ggplot(population, aes(x = earnings)) +
  geom_histogram(bins = 60, fill = "steelblue", color = "white") +
  geom_vline(xintercept = pop_mean, color = "red",
             linetype = "dashed", linewidth = 1) +
  labs(title = "Population Distribution of Weekly Earnings",
       x = "Weekly Earnings ($)", y = "Count",
       caption = paste("Red dashed line = Population Mean =",
                       round(pop_mean, 2))) +
  theme_minimal()

# =============================================================================
# PART 2: RANDOM SAMPLING
# =============================================================================

# -----------------------------------------------------------------------------
# 2A. DRAW RANDOM SAMPLES
# -----------------------------------------------------------------------------

cat("\n=== RANDOM SAMPLING ===\n")

sample_10  <- sample(population$earnings, 10)
sample_100 <- sample(population$earnings, 100)

cat("Sample mean (n = 10):", round(mean(sample_10), 2), "\n")
cat("Sample mean (n = 100):", round(mean(sample_100), 2), "\n")
cat("Population mean:", round(pop_mean, 2), "\n")
cat("Difference (n=10):", round(mean(sample_10) - pop_mean, 2), "\n")
cat("Difference (n=100):", round(mean(sample_100) - pop_mean, 2), "\n")

# =============================================================================
# PART 3: THE SAMPLE MEAN AS A RANDOM VARIABLE
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. STANDARD ERROR FOR DIFFERENT SAMPLE SIZES
# -----------------------------------------------------------------------------

cat("\n=== STANDARD ERROR OF THE SAMPLE MEAN ===\n")
cat("sigma_Y =", round(pop_sd, 2), "\n\n")

for (n in c(10, 100, 1000)) {
  se <- pop_sd / sqrt(n)
  cat("n =", n, " -> Standard Error =", round(se, 4), "\n")
}

# =============================================================================
# PART 4: LAW OF LARGE NUMBERS
# =============================================================================

# -----------------------------------------------------------------------------
# 4A. SAMPLE MEAN AT INCREASING SAMPLE SIZES
# -----------------------------------------------------------------------------

cat("\n=== LAW OF LARGE NUMBERS ===\n")

sample_sizes <- c(10, 25, 50, 100, 250, 500, 1000,
                  2500, 5000, 10000, 50000)

results <- data.frame(
  n = sample_sizes,
  sample_mean = sapply(sample_sizes, function(n) {
    mean(sample(population$earnings, n))
  })
)
results$pop_mean  <- round(pop_mean, 2)
results$deviation <- round(results$sample_mean - pop_mean, 2)
results$sample_mean <- round(results$sample_mean, 2)

print(results)

# -----------------------------------------------------------------------------
# 4B. LLN VISUALIZATION (MULTIPLE SAMPLES PER SIZE)
# -----------------------------------------------------------------------------

lln_data <- do.call(rbind, lapply(
  round(exp(seq(log(10), log(N), length.out = 80))),
  function(n) {
    data.frame(
      n = n,
      sample_mean = replicate(10,
        mean(sample(population$earnings, n)))
    )
  }
))

ggplot(lln_data, aes(x = n, y = sample_mean)) +
  geom_point(alpha = 0.3, color = "steelblue", size = 1.5) +
  geom_hline(yintercept = pop_mean, color = "red",
             linetype = "dashed", linewidth = 1) +
  scale_x_log10(labels = scales::comma) +
  labs(title = "Law of Large Numbers",
       subtitle = "Each dot is a sample mean; spread decreases with n",
       x = "Sample Size (log scale)", y = "Sample Mean",
       caption = paste("Red dashed line = Population Mean =",
                       round(pop_mean, 2))) +
  theme_minimal()

# =============================================================================
# PART 5: CENTRAL LIMIT THEOREM
# =============================================================================

# -----------------------------------------------------------------------------
# 5A. SAMPLING DISTRIBUTIONS FOR DIFFERENT N
# -----------------------------------------------------------------------------

cat("\n=== CENTRAL LIMIT THEOREM ===\n")

clt_data <- do.call(rbind, lapply(c(5, 30, 200), function(n) {
  data.frame(
    n = paste("n =", n),
    sample_mean = replicate(10000,
      mean(sample(population$earnings, n)))
  )
}))

# Order the factor for proper facet ordering
clt_data$n <- factor(clt_data$n, levels = c("n = 5", "n = 30", "n = 200"))

ggplot(clt_data, aes(x = sample_mean)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "steelblue", color = "white", alpha = 0.7) +
  facet_wrap(~ n, scales = "free") +
  labs(title = "Sampling Distribution of the Mean",
       subtitle = "Population is right-skewed, but sampling distribution becomes normal",
       x = "Sample Mean", y = "Density") +
  theme_minimal()

# Print summary statistics for each
for (n_val in c(5, 30, 200)) {
  subset_means <- clt_data$sample_mean[clt_data$n == paste("n =", n_val)]
  cat("\nn =", n_val, ":\n")
  cat("  Mean of sample means:", round(mean(subset_means), 2), "\n")
  cat("  SD of sample means:", round(sd(subset_means), 2), "\n")
  cat("  Theoretical SE:", round(pop_sd / sqrt(n_val), 2), "\n")
}

# -----------------------------------------------------------------------------
# 5B. NORMAL APPROXIMATION OVERLAY (N = 100)
# -----------------------------------------------------------------------------

n <- 100
means_100 <- replicate(10000,
  mean(sample(population$earnings, n)))

ggplot(data.frame(x = means_100), aes(x = x)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "steelblue", color = "white", alpha = 0.7) +
  stat_function(fun = dnorm,
    args = list(mean = pop_mean,
                sd = pop_sd / sqrt(n)),
    color = "darkred", linewidth = 1.2) +
  labs(title = paste0("CLT: Normal Approximation (n = ", n, ")"),
       x = "Sample Mean", y = "Density",
       caption = "Red curve = Normal approximation from CLT") +
  theme_minimal()

cat("\n--- CLT Verification (n = 100) ---\n")
cat("Mean of sample means:", round(mean(means_100), 2), "\n")
cat("Population mean:", round(pop_mean, 2), "\n")
cat("Variance of sample means:", round(var(means_100), 2), "\n")
cat("Theoretical variance (sigma^2/n):", round(pop_var / n, 2), "\n")

# =============================================================================
# PART 6: NORMAL DISTRIBUTION AND STANDARDIZATION
# =============================================================================

# -----------------------------------------------------------------------------
# 6A. STANDARDIZATION EXAMPLE
# -----------------------------------------------------------------------------

cat("\n=== NORMAL DISTRIBUTION CALCULATIONS ===\n")
mu  <- 700
se  <- 20

# (a) P(Y_bar <= 740)
prob_a <- pnorm(740, mean = mu, sd = se)
cat("\n(a) P(Y_bar <= 740) =", round(prob_a, 4), "\n")
cat("    Z = (740 - 700) / 20 =", (740 - 700) / 20, "\n")

# (b) P(660 <= Y_bar <= 740)
prob_b <- pnorm(740, mean = mu, sd = se) - pnorm(660, mean = mu, sd = se)
cat("\n(b) P(660 <= Y_bar <= 740) =", round(prob_b, 4), "\n")
cat("    Z_lower = (660 - 700) / 20 =", (660 - 700) / 20, "\n")
cat("    Z_upper = (740 - 700) / 20 =", (740 - 700) / 20, "\n")

# (c) P(Y_bar > 730)
prob_c <- 1 - pnorm(730, mean = mu, sd = se)
cat("\n(c) P(Y_bar > 730) =", round(prob_c, 4), "\n")
cat("    Z = (730 - 700) / 20 =", (730 - 700) / 20, "\n")

# -----------------------------------------------------------------------------
# 6B. 95% INTERVAL VERIFICATION
# -----------------------------------------------------------------------------

cat("\n=== 95% INTERVAL VERIFICATION ===\n")

se_100 <- pop_sd / sqrt(100)
lower <- pop_mean - 1.96 * se_100
upper <- pop_mean + 1.96 * se_100

cat("Standard error (n=100):", round(se_100, 2), "\n")
cat("95% interval: [", round(lower, 2), ",", round(upper, 2), "]\n")

fraction_within <- mean(means_100 >= lower & means_100 <= upper)
cat("Fraction within 1.96 SE:", fraction_within, "\n")
cat("Theoretical:", 0.95, "\n")

# =============================================================================
# PART 7: PUTTING IT ALL TOGETHER
# =============================================================================

# -----------------------------------------------------------------------------
# 7A. APPLIED PROBLEM
# -----------------------------------------------------------------------------

cat("\n=== APPLIED PROBLEM ===\n")

n_survey <- 400
y_bar    <- 712
sigma_y  <- 200

# Standard error
se_survey <- sigma_y / sqrt(n_survey)
cat("Standard error:", se_survey, "\n")

# P(692 <= Y_bar <= 732) assuming mu = 712
z_lower <- (692 - 712) / se_survey
z_upper <- (732 - 712) / se_survey
prob_interval <- pnorm(z_upper) - pnorm(z_lower)
cat("P(692 <= Y_bar <= 732) =", round(prob_interval, 4), "\n")
cat("Z_lower =", z_lower, ", Z_upper =", z_upper, "\n")

# Test claim that mu = 750
z_claim <- (712 - 750) / se_survey
p_value <- pnorm(z_claim)
cat("\nTest H0: mu = 750\n")
cat("Z = (712 - 750) / 10 =", z_claim, "\n")
cat("P(Y_bar <= 712 | mu = 750) =", format(p_value, scientific = TRUE), "\n")
cat("Conclusion: Very strong evidence against the claim that mu = 750\n")

cat("\n=== END OF HANDOUT 3 CODE ===\n")
