# EC 282: Introduction to Econometrics
# Handout 1: Types of Data & Review of Probability
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

library(dplyr)
library(tidyr)
library(ggplot2)
library(scales)

set.seed(282)
options(scipen = 999)

# =============================================================================
# PART 1: TYPES OF DATA
# =============================================================================

# -----------------------------------------------------------------------------
# 1A. CROSS-SECTIONAL DATA
# Observations on multiple units at a single point in time
# -----------------------------------------------------------------------------

# Example: Student performance data (one semester snapshot)
cross_section <- data.frame(
  student_id = 1:20,
  gpa = round(runif(20, 2.0, 4.0), 2),
  hours_studied = round(rnorm(20, mean = 15, sd = 5), 1),
  employed = sample(c(0, 1), 20, replace = TRUE, prob = c(0.6, 0.4))
)

print("CROSS-SECTIONAL DATA: Student Performance (Single Semester)")
print(head(cross_section, 10))

# -----------------------------------------------------------------------------
# 1B. TIME SERIES DATA
# Observations on a single unit over multiple time periods
# -----------------------------------------------------------------------------

# Example: Monthly unemployment rate for one state
time_series <- data.frame(
  month = seq(as.Date("2024-01-01"), by = "month", length.out = 24),
  unemployment_rate = round(4.5 + cumsum(rnorm(24, 0, 0.3)), 2)
)

print("TIME SERIES DATA: Monthly Unemployment Rate (One State)")
print(head(time_series, 12))

# Plot time series
ggplot(time_series, aes(x = month, y = unemployment_rate)) +
  geom_line(color = "steelblue", linewidth = 1) +
  geom_point(color = "steelblue", size = 2) +
  labs(title = "Time Series: Monthly Unemployment Rate",
       x = "Month", y = "Unemployment Rate (%)") +
  theme_minimal()

# -----------------------------------------------------------------------------
# 1C. PANEL DATA (LONGITUDINAL DATA)
# Observations on multiple units over multiple time periods
# -----------------------------------------------------------------------------

# Example: Student GPA across 4 semesters
panel_data <- expand.grid(
  student_id = 1:5,
  semester = c("Fall 2024", "Spring 2025", "Fall 2025", "Spring 2026")
) %>%
  arrange(student_id, semester) %>%
  mutate(
    gpa = round(2.5 + 0.1 * as.numeric(factor(semester)) +
                  rnorm(n(), 0, 0.3) +
                  rep(rnorm(5, 0, 0.5), each = 4), 2),
    gpa = pmin(pmax(gpa, 0), 4.0)  # Bound between 0 and 4
  )

print("PANEL DATA: Student GPA Across Semesters")
print(panel_data)

# Reshape to wide format
panel_wide <- panel_data %>%
  pivot_wider(names_from = semester, values_from = gpa)

print("PANEL DATA (Wide Format)")
print(panel_wide)

# =============================================================================
# PART 2: RANDOM VARIABLES AND PROBABILITY DISTRIBUTIONS
# =============================================================================

# -----------------------------------------------------------------------------
# 2A. DISCRETE RANDOM VARIABLE: BERNOULLI (COLON CANCER EXAMPLE)
# -----------------------------------------------------------------------------

# Create population with EXACTLY 4% colon cancer rate (Bernoulli distribution)
N <- 100000
p_cancer <- 0.04

# Assign exactly N * p_cancer ones and the rest zeros for exact population mean
n_cancer <- N * p_cancer  # = 4000 individuals with cancer
population <- data.frame(
  id = 1:N,
  colon_cancer = c(rep(1, n_cancer), rep(0, N - n_cancer))
)

# Population mean (exactly p = 0.04 by construction)
pop_mean <- mean(population$colon_cancer)
cat("\nPOPULATION MEAN (Expected Value):", pop_mean, "\n")

# Population variance: p(1-p) for Bernoulli
# With exact proportions, population variance is exactly p(1-p)
pop_var <- p_cancer * (1 - p_cancer)
cat("POPULATION VARIANCE:", pop_var, "\n")
cat("THEORETICAL VARIANCE p(1-p):", p_cancer * (1 - p_cancer), "\n")

# -----------------------------------------------------------------------------
# 2B. DISCRETE RANDOM VARIABLE: DIE ROLL
# -----------------------------------------------------------------------------

# Simulate fair die rolls
die_rolls <- sample(1:6, 10000, replace = TRUE)

# Probability distribution
die_probs <- table(die_rolls) / length(die_rolls)
cat("\nDIE ROLL PROBABILITY DISTRIBUTION:\n")
print(die_probs)

# Expected value: should be 3.5
die_mean <- mean(die_rolls)
cat("\nSample Mean of Die Rolls:", die_mean, "\n")
cat("Theoretical E[Y]:", 3.5, "\n")

# Variance
die_var <- var(die_rolls) * (length(die_rolls) - 1) / length(die_rolls)
cat("Sample Variance:", die_var, "\n")
cat("Theoretical Var(Y):", 35/12, "\n")  # (n^2 - 1)/12 for uniform 1 to n

# =============================================================================
# PART 3: EXPECTED VALUE AND VARIANCE
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. EXPECTED VALUE AS WEIGHTED AVERAGE
# -----------------------------------------------------------------------------

# Grade distribution example
grades <- c(0, 1, 2, 3, 4)  # 0=F, 1=D, 2=C, 3=B, 4=A
probs <- c(0.05, 0.10, 0.30, 0.35, 0.20)

# Expected value calculation
expected_grade <- sum(grades * probs)
cat("\n--- EXPECTED VALUE CALCULATION ---\n")
cat("Grades:", grades, "\n")
cat("Probabilities:", probs, "\n")
cat("E[Grade] = Sum of (grade * probability) =", expected_grade, "\n")

# Variance calculation
variance_grade <- sum((grades - expected_grade)^2 * probs)
sd_grade <- sqrt(variance_grade)
cat("Var(Grade) =", variance_grade, "\n")
cat("SD(Grade) =", sd_grade, "\n")

# =============================================================================
# PART 4: JOINT AND MARGINAL DISTRIBUTIONS
# =============================================================================

# -----------------------------------------------------------------------------
# 4A. COMMUTE TIME AND RAIN EXAMPLE
# -----------------------------------------------------------------------------

# Joint distribution table
# Y = 0 (Long commute), Y = 1 (Short commute)
# X = 0 (Rain), X = 1 (No Rain)

joint_dist <- matrix(
  c(0.15, 0.15,   # Rain: P(Long,Rain)=0.15, P(Short,Rain)=0.15
    0.07, 0.63),  # No Rain: P(Long,NoRain)=0.07, P(Short,NoRain)=0.63
  nrow = 2, byrow = TRUE,
  dimnames = list(
    X = c("Rain (X=0)", "No Rain (X=1)"),
    Y = c("Long (Y=0)", "Short (Y=1)")
  )
)

cat("\n--- JOINT DISTRIBUTION: COMMUTE AND RAIN ---\n")
print(joint_dist)

# Marginal distributions
marginal_X <- rowSums(joint_dist)
marginal_Y <- colSums(joint_dist)

cat("\nMARGINAL DISTRIBUTION OF X (Weather):\n")
print(marginal_X)

cat("\nMARGINAL DISTRIBUTION OF Y (Commute):\n")
print(marginal_Y)

# Verify: joint probabilities sum to 1
cat("\nSum of all joint probabilities:", sum(joint_dist), "\n")

# =============================================================================
# PART 5: CONDITIONAL PROBABILITY AND BAYES' THEOREM
# =============================================================================

# -----------------------------------------------------------------------------
# 5A. CONDITIONAL PROBABILITIES
# -----------------------------------------------------------------------------

# P(Short | Rain) = P(Short, Rain) / P(Rain)
p_short_given_rain <- joint_dist["Rain (X=0)", "Short (Y=1)"] / marginal_X["Rain (X=0)"]
cat("\n--- CONDITIONAL PROBABILITY ---\n")
cat("P(Short Commute | Rain) =", p_short_given_rain, "\n")

# P(Short | No Rain)
p_short_given_norain <- joint_dist["No Rain (X=1)", "Short (Y=1)"] / marginal_X["No Rain (X=1)"]
cat("P(Short Commute | No Rain) =", p_short_given_norain, "\n")

# P(Long | Rain)
p_long_given_rain <- joint_dist["Rain (X=0)", "Long (Y=0)"] / marginal_X["Rain (X=0)"]
cat("P(Long Commute | Rain) =", p_long_given_rain, "\n")

# P(Long | No Rain)
p_long_given_norain <- joint_dist["No Rain (X=1)", "Long (Y=0)"] / marginal_X["No Rain (X=1)"]
cat("P(Long Commute | No Rain) =", p_long_given_norain, "\n")

# -----------------------------------------------------------------------------
# 5B. BAYES' THEOREM
# -----------------------------------------------------------------------------

# What is P(Rain | Long Commute)?
# P(Rain | Long) = P(Long | Rain) * P(Rain) / P(Long)
p_rain_given_long <- (p_long_given_rain * marginal_X["Rain (X=0)"]) / marginal_Y["Long (Y=0)"]
cat("\nBAYES' THEOREM:\n")
cat("P(Rain | Long Commute) =", p_rain_given_long, "\n")

# Verify directly from joint distribution
p_rain_given_long_direct <- joint_dist["Rain (X=0)", "Long (Y=0)"] / marginal_Y["Long (Y=0)"]
cat("P(Rain | Long Commute) [direct] =", p_rain_given_long_direct, "\n")

# =============================================================================
# PART 6: CONDITIONAL EXPECTED VALUE AND LAW OF ITERATED EXPECTATIONS
# =============================================================================

# -----------------------------------------------------------------------------
# 6A. DIE ROLL EXAMPLE: CONDITIONAL ON ODD/EVEN
# -----------------------------------------------------------------------------

cat("\n--- CONDITIONAL EXPECTED VALUE: DIE ROLL ---\n")

# E[Y | Odd]
e_y_given_odd <- (1 + 3 + 5) / 3
cat("E[Y | Odd] =", e_y_given_odd, "\n")

# E[Y | Even]
e_y_given_even <- (2 + 4 + 6) / 3
cat("E[Y | Even] =", e_y_given_even, "\n")

# -----------------------------------------------------------------------------
# 6B. LAW OF ITERATED EXPECTATIONS
# -----------------------------------------------------------------------------

# E[Y] = E[Y|Odd]*P(Odd) + E[Y|Even]*P(Even)
e_y_lie <- e_y_given_odd * 0.5 + e_y_given_even * 0.5
cat("\nLAW OF ITERATED EXPECTATIONS:\n")
cat("E[Y] = E[Y|Odd]*P(Odd) + E[Y|Even]*P(Even)\n")
cat("E[Y] =", e_y_given_odd, "* 0.5 +", e_y_given_even, "* 0.5 =", e_y_lie, "\n")

# Verify with direct calculation
e_y_direct <- sum(1:6) / 6
cat("E[Y] [direct calculation] =", e_y_direct, "\n")

# =============================================================================
# PART 7: INDEPENDENCE, COVARIANCE, AND CORRELATION
# =============================================================================

# -----------------------------------------------------------------------------
# 7A. TESTING FOR INDEPENDENCE
# -----------------------------------------------------------------------------

cat("\n--- TESTING FOR INDEPENDENCE ---\n")

# For independence: P(X,Y) = P(X) * P(Y) for all combinations
# Check if Rain and Commute are independent

p_rain <- marginal_X["Rain (X=0)"]
p_short <- marginal_Y["Short (Y=1)"]
p_rain_and_short <- joint_dist["Rain (X=0)", "Short (Y=1)"]

cat("P(Rain) =", p_rain, "\n")
cat("P(Short) =", p_short, "\n")
cat("P(Rain) * P(Short) =", p_rain * p_short, "\n")
cat("P(Rain AND Short) =", p_rain_and_short, "\n")

if (abs(p_rain * p_short - p_rain_and_short) < 0.001) {
  cat("CONCLUSION: X and Y appear to be INDEPENDENT\n")
} else {
  cat("CONCLUSION: X and Y are NOT INDEPENDENT\n")
}

# -----------------------------------------------------------------------------
# 7B. COVARIANCE AND CORRELATION
# -----------------------------------------------------------------------------

cat("\n--- COVARIANCE AND CORRELATION ---\n")

# Generate correlated data: hours studied and exam scores
n_students <- 500
hours_studied <- rnorm(n_students, mean = 10, sd = 3)
exam_score <- 50 + 3 * hours_studied + rnorm(n_students, mean = 0, sd = 10)

# Calculate covariance
cov_hours_score <- cov(hours_studied, exam_score)
cat("Cov(Hours, Score) =", round(cov_hours_score, 4), "\n")

# Calculate correlation
cor_hours_score <- cor(hours_studied, exam_score)
cat("Corr(Hours, Score) =", round(cor_hours_score, 4), "\n")

# Interpretation
cat("\nINTERPRETATION:\n")
cat("- Positive correlation indicates students who study more tend to score higher\n")
cat("- Correlation is between -1 and 1 (unitless)\n")
cat("- This correlation of", round(cor_hours_score, 2), "indicates a",
    ifelse(cor_hours_score > 0.5, "strong", ifelse(cor_hours_score > 0.3, "moderate", "weak")),
    "positive relationship\n")

# Visualize
ggplot(data.frame(hours = hours_studied, score = exam_score),
       aes(x = hours, y = score)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = paste0("Hours Studied vs Exam Score (r = ", round(cor_hours_score, 2), ")"),
       x = "Hours Studied", y = "Exam Score") +
  theme_minimal()

# -----------------------------------------------------------------------------
# 7C. ZERO COVARIANCE BUT NOT INDEPENDENT
# -----------------------------------------------------------------------------

cat("\n--- ZERO COVARIANCE DOES NOT IMPLY INDEPENDENCE ---\n")

# Example: X uniform on [-1, 1], Y = X^2
x_vals <- runif(1000, -1, 1)
y_vals <- x_vals^2

cat("Cov(X, X^2) =", round(cov(x_vals, y_vals), 4), "\n")
cat("Corr(X, X^2) =", round(cor(x_vals, y_vals), 4), "\n")
cat("Note: Correlation is near zero, but Y = X^2, so they are clearly NOT independent!\n")

# =============================================================================
# PART 8: SAMPLING AND THE LAW OF LARGE NUMBERS
# =============================================================================

# -----------------------------------------------------------------------------
# 8A. SINGLE SAMPLE
# -----------------------------------------------------------------------------

cat("\n--- SAMPLING FROM POPULATION ---\n")

sample_100 <- sample(population$colon_cancer, 100)
sample_mean_100 <- mean(sample_100)
cat("Sample of N=100, Sample Mean =", sample_mean_100, "\n")

# -----------------------------------------------------------------------------
# 8B. INCREASING SAMPLE SIZE (LAW OF LARGE NUMBERS)
# -----------------------------------------------------------------------------

# Use 100 different sample sizes to show convergence and diminishing variance
sample_sizes <- round(exp(seq(log(30), log(N), length.out = 100)))

# For each sample size, draw multiple samples to show variance reduction
n_reps <- 10  # Number of samples per sample size

lln_results <- do.call(rbind, lapply(sample_sizes, function(n) {
  sample_means <- replicate(n_reps, mean(sample(population$colon_cancer, n)))
  data.frame(
    sample_size = n,
    sample_mean = sample_means,
    rep = 1:n_reps
  )
}))

cat("\nLAW OF LARGE NUMBERS: Sample Mean Converges to Population Mean\n")
cat("Sample sizes range from", min(sample_sizes), "to", max(sample_sizes), "\n")
cat("Drawing", n_reps, "samples at each size to show variance reduction\n")

# Plot LLN with multiple samples per size to show variance reduction
ggplot(lln_results, aes(x = sample_size, y = sample_mean)) +
  geom_point(alpha = 0.3, color = "steelblue", size = 1.5) +
  geom_hline(yintercept = pop_mean, color = "red", linetype = "dashed", linewidth = 1) +
  scale_x_log10(labels = scales::comma) +
  labs(title = "Law of Large Numbers: Sample Mean Converges to Population Mean",
       subtitle = "Each dot is a sample mean; vertical spread shows variance decreasing with sample size",
       x = "Sample Size (log scale)", y = "Sample Mean",
       caption = paste("Red dashed line = Population Mean =", round(pop_mean, 4))) +
  theme_minimal()

# -----------------------------------------------------------------------------
# 8C. SAMPLING DISTRIBUTION OF THE MEAN
# -----------------------------------------------------------------------------

cat("\n--- SAMPLING DISTRIBUTION OF THE MEAN ---\n")

# Draw 10,000 samples of size 100 and calculate means
n_samples <- 10000
sample_size <- 100

sample_means_dist <- replicate(n_samples, {
  mean(sample(population$colon_cancer, sample_size))
})

# Mean and variance of sample means
mean_of_means <- mean(sample_means_dist)
var_of_means <- var(sample_means_dist)

cat("Number of samples:", n_samples, "\n")
cat("Sample size:", sample_size, "\n")
cat("Mean of sample means:", round(mean_of_means, 5), "\n")
cat("Population mean:", round(pop_mean, 5), "\n")
cat("\nVariance of sample means:", round(var_of_means, 6), "\n")
cat("Theoretical variance (sigma^2/n):", round(pop_var / sample_size, 6), "\n")

# Histogram of sample means with more bins for better overlap with density
ggplot(data.frame(means = sample_means_dist), aes(x = means)) +
  geom_histogram(aes(y = after_stat(density)), bins = 50,
                 fill = "steelblue", color = "white", alpha = 0.7) +
  geom_vline(xintercept = pop_mean, color = "red", linetype = "dashed", linewidth = 1) +
  stat_function(fun = dnorm,
                args = list(mean = pop_mean, sd = sqrt(pop_var / sample_size)),
                color = "darkred", linewidth = 1.2) +
  labs(title = paste0("Sampling Distribution of the Mean (n = ", sample_size, ", ",
                      format(n_samples, big.mark = ","), " samples)"),
       x = "Sample Mean", y = "Density",
       caption = "Red dashed line = Population Mean; Red curve = Normal approximation (CLT)") +
  theme_minimal()

cat("\n=== END OF HANDOUT 1 CODE ===\n")
