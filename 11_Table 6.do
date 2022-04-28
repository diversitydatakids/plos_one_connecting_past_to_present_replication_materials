***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; version 14.0; run "Resources/Startup"; macro dir;
#d cr

local deplist  "casthma p25_kfr"
local clslist "m3 m2 m2r m1"

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
tab m2r m1, m

reg p25_kfr i.m1
est store kfr1

reg p25_kfr i.m2r
est store kfr2

reg diabetes i.m1
est store diabetes1

reg diabetes i.m2r
est store diabetes2

#d ;

esttab kfr1 diabetes1, 

		cells( b(star fmt(%9.2f)) se(par fmt(%9.2f)) ) 
		collabels(none)  
		
		starlevels(* 0.05 ** 0.01 *** 0.001) 						

		stats(
			N r2 F df_m,
			fmt(%11.0f %9.2f %9.2f %11.0f)
			label("Observations" "R-squared" "F statistic" "Degrees of freedom")
		)
		nonumbers 	
;

esttab kfr2 diabetes2, 

		cells( b(star fmt(%9.2f)) se(par fmt(%9.2f)) ) 
		collabels(none)  
		
		starlevels(* 0.05 ** 0.01 *** 0.001) 						

		stats(
			N r2 F df_m,
			fmt(%11.0f %9.2f %9.2f %11.0f)
			label("Observations" "R-squared" "F statistic" "Degrees of freedom")
		)
		nonumbers 	
;
#d cr	