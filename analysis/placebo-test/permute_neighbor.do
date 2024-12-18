capture program drop permute_neighbor
program define permute_neighbor
    syntax varlist(min=1 max=1) using/
    
    local depvar `1'
    local result_file `"`using'"'
    
    global hedonic_control jiadian kind hotel shop_mall museum old ktv mid prim west_food super sub park
    global transaction_control area bedroom toilet house_age floor_level green_ratio total_building total_floor_number living_room elevator_ratio kitchen floor_ratio total_resident
    global region_control pm25 pop light
    global brokerage_control non_online_effect ln_nego_changes ln_negotiation_period
    
    local start_year 2016
    local end_year 2022
    
    matrix coefficients = J(200, 6, .)
    
    forvalues i = 1/200 {
        // 创建随机处理变量
        gen random_entry = runiform()
        sort id year
        by id: gen random_treatment = (random_entry <= 0.5)
    
        // 创建随机处理变量的年份交互项
        forvalues y = `start_year'/`end_year' {
            gen random_treatment_`y' = random_treatment * (`y' == year)
        }
    
        // 执行回归分析，去掉2016年的交互项
        qui reghdfe `depvar' random_treatment_2017-random_treatment_2022 broker_410 ln_watch_people ln_end_price ln_watch_time $brokerage_control $hedonic_control $transaction_control $region_control, absorb(year#bs_code id) vce(cluster bs_code)
    
        // 将随机处理变量和交互项的系数存储到矩阵中
        local col = 1
        forvalues y = 2017/2022 {
            matrix coefficients[`i', `col'] = _b[random_treatment_`y']
            local col = `col' + 1
        }
    
        // 删除生成的随机变量
        drop random_treatment_2016 random_treatment_2017 random_treatment_2018 random_treatment_2019 random_treatment_2020 random_treatment_2021 random_treatment_2022 random_entry random_treatment
        display "Completed iteration `i'"
    }
    drop *
    // 将系数矩阵保存为数据集
    svmat coefficients
    rename coefficients1 random_treatment_2017
    rename coefficients2 random_treatment_2018
    rename coefficients3 random_treatment_2019
    rename coefficients4 random_treatment_2020
    rename coefficients5 random_treatment_2021
    rename coefficients6 random_treatment_2022
    save `result_file', replace
end