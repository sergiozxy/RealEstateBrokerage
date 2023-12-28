cd "E:\umich\24_January_reclean" // change to your working directory
do "clean district 8_13.do"

generate non_online_effect = 1 if ln_lead == 0
replace non_online_effect = 0 if non_online_effect == .

// instead of using GMM methods to globally control for this one,
// we have to use the different level of control to estimate the results
// so we divide the control variables into the following parts

egen city_id = group(region)

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global L_hedonic_control L.jiadian L.kind L.hotel L.shop_mall L.museum L.old L.ktv L.mid L.prim L.west_food L.super L.sub L.park

global region_control pm25 pop light

global brokerage_control other non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

generate have_lj = 1 if lianjia > 0
replace have_lj = 0 if have_lj == .

reghdfe ln_income density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_num density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

reghdfe ln_end_price density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster id)

// now moving to the part of running whole codes

xtabond2 L(0/1)ln_end_price density lianjia_5 other_5 ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year,  ///
gmmstyle(L.ln_end_price density, equation(diff) lag(1 2) collapse) ///
ivstyle(ln_lead lianjia_5 other_5 ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control ln_profit_1k ln_num_1k ln_end_1k i.year, equation(diff)) twostep nolevel robust





xtivreg ln_end_price (density ln_lead = ln_profit_1k ln_num_1k L.ln_end_price) lianjia_5 other_5 ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, fe vce(cluster id)


// xtivreg2 ln_end_price (density ln_lead = ln_profit_1k ln_num_1k ln_end_1k) lianjia_5 ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, fe cluster(id)

generate ln_profit_1k = log(prft)
generate ln_num_1k = log(num)
generate ln_end_1k = log(price)
