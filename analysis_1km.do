// so our results can be summarized as the follows:

// 1. we use statistical summary to describe the data
// 2. we use stylized fact to dericve the correlation
// GMM method to deal with autocorrelation with random error term
// 3. we use the lagged one year data to predict the lianjia's number and other broker's number
// 4. we use the causal inference to derive the causality
// 5. we further test heterogeneity and robustness
// 6. we conclude our result using geospatial analysis and tools

// after doing all these work, I can finally conclude the results

// so the problem we have can be summarized as the follows
// first, we have beijing, shenzhen, chengdu, whose 2021 and 2022 data are missing
// the best way to do is drop them
// however, the problem exists is that the data will be misspecified, so that the 
// 2021 and 2022 data comparing with 2020 and before data is unbalanced,
// meaning that the price is incomparable

/*
// non significance emmm... so the results indicate that all of the benefits only come from the online parts

generate lianjia_222 = lianjia + 1
generate lj_income_pers = lj_income / lianjia_222
generate ln_income_pers = log(lj_income_pers)
*/


do "E:\umich\analysis and did\clean_23_7_29.do"

generate non_online_effect = 1 if ln_lead == 0
replace non_online_effect = 0 if non_online_effect == .

// instead of using GMM methods to globally control for this one,
// we have to use the different level of control to estimate the results
// so we divide the control variables into the following parts

egen city_id = group(city)

global hedonic_control elect_store kind hotel_num mall museum_num old ktv mid primary west_food super sub park

global transaction_control area bedroom toilet age floor_level green_ratio number_building floor_num living tihu kitchen floor_ratio residence

global L_hedonic_control L.elect_store L.kind L.hotel_num L.mall L.museum_num L.old L.ktv L.mid L.primary L.west_food L.super L.sub L.park

global region_control pm25 pop light

global brokerage_control other non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

generate have_lj = 1 if lianjia > 0
replace have_lj = 0 if have_lj == .


logout, save("E:\umich\analysis and did\statistical results\ttest_with_result.rtf") word replace: ttable3 end_price_pers lj_income trans_num density lianjia other lead_time watching_people watched_times negotiation_times other non_online_effect negotiation_period  $hedonic_control $transaction_control $region_control business_area_sum_income business_area_sum_num business_area_average_price, by(have_lj) tvalue

logout, save("E:\umich\analysis and did\statistical results\ttest_with_result_mean_std.rtf") word replace: tabstat end_price_pers lj_income trans_num density lianjia other lead_time watching_people watched_times negotiation_times other non_online_effect negotiation_period  $hedonic_control $transaction_control $region_control business_area_sum_income business_area_sum_num business_area_average_price, by(have_lj) stat(mean sd) nototal long col(stat)

/*
reghdfe ln_income density lianjia other ln_lead ln_watch_people ln_watch_time ln_nego_changes L.ln_income_bs L.ln_num_bs L.ln_pri_bs $Control_Variables pm25 pop light, absorb(year#city_id id_unique) vce(cluster bs_code)

reghdfe ln_income density lianjia other ln_lead ln_watch_people ln_watch_time ln_nego_changes $Control_Variables L.ln_income L.ln_num L.ln_end L.ln_income_bs L.ln_num_bs L.ln_pri_bs  pm25 pop light, absorb(year#city_id id_unique) vce(cluster bs_code)
est store base_reg_1
*/

// so this period's lianjia's density is significantly correlated with this
// period's income, number and end_price
// however, after controlling the lagged period dependent variable, the
// significance tells us that the two way fixed effect model is not sufficient
// to cover all the details.

// a very good model is xtdpdml and we shall see it through

reghdfe ln_income density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store base_reg_1

reghdfe ln_income density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs, absorb(year#city_id id_unique) vce(cluster id_unique)
est store base_reg_2

reghdfe ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store base_reg_3

reghdfe ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs, absorb(year#city_id id_unique) vce(cluster id_unique)
est store base_reg_4

reghdfe ln_num density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store base_reg_5

reghdfe ln_num density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs, absorb(year#city_id id_unique) vce(cluster id_unique)
est store base_reg_6

esttab base_reg_* using "E:\umich\analysis and did\write a mid term report\base_reg.rtf", label nogaps compress r2 ar2 replace

xtabond2 L(0/1)ln_income density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_income density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store gmm_reg_1

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people other non_online_effect ln_negotiation_period ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust
est store gmm_reg_2

xtabond2 L(0/1)ln_num density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_num density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store gmm_reg_3

esttab gmm_reg_* using "E:\umich\analysis and did\write a mid term report\gmm_reg.rtf", label nogaps compress replace scalars(j ar2p hansenp)

// the fixed effect and incorporating with lagged dependent variable is of no use
// so we propose the dynamic panel methods

/*
bysort id_unique: gen time_fixed = _n
xtset id_unique time_fixed

xtdpdml ln_income density lianjia, pred(ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control) vce(cluster id_unique)
*/

// so we still use the dynamic panel to account for this


// how to use lagged one period to test

global lagged_control_variables L.elect_store L.kind L.hotel_num L.sub L.mall L.museum_num L.old L.ktv L.mid L.primary L.west_food L.super L.park L.pm25 L.pop L.light L.area L.bedroom L.toilet L.age L.floor_level L.green_ratio L.number_building L.floor_num L.living L.tihu L.kitchen L.floor_ratio L.residence  

$brokerage_control $L_hedonic_control $transaction_control $region_control

reghdfe density L.ln_num L.ln_income L.ln_end L.ln_watch_time L.ln_nego_changes L.lianjia L.ln_lead L.ln_watch_people $brokerage_control $lagged_control_variables, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store reverse_lag_1

reghdfe density L.ln_income_bs L.ln_pri_bs L.ln_num_bs L.ln_watch_time L.ln_nego_changes L.lianjia L.ln_lead L.ln_watch_people $brokerage_control $lagged_control_variables, absorb(year#city_id id_unique) vce(cluster id_unique)
est store reverse_lag_2

reghdfe ln_lead L.ln_num L.ln_income L.ln_end L.ln_watch_time L.ln_nego_changes L.lianjia L.ln_watch_people $brokerage_control $lagged_control_variables, absorb(year#city_id id_unique) vce(cluster id_unique)
est store reverse_lag_3

reghdfe ln_lead L.ln_income_bs L.ln_pri_bs L.ln_num_bs L.ln_watch_time L.ln_nego_changes L.lianjia L.ln_watch_people $brokerage_control $lagged_control_variables, absorb(year#city_id id_unique) vce(cluster bs_code)
est store reverse_lag_4

esttab reverse_lag_* using "E:\umich\analysis and did\write a mid term report\reverse_lag.rtf", label nogaps compress r2 ar2 replace

// robustness

/*
generate jingjin = 1 if city == "beijing" | city == "tianjin"
replace jingjin = 0 if jingjin == .

generate changsanjiao = 1 if city == "shanghai" | city == "hangzhou" | city == "nanjing"
replace changsanjiao = 0 if changsanjiao == .

generate chengyu = 1 if city == "chengdu" | city == "chongqing"
replace chengyu = 0 if chengyu == .

generate guangshen = 1 if city == "guangzhou" | city == "shenzhen"
replace guangshen = 0 if guangshen == .

xtset id_unique year

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if jingjin == 1,  ///
gmmstyle(ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store region_check_1 

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if guangshen == 1,  ///
gmmstyle(ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store region_check_2

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if changsanjiao == 1,  ///
gmmstyle(ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store region_check_3

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if chengyu == 1,  ///
gmmstyle(ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(  ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust
est store region_check_4
*/

// heterogeneity

sort light
gen night_heter = group(2)

xtset id_unique year

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if night_heter == 1,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store heter_check_light_1

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if night_heter == 2,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store heter_check_light_2

sort pop
gen pop_heter = group(2)

xtset id_unique year

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if pop_heter == 1,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people other ln_negotiation_period ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust
est store heter_check_light_3

xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year if pop_heter == 2,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_pri_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
est store heter_check_light_4

esttab heter_check_* using "E:\umich\analysis and did\write a mid term report\heter_check.rtf", label nogaps compress replace scalars(j ar2p hansenp)

/* Quasi-Experiment Explannation */

reghdfe ln_end treat_did treated did ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store quasi_reg_1

reghdfe ln_income treat_did treated did ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store quasi_reg_2

reghdfe ln_num treat_did treated did ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)
est store quasi_reg_3

esttab quasi_reg_* using "E:\umich\analysis and did\write a mid term report\quasi_reg.rtf", label nogaps compress r2 ar2 replace


// now the result is more 


// mechanism 

other non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

reghdfe ln_watch_time density lianjia ln_lead ln_watch_people other non_online_effect ln_negotiation_period ln_nego_changes $L_hedonic_control $transaction_control $region_control i.year, absorb(year#bs_code id_unique) vce(cluster id_unique)

other non_online_effect ln_negotiation_period ln_watch_time ln_nego_changes

// 调整参数 然后获得一个好的结果
xtabond2 L(0/2)ln_watch_time density lianjia ln_lead ln_watch_people other ln_negotiation_period ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_watch_time density lianjia, equation(diff) lag(1 2) collapse) ///
ivstyle(ln_lead ln_watch_people other ln_negotiation_period ln_nego_changes  $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust
/*

reghdfe ln_nego_changes density lianjia ln_lead ln_watch_people other non_online_effect ln_watch_time $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)

reghdfe ln_end ln_watch_time lianjia ln_nego_changes ln_watch_people other non_online_effect $L_hedonic_control $transaction_control $region_control, absorb(year#bs_code id_unique) vce(cluster id_unique)

xtabond2 L(0/1)ln_negotiation_period density lianjia ln_lead ln_watch_people other non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_negotiation_period density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people other non_online_effect ln_watch_time ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust


xtabond2 L(0/1)ln_end density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_end density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people other non_online_effect ln_negotiation_period ln_nego_changes $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year, equation(diff)) twostep nolevel robust


xtabond2 L(0/1)ln_num density lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs L.ln_pri_bs i.year,  ///
gmmstyle(L.ln_num density, equation(diff) lag(1 2) collapse) ///
ivstyle(lianjia ln_lead ln_watch_people $brokerage_control $L_hedonic_control $transaction_control $region_control L.ln_income_bs L.ln_num_bs i.year, equation(diff)) twostep nolevel robust
*/
