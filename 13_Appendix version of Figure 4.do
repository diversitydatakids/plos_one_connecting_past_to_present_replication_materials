***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr

********************************************************************************

use "Data/CrossvalidationResults"
CleanCVResults

*** Baseline differences

decode ulbl, gen(ind)
isid ind dep thresh

***

preserve
	collapse (p50) te df, by(ind)
	isid ind
	tempfile tmp
	save `tmp'
restore

collapse (p50) te df, by(ind dep)

isid dep ind
append using `tmp'
macro drop _tmp

gen filter=0
replace filter=1 if ind=="RO-3"
replace filter=2 if ind=="RO-2"

drop if dep==.
rename ind lbl

replace dep=dep+rnormal(0,.1) if lbl!="RO-3" & lbl!="RO-2"

#d ;

	twoway 	scatter dep te if lbl!="RO-3" & lbl!="RO-2", mc("gs10") ms(Oh) ||
			scatter dep te if lbl=="RO-3", mc("${dkyellow}")  ||
			scatter dep te if lbl=="RO-2", mc("${ddkblue}") 
		
	xti("Median Test MSE") yti("")
	
	ylab( 
           1 "Household income rank"
           2 "Life expectancy"
           3 "Low poverty neighborhood"
           4 "Mental Health"
           5 "Physical Health"
           6 "Child Opportunity Index 2.0",
		   angle(0)
		   glw(vthin) 
		   glc(gs14)
		   
	)
   					
	legend(off)

	graphregion(color(white) margin(medsmall))
	name(p2, replace)	
;
#d cr

 

