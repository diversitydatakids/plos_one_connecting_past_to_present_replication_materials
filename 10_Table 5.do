***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; version 14.0; run "Resources/Startup"; macro dir;
#d cr

local deplist  "csmoking binge lpa obesity casthma chd diabetes cancer p25_kfr p25_kfr_top20 p25_lpov_nbh"
local clslist  "m3 m2 m2r m1"

***********************************************************************************

use "data/analysis_file.dta"
MakesClassification, dropu("yes") thresh(5)
keep geoid _* a_a-lpov_nbh
rename _?? ??

**********************************************************************************

replace p25_kfr=100*p25_kfr

gen m2r = m2
recode m2r (1/4=1) // A AB AC AD
recode m2r (6=2) // BA
recode m2r (5=3) // B
recode m2r (10=4) (14=4) // CA DA
recode m2r (7=5) (8=5)   // BC BD
recode m2r (9=6)  // C
recode m2r (11=7) (15=7) // CB DB
recode m2r (13=8) // D
recode m2r (12=9) // CD
recode m2r (16=10) // DC

#d ;
label def m2r
	1 "Only or mainly A"
	2 "Mainly B, some A "
	3 "Only B"
	4 "Mainly C or D, some A"
	5 "Mainly B, some C or D"
	6 "Only C"
	7 "Mainly C or D, some B"
	8 "Only D"
	9 "Mainly C, some D"
	10 "Mainly D, some C"
;
#d cr

label val m2r m2r

tab m2 m2r, m

foreach cls in `clslist' {
	tab `cls', m
}

foreach dep in `deplist' {
		
	noi di in green _n "`dep'"
	
	qui sum `dep' [fw=pop]
	gen s_`dep' = (`dep'-`r(mean)')/`r(sd)'
	
	foreach cls in `clslist' {
		
		di "  `cls': " _cont
		
		local iter = `iter'+1
		
		qui reg s_`dep' i.`cls'
		local res`iter' "`dep'|`cls'|`e(r2)'|`e(r2_a)'|`e(df_m)'|`e(rmse)'"

	}
	
	qui reg s_`dep' a_b a_c a_d
	local iter = `iter'+1
	local res`iter' "`dep'|pr|`e(r2)'|`e(r2_a)'|`e(df_m)'|`e(rmse)'"
	
	drop s_`dep'
	
}

*** Results table

clear
set obs `iter'
gen v=""
forval i = 1/`iter' {
	replace v="`res`i''" in `i'
	macro drop _res`i'
}
macro drop _iter

split v, p("|")
destring v3-v6, replace


keep v1 v2 v3 v4 v5 v6
rename v1 dep 
rename v2 m
rename v3 r2_
rename v4 r2a_
rename v5 df_
rename v6 rmse_

reshape wide r2_ r2a_ df_ rmse_, i(dep) j(m) string

gen grp=regexm(dep, "p25")

foreach model in pr m1 m2 m2r m3 {
	
	preserve
	
		keep dep *_`model' grp
		rename *_`model' *

		local df = df[1]
		drop df

		tempfile `model'
		qui save ``model''
		
		collapse (mean) r2 r2a rmse, by(grp)
		
		gen dep="zz_health"
		qui replace dep="zz_ses" if grp==1
		tempfile ave
		qui save `ave'
		
		use ``model''
		append using `ave'
		macro drop _ave
		
		foreach vr in r2 r2a rmse {
			rename `vr' `vr'_`model'
		}
		macro drop _df
		
		isid grp dep, sort
		qui save ``model'', replace
	
	restore
	
}

clear
use `pr'
macro drop _pr
foreach model in m1 m2r m2 m3 {
	qui isid grp dep, sort
	merge 1:1 grp dep using ``model''
	macro drop _`model'
	MergePerfect, dropmerge
}
drop grp

format r2_* r2a_* rmse_* %9.2f
order rmse_* r2_* r2a_* 
order dep

list dep r2_*