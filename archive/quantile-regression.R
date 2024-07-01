# library(qte) # this is the implementation of CIC model and we do not need it right now

# if you are using the caen version's R
# first install R-tools from https://cran.rstudio.com/bin/windows/Rtools/history.html
# this CAEN version is 4.0.2 and install it to the zxuyuan
# install.packages("rlang")
# install.packages("lifecycle")
# and then install other packages
library(lfe)
library(haven)
library(dplyr)
library(quantreg)
library(fixest)
set.seed(130)
getwd()

setwd('C:/Users/zxuyuan/Downloads')
# setwd('/home/xuyuan/Desktop/2024 summer/real estate paper/oritignal cleaning/RealEstateBrokerage')
data <- read_dta("template.dta")

# now here we consider the CIC model where the dependent variable is the influence
# and the treatment effect is a set of variables indicating whether the online 
# consolidation spread the influence effect. I have already know that the treatment 
# effect can make the influence effect heterogenous because treatment effect can 
# have different heterogenous effect on various level of the influence, 
# and therefore, we cannot use traditional DID, then we have to use CIC and the 
# expected result should be a quantiled treatment effect on various level of the 
# influence. Give me the code in R.

pre_policy_data <- data[data$year %in% c(2016, 2017), ]
post_policy_data <- data[data$year %in% c(2018, 2019, 2020, 2021, 2022), ]

hedonic_control <- c("jiadian", "kind", "hotel", "shop_mall", "museum", "old", "ktv", "mid", "prim", "west_food", "super", "sub", "park")
transaction_control <- c("area", "bedroom", "toilet", "house_age", "floor_level", "green_ratio", "total_building", "total_floor_number", "living_room", "elevator_ratio", "kitchen", "floor_ratio", "total_resident")
region_control <- c("pm25", "pop", "light")
brokerage_control <- c("non_online_effect", "ln_nego_changes", "ln_negotiation_period")
other_main_variables <- c("broker_410", "ln_end_price", "ln_watch_people", "ln_watch_time")
control_variables <- c(other_main_variables, brokerage_control, hedonic_control, transaction_control, region_control)
control_formula <- paste(control_variables, collapse = " + ")
dependent_variable <- c("pre1_treatment", "treatment", "post1_treatment", "post2_treatment", "post3_treatment")
quantiles <- c(0.05, 0.95, 0.05)

data <- data %>%
  mutate(year_factor = as.factor(year),
         bs_code_year = interaction(bs_code, year, drop = TRUE),
         id_factor = as.factor(id))

formula_influence <- as.formula(paste("influence ~", paste(dependent_variable, collapse = " + "), "+", 
                                      paste(control_variables, collapse = " + "), "+ bs_code_year + id_factor"))
results <- list()
for (q in quantiles) {
  rq_model <- rq(formula_influence, tau = q, data = data)
  
  # Clustered standard errors
  clustered_se <- summary(rq_model, se = "boot", cluster = data$bs_code)
  
  # Extract relevant results
  relevant_results <- clustered_se$coefficients[dependent_variable, ]
  
  results[[paste0("Quantile_", q)]] <- relevant_results
}



# so the main idea is to generate the treatment effect where the treated group 
# happens when the

# our result is not influenced by the COVID because the network effect is consistent in terms of the 
# because the stores are faced with the short term shock and the operation should be long term that they can not directly close or open new stores
# so the network effect is consistent in terms of the COVID-19
# Besides, we can also estimate the model trying to see the parallel trend is satisfied or not in this model

# data <- data %>%
#   mutate(across(matches("^yearx"), ~ . * influence, .names = "influence_{col}"))

# now we are working on the CIC estimation


# define a set of control variables


# finally we need to estimate the counterfactual changes in the result


c1 <- CiC(influence ~ treat, t=2018, tmin1=2016, tname="year",
          xformla=~age + I(age^2) + education + black + hispanic + married + nodegree,
          data=lalonde.psid.panel, idname="id", se=TRUE,
          probs=seq(0.05, 0.95, 0.05))


# I am using the qte package available in the Rstudio.
# 
# # Load the required library
# library(qte)
# 
# data(lalonde)
# ## Run the Change in Changes model conditioning on age, education,
# ## black, hispanic, married, and nodegree
c1 <- CiC(re ~ treat, t=1978, tmin1=1975, tname="year",
          xformla=~age + I(age^2) + education + black + hispanic + married + nodegree,
          data=lalonde.psid.panel, idname="id", se=TRUE,
          probs=seq(0.05, 0.95, 0.05))
# summary(c1)
# 
# 
# 
