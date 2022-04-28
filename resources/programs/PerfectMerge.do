***Author: Clemens Noelke

noi di in yellow "MergePerfect: " in green _col(20) "syntax, [DROPMERGE]" in yellow "  Run immediately after merge command, aborts if merge is not perfect."

cap program drop MergePerfect

program define MergePerfect
syntax, [DROPMERGE]

	version 14.2

	qui count if _merge!=3
	
	if `r(N)'!=0 {
		tab _merge, m
		noi di in red "  Merge not perfect."
		exit 1
	}
	
	if "`dropmerge'"=="dropmerge" drop _merge

end

