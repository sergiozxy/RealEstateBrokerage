cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

/*
clear matrix
clear mata
set maxvar 100000
*/

use "individual.dta", clear

cd "E:\umich\RealEstateBrokerage"
/*
drop influence _merge
merge n:1 id year using "temp_csv.dta"
save "individual", replace
*/



generate low_hhi = (hhi < 0.1)
generate mode_hhi = (hhi >= 0.1) & (hhi < 0.25)
generate high_hhi = (hhi >= 0.25)


tab year, gen(yearx)

foreach var of varlist yearx* {
    gen `var'_density = `var' * density
}

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes

global dependent_variable yearx2_density yearx3_density yearx4_density yearx5_density yearx6_density yearx7_density

replace price_concession = 100 * price_concession
// save "for-analysis.dta", replace

/* Stylized Fact */

reghdfe ln_negotiation_period density $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_3

reghdfe price_concession density $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_4

// broker_410 ln_end_price ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes
esttab stylized_fact_1 stylized_fact_2 stylized_fact_3 stylized_fact_4 ///
 using result_tables/stylized_fact.tex, ///
style(tex) booktabs keep(density) ///
mtitle("log(number)" "log(lead times)" "log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Lag(Hedonic Control) = $Lag_hedonic_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

/* Dynamic Effect and Estimtion */

reghdfe ln_negotiation_period $dependent_variable $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_3

reghdfe price_concession $dependent_variable $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_4

esttab dynamic_1 dynamic_2 dynamic_3 dynamic_4 ///
 using result_tables/dynamic.tex, ///
style(tex) booktabs keep($dependent_variable) ///
mtitle("log(number)" "log(lead times)" "log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Lag(Hedonic Control) = $Lag_hedonic_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

/* Exogenous Shock with lianjia's entry */
preserve

// drop if to_keep == 0

drop if to_keep == 0
gen effect = 0
replace effect = 1 if (entry == 1 | post1 == 1 | post2 == 1 | post3 == 1)

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_3

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_4

// broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes
// can also be exported to a LaTeX table
esttab entry_1 entry_2 entry_3 entry_4 ///
 using result_tables/entry_effect.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3) ///
mtitle("log(number)" "log(lead times)" "log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_7

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_8

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_9

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_10

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_11

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_12

// broker_410 ln_watch_people ln_watch_time ln_nego_changes
esttab hetero_entry_7 hetero_entry_8 hetero_entry_9 hetero_entry_10 hetero_entry_11 hetero_entry_12 ///
 using result_tables/entry_effect_hetero_2.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3) ///
mtitle("log(negotiation period)"  "log(negotiation period)" "log(negotiation period)" "price concession" "price concession" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

// note that we need to add the results:
// & [higher] & [lower] & [higher] & [lower] & [higher] & [lower] & [higher] & [lower] \\ \hline

restore

drop if influence == 0
// now replace the result with the outcome.

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_3

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_4

* Define the names and titles using global macros
global names "did_3 did_4"
global titles ""log(negotiation_period)" "price concession""

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
    graph export "`name'.pdf", as(pdf) replace
}

// ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes
esttab did_1 did_2 did_3 did_4 ///
 using result_tables/difference_in_difference.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment ) ///
mtitle("log(number)" "log(lead times)" "log(negotiation period)" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

/*** Heterogenous Check of The Mechanism ***/
reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_7

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_8

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_9

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_10

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_11

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_12

// ln_end_price broker_410 ln_watch_people ln_watch_time ln_nego_changes
esttab hetero_did_7 hetero_did_8 hetero_did_9 hetero_did_10 hetero_did_11 hetero_did_12 ///
 using result_tables/heter_platform_did_2.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment ) ///
mtitle("log(negotiation period)"  "log(negotiation period)" "log(negotiation period)" "price concession"  "price concession" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

 



