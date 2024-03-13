cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

use template.dta, clear

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

foreach var of varlist yearx* {
    gen treatment_`var' = `var' * treatment
}

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

reghdfe ln_income density broker_410 ln_watch_people ln_end_price, absorb(id) vce(cluster bs_code)
est store stylized_fact_1

reghdfe ln_income density broker_410 ln_watch_people ln_end_price, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_2

reghdfe ln_income density broker_410 ln_watch_people ln_end_price $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(id) vce(cluster bs_code)
est store stylized_fact_3

reghdfe ln_income density broker_410 ln_watch_people ln_end_price $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_4

esttab stylized_fact_1 stylized_fact_2 stylized_fact_3 stylized_fact_4 ///
 using result_tables/stylized_fact.tex, ///
style(tex) booktabs keep(density broker_410 ln_end_price ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(income)" "log(income)" "log(income)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 
 
/* Dynamic Effect and Estimtion */

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_1

reghdfe price_concession L.price_concession $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_2

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_3

esttab dynamic_1 dynamic_2 dynamic_3 ///
 using result_tables/dynamic.tex, ///
style(tex) booktabs keep($dependent_variable L.ln_income L.price_concession L.ln_lead broker_410 ln_end_price ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "price concession" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 

/* Exogenous Shock with lianjia's entry */
preserve

drop entry* pre* pos*
by id: gen firstobs = (_n == 1)
by id: gen dropflag = (firstobs == 1 & lianjia_410 > 0)
by id: egen todrop = max(dropflag)

order firstobs dropflag todrop lianjia_410
drop if todrop == 1
drop firstobs dropflag todrop

by id: gen flag = sum(lianjia_410 > 0)
by id: gen entry = (flag == 1) & (lianjia_410 > 0)
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

drop entry_lianjia_lag1 entry_lianjia_lag2 entry_lianjia_lag3 ///
 entry_lianjia_lead1 entry_lianjia_lead2 entry_lianjia_lead3

reghdfe ln_income L.ln_income pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1

reghdfe price_concession L.price_concession pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_2

reghdfe ln_lead L.ln_lead pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_3

esttab entry_1 entry_2 entry_3 ///
 using result_tables/entry_effect.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "price concession" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace

restore

// now replace the result with the outcome.

reghdfe ln_income treatment_yearx2 treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_1

reghdfe price_concession treatment_yearx2 treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_2

reghdfe ln_lead treatment_yearx2 treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_3

local names "did_1 did_2 did_3"
local titles `"natural logarithm of income" "price concession" "natural logarithm of leading times"'

* Loop through each variable and its corresponding title
forvalues i = 1/3 {
    * Extract the ith name and title from the lists
    local name: word `i' of `names'
    local title: word `i' of `titles'
    
    * Use coefplot to generate the graph for the current variable
    coefplot `name', baselevels ///
    keep(treatment_yearx2 treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7) ///
    vertical ci(90) ///
    yline(0, lcolor(edkblue*0.8)) ///
    xline(3, lwidth(vthin) lpattern(dash) lcolor(teal)) ///
    ylabel(,labsize(*0.75)) ///
    xlabel(1 "2017" 2 "2018" 3 "2019" 4 "2020" 5 "2021" 6 "2022", labsize(*0.75)) ///
    ytitle("`title'", size(small)) ///
    xtitle("time", size(small)) ///
    addplot(line @b @at) ///
    ciopts(lpattern(dash) recast(rcap) msize(medium)) ///
    msymbol(circle_hollow) ///
    scheme(s1mono)

    * Export each graph to a PDF file with DPI 300, naming the file based on the variable name
    graph export "`name'.pdf", as(pdf) replace
}

esttab did_1 did_2 did_3 ///
 using result_tables/difference_in_difference.tex, ///
style(tex) booktabs keep(treatment_yearx2 treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "price concession" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 
 

/* Heterogenous Check */

** mechanism: 
* Compare mature markets where brokerages have been established for a long time with emerging markets where brokerages are relatively new.
* Competitor Analysis: Compare areas where Lianjia faces different levels of competition. The impact of Lianjia in highly competitive markets versus those with limited competition could reveal its market influence.

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_le_01

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_geq_02

reghdfe price_concession L.price_concession $dependent_variable ln_end_price broker_410 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_le_03

reghdfe price_concession L.price_concession $dependent_variable ln_end_price broker_410 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_geq_04

reghdfe ln_lead L.ln_lead $dependent_variable ln_end_price broker_410 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_le_05

reghdfe ln_lead L.ln_lead $dependent_variable ln_end_price broker_410 ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hhi_geq_06

esttab hhi_le_01 hhi_geq_02 hhi_le_03 hhi_geq_04 hhi_le_05 hhi_geq_06 ///
 using result_tables/robust_hhi.tex, ///
style(tex) booktabs keep($dependent_variable L.ln_income L.price_concession L.ln_lead  ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(income)" "price concession" "price concession" "log(lead times)" "log(lead times)") ///
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

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_0

reghdfe ln_income L.ln_income $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_1

reghdfe price_concession L.price_concession $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_2

reghdfe price_concession L.price_concession $dependent_variable broker_410 ln_end_price ln_watch_people $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_3

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_watch_people ln_end_price $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 0, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_4

reghdfe ln_lead L.ln_lead $dependent_variable broker_410 ln_watch_people ln_end_price $brokerage_control $Lag_hedonic_control $transaction_control $region_control if max_mature == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store robust_mature_5

esttab robust_mature_0 robust_mature_1 robust_mature_2 robust_mature_3 robust_mature_4 robust_mature_5 ///
 using result_tables/robust_mature.tex, ///
style(tex) booktabs keep($dependent_variable L.ln_income L.price_concession L.ln_lead  ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes) ///
mtitle("log(income)" "log(income)" "price concession" "price concession" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 replace
 

/*
// statistical result

logout, save("ttest_with_result.rtf") word replace: ttable3 kou yiji erji sanji end_price_pers pop light pm25 $Control_Variables, by(have_kou) tvalue
logout, save("ttest_with_result_mean_std.rtf") word replace: tabstat kou yiji erji sanji end_price_pers pop light pm25 $Control_Variables, by(have_kou) stat(mean sd) nototal long col(stat)



*/