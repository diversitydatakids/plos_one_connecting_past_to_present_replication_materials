***Author: Clemens Noelke
***Version 14.0

#d ;
cap log close; clear all; macro drop _all; cap program drop _all; 
set more off; set seed 1003; version 14.0; run "Resources/Startup"; macro dir;
#d cr

local deplist    "mhlth phlth lifex r_coi_nat kfr lpov_nbh"
local threshlist "1 5 10 15 25 33 50"

***********************************************************************************

* Iterave over thresholds
foreach thresh in `threshlist' {
	
	noi di in yellow _n _n "Threshold = `thresh'"

	foreach dropu in yes no {
		
		di in yellow _n _n " Dropping U = `dropu'" _n
		
		if      "`dropu'"=="yes" local maxlayers = 4
		else if "`dropu'"=="no"  local maxlayers = 5
		else exit 1

		use "data/analysis_file.dta"
		
		MakesClassification, dropu("`dropu'") thresh(`thresh') 
		
		* Standardize outcomes, retain raw outcomes as _`vr'
		foreach vr of varlist r_coi_nat mhlth phlth kfr lpov_nbh lifex {
		    noi di "  `vr': " _cont
			qui sum `vr'
			qui replace `vr'=(`vr'-`r(mean)')/`r(sd)'
			qui sum `vr'
			di `: display %9.5f `r(mean)'' " " `: display %9.5f `r(sd)'' " " _cont
		}

		foreach vr in mhlth phlth {
			qui replace `vr'=(-1)*`vr'
		}
		
		* Iterave over dependent variables
		foreach dep in `deplist' {
			
			di _n
			
			* CV5 variable
			qui gen ind=runiform() if `dep'!=.
			xtile cv5=ind if `dep'!=., n(5)
			drop ind
			noi di in green "  CV5: " _cont
			forval fld=1/5 {
				qui count if cv5==`fld'
				noi di "  `fld' (`r(N)')" _cont
			}
				
			* Iterate over classification variables
			foreach ltr in b c d e f m {
			 
				* Iterate over class depths
				di in yellow _n "  `dep', `ltr': " _cont
				
				forval cls = 1/`maxlayers' {
								
					di in white "  layer `cls', folds " _cont
					
					* Iterate over five folds, store training and test MSE
					forval cv = 1/5 {
						
						di `cv' " " _cont
						
						qui reg `dep' ib1._`ltr'`cls' if cv5!=`cv'
						
						local df`cv' = e(df_m)

						qui predict yhat
						qui gen sqer = (`dep'-yhat)^2
						
						sum sqer if cv5!=`cv', meanonly
						local tr`cv' = `r(mean)'
						
						sum sqer if cv5==`cv', meanonly
						local te`cv'  = `r(mean)'	
						
						drop yhat sqer
						
					}

					* Record results and average across folds
					preserve

						clear
						
						qui set obs 5
						qui gen cv=.
						qui gen tr=.
						qui gen te=.
						qui gen df=.
						
						forval cv = 1/5 {
							
							qui replace cv = `cv'     in `cv'
							qui replace tr = `tr`cv'' in `cv'
							qui replace te = `te`cv'' in `cv'
							qui replace df = `df`cv'' in `cv'
							
							macro drop _tr`cv' _te`cv' _df`cv'
							
						}

						collapse (mean) tr te df
						
						qui gen dep = "`dep'"
						qui gen ltr = "`ltr'"
						qui gen cls = `cls'
						order dep ltr cls
						
						local iter = `iter'+1
						tempfile res`iter'
						qui save `res`iter''
						
					restore
					
				}
				
			}
			
			drop cv5
		   
		}

		clear
		forval i = 1/`iter' {
			qui append using `res`i''
			macro drop _res`i'
		}
		macro drop _iter
		
		gen dropu="`dropu'"
		gen thresh=`thresh'
		order thresh dropu
		qui isid dep cls ltr, sort

		qui compress
		tempfile `dropu'_`thresh'
		qui save ``dropu'_`thresh''
		
		macro drop _maxlayers
		clear
				
	}

}

*** Append results
clear
foreach thresh in `threshlist' {
	
	foreach dropu in yes no {

		qui append using  ``dropu'_`thresh''
		macro drop _`dropu'_`thresh'
	
	}
	
}

CloseOut thresh dropu dep cls ltr using "data/crossvalidation_results"
