library(lfe)
library(haven)
library(dplyr)
library(quantreg)
getwd()

setwd('E:/umich/RealEstateBrokerage-main')
data <- read_dta("individual.dta")


data <- data %>%
  mutate(across(matches("^yearx"), ~ . * influence, .names = "influence_{col}"))

# now we are working on the CIC estimation
pre_policy_data <- data[data$year %in% c(2016, 2017), ]
post_policy_data <- data[data$year %in% c(2018, 2019, 2020, 2021, 2022), ]

# define a set of control variables

hedonic_control <- c("jiadian", "kind", "hotel", "shop_mall", "museum", "old", "ktv", "mid", "prim", "west_food", "super", "sub", "park")
transaction_control <- c("area", "bedroom", "toilet", "house_age", "floor_level", "green_ratio", "total_building", "total_floor_number", "living_room", "elevator_ratio", "kitchen", "floor_ratio", "total_resident")
region_control <- c("pm25", "pop", "light")
brokerage_control <- c("non_online_effect", "ln_nego_changes", "ln_negotiation_period")
control_variables <- c(brokerage_control, hedonic_control, transaction_control, region_control)

quantiles <- c(0.1, 0.25, 0.5, 0.75, 0.9)
coefficients <- list()
standard_errors <- list()

# Loop over each quantile
for (q in quantiles) {
    # Run quantile regression
    model <- rq(price_concession ~ policy + influence + policy_influence + control_variables, 
                data = data, tau = q)
    
    # Store the coefficients and standard errors
    coefficients[[as.character(q)]] <- coef(summary(model))["policy_influence", "Value"]
    standard_errors[[as.character(q)]] <- coef(summary(model))["policy_influence", "Std. Error"]
}


dependent_variable <- c("yearx2_density", "yearx3_density", "yearx4_density", "yearx5_density", "yearx6_density", "yearx7_density", "broker_410", "ln_end_price", "ln_watch_people", "ln_watch_time")


all_vars <- c("ln_income", dependent_variable, control_variables, "year", "bs_code", "id")
data_subset <- data[complete.cases(data[all_vars]), ]
# regression on the dependent variables to generate the residual
model_felm <- felm(as.formula(paste("ln_income ~", paste(dependent_variable, collapse = " + "), "+", paste(control_variables, collapse = " + "), "| year + bs_code + id")), data = data_subset)
data_subset$resid <- residuals(model_felm)



# finally we need to estimate the counterfactual changes in the result





