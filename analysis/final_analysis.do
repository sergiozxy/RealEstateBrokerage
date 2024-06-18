cd "C:\Users\zxuyuan\Downloads\RealEstateResult" // change to your working directory

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

tab year, gen(yearx)

generate treatment = 1 if beke_410 - lianjia_410 > 0
replace treatment = 0 if treatment == .

bysort id: egen max_treatment = max(treatment)
replace treatment = max_treatment

foreach var of varlist yearx* {
    gen treatment_`var' = `var' * treatment
}

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

// save "for-analysis.dta", replace

/* Stylized Fact */

reghdfe ln_income density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_1

reghdfe ln_lead density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_2

esttab stylized_fact_1 stylized_fact_2 ///
 using result_tables/stylized_fact.tex, ///
style(tex) booktabs keep(density broker_410 ln_end_price ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

/* Dynamic Effect and Estimtion */

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_1

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_2

esttab dynamic_1 dynamic_2 ///
 using result_tables/dynamic.tex, ///
style(tex) booktabs keep($dependent_variable L.ln_income L.ln_lead broker_410 ln_end_price ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

/* Exogenous Shock with lianjia's entry */
preserve

drop entry* pre* pos*
by id: gen firstobs = (_n == 1)
// we should not drop the observation that have entry in the first period
// but we should drop the observation that have lianjia before our sample begin
by id: gen dropflag = (year == 2016 & lianjia_410 > 0)
by id: egen todrop = max(dropflag)

order firstobs dropflag todrop lianjia_410
gen to_keep = todrop == 0
// drop if todrop == 1 // (83,979 observations deleted)
drop firstobs dropflag todrop

by id: gen flag = sum(lianjia_410 > 0)
by id: gen entry = (flag == 1) & (lianjia_410 > 0) & (to_keep == 1)
// we should drop the samples that have to_keep = 0 in the final state of regression in individual samples
order flag entry lianjia_410


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

gen effect = 0
replace effect = 1 if (entry == 1 | post1 == 1 | post2 == 1 | post3 == 1)

drop entry_lianjia_lag1 entry_lianjia_lag2 entry_lianjia_lag3 ///
 entry_lianjia_lead1 entry_lianjia_lead2 entry_lianjia_lead3

// save "for-analysis-with-dummy(should drop).dta", replace

reghdfe ln_income L.ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1

reghdfe ln_lead L.ln_lead pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_2

esttab entry_1 entry_2 ///
 using result_tables/entry_effect.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 

reghdfe ln_income L.ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_1

reghdfe ln_income L.ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_2

reghdfe ln_lead L.ln_lead pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_3

reghdfe ln_lead L.ln_lead pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_4

esttab hetero_entry_1 hetero_entry_2 hetero_entry_3 hetero_entry_4 ///
 using result_tables/entry_effect_hetero.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income) [lower]"  "log(income) [higher]" "log(lead times) [lower]" "log(lead times) [higher]") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

restore

// now replace the result with the outcome.

reghdfe ln_income treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_1

reghdfe ln_lead treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
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
    keep(treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7) ///
    vertical ci(90) ///
    yline(0, lcolor(edkblue*0.8)) ///
    xline(1, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
    ylabel(, labsize(*0.75)) ///
    xlabel(1 "2018" 2 "2019" 3 "2020" 4 "2021" 5 "2022", labsize(*0.75)) ///
    ytitle("`title'", size(small)) ///
    xtitle("time", size(small)) ///
    addplot(line @b @at) ///
    ciopts(lpattern(dash) recast(rcap) msize(medium)) ///
    msymbol(circle_hollow) ///
    scheme(s1mono)

    * Export each graph to a PDF file with DPI 300, naming the file based on the variable name
    graph export "`name'.pdf", as(pdf) replace
}

esttab did_1 did_2 ///
 using result_tables/difference_in_difference.tex, ///
style(tex) booktabs keep(treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

/*** Heterogenous Check of The Mechanism ***/
reghdfe ln_income treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_1

reghdfe ln_income treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_2

reghdfe ln_lead treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_3

reghdfe ln_lead treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_4

esttab hetero_did_1 hetero_did_2 hetero_did_3 hetero_did_4 ///
 using result_tables/heter_platform_did.tex, ///
style(tex) booktabs keep(treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income) [lower]" "log(income) [higher]" "log(lead times) [lower]" "log(lead times) [higher]") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

 
 
// now we compare the mature market with non-mature markets

by id: gen first_year = _n == 1
gen mature_market = (lianjia_410 > 0) if first_year == 1
replace mature_market = 0 if mature_market == .
by id: egen max_mature = max(mature_market)
drop first_year

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_1

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_2

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_3

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_4

esttab robust_mature_1 robust_mature_2 robust_mature_3 robust_mature_4 ///
 using result_tables/robust_mature.tex, ///
style(tex) booktabs keep($dependent_variable L.ln_income L.ln_lead  ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income) [lower]" "log(income) [higher]" "log(lead times) [lower]" "log(lead times) [higher]") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 


// statistical result


generate by_lj = (lianjia_410 > 0)

logout, save(ttest_with_result) dta replace: ttable3 income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) tvalue

logout, save(ttest_with_result_mean_std) dta replace: tabstat income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) stat(mean sd) nototal long col(stat)


