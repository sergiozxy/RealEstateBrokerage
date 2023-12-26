import delimited "cleaned_district.csv", clear 

// bysort id (year): drop if _N==1

drop if pm25 == .
drop if pop == .

xtset id year
egen bs_code = group(business_area)
egen district_id = group(district)
replace end_price_pers = end_price * 10000 / area

replace income = income * 10000 * 0.03

/*
winsor2 watched_times, replace cuts(0.5 99.5)
winsor2 end_price_pers, replace cuts(0.5 99.5)
winsor2 nego_period, replace cuts(0.5 99.5)
winsor2 number, replace cuts(0.5 99.5)
winsor2 end_price, replace cuts(1 99)
winsor2 income, replace cuts(0.5 99.5)
winsor2 striker_price_pers, replace cuts(0.5 99.5)
*/

generate treated = 1 if region == "shanghai" & year == 2022
replace treated = 1 if region == "wuhan" & year >= 2020
replace treated = 0 if treated == .

global Control_Variables floor_level floor_ratio green_ratio total_building total_resident area bedroom living_room kitchen toilet total_floor_number elevator_ratio super sub hotel kind prim mid shop_mall west_food park museum ktv jiadian house_age old light pop pm25

generate density = lianjia_5 / other_5
generate lj_ratio = lianjia_5 / (lianjia_5 + beke_5)

generate density_1k = lianjia / other
replace density_1k = 0 if density_1k == .

replace watched_times = watched_times + 1
generate ln_watched = log(watched_times)

replace density = 0 if density == .
replace lj_ratio = 0 if lj_ratio == .
generate ln_end_price = log(end_price_pers)
generate ln_num = log(number)
generate ln_negotiation_period = log(nego_period)
generate ln_income = log(income)
generate diff_ratio = (end_price_pers - striker_price_pers) / striker_price_pers

replace watching_people = watching_people + 1
generate ln_watch_people = log(watching_people)

generate non_watch = 0 if watching_people == 1
replace non_watch = 1 if non_watch == .

generate non_nego = 1 if nego_times == 1
replace non_nego = 0 if non_nego == .

// so why they have so many watching people and they do not have a valid 

replace lead_times = lead_times + 1
generate ln_lead = log(lead_times)

replace nego_times = nego_times + 1
generate ln_nego_times = log(nego_times)

generate ln_profit_1k = log(prft)
generate ln_num_1k = log(num)
generate ln_end_1k = log(price)

// this captures the effect of platformization globally.

tabstat ln_num_1k, stat(p75 p90)

generate density2 = density * density

drop if region == "xian"
