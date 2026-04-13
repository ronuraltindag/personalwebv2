# EC 282: Introduction to Econometrics
# Handout 7: Multiple Regression
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

# Install the wooldridge package (run once if not installed)
# install.packages("wooldridge")

library(wooldridge)
library(ggplot2)

options(scipen = 999)

# Load the CPS wage data
data(wage1)

# =============================================================================
# PART 1: EXPLORE THE DATA
# =============================================================================

cat("=== DATA OVERVIEW ===\n\n")
cat("Number of workers:", nrow(wage1), "\n")
cat("Variables:", paste(names(wage1)[1:12], collapse = ", "), "\n\n")

# Key variables:
# wage     = average hourly earnings ($)
# educ     = years of education
# exper    = years of potential experience
# tenure   = years with current employer
# female   = 1 if female, 0 if male
# nonwhite = 1 if nonwhite, 0 if white
# married  = 1 if married
# northcen, south, west = region dummies (northeast is omitted)

cat("=== SUMMARY STATISTICS ===\n\n")
summary(wage1[, c("wage", "educ", "exper", "tenure",
                  "female", "nonwhite", "married")])

# Scatterplot: wages vs education
ggplot(wage1, aes(x = educ, y = wage)) +
  geom_jitter(color = "steelblue", alpha = 0.5, width = 0.3) +
  geom_smooth(method = "lm", color = "red", se = FALSE) +
  labs(title = "Hourly Wage vs. Years of Education",
       x = "Years of Education",
       y = "Hourly Wage ($)") +
  theme_minimal()

# =============================================================================
# PART 2: SIMPLE REGRESSION
# =============================================================================

cat("\n=== MODEL 1: SIMPLE REGRESSION ===\n\n")
reg1 <- lm(wage ~ educ, data = wage1)
summary(reg1)

# =============================================================================
# PART 3: MULTIPLE REGRESSION AND PARTIAL EFFECTS
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. ADD EXPERIENCE AND TENURE
# -----------------------------------------------------------------------------

cat("\n=== MODEL 2: MULTIPLE REGRESSION ===\n\n")
reg2 <- lm(wage ~ educ + exper + tenure, data = wage1)
summary(reg2)

cat("\nComparison of education coefficients:\n")
cat("Model 1 (simple):", round(coef(reg1)["educ"], 4), "\n")
cat("Model 2 (multiple):", round(coef(reg2)["educ"], 4), "\n")
cat("Change:", round(coef(reg2)["educ"] - coef(reg1)["educ"], 4), "\n")

# -----------------------------------------------------------------------------
# 3B. VERIFY THE OVB FORMULA
# -----------------------------------------------------------------------------

cat("\n=== OVB VERIFICATION ===\n\n")

# Auxiliary regression: exper on educ
aux_reg <- lm(exper ~ educ, data = wage1)
alpha1_hat <- coef(aux_reg)["educ"]
cat("alpha1_hat (exper ~ educ):", round(alpha1_hat, 4), "\n")
cat("Correlation(educ, exper):", round(cor(wage1$educ, wage1$exper), 4), "\n")

# OVB formula verification (2-variable case)
reg_two <- lm(wage ~ educ + exper, data = wage1)
beta1_tilde <- coef(reg1)["educ"]        # simple regression
beta1_hat   <- coef(reg_two)["educ"]     # multiple regression
beta2_hat   <- coef(reg_two)["exper"]    # coefficient on exper

cat("\nbeta1_tilde (simple):", round(beta1_tilde, 4), "\n")
cat("beta1_hat (multiple):", round(beta1_hat, 4), "\n")
cat("beta2_hat (exper):", round(beta2_hat, 4), "\n")
cat("beta2_hat * alpha1_hat:", round(beta2_hat * alpha1_hat, 4), "\n")
cat("beta1_hat + beta2_hat * alpha1_hat:",
    round(beta1_hat + beta2_hat * alpha1_hat, 4), "\n")
cat("Does it match beta1_tilde?",
    round(beta1_hat + beta2_hat * alpha1_hat, 4) ==
    round(beta1_tilde, 4), "\n")

# -----------------------------------------------------------------------------
# 3C. ADD DEMOGRAPHIC CONTROLS
# -----------------------------------------------------------------------------

cat("\n=== MODEL 3: WITH DEMOGRAPHICS ===\n\n")
reg3 <- lm(wage ~ educ + exper + tenure + female + nonwhite, data = wage1)
summary(reg3)

cat("\nEducation coefficient across models:\n")
cat("Model 1:", round(coef(reg1)["educ"], 4), "\n")
cat("Model 2:", round(coef(reg2)["educ"], 4), "\n")
cat("Model 3:", round(coef(reg3)["educ"], 4), "\n")

# =============================================================================
# PART 4: MEASURES OF FIT
# =============================================================================

cat("\n=== MEASURES OF FIT ===\n\n")

models <- list(reg1, reg2, reg3)
model_names <- c("(1) Educ only", "(2) + Exper, Tenure",
                 "(3) + Female, Nonwhite")

cat(sprintf("%-25s %8s %8s %8s %8s\n",
    "Model", "R2", "Adj R2", "SER", "RMSE"))
cat(paste(rep("-", 60), collapse = ""), "\n")

for (i in 1:3) {
  s <- summary(models[[i]])
  n <- nrow(models[[i]]$model)
  k <- length(coef(models[[i]])) - 1
  RSS <- sum(residuals(models[[i]])^2)
  SER <- sqrt(RSS / (n - k - 1))
  RMSE <- sqrt(RSS / n)
  cat(sprintf("%-25s %8.4f %8.4f %8.4f %8.4f\n",
      model_names[i], s$r.squared, s$adj.r.squared, SER, RMSE))
}

# Irrelevant variable demonstration
cat("\n=== IRRELEVANT VARIABLE (numdep) ===\n\n")
reg_irrel <- lm(wage ~ educ + exper + tenure + numdep, data = wage1)

cat("Model 2:     R2 =", round(summary(reg2)$r.squared, 4),
    "  Adj R2 =", round(summary(reg2)$adj.r.squared, 4), "\n")
cat("+ numdep:    R2 =", round(summary(reg_irrel)$r.squared, 4),
    "  Adj R2 =", round(summary(reg_irrel)$adj.r.squared, 4), "\n")

# =============================================================================
# PART 5: DUMMY VARIABLES AND THE DUMMY VARIABLE TRAP
# =============================================================================

# -----------------------------------------------------------------------------
# 5A. THE DUMMY VARIABLE TRAP
# -----------------------------------------------------------------------------

cat("\n=== DUMMY VARIABLE TRAP ===\n\n")

wage1$male <- 1 - wage1$female

# Try to include both female and male
reg_trap <- lm(wage ~ educ + exper + female + male, data = wage1)
summary(reg_trap)

# -----------------------------------------------------------------------------
# 5B. FULL MODEL WITH REGION DUMMIES
# -----------------------------------------------------------------------------

cat("\n=== MODEL 4: FULL MODEL ===\n\n")
reg4 <- lm(wage ~ educ + exper + tenure + female + nonwhite +
           married + northcen + south + west, data = wage1)
summary(reg4)

# =============================================================================
# PART 6: MULTICOLLINEARITY
# =============================================================================

# -----------------------------------------------------------------------------
# 6A. PERFECT MULTICOLLINEARITY
# -----------------------------------------------------------------------------

cat("\n=== PERFECT MULTICOLLINEARITY ===\n\n")

# Age = educ + 6 + exper (exact)
wage1$age <- wage1$educ + 6 + wage1$exper

reg_perfect_mc <- lm(wage ~ educ + exper + age, data = wage1)
summary(reg_perfect_mc)

# -----------------------------------------------------------------------------
# 6B. IMPERFECT MULTICOLLINEARITY
# -----------------------------------------------------------------------------

cat("\n=== IMPERFECT MULTICOLLINEARITY ===\n\n")

set.seed(42)
wage1$age_noisy <- wage1$age + rnorm(nrow(wage1), 0, 2)

cat("Correlation(age_noisy, age):",
    round(cor(wage1$age_noisy, wage1$age), 4), "\n\n")

reg_noisy <- lm(wage ~ educ + exper + age_noisy, data = wage1)
summary(reg_noisy)

# Compare standard errors
cat("\nStandard error comparison:\n")
cat("  SE(educ) in Model 2:", round(summary(reg2)$coefficients["educ", "Std. Error"], 4), "\n")
cat("  SE(educ) with noisy age:", round(summary(reg_noisy)$coefficients["educ", "Std. Error"], 4), "\n")
cat("  SE(exper) in Model 2:", round(summary(reg2)$coefficients["exper", "Std. Error"], 4), "\n")
cat("  SE(exper) with noisy age:", round(summary(reg_noisy)$coefficients["exper", "Std. Error"], 4), "\n")

# -----------------------------------------------------------------------------
# 6C. VARIANCE INFLATION FACTOR (VIF)
# -----------------------------------------------------------------------------

cat("\n=== VARIANCE INFLATION FACTOR ===\n\n")

# Manual VIF function
compute_vif <- function(model) {
  vars <- attr(terms(model), "term.labels")
  dat  <- model$model
  vifs <- numeric(length(vars))
  names(vifs) <- vars
  for (i in seq_along(vars)) {
    f <- as.formula(paste(vars[i], "~",
         paste(vars[-i], collapse = " + ")))
    r2 <- summary(lm(f, data = dat))$r.squared
    vifs[i] <- 1 / (1 - r2)
  }
  return(round(vifs, 2))
}

cat("VIF for Model 2 (no multicollinearity):\n")
print(compute_vif(reg2))

cat("\nVIF for noisy age model (severe multicollinearity):\n")
print(compute_vif(reg_noisy))

# =============================================================================
# PART 7: HYPOTHESIS TESTING AND F-TESTS
# =============================================================================

# -----------------------------------------------------------------------------
# 7A. TESTING INDIVIDUAL COEFFICIENTS
# -----------------------------------------------------------------------------

cat("\n=== HYPOTHESIS TESTING: EDUCATION ===\n\n")

beta_educ <- coef(reg4)["educ"]
se_educ   <- summary(reg4)$coefficients["educ", "Std. Error"]
t_stat    <- beta_educ / se_educ
p_value   <- 2 * pnorm(-abs(t_stat))

cat("beta_hat (educ):", round(beta_educ, 4), "\n")
cat("SE:", round(se_educ, 4), "\n")
cat("t-statistic:", round(t_stat, 3), "\n")
cat("p-value:", p_value, "\n")
cat("95% CI: [", round(beta_educ - 1.96 * se_educ, 4), ",",
    round(beta_educ + 1.96 * se_educ, 4), "]\n")

# -----------------------------------------------------------------------------
# 7B. F-TEST FOR JOINT SIGNIFICANCE
# -----------------------------------------------------------------------------

cat("\n=== F-TEST: JOINT SIGNIFICANCE OF REGIONS ===\n\n")

# Restricted model (without region dummies)
reg_restricted <- lm(wage ~ educ + exper + tenure + female +
                     nonwhite + married, data = wage1)

# Unrestricted model (with region dummies)
reg_unrestricted <- reg4

# R-squared values
R2_unr <- summary(reg_unrestricted)$r.squared
R2_res <- summary(reg_restricted)$r.squared

cat("R2 (unrestricted):", round(R2_unr, 4), "\n")
cat("R2 (restricted):", round(R2_res, 4), "\n")

# F-test by hand
q <- 3       # number of restrictions
k <- 9       # regressors in unrestricted model
n <- nrow(wage1)

F_stat <- ((R2_unr - R2_res) / q) / ((1 - R2_unr) / (n - k - 1))
p_value_F <- 1 - pf(F_stat, q, n - k - 1)

cat("\nF-statistic (by hand):", round(F_stat, 4), "\n")
cat("Critical value (5%, q=3):", round(qf(0.95, q, n - k - 1), 4), "\n")
cat("p-value:", round(p_value_F, 4), "\n")
cat("Reject H0 at 5%?", F_stat > qf(0.95, q, n - k - 1), "\n")

# Verify with anova()
cat("\nanova() verification:\n")
print(anova(reg_restricted, reg_unrestricted))

# =============================================================================
# PART 8: PUTTING IT ALL TOGETHER
# =============================================================================

cat("\n=== FINAL MODEL COMPARISON ===\n\n")

models_all <- list(reg1, reg2, reg3, reg4)
names_all  <- c("(1) Educ", "(2)+Exp,Ten", "(3)+Fem,NW", "(4) Full")

for (i in 1:4) {
  s <- summary(models_all[[i]])
  n <- nrow(models_all[[i]]$model)
  k <- length(coef(models_all[[i]])) - 1
  RSS <- sum(residuals(models_all[[i]])^2)
  cat(names_all[i], "\n")
  cat("  educ coef:", round(coef(models_all[[i]])["educ"], 4), "\n")
  cat("  SE(educ):", round(s$coefficients["educ", "Std. Error"], 4), "\n")
  cat("  R2:", round(s$r.squared, 4), "\n")
  cat("  Adj R2:", round(s$adj.r.squared, 4), "\n")
  cat("  SER:", round(sqrt(RSS / (n - k - 1)), 4), "\n\n")
}

# Visualization: Gender wage gap by education
ggplot(wage1, aes(x = educ, y = wage,
       color = factor(female, labels = c("Male", "Female")))) +
  geom_jitter(alpha = 0.4, width = 0.3) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 1.2) +
  labs(title = "Wage vs. Education by Gender",
       x = "Years of Education", y = "Hourly Wage ($)",
       color = "Gender") +
  theme_minimal()

cat("\n=== END OF HANDOUT 7 CODE ===\n")
