cap program drop CloseOut
program define CloseOut
syntax varlist using/, [NOCompress] [NOOorder] [NOReplace] [NEW]
	
	local replace "replace"
	if "`noreplace'"=="noreplace" macro drop _replace
	
	if "`nocompress'"=="" qui compress
	if "`noorder'"=="" order `varlist'
	isid `varlist'
	sort `varlist'
	
	noi di in green "  Saving to " in yellow "`using'"
	if "`new'"!="new" qui saveold "`using'", `replace' version(12)
	else qui save "`using'", `replace'

end
