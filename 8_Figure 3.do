***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr

********************************************************************************


use "data/crossvalidation_results"
CleanCVResults

*** Baseline differences

decode ulbl, gen(ind)

***

gen obs=1
collapse (p50) te df (sum) obs, by(ulbl)
decode ulbl, gen(ind)
drop ulbl
rename ind lbl

sum te
local ymin = `r(min)'

#d ;

twoway 	scatter te df if lbl!="RO-3" & lbl!="RO-2", mc("${grey}") ms(Oh) ||
		scatter te df if lbl=="RO-3", mc("${dkyellow}") ||
		scatter te df if lbl=="RO-2", mc("${ddkblue}") 
			yline(`ymin', lc("${dkyellow}"))
		   legend(off)
		   xti(" " "Median degrees of freedom" " ")
		   yti("Median Test MSE" " " ) 
		   ylab(, glw(vvthin) glc(gs14))
			graphregion(color(white) margin(medsmall))
			name(p1, replace)
			
;
#d cr

drop if df>100

#d ;

twoway 	scatter te df if lbl!="RO-3" & lbl!="RO-2", mc("${grey}") ms(Oh) ||
		scatter te df if lbl=="RO-3", mc("${dkyellow}") ||
		scatter te df if lbl=="RO-2", mc("${ddkblue}") 
			yline(`ymin', lc("${dkyellow}"))
		   legend(off)
		   xti(" " "Median degrees of freedom" " ")
		   yti("Median Test MSE" " " ) 
		   ylab(, glw(vvthin) glc(gs14))
			graphregion(color(white) margin(medsmall))
			name(p2, replace)
;
#d cr

