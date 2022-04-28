***Author: Clemens Noelke
***This version 01/11/2016

noi di in yellow "CheckMiss: " in green _col(20) "syntax, [FLAG(string)] [IGNORE(string)]" in yellow "  Checks all variables for missings."



cap program drop CheckMiss
program define CheckMiss
syntax [if], [FLAG(string)] [IGNORE(string)]

preserve 

	if "`if'"!="" {
		qui keep `if'
		noi di in green "  Data subset: keep `if'."
	}

	unab vrs : _all
	if "`ignore'"!=""{
		foreach vr in `vrs'{
			foreach ivr in `ignore' {
				if "`vr'"=="`ivr'" drop `vr'
			}
		}
	}
	
	unab vrs : _all
	
	if "`flag'"!=""{
		foreach vr in `flag'{
			local vrs = itrim(subinstr("`vrs'","`vr'","",.))
		}
	}
	
	local vrs = trim("`vrs'")
	
	foreach vr in `vrs'{
		capture confirm string variable `vr'
		if _rc==0 { /* string vars */
			qui count if `vr'==""
			if `r(N)'!=0{
				noi di in red "`vr' has missings."
				exit 1
			}
		}
		else { /* non-string vars, make sure they're numeric, otherwise abort. */
			capture confirm numeric variable `vr'
			if _rc!=0 {
				noi di in red "Missing check not supported. `vr' is neither numeric nor string"
				exit 1
			}
			qui count if `vr'==.
			if `r(N)'!=0{
				noi di in red "`vr' has missings."
				exit 1
			}
		}
	}
	
	if "`flag'"=="" & "`ignore'"==""{
		noi di in green "  No missing in any variable."
	}
	else {
		noi di in green "  No missing observations in: `vrs'."
	}
	macro drop _vrs
	
	if "`flag'"!=""{
		noi di in yellow "  Flagging potential missing observations in: `flag'."
		foreach vr in `flag'{
			capture confirm string variable `vr'
			if _rc==0 { /* string vars */
				qui count if `vr'==""
				if `r(N)'!=0{
					noi di in red "    `vr' has `r(N)' missing observations."
				}
			}
			else { /* non-string vars, make sure they're numeric, otherwise abort. */
				capture confirm numeric variable `vr'
				if _rc!=0 {
					noi di in red "Missing check not supported. `vr' is neither numeric nor string"
					exit 1
				}
				qui count if `vr'==.
				if `r(N)'!=0{
					noi di in red "    `vr' has `r(N)' missing observations."
				}
			}
		}
	}

	if "`ignore'"!=""{
		noi di in yellow "  Omitting from checks: `ignore'."
	}

restore
	
end

exit
