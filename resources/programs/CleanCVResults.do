cap program drop CleanCVResults
program define CleanCVResults
syntax

	isid thresh dropu dep cls ltr, sort	

	*** Classification Set

	rename ltr cset
	
	* clean string for label
	qui replace cset="10%" if cset=="b"
	qui replace cset="20%" if cset=="c"
	qui replace cset="25%" if cset=="d"
	qui replace cset="33%" if cset=="e"
	qui replace cset="50%" if cset=="f"
	qui replace cset="RO"  if cset=="m"

	* numeric
	rename cset str_cset
	qui encode str_cset, gen(cset)

	*** Include U
	
	* numeric
	qui gen incU=0
	qui replace incU=1 if dropu=="no"
	drop dropu
	
	* string for label
	qui gen str_incU=""
	qui replace str_incU="-U" if incU==1

	*** Layer
	
	* numeric
	rename cls layers
	
	* string
	qui tostring layers, gen(str_layers) 

	*** Label

	* string
	qui gen str_lbl=str_cset+"-"+str_layers
	qui gen str_ulbl=str_lbl+str_incU
	
	* numeric
	encode str_lbl, gen(lbl)
	encode str_ulbl, gen(ulbl)
	
	*** Dependent variable
	rename dep str_dep
	encode str_dep, gen(dep)
	drop str_*
	
	order dep thresh incU cset layers tr te df

	tab layers cset, m
	tab dep thresh, m
	bysort incU: tab dep thresh if layers==1 & cset==1, m
	qui compress
	

end