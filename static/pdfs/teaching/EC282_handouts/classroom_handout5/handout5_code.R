# EC 282: Introduction to Econometrics
# Handout 5: Introduction to Simple Linear Regression
# Spring 2026

# =============================================================================
# SETUP
# =============================================================================

library(ggplot2)

options(scipen = 999)

# =============================================================================
# PART 1: THE DATA
# =============================================================================

# -----------------------------------------------------------------------------
# 1A. LOAD THE GAPMINDER DATA
# -----------------------------------------------------------------------------

gapminder_full <- read.csv(
  "https://raw.githubusercontent.com/resbaz/r-novice-gapminder-files/master/data/gapminder-FiveYearData.csv"
)

# Keep only the year 2007 (a single cross-section)
gap07 <- gapminder_full[gapminder_full$year == 2007, ]

cat("=== GAPMINDER 2007 CROSS-SECTION ===\n")
cat("Number of countries:", nrow(gap07), "\n")
cat("Variables:", paste(names(gap07), collapse = ", "), "\n\n")
summary(gap07[, c("lifeExp", "gdpPercap")])

# -----------------------------------------------------------------------------
# 1B. SCATTERPLOT
# -----------------------------------------------------------------------------

ggplot(gap07, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(color = "steelblue", size = 2, alpha = 0.7) +
  labs(title = "Life Expectancy vs. GDP per Capita (2007)",
       x = "GDP per Capita (USD)",
       y = "Life Expectancy (years)") +
  theme_minimal()

# -----------------------------------------------------------------------------
# 1C. SAMPLE STATISTICS
# -----------------------------------------------------------------------------

X <- gap07$gdpPercap
Y <- gap07$lifeExp
n <- length(Y)

x_bar <- mean(X)
y_bar <- mean(Y)
s_x   <- sd(X)
s_y   <- sd(Y)
r_xy  <- cor(X, Y)

cat("\n=== SAMPLE STATISTICS ===\n")
cat("n:", n, "\n")
cat("X_bar (mean GDP/cap):", round(x_bar, 2), "\n")
cat("Y_bar (mean life exp):", round(y_bar, 2), "\n")
cat("S_X:", round(s_x, 2), "\n")
cat("S_Y:", round(s_y, 2), "\n")
cat("r_XY:", round(r_xy, 4), "\n")

# =============================================================================
# PART 2: ORDINARY LEAST SQUARES
# =============================================================================

# -----------------------------------------------------------------------------
# 2A. OLS BY HAND
# -----------------------------------------------------------------------------

cat("\n=== OLS ESTIMATION BY HAND ===\n")

s_xy <- cov(X, Y)          # sample covariance
s_x2 <- var(X)             # sample variance of X

beta1_hat <- s_xy / s_x2
beta0_hat <- y_bar - beta1_hat * x_bar

cat("Sample covariance S_XY:", round(s_xy, 2), "\n")
cat("Sample variance S_X^2:", round(s_x2, 2), "\n\n")
cat("beta1_hat:", round(beta1_hat, 6), "\n")
cat("beta0_hat:", round(beta0_hat, 4), "\n")

# -----------------------------------------------------------------------------
# 2B. VERIFY WITH lm()
# -----------------------------------------------------------------------------

cat("\n=== OLS ESTIMATION WITH lm() ===\n")

reg <- lm(lifeExp ~ gdpPercap, data = gap07)
summary(reg)

# -----------------------------------------------------------------------------
# 2C. INTERPRETATION: SCALING THE COEFFICIENT
# -----------------------------------------------------------------------------

cat("\n=== INTERPRETING THE SLOPE ===\n")
cat("A $1 increase in GDP/cap ->",
    round(beta1_hat, 6), "year increase in life exp\n")
cat("A $1,000 increase in GDP/cap ->",
    round(beta1_hat * 1000, 4), "year increase\n")
cat("A $10,000 increase in GDP/cap ->",
    round(beta1_hat * 10000, 2), "year increase\n")

# -----------------------------------------------------------------------------
# 2D. PREDICTIONS
# -----------------------------------------------------------------------------

cat("\n=== PREDICTIONS ===\n")

pred_5k  <- beta0_hat + beta1_hat * 5000
pred_40k <- beta0_hat + beta1_hat * 40000

cat("Predicted life exp at GDP/cap = $5,000: ",
    round(pred_5k, 2), "years\n")
cat("Predicted life exp at GDP/cap = $40,000:",
    round(pred_40k, 2), "years\n")

# -----------------------------------------------------------------------------
# 2E. SCATTERPLOT WITH REGRESSION LINE
# -----------------------------------------------------------------------------

ggplot(gap07, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(color = "steelblue", size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE,
              color = "red", linewidth = 1) +
  labs(title = "OLS Regression: Life Expectancy on GDP per Capita",
       x = "GDP per Capita (USD)",
       y = "Life Expectancy (years)") +
  theme_minimal()

# =============================================================================
# PART 3: PREDICTED VALUES AND RESIDUALS
# =============================================================================

# -----------------------------------------------------------------------------
# 3A. COMPUTE PREDICTED VALUES AND RESIDUALS
# -----------------------------------------------------------------------------

cat("\n=== PREDICTED VALUES AND RESIDUALS ===\n")

gap07$Y_hat <- beta0_hat + beta1_hat * X
gap07$u_hat <- Y - gap07$Y_hat

# Show selected countries
subset(gap07, country %in% c("United States", "China",
                              "Nigeria", "Norway", "Brazil"),
       select = c(country, lifeExp, gdpPercap, Y_hat, u_hat))

# -----------------------------------------------------------------------------
# 3B. LARGEST RESIDUALS
# -----------------------------------------------------------------------------

cat("\n=== TOP 5 POSITIVE RESIDUALS (longer-lived than predicted) ===\n")
print(head(gap07[order(-gap07$u_hat),
     c("country", "lifeExp", "gdpPercap", "u_hat")], 5))

cat("\n=== TOP 5 NEGATIVE RESIDUALS (shorter-lived than predicted) ===\n")
print(head(gap07[order(gap07$u_hat),
     c("country", "lifeExp", "gdpPercap", "u_hat")], 5))

# =============================================================================
# PART 4: MEASURES OF FIT
# =============================================================================

# -----------------------------------------------------------------------------
# 4A. TSS, ESS, RSS
# -----------------------------------------------------------------------------

cat("\n=== MEASURES OF FIT ===\n")

TSS <- sum((Y - y_bar)^2)
ESS <- sum((gap07$Y_hat - y_bar)^2)
RSS <- sum(gap07$u_hat^2)

cat("TSS:", round(TSS, 2), "\n")
cat("ESS:", round(ESS, 2), "\n")
cat("RSS:", round(RSS, 2), "\n")
cat("ESS + RSS:", round(ESS + RSS, 2), "\n")
cat("TSS = ESS + RSS?", all.equal(TSS, ESS + RSS), "\n")

# -----------------------------------------------------------------------------
# 4B. R-SQUARED
# -----------------------------------------------------------------------------

R2 <- ESS / TSS

cat("\nR-squared:", round(R2, 4), "\n")
cat("R-squared (alternative):", round(1 - RSS/TSS, 4), "\n")
cat("r_XY squared:", round(r_xy^2, 4), "\n")

# -----------------------------------------------------------------------------
# 4C. STANDARD ERROR OF THE REGRESSION (SER)
# -----------------------------------------------------------------------------

SER <- sqrt(RSS / (n - 2))

cat("\nSER:", round(SER, 4), "years\n")
cat("S_Y:", round(s_y, 4), "years\n")
cat("SER / S_Y:", round(SER / s_y, 4),
    "(SER as fraction of total SD)\n")

# =============================================================================
# PART 5: PROPERTIES OF OLS RESIDUALS
# =============================================================================

cat("\n=== VERIFYING OLS RESIDUAL PROPERTIES ===\n")

# Property 1: Mean of residuals is zero
cat("\nProperty 1 - Mean of residuals:", mean(gap07$u_hat), "\n")

# Property 2: Mean of Y_hat equals Y_bar
cat("\nProperty 2 - Mean of Y_hat:", round(mean(gap07$Y_hat), 4), "\n")
cat("Property 2 - Mean of Y:    ", round(y_bar, 4), "\n")

# Property 3: Residuals uncorrelated with X (and Y_hat)
cat("\nProperty 3 - Sum of u_hat * X:", sum(gap07$u_hat * X), "\n")
cat("Property 3 - Cor(u_hat, X):    ", cor(gap07$u_hat, X), "\n")
cat("Property 3 - Cor(u_hat, Y_hat):", cor(gap07$u_hat, gap07$Y_hat), "\n")

# Property 4: TSS = ESS + RSS
cat("\nProperty 4 - TSS:", round(TSS, 2), "\n")
cat("Property 4 - ESS + RSS:", round(ESS + RSS, 2), "\n")
cat("Property 4 - Equal?", all.equal(TSS, ESS + RSS), "\n")

# -----------------------------------------------------------------------------
# RESIDUAL PLOT
# -----------------------------------------------------------------------------

ggplot(gap07, aes(x = gdpPercap, y = u_hat)) +
  geom_point(color = "steelblue", size = 2, alpha = 0.7) +
  geom_hline(yintercept = 0, color = "red",
             linetype = "dashed") +
  labs(title = "Residuals vs. GDP per Capita",
       subtitle = "Look for patterns -- a good model has random scatter",
       x = "GDP per Capita (USD)",
       y = "Residual (years)") +
  theme_minimal()

# =============================================================================
# PART 6: BRINGING IT TOGETHER
# =============================================================================

# -----------------------------------------------------------------------------
# 6A. REGRESSION LINE PASSES THROUGH (X_BAR, Y_BAR)
# -----------------------------------------------------------------------------

ggplot(gap07, aes(x = gdpPercap, y = lifeExp)) +
  geom_point(color = "steelblue", size = 2, alpha = 0.7) +
  geom_smooth(method = "lm", se = FALSE,
              color = "red", linewidth = 1) +
  annotate("point", x = x_bar, y = y_bar,
           color = "red", size = 5, shape = 18) +
  annotate("text", x = x_bar + 3000, y = y_bar - 2,
           label = paste0("(X_bar, Y_bar) = (",
                          round(x_bar, 0), ", ",
                          round(y_bar, 1), ")"),
           color = "red", hjust = 0) +
  labs(title = "The OLS Line Passes Through the Point of Means",
       x = "GDP per Capita (USD)",
       y = "Life Expectancy (years)") +
  theme_minimal()

# -----------------------------------------------------------------------------
# 6B. PREDICTION WITH SER RANGE
# -----------------------------------------------------------------------------

cat("\n=== PREDICTION FOR GDP/CAP = $20,000 ===\n")

pred_20k <- beta0_hat + beta1_hat * 20000
cat("Predicted life expectancy:", round(pred_20k, 2), "years\n")
cat("Plausible range:", round(pred_20k - SER, 2), "to",
    round(pred_20k + SER, 2), "years\n")

cat("\n=== END OF HANDOUT 5 CODE ===\n")
