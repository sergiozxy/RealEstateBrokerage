cd "E:\umich\RealEstateBrokerage-main"

use "for-analysis-with-dummy(should drop).dta", clear

* Generate summary statistics for each year and group
collapse (mean) mean_ln_income=ln_income, by(treatment_year* group)

* Plot the data
twoway (line mean_ln_income treatment_year* if group == 1, sort lcolor(red) lpattern(solid) lwidth(medium) ///
       title("Income over Years for Treatment and Control Groups") ///
       xlabel(1(1)5) ylabel( , angle(0))) ///
       (line mean_ln_income treatment_year* if group == 0, sort lcolor(blue) lpattern(dash) lwidth(medium) ///
       legend(label(1 "Treatment Group") label(2 "Control Group")))
	   
	   
// now we also need to plot the distribution among the groups with or without the results

