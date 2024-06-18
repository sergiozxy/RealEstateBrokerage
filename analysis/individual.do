cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

set maxvar 100000
use "individual.dta", clear

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

foreach var of varlist yearx* {
    gen `var'_density = `var' * density
}

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control non_online_effect ln_nego_changes

global dependent_variable yearx2_density yearx3_density yearx4_density yearx5_density yearx6_density yearx7_density

// save "for-analysis.dta", replace

/* Stylized Fact */

reghdfe ln_negotiation_period density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_3

reghdfe price_concession density broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_4

esttab stylized_fact_3 stylized_fact_4 ///
 using result_tables/stylized_fact.tex, ///
style(tex) booktabs keep(density broker_410 ln_end_price ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append

/* Dynamic Effect and Estimtion */

reghdfe ln_negotiation_period $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_3

reghdfe price_concession $dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_4

esttab dynamic_3 dynamic_4 ///
 using result_tables/dynamic.tex, ///
style(tex) booktabs keep($dependent_variable broker_410 ln_end_price ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append

/* Exogenous Shock with lianjia's entry */
preserve

drop if to_keep == 0

gen effect = 0
replace effect = 1 if (entry == 1 | post1 == 1 | post2 == 1 | post3 == 1)

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_3

reghdfe price_concession pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_4

esttab entry_3 entry_4 ///
 using result_tables/entry_effect.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_5

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_6

reghdfe price_concession pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_7

reghdfe price_concession pre2 entry post1 post2 post3 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_8

esttab hetero_entry_5 hetero_entry_6 hetero_entry_7 hetero_entry_8 ///
 using result_tables/entry_effect_hetero.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period) [lower]"  "log(negotiation period) [higher]" "price concession [lower]" "price concession [higher]") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append

restore

// now replace the result with the outcome.

reghdfe ln_negotiation_period treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_3

reghdfe price_concession treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_4

* Define the names and titles using global macros
global names "did_3 did_4"
global titles `"log(negotiation_period)" "price concession"'

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
    ytitle(`"`title'"', size(small)) ///
    xtitle("time", size(small)) ///
    addplot(line @b @at) ///
    ciopts(lpattern(dash) recast(rcap) msize(medium)) ///
    msymbol(circle_hollow) ///
    scheme(s1mono)

    * Export each graph to a PDF file with DPI 300, naming the file based on the variable name
    graph export "`name'.pdf", as(pdf) replace
}



esttab did_3 did_4 ///
 using result_tables/difference_in_difference.tex, ///
style(tex) booktabs keep(treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 ln_end_price broker_410 ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append

/*** Heterogenous Check of The Mechanism ***/

reghdfe ln_negotiation_period treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_5

reghdfe ln_negotiation_period treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_6

reghdfe price_concession treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi < 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_7

reghdfe price_concession treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 broker_410 ln_end_price ln_watch_people ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control if hhi >= 0.2, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_8

esttab hetero_did_5 hetero_did_6 hetero_did_7 hetero_did_8 ///
 using result_tables/heter_platform_did.tex, ///
style(tex) booktabs keep(treatment_yearx3 treatment_yearx4 treatment_yearx5 treatment_yearx6 treatment_yearx7 ln_end_price broker_410 ln_watch_people ln_watch_time ln_nego_changes) ///
mtitle("log(negotiation period) [lower]"  "log(negotiation period) [higher]" "price concession [lower]" "price concession [higher]") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
 append



// statistical result


generate by_lj = (lianjia_410 > 0)

logout, save(ttest_with_result) dta replace: ttable3 income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) tvalue

logout, save(ttest_with_result_mean_std) dta replace: tabstat income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) stat(mean sd) nototal long col(stat)



