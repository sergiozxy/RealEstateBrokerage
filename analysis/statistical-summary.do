cd "E:\umich\RealEstateBrokerage-main" // change to your working directory



global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park

global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident

global region_control pm25 pop light

global brokerage_control non_online_effect ln_nego_changes ln_negotiation_period


use "template.dta", clear
// statistical result

replace income = income / 10000
generate by_lj = (lianjia_410 > 0)

logout, save(ttest_with_result) dta replace: ttable3 income lead_times price_concession density end_price broker_410 watching_people non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) tvalue

logout, save(ttest_with_result_mean_std) dta replace: tabstat income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) stat(mean sd) nototal long col(stat)

use "individual.dta", clear

replace income = income / 10000
generate by_lj = (lianjia_410 > 0)

logout, save(ttest_with_result_indi) dta replace: ttable3 income lead_times price_concession density end_price broker_410 watching_people non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) tvalue

logout, save(ttest_with_result_mean_std_indi) dta replace: tabstat income lead_times price_concession density broker_410 watching_people end_price non_online_effect watched_times nego_times nego_period $hedonic_control $transaction_control $region_control, by(by_lj) stat(mean sd) nototal long col(stat)


