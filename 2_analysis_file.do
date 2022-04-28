***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "resources/startup"; macro dir;
#d cr

********************************************************************************

use "data/source_file"

rename _all, lower
rename ??rea ??
rename ?a a_?
label var r_coi_nat "COI 2.0 Opportunity Score, nationally normed"

foreach vr in kfr kfr_top20 lpov_nbh work_32 {
	rename `vr' p25_`vr'
}

keep geoid pop binge-phlth lifex p50_kfr p50_lpov_nbh p25_* r_coi_nat a_* trctarea nonzero cbsa cbsaname

* Checks: ?Area variables sum up to TrctArea
egen ind=rowtotal(a_*), missing
replace ind=ind-trctarea
sum ind
drop ind trctarea

* Generate total area, only defined
egen tarea=rowtotal(a_*), missing

* Generate percent rated area
egen p_rarea=rowtotal(a_a a_b a_c a_d), missing
replace p_rarea=100*p_rarea/tarea

* Drop fully unrated tracts in rated metros
tab cbsa nonzero, m
drop if nonzero=="no HOLC"
drop nonzero

* Subset to at least 1% rated
sum p_rarea, d
drop if p_rarea<1
drop p_rarea tarea
count 

********************************************************************************

* Rename/Rescale OA vars
foreach vr in kfr lpov_nbh {
	gen `vr'=100*p50_`vr'
	label var `vr' "p50, `: variable label p50_`vr''"
	drop p50_`vr'
}

order geoid cbsa cbsaname a_* pop 

CloseOut geoid using "data/analysis_file"