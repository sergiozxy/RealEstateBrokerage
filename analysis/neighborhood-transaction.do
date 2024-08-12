cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

use "template.dta", clear

cd "E:\umich\RealEstateBrokerage"
// ssc install reghdfe
// ssc install ftools
// ssc install estout
// ssc install coefplot


global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes ln_negotiation_period

global Lag_hedonic_control *_hedonic_lag

global dependent_variable yearx2_density yearx3_density yearx4_density yearx5_density yearx6_density yearx7_density

xtset id year

/******************** Stylized Fact *************************************************/

reghdfe ln_num density $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_1

reghdfe ln_lead density $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store stylized_fact_2

/* Dynamic Effect and Estimtion */

reghdfe ln_num L.ln_num $dependent_variable $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_1

reghdfe ln_lead L.ln_lead $dependent_variable $brokerage_control $Lag_hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store dynamic_2

/* Exogenous Shock with lianjia's entry */
preserve

/*
reghdfe ln_income pre2 entry post1 post2 post3 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1
*/

drop if to_keep == 0

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_1

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store entry_2

/*
 make a graph here
*/





reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_1

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_2

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_3

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_4

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_5

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_entry_6

//  broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes
// can also be exported to a table
esttab hetero_entry_1 hetero_entry_2 hetero_entry_3 hetero_entry_4 hetero_entry_5 hetero_entry_6 ///
 using result_tables/entry_effect_hetero_1.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3) ///
mtitle("log(number)" "log(number)"  "log(number)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace


restore

// now replace the result with the outcome.


drop if influence == 0

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_1

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
est store did_2

* Define the names and titles using global macros
global names "did_1 did_2"
global titles ""log(number)" "log(leading_times)""

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

/*** Heterogenous Check of The Mechanism ***/

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_1

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_2

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_3

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if low_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_4

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if mode_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_5

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control if high_hhi == 1, absorb(year#bs_code id) vce(cluster bs_code)
est store hetero_did_6

// ln_end_price broker_410 ln_watch_people ln_negotiation_period ln_watch_time ln_nego_changes

esttab hetero_did_1 hetero_did_2 hetero_did_3 hetero_did_4 hetero_did_5 hetero_did_6 ///
 using result_tables/heter_platform_did_1.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle("log(number)" "log(number)" "log(number)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 "Regional Control = $region_control", labels("\checkmark")) ///
 replace

// consider the case of the network spillover effects
