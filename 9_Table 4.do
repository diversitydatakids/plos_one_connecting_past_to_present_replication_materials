***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; version 14.0; run "Resources/Startup"; macro dir;
#d cr

local deplist "mhlth phlth lifex r_coi_nat kfr lpov_nbh"

***********************************************************************************

use "data/analysis_file.dta"
MakesClassification, dropu("yes") thresh(1)
keep geoid _* a_a-lpov_nbh

rename _?? ??

keep `deplist' m2

* Standardize outcomes, retain raw outcomes as _`vr'
foreach vr of varlist `deplist' {
	noi di "  `vr': " _cont
	qui sum `vr'
	qui replace `vr'=(`vr'-`r(mean)')/`r(sd)'
	qui sum `vr'
	di `: display %9.5f `r(mean)'' " " `: display %9.5f `r(sd)'' " " _cont
}

foreach vr in mhlth phlth {
	qui replace `vr'=(-1)*`vr'
}

corr `deplist'
alpha `deplist'
egen mo=rowmean(`deplist')

pca `deplist'

**********************************************************************************

/*

A AB AC AD
BA
B
CA DA
BC BD
C
CB DB
D
CD
DC
*/


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

tab m2 m2r, m

preserve 
	collapse (mean) `deplist' mo, by(m2r)
	list
restore

preserve 
	collapse (mean) `deplist' mo, by(m2)
	list
restore






