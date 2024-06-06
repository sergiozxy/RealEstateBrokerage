library(quantreg)
library(lfe)
library(haven)
getwd()

setwd('E:/umich/RealEstateBrokerage-main')
data <- read_dta("for-analysis.dta")

# define a set of control variables

hedonic_control <- c("jiadian", "kind", "hotel", "shop_mall", "museum", "old", "ktv", "mid", "prim", "west_food", "super", "sub", "park")
transaction_control <- c("area", "bedroom", "toilet", "house_age", "floor_level", "green_ratio", "total_building", "total_floor_number", "living_room", "elevator_ratio", "kitchen", "floor_ratio", "total_resident")
region_control <- c("pm25", "pop", "light")
brokerage_control <- c("non_online_effect", "ln_nego_changes", "ln_negotiation_period")
lag_hedonic_control <- paste0(hedonic_control, "_hedonic_lag")

dependent_variable <- c("yearx2_density", "yearx3_density", "yearx4_density", "yearx5_density", "yearx6_density", "yearx7_density", "broker_410", "ln_end_price", "ln_watch_people", "ln_watch_time")
control_variables <- c(brokerage_control, lag_hedonic_control, transaction_control, region_control)

all_vars <- c("ln_income", dependent_variable, control_variables, "year", "bs_code", "id")
data_subset <- data[complete.cases(data[all_vars]), ]
# regression on the dependent variables to generate the residual
model_felm <- felm(as.formula(paste("ln_income ~", paste(dependent_variable, collapse = " + "), "+", paste(control_variables, collapse = " + "), "| year + bs_code + id")), data = data_subset)
data_subset$resid <- residuals(model_felm)

# save the residual and conduct the quantile model
key_vars <- c("yearx2_density", "yearx3_density", "yearx4_density", "yearx5_density", "yearx6_density", "yearx7_density")
quantile_results <- list()

for (var in key_vars) {
    formula <- as.formula(paste(var, "~ avg_watch_time"))
    quantile_model <- rq(formula, data = data_subset, tau = seq(0.1, 0.9, by = 0.1))
    quantile_results[[var]] <- summary(quantile_model)
}


quantile_results
