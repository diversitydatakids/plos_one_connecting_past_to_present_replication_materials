***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr

********************************************************************************

*** How many tracts are covered by more than one rating?

use "data/analysis_file"

keep a_a a_b a_c a_d
foreach vr of varlist a_* {
	replace `vr'=1 if `vr'!=0
}
egen ind=rowtotal(a_*)
tab ind, m