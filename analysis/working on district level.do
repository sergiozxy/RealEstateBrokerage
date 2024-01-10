cd "C:\Users\zxuyuan\Downloads" // change to your working directory

// revise based on L_hedonic_control

use template.dta, clear

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

foreach var in $hedonic_control {
    gen `var'_hedonic_lag = L.`var'
}

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global Lag_hedonic_control *_hedonic_lag

global region_control pm25 pop light

foreach var in $region_control {
    gen `var'_region_lag = L.`var'
}

global Lag_region_control *_region_lag

global brokerage_control non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

foreach var in $brokerage_control {
    gen `var'_broker_lag = L.`var'
}

global Lag_brokerage_control *_broker_lag

// we first test the strictly exogeneity property of the result

xtserial ln_income density lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control

// the resut indicates that there is strong evidence of first-order autocorrelation

// stylized facts

// ssc install reghdfe
// ssc install ftool
// lianjia_420 broker_420

reghdfe ln_income density lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store baseline_1

reghdfe ln_end_price density lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store baseline_2

reghdfe ln_negotiation_period density ln_watch_time ln_nego_changes lianjia_420 broker_420 ln_lead ln_watch_people $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store baseline_3

esttab baseline_* using result_tables/baseline.tex, ///
style(tex) booktabs keep(density lianjia_5 other_5 ln_lead ln_negotiation_period ln_watch_time ln_nego_changes ln_watch_people) ///
mtitle("log(income)" "log(price)" "log(period)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

 
// dynamically estimations

// sum entry post1 post2 post3 pre1 pre2 pre3

reghdfe ln_income pre1 entry post1 post2 post3 lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store dynamic_1

reghdfe ln_end_price pre1 entry post1 post2 post3 lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store dynamic_2

reghdfe ln_negotiation_period ln_watch_time ln_nego_changes pre1 entry post1 post2 post3 lianjia_420 broker_420 ln_lead non_online_effect ln_watch_people $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)
est store dynamic_3


esttab dynamic_* using result_tables/dynamic.tex, ///
style(tex) booktabs keep(pre3 pre2 entry post1 post2 post3 ln_negotiation_period ln_watch_time ln_nego_changes lianjia_420 broker_420 ln_lead non_online_effect ln_watch_people) ///
mtitle("log(income)" "log(income)" "log(price)" "log(price)" ///
"log(period)" "log(period)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

// now using GMM estimations to estimate it.

// done for ln_income

// ssc install xtabond2

/*
xtabond2 L(0/1)ln_income density lianjia_420 broker_420 ln_lead ln_watch_people $brokerage_control $hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_income L.lianjia_420 ln_lead, equation(diff) lag(1 2) collapse) ///
ivstyle(density broker_420 ln_watch_people $brokerage_control $hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust
est store gmm_1
*/

xtabond2 L(0/1)ln_income pre1 entry post1 post2 post3 broker_420 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $Lag_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_income ln_watch_time ln_nego_changes, equation(diff) lag(1 2) collapse) ///
ivstyle(pre1 entry post1 post2 post3 broker_420 ln_lead ln_watch_people non_online_effect ln_negotiation_period  $Lag_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust
est store gmm_1

// done for ln_end_price

/*
xtabond2 L(0/1)ln_end_price density lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price L.other_5 L.pop, equation(diff) lag(1 2) collapse) ///
ivstyle(density lianjia_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25  light  ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust
est store gmm_3
*/

// market anticipation because the sellers increases, the lianjia decided to enter the market where there are bundles of listings
xtabond2 L(0/1)ln_end_price prer1 entry1 postr1 postr2 postr3 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price L.other_5 L.pop, equation(diff) lag(1 2) collapse) ///
ivstyle(prer1 entry1 postr1 postr2 postr3 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25  light  ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

est store gmm_robust_2

xtabond2 L(0/1)ln_end_price pre1 entry post1 post2 post3 broker_420 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $Lag_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price L.broker_420 L.pop, equation(diff) lag(1 2) collapse) ///
ivstyle( pre1 entry post1 post2 post3 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $Lag_hedonic_control $transaction_control pm25 light ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust
est store gmm_2

// done for ln_negotiation_period

xtabond2 L(0/2)ln_negotiation_period pre1 entry post1 post2 post3 broker_420 ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year, ///
gmmstyle(L.ln_negotiation_period ln_lead L.ln_num_1k, equation(diff) lag(1 2) collapse) ///
ivstyle(pre1 entry post1 post2 post3 broker_420  ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust
est store gmm_3



esttab gmm_* using result_tables/gmm.tex, ///
style(tex) booktabs keep(density proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 L.ln_income L.ln_end_price L.ln_negotiation_period L2.ln_negotiation_period lianjia_5 other_5 ln_lead ln_watch_people ln_watch_time ln_nego_changes ln_negotiation_period) ///
mtitle("log(income)" "log(income)" "log(price)" "log(price)" ///
"log(period)" "log(period)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se stats(N ar1p ar2p hansenp, labels("observations" "AR(1) p-value" "AR(2) p-value" "Hansen J Test p-value" "Sargan Test p-value")) ///
 replace

// we can also carry out Granger tests
// and please refer to the jupyter notebook.
// the result shows that it is okay

// heterogeneous checkings and robustness checkings


// mechanism design



