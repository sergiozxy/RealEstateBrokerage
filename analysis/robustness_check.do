** APPENDIX **

** this notebook is for tables in appendix that conducting the robustness check

cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "for-analysis-with-dummy(should drop).dta", clear

cd "C:\Users\zxuyuan\Downloads\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes ln_negotiation_period

global Lag_hedonic_control *_hedonic_lag

drop if to_keep == 0

reghdfe ln_num pre2 entry post1 post2 post3, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_1

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_2

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_3

reghdfe ln_num pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_4

reghdfe ln_lead pre2 entry post1 post2 post3, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_5

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_6

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_7

reghdfe ln_lead pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_8

esttab robustness_entry_1 robustness_entry_2 robustness_entry_3 robustness_entry_4 robustness_entry_5 robustness_entry_6 robustness_entry_7 robustness_entry_8 ///
 using result_tables/entry_robust_adding_variables_1.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3) ///
mtitle("log(number)" "log(number)"  "log(number)" "log(number)" "log(lead times)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 , labels("\checkmark")) ///
 replace

cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "individual.dta", clear

cd "C:\Users\zxuyuan\Downloads\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes

replace price_concession = 100 * price_concession

drop if to_keep == 0

reghdfe ln_negotiation_period pre2 entry post1 post2 post3, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_9

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_10

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_11

reghdfe ln_negotiation_period pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_12

reghdfe price_concession pre2 entry post1 post2 post3, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_13

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_14

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_15

reghdfe price_concession pre2 entry post1 post2 post3 $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_entry_16

esttab robustness_entry_9 robustness_entry_10 robustness_entry_11 robustness_entry_12 robustness_entry_13 robustness_entry_14 robustness_entry_15 robustness_entry_16 ///
 using result_tables/entry_robust_adding_variables_2.tex, ///
style(tex) booktabs keep(pre2 entry post1 post2 post3) ///
mtitle("log(negotiation period)"  "log(negotiation period)" "log(negotiation period)" "log(negotiation period)" "price concession" "price concession" "price concession" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 , labels("\checkmark")) ///
 replace
 
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "for-analysis-with-dummy(should drop).dta", clear

cd "C:\Users\zxuyuan\Downloads\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes ln_negotiation_period

global Lag_hedonic_control *_hedonic_lag

drop if influence  == 0

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_1

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_2

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_3

reghdfe ln_num pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_4

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_5

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_6

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_7

reghdfe ln_lead pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_8

esttab robustness_plat_1 robustness_plat_2 robustness_plat_3 robustness_plat_4 robustness_plat_5 robustness_plat_6 robustness_plat_7 robustness_plat_8 ///
 using result_tables/plat_robust_adding_variables_1.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle("log(number)" "log(number)"  "log(number)" "log(number)" "log(lead times)" "log(lead times)" "log(lead times)" "log(lead times)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 , labels("\checkmark")) ///
 replace

cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "individual.dta", clear

cd "C:\Users\zxuyuan\Downloads\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes

replace price_concession = 100 * price_concession

drop if influence == 0

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_9

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_10

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_11

reghdfe ln_negotiation_period pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_12

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_13

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_14

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_15

reghdfe price_concession pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control, absorb(year#bs_code id) vce(cluster bs_code)
est store robustness_plat_16

esttab robustness_plat_9 robustness_plat_10 robustness_plat_11 robustness_plat_12 robustness_plat_13 robustness_plat_14 robustness_plat_15 robustness_plat_16 ///
 using result_tables/plat_robust_adding_variables_2.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle("log(negotiation period)"  "log(negotiation period)" "log(negotiation period)" "log(negotiation period)" "price concession" "price concession" "price concession" "price concession") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
scalars("r2 R-squared") ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
		 "Hedonic Control = $hedonic_control" ///
		 "Transaction Control = $transaction_control" ///
		 , labels("\checkmark")) ///
 replace
 
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

cd "C:\Users\zxuyuan\Downloads" // change to your working directory

use "for-analysis-with-dummy(should drop).dta", clear

cd "C:\Users\zxuyuan\Downloads\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes ln_negotiation_period

global Lag_hedonic_control *_hedonic_lag

drop if influence  == 0


 
 