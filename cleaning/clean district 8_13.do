// you should not directly run the codes, you shall run with the
// "working on district level.do"
// which gives the directory of the file
cd "E:\umich\RealEstateBrokerage-main"
import delimited "cleaned_district_Jan_8.csv", clear 


label variable building_type "The classification of a particular building."
label variable village "The region that it belongs to."
label variable district "Administrative division that the Community belongs to."
label variable floor_level "The level on which a particular room or apartment is, within a building."
label variable new_lng "The longitude coordinates."
label variable new_lat "The latitude coordinates."
label variable year "Time ID."
label variable floor_ratio "The ratio of the floor area to the total plot area."
label variable green_ratio "The ratio of the green space to the total plot area."
label variable nego_times "The number of times a negotiation was held."
label variable lead_times "The time it takes before a deal is made."
label variable total_building "The total number of buildings in an area."
label variable total_resident "The total number of residents in an area."
label variable watching_people "The number of people watching a listing."
label variable watched_times "The number of times a listing is watched."
label variable striker_price "The initial asking price."
label variable striker_price_pers "The asking price per square foot."
label variable end_price "The final agreed price."
label variable end_price_pers "The final agreed price per square foot."
label variable area "The area of a property."
label variable nego_period "The period over which negotiations took place."
label variable bedroom "The number of bedrooms in a property."
label variable living_room "The number of living rooms in a property."
label variable kitchen "The number of kitchens in a property."
label variable toilet "The number of toilets in a property."
label variable total_floor_number "The number of floors in a building."
label variable elevator_ratio "The ratio of elevators to the total number of floors."
label variable house_age "The age of the house."
label variable income "The income lianjia in this given district."
label variable number "The number lianjia in this given district."
label variable super "Referring to proximity to supermarkets (measured by number within given distance)."
label variable sub "Referring to proximity to subway stations."
label variable hotel "Referring to proximity to hotels"
label variable kind "Referring to proximity to kindergartens"
label variable prim "Referring to primary schools."
label variable mid "Referring to middle schools."
label variable shop_mall "Referring to shopping mall."
label variable west_food "Referring to the availability of western food nearby."
label variable park "Referring to parks."
label variable museum "Distance to the nearest museum."
label variable ktv "Referring to KTV and some entertainment venues."
label variable jiadian "Referring to electronic shops."
label variable old "Referring to old care systems."
label variable other "Other real estate brokerages within 1km."
label variable other_5 "Other real estate brokerages within 0.5km."
label variable lianjia "Lianjia's number within 1km."
label variable lianjia_5 "Lianjia's number within 0.5km."
label variable beke "Beke's number within 1km."
label variable beke_5 "Beke's number within 0.5km."
label variable geometry "Geometry information."
label variable light "Night time lights."
label variable pop "Population density."
label variable pm25 "Air quality measure."
label variable region "City name."
label variable id "Unique id."
label variable business_area "Business area."
label variable region_num "Transaction number within 1km"
label variable region_income "Lianjia's income within 1km"
label variable region_price "Housing price within 1km"
label variable nearest_index_1 "dummy if it is the nearest communities to stores"
label variable nearest_index_2 "dummy if it is the nearest two communities to stores"
label variable nearest_store_indices "the nearest lianjia's store's index"
label variable nearest_store_distances "the distance to nearest lianjia's store"
label variable lianjia_420 "number of lianjia within 420 meters, which is the cutoff of RD"
label variable broker_420 "number of brokerages within 420 meters, which is the cutoff of RD"
rename all_beke_420 beke_420
label variable beke_420 "number of beke within 420 meters, which is the cutoff of RD"
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

generate density = lianjia_420 / broker_420
replace density = 0 if density == .

generate density_5 = lianjia_5 / other_5
generate lj_ratio = lianjia_5 / (lianjia_5 + beke_5)

generate density_1k = lianjia / other
replace density_1k = 0 if density_1k == .

replace watched_times = watched_times + 1
generate ln_watch_time = log(watched_times)

replace density_5 = 0 if density_5 == .
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
generate ln_nego_changes = log(nego_times)
 
generate ln_profit_1k = log(region_income)
generate ln_num_1k = log(region_num)
generate ln_end_1k = log(region_price)

// this captures the effect of platformization globally.

tabstat ln_num_1k, stat(p75 p90)

generate density2 = density * density

drop if region == "xian"
generate non_online_effect = 1 if ln_lead == 0
replace non_online_effect = 0 if non_online_effect == .


// instead of using GMM methods to globally control for this one,
// we have to use the different level of control to estimate the results
// so we divide the control variables into the following parts

egen city_id = group(region)

// now using proxy variable to conduct the analysis

winsor2 price_concession, replace cuts(1 99) trim

save template.dta, replace
