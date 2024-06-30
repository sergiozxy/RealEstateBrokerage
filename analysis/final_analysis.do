cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "template.dta", clear

// ssc install reghdfe
// ssc install ftools
// ssc install estout
// ssc install coefplot

// replace price_concession = - price_concession if price_concession < 0
 
/*
*** basic idea: 
** we first conduct using stylized facts: ln_income ~ density and by conducting four sets of researches;
* without controls, with controls, with control FE and with controls multi-way FE

** we then estimate the dynamic effect of density to the incomes, 
* and we test the mechanism by adding other dependent varialbes, including price_concession, ln_lead
* then we add the robustness check.

** we then estimate the lianjia's entry effect to these regions, we also test them with mechanism variables

** we then use estimate the platformization effect of brokerages by conducting the number of

** mechanism: 
* Compare mature markets where brokerages have been established for a long time with emerging markets where brokerages are relatively new.
*  Competitor Analysis: Compare areas where Lianjia faces different levels of competition. The impact of Lianjia in highly competitive markets versus those with limited competition could reveal its market influence.
*/


/*
// merge the result back to the file
import delimited "combined_result-with-network.csv", clear
* Sort the imported CSV file by id and year
sort id year

save "temp_csv.dta", replace

use "template.dta", clear
drop influence _merge
sort id year

merge 1:1 id year using "temp_csv.dta"
save "template.dta", replace
*/

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


// save "for-analysis.dta", replace

/* Stylized Fact */

reghdfe ln_income density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_1

reghdfe ln_lead density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_2

/* Dynamic Effect and Estimtion */

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_1

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_2

/* Exogenous Shock with lianjia's entry */
preserve

by id: gen firstobs = (_n == 1)
// we should not drop the observation that have entry in the first period
// but we should drop the observation that have lianjia before our sample begin
by id: gen first_obs_flag = (firstobs == 1 & lianjia_410 > 0)
by id: gen dropflag = (year == 2016 & lianjia_410 > 0)
by id: egen todrop = max(first_obs_flag)

order firstobs dropflag todrop lianjia_410
gen to_keep = todrop == 0
// drop if to_keep == 0 // (83,979 observations deleted)
drop firstobs dropflag todrop

by id: gen flag = sum(lianjia_410 > 0)
by id (year), sort: gen entry = 1 if (flag == 1) & (lianjia_410 > 0) & (first_obs_flag == 0) & (L.flag == 0 | L.flag == .)
replace entry = 0 if entry == .
// we should drop the samples that have to_keep = 0 in the final state of regression in individual samples
order flag entry lianjia_410


forvalues i = 1/3 {
    by id: gen entry_lianjia_lag`i' = F`i'.entry
    by id: gen entry_lianjia_lead`i' = L`i'.entry
}

gen pre1 = (entry_lianjia_lag1 == 1)
gen pre2 = (entry_lianjia_lag2 == 1)
gen pre3 = (entry_lianjia_lag3 == 1)
gen post1 = (entry_lianjia_lead1 == 1)
gen post2 = (entry_lianjia_lead2 == 1)
gen post3 = (entry_lianjia_lead3 == 1)

gen effect = 0
replace effect = 1 if (entry == 1 | post1 == 1 | post2 == 1 | post3 == 1)

drop entry_lianjia_lag1 entry_lianjia_lag2 entry_lianjia_lag3 ///
 entry_lianjia_lead1 entry_lianjia_lead2 entry_lianjia_lead3

 order pre3 pre2 pre1 entry post1 post2 post3 year
// save "for-analysis-with-dummy(should drop).dta", replace

/*
reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1
*/

drop if to_keep == 0

reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1

reghdfe ln_lead pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_2

/*
 make a graph here
*/





reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_1

reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_2

reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_3

reghdfe ln_lead pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_4

reghdfe ln_lead pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_5

reghdfe ln_lead pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_6

esttab hetero_entry_1 hetero_entry_2 hetero_entry_3 hetero_entry_4 hetero_entry_5 hetero_entry_6 ///
 using result_tables/entry_effect_hetero_1.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(income)"  "log(income)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
 replace


restore

// now replace the result with the outcome.


drop if influence == 0

reghdfe ln_income pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_1

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_2

* Define the names and titles using global macros
global names "did_1 did_2"
global titles ""log(income)" "log(leading_times)""

* Loop through each variable and its corresponding title
forvalues i = 1/2 {
    * Extract the ith name and title from the lists
    local name : word `i' of $names
    local title : word `i' of $titles
    
    * Display the name and title being processed
    di "Processing `name' with title `title'"

    * Use coefplot to generate the graph for the current variable
    coefplot `name', baselevels ///
    keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
    vertical ci(90) ///
    yline(0, lcolor(edkblue*0.8)) ///
    xline(1, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
    ylabel(, labsize(*0.75)) ///
    xlabel(1 "pre1" 2 "treatment" 3 "post1" 4 "post2" 5 "post3", labsize(*0.75)) ///
    ytitle("`title'", size(small)) ///
    xtitle("time", size(small)) ///
    addplot(line @b @at) ///
    ciopts(lpattern(dash) recast(rcap) msize(medium) lcolor(blue*0.7)) ///
    msymbol(circle) msize(small) ///
    scheme(s2color) ///
    graphregion(color(white)) ///
    plotregion(color(white) lcolor(none))

    * Export each graph to a PDF file with DPI 300, naming the file based on the variable name
    graph export "`name'.tif", as(tif) width(1500) height(900) replace
}

/*** Heterogenous Check of The Mechanism ***/

reghdfe ln_income pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_1

reghdfe ln_income pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_2

reghdfe ln_income pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_3

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_4

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_5

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store heter_did_6

esttab hetero_did_1 hetero_did_2 hetero_did_3 hetero_did_4 hetero_did_5 hetero_did_6 ///
 using result_tables/heter_platform_did_1.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(income)" "log(income)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
 replace

// consider the case of the network spillover effects
