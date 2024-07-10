
set maxvar 10000
cd "E:\umich\RealEstateBrokerage-main" // change to your working directory

use "for-analysis-with-dummy(should drop).dta", clear

cd "E:\umich\RealEstateBrokerage"

global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control broker_410 ln_watch_people ln_end_price ln_watch_time  non_online_effect ln_nego_changes ln_negotiation_period


// ssc install reghdfe
// ssc install ftools
// ssc install estout
// ssc install coefplot
// ssc install xtqreg
// ssc install boottest


drop if influence == 0


reghdfe influence pre1_treatment treatment post1_treatment post2_treatment post3_treatment $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year id) vce(cluster bs_code)
est store extension_base_1


forvalues q = 5(5)95 {
    local tau = `q' / 100
    qui: xtqreg influence pre1_treatment treatment post1_treatment post2_treatment post3_treatment ///
    $brokerage_control $hedonic_control $transaction_control $region_control i.year, id(id) q(`tau')
    est store quantile_`q'
}

local quantile_titles
forvalues q = 5(5)95 {
    local quantile_titles `quantile_titles' "`q'%ile"
}

esttab extension_base_1 quantile_5 quantile_10 quantile_15 quantile_20 quantile_25 quantile_30 ///
quantile_35 quantile_40 quantile_45 ///
using quantile_network_formation_1.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle("FE" "Q(5)" "Q(10)" "Q(15)" "Q(20)" "Q(25)" "Q(30)" "Q(35)" "Q(40)" "Q(45)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
        "Hedonic Control = $hedonic_control" ///
        "Transaction Control = $transaction_control" ///
        "Regional Control = $region_control", labels("\checkmark")) ///
replace

esttab quantile_50 quantile_55 quantile_60 quantile_65 quantile_70 quantile_75 quantile_80 ///
quantile_85 quantile_90 quantile_95 ///
using quantile_network_formation_2.tex, ///
style(tex) booktabs keep(pre1_treatment treatment post1_treatment post2_treatment post3_treatment) ///
mtitle("Q(50)" "Q(55)" "Q(60)" "Q(65)" "Q(70)" "Q(75)" "Q(80)" "Q(85)" "Q(90)" "Q(95)") ///
star(* 0.1 ** 0.05 *** 0.01) ///
se ///
b(%9.3f) se(%9.3f) ///
indicate("Brokerage Control = $brokerage_control" ///
        "Hedonic Control = $hedonic_control" ///
        "Transaction Control = $transaction_control" ///
        "Regional Control = $region_control", labels("\checkmark")) ///
replace
