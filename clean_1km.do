import delimited "E:\umich\analysis and did\final_8_12.csv", clear
drop id
xtset id_unique year
drop top left bottom right

rename hotel hotel_num
rename jd elect_store
rename flrate floor_ratio
rename grrate green_ratio
rename muse museum_num
rename fllvl floor_level
rename kitche kitchen
rename bedroo bedroom
rename lianj lianjia
rename west west_food
rename flnum floor_num
rename prft lj_income
rename prim primary
rename reside residence
rename price end_price
rename ldtm lead_time
rename broke other
rename wtpp watching_people
rename peri negotiation_period

rename ngtm negotiation_times
rename diff negotiation_difference
rename wttm watched_times
rename numbu number_building
rename dfrat difference_ratio
rename pripe end_price_pers
rename grppr business_area_average_price
rename grpnu business_area_sum_num
rename grpic business_area_sum_income

drop lttm
drop nego
drop index
rename point_value business_area
rename num trans_num


/*
replace age = L.age if city == "beijing" & year == 2021
replace green_ratio = L.green_ratio if city == "beijing" & year == 2021
replace number_building = L.number_building if city == "beijing" & year == 2021
replace tihu = L.tihu if city == "beijing" & year == 2021
replace floor_ratio = L.floor_ratio if city == "beijing" & year == 2021
replace residence = L.residence if city == "beijing" & year == 2021
replace end_price = L.end_price if city == "beijing" & year == 2021
replace end_price_pers = L.end_price_pers if city == "beijing" & year == 2021

replace age = L.age if city == "beijing" & year == 2022
replace green_ratio = L.green_ratio if city == "beijing" & year == 2022
replace number_building = L.number_building if city == "beijing" & year == 2022
replace tihu = L.tihu if city == "beijing" & year == 2022
replace floor_ratio = L.floor_ratio if city == "beijing" & year == 2022
replace residence = L.residence if city == "beijing" & year == 2022
replace end_price = L.end_price if city == "beijing" & year == 2022
replace end_price_pers = L.end_price_pers if city == "beijing" & year == 2022

replace age = L.age if city == "chengdu" & year == 2021
replace green_ratio = L.green_ratio if city == "chengdu" & year == 2021
replace number_building = L.number_building if city == "chengdu" & year == 2021
replace tihu = L.tihu if city == "chengdu" & year == 2021
replace floor_ratio = L.floor_ratio if city == "chengdu" & year == 2021
replace residence = L.residence if city == "chengdu" & year == 2021
replace end_price = L.end_price if city == "chengdu" & year == 2021
replace end_price_pers = L.end_price_pers if city == "chengdu" & year == 2021

replace age = L.age if city == "chengdu" & year == 2022
replace green_ratio = L.green_ratio if city == "chengdu" & year == 2022
replace number_building = L.number_building if city == "chengdu" & year == 2022
replace tihu = L.tihu if city == "chengdu" & year == 2022
replace floor_ratio = L.floor_ratio if city == "chengdu" & year == 2022
replace residence = L.residence if city == "chengdu" & year == 2022
replace end_price = L.end_price if city == "chengdu" & year == 2022
replace end_price_pers = L.end_price_pers if city == "chengdu" & year == 2022

replace age = L.age if city == "xian" & year == 2021
replace green_ratio = L.green_ratio if city == "xian" & year == 2021
replace number_building = L.number_building if city == "xian" & year == 2021
replace tihu = L.tihu if city == "xian" & year == 2021
replace floor_ratio = L.floor_ratio if city == "xian" & year == 2021
replace residence = L.residence if city == "xian" & year == 2021
replace end_price = L.end_price if city == "xian" & year == 2021
replace end_price_pers = L.end_price_pers if city == "xian" & year == 2021

replace age = L.age if city == "xian" & year == 2022
replace green_ratio = L.green_ratio if city == "xian" & year == 2022
replace number_building = L.number_building if city == "xian" & year == 2022
replace tihu = L.tihu if city == "xian" & year == 2022
replace floor_ratio = L.floor_ratio if city == "xian" & year == 2022
replace residence = L.residence if city == "xian" & year == 2022
replace end_price = L.end_price if city == "xian" & year == 2022
replace end_price_pers = L.end_price_pers if city == "xian" & year == 2022

replace age = L.age if city == "shenzhen" & year == 2021
replace green_ratio = L.green_ratio if city == "shenzhen" & year == 2021
replace number_building = L.number_building if city == "shenzhen" & year == 2021
replace tihu = L.tihu if city == "shenzhen" & year == 2021
replace floor_ratio = L.floor_ratio if city == "shenzhen" & year == 2021
replace residence = L.residence if city == "shenzhen" & year == 2021
replace end_price = L.end_price if city == "shenzhen" & year == 2021
replace end_price_pers = L.end_price_pers if city == "shenzhen" & year == 2021

replace age = L.age if city == "shenzhen" & year == 2022
replace green_ratio = L.green_ratio if city == "shenzhen" & year == 2022
replace number_building = L.number_building if city == "shenzhen" & year == 2022
replace tihu = L.tihu if city == "shenzhen" & year == 2022
replace floor_ratio = L.floor_ratio if city == "shenzhen" & year == 2022
replace residence = L.residence if city == "shenzhen" & year == 2022
replace end_price = L.end_price if city == "shenzhen" & year == 2022
replace end_price_pers = L.end_price_pers if city == "shenzhen" & year == 2022
*/
// give a try

drop if city == "xian"
drop if city == "shenzhen" & year == 2021
drop if city == "shenzhen" & year == 2022
drop if city == "chengdu" & year == 2021
drop if city == "chengdu" & year == 2022
drop if city == "beijing" & year == 2021
drop if city == "beijing" & year == 2022

egen mean_pm25 = mean(pm25)
replace pm25 = mean_pm25 if mi(pm25)
drop mean_pm25

generate treated = 1 if city == "shanghai" & year == 2022
replace treated = 1 if city == "wuhan" & year >= 2020
replace treated = 0 if treated == .



global Control_Variables elect_store area bedroom kind toilet age hotel_num mall museum_num floor_level old ktv mid primary west_food super green_ratio number_building floor_num living tihu sub kitchen floor_ratio residence park  

generate density = lianjia / other
replace density = 0 if density == .

drop if negotiation_period == 0

/*
winsor2 end_price_pers, replace cuts(1 99)
winsor2 lj_income, replace cuts(1 99)
winsor2 negotiation_period, replace cuts(1 99)
winsor2 lead_time, replace cuts(1 99)
winsor2 negotiation_times, replace cuts(1 99)
winsor2 negotiation_period, replace cuts(1 99)
winsor2 watching_people, replace cuts(1 99)
winsor2 watched_times, replace cuts(1 99)
*/

replace lj_income = lj_income * 10000 * 0.03
replace lj_income = lj_income + 1
replace end_price_pers = end_price_pers * 10000

replace lead_time = lead_time + 1
replace negotiation_times = negotiation_times + 1
replace watched_times = watched_times + 1
replace watching_people = watching_people + 1
replace negotiation_period = negotiation_period + 1

generate ln_income = log(lj_income)
generate ln_end = log(end_price_pers)
generate ln_num = log(trans_num)
generate ln_lead = log(lead_time)
generate ln_watch_people = log(watching_people)
generate ln_watch_time = log(watched_times)
generate ln_nego_changes = log(negotiation_times)
generate ln_negotiation_period = log(negotiation_period)

replace business_area_sum_income = business_area_sum_income * 10000 * 0.03
replace business_area_sum_income = business_area_sum_income + 1
generate ln_income_bs = log(business_area_sum_income)
generate ln_num_bs = log(business_area_sum_num)
replace ln_num_bs = 0 if ln_num_bs == .
replace business_area_average_price = business_area_average_price * 10000
generate ln_pri_bs = log(business_area_average_price)

replace ln_pri_bs = 0 if ln_pri_bs == .

generate did = 1 if density > 0
replace did = 0 if did == .

generate treat_did = treated * did

egen bs_code = group(business_area)

drop if bs_code == .

sum ln_num_bs ln_num


// xtheckmanfe wage age tenure, select(working = age market)