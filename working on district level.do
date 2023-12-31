cd "E:\umich\24_January_reclean" // change to your working directory

use template.dta, clear

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global L_hedonic_control L.jiadian L.kind L.hotel L.shop_mall L.museum L.old L.ktv L.mid L.prim L.west_food L.super L.sub L.park

global region_control pm25 pop light

global brokerage_control non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

// stylized facts

// ssc install reghdfe
reghdfe ln_income density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_end_price density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_negotiation_period ln_watch_time ln_nego_changes density lianjia_5 other_5 ln_lead ln_watch_people $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

// dynamically estimations

sum entry post1 post2 post3 pre1 pre2 pre3

reghdfe ln_income pre3 pre2 entry post1 post2 post3 lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_end_price pre3 pre2 entry post1 post2 post3 lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_negotiation_period ln_watch_time ln_nego_changes pre3 pre2 entry post1 post2 post3 lianjia_5 other_5 ln_lead non_online_effect ln_watch_people $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_income proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_end_price proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_negotiation_period ln_watch_time ln_nego_changes proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead non_online_effect ln_watch_people $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

// now using GMM estimations to estimate it.

// done for ln_income

// ssc install xtabond2

xtabond2 L(0/1)ln_income density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_income L.lianjia_5 ln_lead, equation(diff) lag(1 2) collapse) ///
ivstyle(density other_5 ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

xtabond2 L(0/1)ln_income proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_income ln_watch_time ln_nego_changes, equation(diff) lag(1 2) collapse) ///
ivstyle(proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period  $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

// done for ln_end_price

xtabond2 L(0/1)ln_end_price density lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price L.other_5 L.pop, equation(diff) lag(1 2) collapse) ///
ivstyle(density lianjia_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25  light  ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

xtabond2 L(0/1)ln_end_price proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price L.other_5 L.pop, equation(diff) lag(1 2) collapse) ///
ivstyle(proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 ln_lead ln_watch_people non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25  light  ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

// done for ln_negotiation_period
xtabond2 L(0/2)ln_negotiation_period density lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year, ///
gmmstyle(L.L.ln_negotiation_period L.other_5 L.ln_num_1k, equation(diff) lag(1 2) collapse) ///
ivstyle(density lianjia_5  ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

xtabond2 L(0/2)ln_negotiation_period proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year, ///
gmmstyle(L.ln_negotiation_period other_5  L.ln_num_1k, equation(diff) lag(1 2) collapse) ///
ivstyle(proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

xtabond2 L(0/2)ln_negotiation_period proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5 other_5 ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k ln_num_1k ln_end_1k i.year, ///
gmmstyle(L.ln_negotiation_period other_5  L.ln_num_1k, equation(diff) lag(1 2) collapse) ///
ivstyle(proxy_entry proxy_pos1 proxy_pos2 proxy_pos3 lianjia_5  ln_lead ln_watch_people non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control pm25 pop light ln_profit_1k  ln_end_1k i.year, equation(diff)) noconstant twostep nolevel robust

// we can also carry out Granger tests
// and please refer to the jupyter notebook.
// the result shows that it is okay

// heterogeneous checkings and robustness checkings



// mechanism design
