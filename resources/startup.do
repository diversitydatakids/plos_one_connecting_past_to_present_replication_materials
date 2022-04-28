** Colors

global ddkred  	"146 47 32"
global ddkblue 	"1 52 87"

global dkorange	"230 97 0"
global dkyellow "230 169 0"
global dkgreen 	"51 153 0"
global dkpurple "83 1 127"

global ltorange	"255 115 12"
global ltyellow "255 195 26"
global ltgreen 	"102 204 0"
global ltpurple "116 1 177"

global grey 	"92 96 104"


** Load Programs

#d ;

local programs "
	PerfectMerge
	CheckMiss
	CloseOut
	MakesClassification
	CleanCVResults
	";
	

#d cr
	
foreach prg in `programs' {

	noi run "resources/programs/`prg'.do"
	
}

macro dir