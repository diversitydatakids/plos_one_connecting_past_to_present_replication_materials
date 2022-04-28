***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr

********************************************************************************

use "data/source_file"

rename _all, lower
rename ??rea ??
rename ?a a_?
label var r_coi_nat "COI 2.0 Opportunity Score, nationally normed"

keep geoid binge cancer casthma chd csmoking diabetes lpa mhlth obesity phlth kfr lpov_nbh kfr_top20 p50_kfr p50_lpov_nbh lifex r_coi_nat a_* trctarea nonzero cbsa cbsaname

* Calculate total area
qui egen tarea=rowtotal(a_a a_b a_c a_d a_u), missing

* Calculate percentag of total area covered by A, B, C, D 
qui egen ind=rowtotal(a_a a_b a_c a_d), missing
qui replace ind=100*ind/tarea
	
* Drop if marginally covered
gen included=ind>=1 & ind!=.
drop ind 

********************************************************************************

foreach vr in kfr lpov_nbh kfr_top20 {
    rename `vr' p25_`vr'
}

* Rename/Rescale OA vars
foreach vr in p25_kfr p25_kfr_top20 p25_lpov_nbh p50_kfr p50_lpov_nbh {
	replace `vr'=100*`vr'
}

foreach vr of varlist a_* {
    replace `vr'=100*`vr'/tarea
}

foreach vr of varlist a_* {
    replace `vr'=0 if `vr'==.
}
replace a_u=100 if a_a==0 & a_b==0 & a_c==0 & a_d==0

*** Output statistics 
foreach vr of varlist a_* lifex phlth mhlth binge cancer casthma chd csmoking diabetes lpa obesity r_coi_nat p50_kfr p50_lpov_nbh p25_kfr p25_kfr_top20 p25_lpov_nbh {

	forval i = 0/1 {
		qui sum `vr' if included==`i'
		local m`i' = `r(mean)'
		local s`i' = `r(sd)'
		local n`i' = `r(N)'
	}
	
	local obs = `obs'+1
	
	local lcl`obs' "`vr'|`m0'|`s0'|`n0'|`m1'|`s1'|`n1'"
	macro drop _m* _s* _n*
	
}

clear
set obs `obs'
gen ind=""
forval i = 1/`obs' {
    replace ind="`lcl`i''" in `i'
	macro drop _lcl`i'
}
macro drop _obs

split ind, p("|") gen(i)

list i?
