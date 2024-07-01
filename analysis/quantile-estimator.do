cd "C:\Users\zxuyuan\Downloads" // change to your working directory

set maxvar 10000
use "template.dta", clear

// ssc install reghdfe
// ssc install ftools
// ssc install estout
// ssc install coefplot
// ssc install xtqreg
// ssc install boottest

generate low_hhi = (hhi < 0.1)
generate mode_hhi = (hhi >= 0.1) & (hhi < 0.25)
generate high_hhi = (hhi >= 0.25)

drop entry* pre* pos*
xtset id year

tab year, gen(yearx)
* Step 1: 创建treatment_effect变量
generate treatment_effect = 1 if (lianjia_410 / beke_410 <= 0.8) & (year >= 2018)
replace treatment_effect = 0 if treatment_effect == .

* Step 2: 生成标记第一次treatment_effect == 1的年份
by id (year), sort: gen first_treatment_year = year if treatment_effect == 1 & (L.treatment_effect != 1 | L.treatment_effect == .)
by id: replace first_treatment_year = first_treatment_year[_n-1] if first_treatment_year == .

* 创建一个标记变量
by id (year): gen flag_all_treatment = 1 if treatment == 1 & year >= first_treatment_year
by id: replace flag_all_treatment = 0 if flag_all_treatment == . & treatment != 1 & year >= first_treatment_year

* 检查是否在首次treatment_effect == 1之后的所有年份中，treatment都为1
egen check_all_treatment = total(flag_all_treatment == 1), by(id)
egen total_years_after_first = total(year >= first_treatment_year), by(id)

* 创建最终标记变量
gen final_flag = 1 if check_all_treatment == total_years_after_first & total_years_after_first > 0
replace final_flag = 0 if final_flag == .

order first_treatment_year treatment_effect year flag_all_treatment total_years_after_first final_flag
* 清理临时变量
drop first_treatment_year flag_all_treatment check_all_treatment total_years_after_first

by id (year), sort: gen treatment = 1 if treatment_effect == 1 & (L.treatment_effect != 1 | L.treatment_effect == .) & (final_flag == 1)
replace treatment = 0 if treatment == .
order treatment

* Generate lagged and lead entry variables
forvalues i = 1/3 {
    by id: gen entry_platform_lag`i' = F`i'.treatment
    by id: gen entry_platform_lead`i' = L`i'.treatment
}
// order entry_platform_lag1 entry_platform_lag2 entry_platform_lag3
* Generate pre and post treatment indicators
gen pre1_treatment = (entry_platform_lag1 == 1)
gen pre2_treatment = (entry_platform_lag2 == 1)
gen pre3_treatment = (entry_platform_lag3 == 1)
gen post1_treatment = (entry_platform_lead1 == 1)
gen post2_treatment = (entry_platform_lead2 == 1)
gen post3_treatment = (entry_platform_lead3 == 1)

foreach var of varlist yearx* {
    gen `var'_density = `var' * density
}

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control non_online_effect ln_nego_changes ln_negotiation_period

foreach var in $hedonic_control {
    gen `var'_hedonic_lag = L.`var'
}

global Lag_hedonic_control *_hedonic_lag

global dependent_variable yearx2_density yearx3_density yearx4_density yearx5_density yearx6_density yearx7_density

by id year: egen avg_watch_time = mean(watched_times)
tabstat avg_watch_time, stat(p50, mean, p25, p75)

by id: gen first_year = _n == 1
gen mature_market = (lianjia_410 > 0) if first_year == 1
replace mature_market = 0 if mature_market == .
by id: egen max_mature = max(mature_market)
drop first_year

foreach var of varlist yearx* {
    gen `var'_influence = `var' * influence
}

drop if influence == 0

/*
reghdfe influence pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store extension_base_1
*/

forvalues q = 5(5)95 {
    local tau = `q' / 100
    qui: xtqreg influence pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_watch_people ln_end_price ln_watch_time ///
    $brokerage_control $hedonic_control $transaction_control $region_control i.year, id(id) q(`tau')
    est store quantile_`q'
}

local quantile_titles
forvalues q = 5(5)95 {
    local quantile_titles `quantile_titles' "`q'%ile"
}

esttab quantile_* ///
 using  quantile_network_formation.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle(`"`quantile_titles'"') ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
b(%9.3f) se(%9.3f) ///
 replace

