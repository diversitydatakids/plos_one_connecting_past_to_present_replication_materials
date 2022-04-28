***Author: Clemens Noelke

cap program drop MakesClassification
program define MakesClassification
syntax, DROPU(string) THRESH(real) [NOI]

	***********************************************************************************
	
	*** Subset data based on threshold
	
	* Calculate total area
	qui egen tarea=rowtotal(a_a a_b a_c a_d a_u)

	* Calculate percentag of total area covered by A, B, C, D 
	qui egen ind=rowtotal(a_a a_b a_c a_d)
	qui replace ind=100*ind/tarea
	
	*** Drop if below theshold
	noi di in yellow "  Dropping tracts with less than `thresh'% rating coverage: " _cont
	drop if ind<`thresh'
	drop ind tarea

	***********************************************************************************

	*** Dropping U-rated areas
	
	if "`dropu'"=="yes" {
		noi di in yellow "  Dropping U ratings."
		drop a_u
	}
	else if "`dropu'"=="no" di in yellow "  Keeping U rated areas."
	else exit 1
	
	***********************************************************************************

	* Calculate total tract area and percentage coverage (after optionally dropping a_u)
	
	unab varlist : a_*
	
	qui egen tarea=rowtotal(a_*)
	foreach vr in `varlist' {
		qui replace `vr'=100*`vr'/tarea
		qui replace `vr'=0 if `vr'<0 & `vr'!=.
		qui replace `vr'=100 if `vr'>100 & `vr'!=.
	}

	noi di in yellow "  Making classification using variables: `varlist'."	
	
	***********************************************************************************

	preserve
		drop tarea cbsa cbsaname
		qui isid geoid, sort
		tempfile tmp
		qui save `tmp'
	restore

	***********************************************************************************

	keep geoid `varlist'
		
	qui reshape long a, i(geoid) j(grd) string
	
	noi di in yellow "  Dropping observations rows (identified by geoid-rating_grade) with zero area: " _cont
	drop if a==0
	
	qui replace grd=upper(subinstr(grd,"_","",.))

	gsort geoid -a
	qui by geoid: gen ind=_n
	order geoid grd ind

	*** Create D4-U3-... type variable

	qui gen b=.
	forval low=0(10)90 {
		local high = `low'+10
		qui replace b=`low'/10 if a>=`low' & a<`high'  & a!=.
		macro drop _high
	}

	qui replace b=9 if a>=100 & b==. & a!=.
	qui replace b=0 if a<=0   & b==. & a!=.
	if "`noi'"!="" bysort b: sum a

	* 20% intervals
	qui gen c=b
	qui recode c (0/1=0) (2/3=1) (4/5=2) (6/7=3) (8/10=4)
	if "`noi'"!="" tab b c, m

	* 25% intervals
	qui gen d=.
	qui replace d=0 if a>=0  & a<25   & a!=.
	qui replace d=1 if a>=25 & a<50   & a!=.
	qui replace d=2 if a>=50 & a<75   & a!=.
	qui replace d=3 if a>=75 & a<=100 & a!=.
	if "`noi'"!="" bysort d: sum a

	* 33% intervals
	qui gen e=.
	qui replace e=0 if a>=0      & a<33.334   & a!=.
	qui replace e=1 if a>=33.334 & a<66.334   & a!=.
	qui replace e=2 if a>=66.334 & a<=100     & a!=.
	if "`noi'"!="" bysort e: sum a

	* 50% intervals
	qui gen f=.
	qui replace f=0 if a>=0  & a<50   & a!=.
	qui replace f=1 if a>=50 & a<=100   & a!=.
	if "`noi'"!="" tab d f, m

	qui CheckMiss

	* create string variables

	foreach vr in b c d e f {
		qui tostring `vr', replace
		qui replace `vr'=grd+`vr'
	}
	
	* create modal variable
	qui isid geoid ind, sort
	qui gen m=grd

	* Create wide dataset with grd?, ordered in terms of percentage area covered
	drop grd a
	qui reshape wide b c d e f m, i(geoid) j(ind) 
	order geoid b* c* d* e* f* m*

	* Create classification using first, second, ... n-th most important rating

	foreach ltr in b c d e f m {
		
		foreach vr of varlist `ltr'? {
			
			local iter = `iter'+1
			
			* collect list of ltr variables, add one in each iteration
			local vrlist=trim("`vrlist' `vr'")
			
			if `iter'==1 qui gen ind = `vr'
			else {
				
				foreach itm in `vrlist' {
					
					local ii = `ii'+1
					if `ii'==1 gen ind = `itm'
					else qui replace ind = ind+"-"+`itm' if `itm'!=""
					
				}
				macro drop _ii

			}
			
			qui encode ind, gen(_`ltr'`iter')
			drop ind
				
		}
		
		macro drop _iter _vrlist
		
	}

	***********************************************************************************

	qui isid geoid, sort
	qui merge 1:1 geoid using `tmp'
	macro drop _tmp
	MergePerfect, dropmerge

end

exit
