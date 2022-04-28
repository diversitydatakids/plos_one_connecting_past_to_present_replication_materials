***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "resources/startup"; macro dir;
#d cr

********************************************************************************

use "data/crossvalidation_results"
CleanCVResults

*** Baseline differences
reg te ib6.cset
est store cset

reg te ib2.layers
est store layers

reg te ib0.incU
est store incU

reg te ib6.dep
est store dep

reg te ib5.thresh
est store thresh

reg te ib6.cset ib2.layers ib0.incU ib6.dep ib5.thresh
est store pooled

sum te
est table cset layers incU dep thresh pooled, stats(N r2) b(%9.4f)


#d ; 

esttab  cset layers incU dep thresh pooled, 

		cells( b(star fmt(%9.3f)) se(par fmt(%9.3f)) ) 
		collabels(none)  
		
		label
		
		starlevels(* 0.05 ** 0.01 *** 0.001) 						

		stats(
			N r2 F df_m,
			fmt(%11.0f %9.2f %9.2f %11.0f)
			label("Observations" "R-squared" "F statistic" "Degrees of freedom")
		)
		nonumbers 	
;
#d cr	