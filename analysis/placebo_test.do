global base_path "C:\Users\zxuyuan\Downloads"
global result_path "C:\Users\zxuyuan\Downloads\RealEstateBrokerage\analysis\placebo-test"

**** NOW WE CONSIDER THE PLACEBO FOR ENTRY EFFECT

cd $base_path
use "for-analysis-with-dummy(should drop).dta", clear
cd $result_path

drop if to_keep == 0
set seed 130

do "permute_neighbor.do"
permute_neighbor ln_num using "num_entry_effect.dta"


cd $base_path
use "for-analysis-with-dummy(should drop).dta", clear
cd $result_path

drop if to_keep == 0
set seed 130

do "permute_neighbor.do"
permute_neighbor ln_lead using "lead_entry_effect.dta"


cd $base_path
use "individual.dta", clear
cd $result_path

drop if to_keep == 0
set seed 130 

do "permute_indi.do"
permute_indi ln_negotiation_period using "period_entry_effect.dta"


cd $base_path
use "individual.dta", clear
cd $result_path

drop if to_keep == 0
set seed 130

do "permute_indi.do"
permute_indi price_concession using "conces_entry_effect.dta"


**** NOW WE CONSIDER THE PLACEBO FOR TREATMENT EFFECT

cd $base_path
use "for-analysis-with-dummy(should drop).dta", clear
cd $result_path

drop if influence == 0
set seed 130

do "permute_neighbor.do"
permute_neighbor ln_num using "num_platform.dta"
permute_neighbor ln_lead using "lead_platform.dta"

cd $base_path
use "individual.dta", clear
cd $result_path

drop if influence == 0
set seed 130

do "permute_indi.do"
permute_indi ln_negotiation_period using "period_platform.dta"
permute_indi price_concession using "conces_platform.dta"
