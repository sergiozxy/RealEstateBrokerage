cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

// revise based on L_hedonic_control

use template.dta, clear

/*

** basic idea: 
* we first conduct using stylized facts: density ~ ln_income and so on
* estimation of the dynamic effect of density to these
* estimation of lianjia's entry to the effects
* estimation of GMM to capture the lagged influential impact

** mechanism: 
* Compare mature markets where brokerages have been established for a long time with emerging markets where brokerages are relatively new.
*  Competitor Analysis: Compare areas where Lianjia faces different levels of competition. The impact of Lianjia in highly competitive markets versus those with limited competition could reveal its market influence.

* robustness test: using 500 meters to make it robust

// we shuold define a new variable called the price concession,
// the price changes relative to the whole initial housing price.
*/

tab year, gen(yearx)

foreach var of varlist yearx* {
    gen `var'_density = `var' * density
}

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control non_online_effect ln_watch_time ln_nego_changes ln_negotiation_period

foreach var in $hedonic_control {
    gen `var'_hedonic_lag = L.`var'
}

global Lag_hedonic_control *_hedonic_lag

global dependent_variable yearx2_density yearx3_density yearx4_density yearx5_density yearx6_density yearx7_density

/* Stylized Fact */

reghdfe ln_income density broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession density broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead density broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

/* Dynamic Effect and Estimtion */

reghdfe ln_income L.ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession L.price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead L.ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

xtabond2 L(0/1)ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control i.year,  ///
gmmstyle(L.ln_income L.ln_negotiation_period total_building L.house_age, equation(diff) lag(1 2) collapse) ///
ivstyle($dependent_variable broker_420 ln_watch_people non_online_effect ln_watch_time ln_nego_changes area bedroom toilet floor_level green_ratio total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident jiadian_hedonic_lag kind_hedonic_lag hotel_hedonic_lag shop_mall_hedonic_lag museum_hedonic_lag old_hedonic_lag ktv_hedonic_lag mid_hedonic_lag prim_hedonic_lag west_food_hedonic_lag super_hedonic_lag sub_hedonic_lag park_hedonic_lag pm25 pop light i.year, equation(diff)) noconstant twostep nolevel robust 

// looking good result, but can refine
xtabond2 L(0/1)price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control i.year,  ///
gmmstyle(L.price_concession floor_level total_building L.house_age, equation(diff) lag(1 2) collapse) ///
ivstyle($dependent_variable broker_420 ln_watch_people non_online_effect ln_watch_time ln_nego_changes ln_negotiation_period area bedroom toilet  green_ratio total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident jiadian_hedonic_lag kind_hedonic_lag hotel_hedonic_lag shop_mall_hedonic_lag museum_hedonic_lag old_hedonic_lag ktv_hedonic_lag mid_hedonic_lag prim_hedonic_lag west_food_hedonic_lag super_hedonic_lag sub_hedonic_lag park_hedonic_lag pm25 pop light i.year, equation(diff)) noconstant twostep nolevel robust 

// now working on this result
// we need to refine the result to make it comparable so that we would not bother to calculate the results further

xtabond2 L(0/1)price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control i.year,  ///
gmmstyle(L.price_concession floor_level total_building L.house_age, equation(diff) lag(1 2) collapse) ///
ivstyle($dependent_variable broker_420 ln_watch_people non_online_effect ln_watch_time ln_nego_changes ln_negotiation_period area bedroom toilet  green_ratio total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident jiadian_hedonic_lag kind_hedonic_lag hotel_hedonic_lag shop_mall_hedonic_lag museum_hedonic_lag old_hedonic_lag ktv_hedonic_lag mid_hedonic_lag prim_hedonic_lag west_food_hedonic_lag super_hedonic_lag sub_hedonic_lag park_hedonic_lag pm25 pop light i.year, equation(diff)) noconstant twostep nolevel robust 










xtabond2 L(0/1)ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control i.year,  ///
gmmstyle(L.ln_lead L.ln_negotiation_period total_building L.house_age, equation(diff) lag(1 2) collapse) ///
ivstyle($dependent_variable broker_420 ln_watch_people non_online_effect ln_watch_time ln_nego_changes area bedroom toilet floor_level green_ratio total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident jiadian_hedonic_lag kind_hedonic_lag hotel_hedonic_lag shop_mall_hedonic_lag museum_hedonic_lag old_hedonic_lag ktv_hedonic_lag mid_hedonic_lag prim_hedonic_lag west_food_hedonic_lag super_hedonic_lag sub_hedonic_lag park_hedonic_lag pm25 pop light i.year, equation(diff)) noconstant twostep nolevel robust 


xtabond2 L(0/1)ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control i.year,  ///
gmmstyle(L.ln_lead ln_negotiation_period ln_nego_changes L.house_age, equation(diff) lag(1 2) collapse) ///
ivstyle($dependent_variable total_building ln_watch_time broker_420 ln_watch_people non_online_effect   area bedroom toilet floor_level green_ratio total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident jiadian_hedonic_lag kind_hedonic_lag hotel_hedonic_lag shop_mall_hedonic_lag museum_hedonic_lag old_hedonic_lag ktv_hedonic_lag mid_hedonic_lag prim_hedonic_lag west_food_hedonic_lag super_hedonic_lag sub_hedonic_lag park_hedonic_lag pm25 pop light i.year, equation(diff)) noconstant twostep nolevel robust 



/* Exogenous Shock with lianjia's entry */
preserve

drop entry* pre* pos*
by id: gen firstobs = (_n == 1)
by id: gen dropflag = (firstobs == 1 & lianjia_420 > 0)
by id: egen todrop = max(dropflag)

order firstobs dropflag todrop lianjia_420
drop if todrop == 1
drop firstobs dropflag todrop

by id: gen flag = sum(lianjia_420 > 0)
by id: gen entry = (flag == 1) & (lianjia_420 > 0)
order flag entry lianjia_420


forvalues i = 1/3 {
    by id: gen entry_lianjia_lag`i' = L`i'.entry
    by id: gen entry_lianjia_lead`i' = F`i'.entry
}

gen pre1 = (entry_lianjia_lag1 == 1)
gen pre2 = (entry_lianjia_lag2 == 1)
gen pre3 = (entry_lianjia_lag3 == 1)
gen post1 = (entry_lianjia_lead1 == 1)
gen post2 = (entry_lianjia_lead2 == 1)
gen post3 = (entry_lianjia_lead3 == 1)

drop entry_lianjia_lag1 entry_lianjia_lag2 entry_lianjia_lag3 ///
 entry_lianjia_lead1 entry_lianjia_lead2 entry_lianjia_lead3

reghdfe ln_income pre3 pre2 entry post1 post2 post3 broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession pre3 pre2 entry post1 post2 post3 broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead pre3 pre2 entry post1 post2 post3 broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
restore


/* Heterogenous Check */

** mechanism: 
* Compare mature markets where brokerages have been established for a long time with emerging markets where brokerages are relatively new.
* Competitor Analysis: Compare areas where Lianjia faces different levels of competition. The impact of Lianjia in highly competitive markets versus those with limited competition could reveal its market influence.

reghdfe ln_income L.ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_income L.ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession L.price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession L.price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead L.ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead L.ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)

// now we compare the mature market with non-mature markets

by id: gen first_year = _n == 1
gen mature_market = (lianjia_420 > 0) if first_year == 1
replace mature_market = 0 if mature_market == .
by id: egen max_mature = max(mature_market)
drop first_year

reghdfe ln_income L.ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_income L.ln_income $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession L.price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe price_concession L.price_concession $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead L.ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)

reghdfe ln_lead L.ln_lead $dependent_variable broker_420 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)