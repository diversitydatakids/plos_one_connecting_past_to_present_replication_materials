***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr


***********************************************************************************

foreach dropu in yes no {
	
	di in yellow _n _n " Dropping U = `dropu'" _n
	if      "`dropu'"=="yes" {
	    local maxlayers = 4
		local example = 175
	}
	else if "`dropu'"=="no"  {
	    local maxlayers = 5
		local example = 84
	}
	else exit 1

	use "data/analysis_file.dta"
	
	MakesClassification, dropu("`dropu'") thresh(1) 
	keep geoid _*
	qui CheckMiss
	
	foreach vr of varlist _* {
	    decode `vr', gen(ind)
		drop `vr'
		rename ind `vr'
	}
	rename _* *

	sort geoid
	di _n _n
	forval layer = 1/`maxlayers' {
		foreach cset in m f e d c b {
			*di "`cset'`layer'," _cont
			qui tab `cset'`layer', m
			di `r(r)' "," _cont 
			di `cset'`layer'[`example'] "," _cont
		}
		di " "
	}
	macro drop _maxlayers _example
	
	clear
	
}