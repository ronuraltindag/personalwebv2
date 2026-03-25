# EC 282: Introduction to Econometrics
# Handout 6: Inference and Binary Regressors
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

library(ggplot2)

options(scipen = 999)

# =============================================================================
# PART 1: RELOAD THE DATA
# =============================================================================

# Load the Gapminder data (same as Handout 5)
gapminder_full <- read.csv(
  "https://raw.githubusercontent.com/resbaz/r-novice-gapminder-files/master/data/gapminder-FiveYearData.csv"
)

# Keep only the year 2007
gap07 <- gapminder_full[gapminder_full$year == 2007, ]

# Re-estimate the simple regression from Handout 5
reg <- lm(lifeExp ~ gdpPercap, data = gap07)

# =============================================================================
# PART 2: READING THE REGRESSION OUTPUT
# =============================================================================

# -----------------------------------------------------------------------------
# 2A. FULL REGRESSION SUMMARY
# -----------------------------------------------------------------------------

cat("=== REGRESSION SUMMARY ===\n\n")
summary(reg)

# -----------------------------------------------------------------------------
# 2B. EXTRACTING KEY VALUES
# -----------------------------------------------------------------------------

cat("\n=== KEY VALUES FROM THE OUTPUT ===\n")

beta0_hat <- coef(reg)["(Intercept)"]
beta1_hat <- coef(reg)["gdpPercap"]
se_beta1  <- summary(reg)$coefficients["gdpPercap", "Std. Error"]
t_stat_r  <- summary(reg)$coefficients["gdpPercap", "t value"]
p_val_r   <- summary(reg)$coefficients["gdpPercap", "Pr(>|t|)"]
r_squared <- summary(reg)$r.squared

cat("beta0_hat:", round(beta0_hat, 4), "\n")
cat("beta1_hat:", round(beta1_hat, 7), "\n")
cat("SE(beta1_hat):", round(se_beta1, 7), "\n")
cat("t-statistic:", round(t_stat_r, 3), "\n")
cat("p-value:", p_val_r, "\n")
cat("R-squared:", round(r_squared, 4), "\n")

# =============================================================================
# PART 3: HYPOTHESIS TESTING
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. COMPUTE T-STATISTIC BY HAND
# -----------------------------------------------------------------------------

cat("\n=== HYPOTHESIS TESTING ===\n")
cat("H0: beta1 = 0  (no relationship)\n")
cat("HA: beta1 ≠ 0  (there is a relationship)\n\n")

t_stat <- beta1_hat / se_beta1

cat("beta1_hat:", beta1_hat, "\n")
cat("SE(beta1_hat):", se_beta1, "\n")
cat("t-statistic (by hand):", round(t_stat, 3), "\n")
cat("t-statistic (from summary):", round(t_stat_r, 3), "\n")

# -----------------------------------------------------------------------------
# 3B. DECISION USING CRITICAL VALUES
# -----------------------------------------------------------------------------

cat("\n=== DECISION ===\n")
cat("|t| =", round(abs(t_stat), 3), "\n")
cat("Reject at 5% level (|t| > 1.96)?", abs(t_stat) > 1.96, "\n")
cat("Reject at 1% level (|t| > 2.576)?", abs(t_stat) > 2.576, "\n")

# -----------------------------------------------------------------------------
# 3C. COMPUTE P-VALUE
# -----------------------------------------------------------------------------

cat("\n=== P-VALUE ===\n")

# Two-sided p-value
p_value <- 2 * pnorm(-abs(t_stat))
cat("p-value (two-sided, by hand):", p_value, "\n")
cat("p-value (from summary):", p_val_r, "\n")

# One-sided p-value (testing beta1 > 0)
p_value_one <- pnorm(-abs(t_stat))
cat("p-value (one-sided):", p_value_one, "\n")

# =============================================================================
# PART 4: CONFIDENCE INTERVALS
# =============================================================================

# -----------------------------------------------------------------------------
# 4A. 95% CONFIDENCE INTERVAL BY HAND
# -----------------------------------------------------------------------------

cat("\n=== CONFIDENCE INTERVALS ===\n")

ci_lower <- beta1_hat - 1.96 * se_beta1
ci_upper <- beta1_hat + 1.96 * se_beta1

cat("95% CI (by hand): [", round(ci_lower, 7), ",",
    round(ci_upper, 7), "]\n")

# Verify with confint()
cat("95% CI (from R):\n")
print(confint(reg, "gdpPercap", level = 0.95))

# -----------------------------------------------------------------------------
# 4B. 99% CONFIDENCE INTERVAL
# -----------------------------------------------------------------------------

ci99_lower <- beta1_hat - 2.576 * se_beta1
ci99_upper <- beta1_hat + 2.576 * se_beta1

cat("\n99% CI (by hand): [", round(ci99_lower, 7), ",",
    round(ci99_upper, 7), "]\n")

cat("99% CI (from R):\n")
print(confint(reg, "gdpPercap", level = 0.99))

# -----------------------------------------------------------------------------
# 4C. CI FOR PREDICTED CHANGE
# -----------------------------------------------------------------------------

cat("\n=== CI FOR PREDICTED CHANGE (delta_X = $10,000) ===\n")

delta_X <- 10000
pred_change <- beta1_hat * delta_X
ci_change_lower <- ci_lower * delta_X
ci_change_upper <- ci_upper * delta_X

cat("Predicted change:", round(pred_change, 2), "years\n")
cat("95% CI for change: [", round(ci_change_lower, 2), ",",
    round(ci_change_upper, 2), "] years\n")

# =============================================================================
# PART 5: REGRESSION WITH BINARY VARIABLES
# =============================================================================

# -----------------------------------------------------------------------------
# 5A. CREATE BINARY VARIABLE
# -----------------------------------------------------------------------------

cat("\n=== BINARY VARIABLE: AFRICA ===\n")

gap07$africa <- ifelse(gap07$continent == "Africa", 1, 0)

cat("Number of African countries:", sum(gap07$africa), "\n")
cat("Number of non-African countries:", sum(1 - gap07$africa), "\n")

# -----------------------------------------------------------------------------
# 5B. GROUP MEANS
# -----------------------------------------------------------------------------

cat("\n=== GROUP MEANS ===\n")

mean_africa     <- mean(gap07$lifeExp[gap07$africa == 1])
mean_non_africa <- mean(gap07$lifeExp[gap07$africa == 0])

cat("Mean life exp (Africa):", round(mean_africa, 2), "years\n")
cat("Mean life exp (non-Africa):", round(mean_non_africa, 2), "years\n")
cat("Difference:", round(mean_africa - mean_non_africa, 2), "years\n")

# -----------------------------------------------------------------------------
# 5C. BINARY REGRESSION
# -----------------------------------------------------------------------------

cat("\n=== BINARY REGRESSION ===\n")

reg_binary <- lm(lifeExp ~ africa, data = gap07)
summary(reg_binary)

# Verify: intercept = mean of non-Africa, slope = difference
cat("\nVerification:\n")
cat("beta0 (intercept) =", round(coef(reg_binary)[1], 4),
    "vs. mean non-Africa =", round(mean_non_africa, 4), "\n")
cat("beta1 (slope)     =", round(coef(reg_binary)[2], 4),
    "vs. difference     =", round(mean_africa - mean_non_africa, 4), "\n")

# -----------------------------------------------------------------------------
# 5D. COMPARISON WITH T-TEST
# -----------------------------------------------------------------------------

cat("\n=== TWO-SAMPLE T-TEST ===\n")
t.test(lifeExp ~ africa, data = gap07, var.equal = FALSE)

# -----------------------------------------------------------------------------
# 5E. CONFIDENCE INTERVAL FOR BINARY COEFFICIENT
# -----------------------------------------------------------------------------

cat("\n=== 95% CI FOR AFRICA COEFFICIENT ===\n")
print(confint(reg_binary, "africa", level = 0.95))

# -----------------------------------------------------------------------------
# 5F. VISUALIZATION
# -----------------------------------------------------------------------------

ggplot(gap07, aes(x = factor(africa, labels = c("Non-Africa", "Africa")),
                  y = lifeExp)) +
  geom_boxplot(fill = c("steelblue", "coral"), alpha = 0.7) +
  geom_jitter(width = 0.2, alpha = 0.4, size = 1.5) +
  labs(title = "Life Expectancy: Africa vs. Rest of World (2007)",
       x = "", y = "Life Expectancy (years)") +
  theme_minimal()

# =============================================================================
# PART 6: BRINGING IT TOGETHER
# =============================================================================

# -----------------------------------------------------------------------------
# 6A. SIDE-BY-SIDE COMPARISON
# -----------------------------------------------------------------------------

cat("\n=== SIDE-BY-SIDE COMPARISON ===\n\n")

cat("=== GDP per Capita Regression ===\n")
cat("beta0:", round(coef(reg)[1], 4), "\n")
cat("beta1:", round(coef(reg)[2], 7), "\n")
cat("SE(beta1):", round(summary(reg)$coefficients[2, 2], 7), "\n")
cat("t-stat:", round(summary(reg)$coefficients[2, 3], 3), "\n")
cat("R-squared:", round(summary(reg)$r.squared, 4), "\n\n")

cat("=== Africa Dummy Regression ===\n")
cat("beta0:", round(coef(reg_binary)[1], 4), "\n")
cat("beta1:", round(coef(reg_binary)[2], 4), "\n")
cat("SE(beta1):", round(summary(reg_binary)$coefficients[2, 2], 4), "\n")
cat("t-stat:", round(summary(reg_binary)$coefficients[2, 3], 3), "\n")
cat("R-squared:", round(summary(reg_binary)$r.squared, 4), "\n")

cat("\n=== END OF HANDOUT 6 CODE ===\n")
