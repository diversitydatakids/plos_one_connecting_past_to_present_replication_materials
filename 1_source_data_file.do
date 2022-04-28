***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "resources/startup"; macro dir;
#d cr


********************************************************************************

import delim using "data/tract_redlining_file_michael_outrich.csv", delim(",") stringcol(_all) varn(1) case(preserve)
keep GeoID CBSAName ?Area TrctArea 
destring *Area, replace
rename GeoID geoid
isid geoid, sort
tempfile holc
save `holc'
d
clear

********************************************************************************

* Load and merge COI 2.0 data files
foreach fle in zscores raw index pop {
	
	di "`fle': " _cont
	
	import delim using "Data/`fle'.csv", stringcol(_all) varn(1) delim(",") case(preserve)
	
	if "`fle'"!="pop" keep geoid year *_*
	
	qui keep if year=="2015"
	drop year
	
	isid geoid, sort
	tempfile `fle'
	qui save ``fle''
	
	clear
	
}

use `pop'
macro drop _pop

foreach fle in raw zscores index {
	
	di _n "`fle'" _cont
	
	isid geoid, sort
	merge 1:1 geoid using ``fle''
	macro drop _`fle'
	qui count if _merge==2
	if `r(N)'!=0 exit 1
	drop _merge
	
}

drop total

* Merge on other outcomes data
isid geoid, sort
merge m:1 geoid using "data/other_nbh_metrics"
MergePerfect, dropmerge

* Convert COI 2.0 levels variables from string to labelled numeric

foreach lvl in "Very Low" "Low" "Moderate" "High" "Very High" {
	local iter = `iter'+1
	label define lvls `iter' "`lvl'", modify
}
macro drop _iter
label list lvls

unab vrs : _all

foreach vr of varlist c5_* {
	
	di _n "`vr'" _cont
	
	qui gen _`vr'=.
	
	foreach lvl in "Very Low" "Low" "Moderate" "High" "Very High" {
		local iter = `iter'+1
		qui replace _`vr'=`iter' if `vr'=="`lvl'"
	}
	macro drop _iter

	label val _`vr' lvls
	
	tab _`vr' `vr', m
	
	drop `vr'
	rename _`vr' `vr'
	
}
macro drop _iter

order `vrs'
macro drop _vrs

* Convert to numeric

destring in100 pop aian-white, replace
destring ED_* HE_* SE_*, replace
destring zED_* zHE_* zSE_*, replace
destring z_* r_*, replace

********************************************************************************

isid geoid, sort
merge 1:1 geoid using `holc'
drop if _merge==2
drop _merge

* Identify tracts with non-zero A, B, C, or D rating
gen nonzero="no HOLC"
foreach vr in AArea BArea CArea DArea {
	replace nonzero="some HOLC" if `vr'>0 & `vr'!=.
}
tab nonzero, m

* CBSA status
gen cbsa=""
replace cbsa="cbsa, 100 largest" if in100==1
replace cbsa="cbsa, not 100 largest" if in100==0
replace cbsa="rural" if in100==.
tab cbsa in100, m

********************************************************************************

CloseOut geoid using "data/source_file"
