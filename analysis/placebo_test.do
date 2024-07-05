global base_path "E:\umich\RealEstateBrokerage-main"
global result_path "E:\umich\RealEstateBrokerage\analysis\placebo-test"

**** NOW WE CONSIDER THE PLACEBO FOR ENTRY EFFECT

cd $base_path
use "for-analysis-with-dummy(should drop).dta", clear
cd $result_path

drop if to_keep == 0
set seed 130

do "permute_neighbor.do"
permute_neighbor ln_num using "for-analysis-with-dummy(should drop).dta"
permute_neighbor ln_lead using "for-analysis-with-dummy(should drop).dta"

cd $base_path
use "individual.dta", clear
cd $result_path

drop if to_keep == 0
set seed 130

do "permute_indi.do"
permute_indi ln_negotiation_period using "individual.dta"
permute_indi price_concession using "individual.dta"


**** NOW WE CONSIDER THE PLACEBO FOR TREATMENT EFFECT

cd $base_path
use "for-analysis-with-dummy(should drop).dta", clear
cd $result_path

drop if influence == 0
set seed 130

do "permute_neighbor.do"
permute_neighbor ln_num using "for-analysis-with-dummy(should drop).dta"
permute_neighbor ln_lead using "for-analysis-with-dummy(should drop).dta"

cd $base_path
use "individual.dta", clear
cd $result_path

drop if influence == 0
set seed 130

do "permute_indi.do"
permute_indi ln_negotiation_period using "individual.dta"
permute_indi price_concession using "individual.dta"
