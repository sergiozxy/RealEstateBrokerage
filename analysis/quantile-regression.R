library(qte)
library(lfe)
library(haven)
library(dplyr)
library(quantreg)
getwd()

setwd('E:/umich/RealEstateBrokerage-main')
data <- read_dta("template.dta")

# so the main idea is to generate the treatment effect where the treated group 
# happens when the

# our result is not influenced by the COVID because the network effect is consistent in terms of the 
# because the stores are faced with the short term shock and the operation should be long term that they can not directly close or open new stores
# so the network effect is consistent in terms of the COVID-19
# Besides, we can also estimate the model trying to see the parallel trend is satisfied or not in this model

# data <- data %>%
#   mutate(across(matches("^yearx"), ~ . * influence, .names = "influence_{col}"))

# now we are working on the CIC estimation
pre_policy_data <- data[data$year %in% c(2016, 2017), ]
post_policy_data <- data[data$year %in% c(2018, 2019, 2020, 2021, 2022), ]

# define a set of control variables

hedonic_control <- c("jiadian", "kind", "hotel", "shop_mall", "museum", "old", "ktv", "mid", "prim", "west_food", "super", "sub", "park")
transaction_control <- c("area", "bedroom", "toilet", "house_age", "floor_level", "green_ratio", "total_building", "total_floor_number", "living_room", "elevator_ratio", "kitchen", "floor_ratio", "total_resident")
region_control <- c("pm25", "pop", "light")
brokerage_control <- c("non_online_effect", "ln_nego_changes", "ln_negotiation_period")
control_variables <- c(brokerage_control, hedonic_control, transaction_control, region_control)

quantiles <- c(0.05, 0.95, 0.05)


dependent_variable <- c("yearx2_density", "yearx3_density", "yearx4_density", "yearx5_density", "yearx6_density", "yearx7_density", "broker_410", "ln_end_price", "ln_watch_people", "ln_watch_time")

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
# c1 <- CiC(re ~ treat, t=1978, tmin1=1975, tname="year",
#           xformla=~age + I(age^2) + education + black + hispanic + married + nodegree,
#           data=lalonde.psid.panel, idname="id", se=TRUE,
#           probs=seq(0.05, 0.95, 0.05))
# summary(c1)
# 
# 
# 
