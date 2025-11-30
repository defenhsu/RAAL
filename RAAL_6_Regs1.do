*** with the best data, go ahead and define demographics and run regs ***

cls
clear all
capture log close
set more off
pwd

cd "G:\Shared drives\AANP&RAAL\MSAP_RAAL"
log using log/RAAL_6_Regs1.txt, text replace
*****************************************************
use WorkingData/RAAL_sample_v1, clear

***** DEFINE COVARIATES ****

*** race ***
tab race_new
gen race_blk = (race_new == 4)
gen race_hisp = (race_new == 3)
gen race_wht = (race_new == 5)
gen race_oth = 1 - race_blk - race_hisp - race_wht

tab spec_ed
tab lep_current
tab gender
gen male = gender == "M"

local covars "male race_blk race_hisp race_oth spec_ed lep_current"

* gen indicators
gen year2018_srmhs = (year == 2018)*srmhs
gen year2019_srmhs = (year == 2019)*srmhs

gen year2017 = year == 2017
gen year2018 = year == 2018
gen year2019 = year == 2019

label var year2018_srmhs "SRMHS 2018"
label var year2019_srmhs "SRMHS 2019"
label var srmhs "SRMHS"
label var year2018 "Year 2018"
label var year2019 "Year 2019"
label var male "Male"
label var race_blk "Black"
label var race_hisp "Hispanic"
label var race_oth "Other Race/Ethnicity"
label var spec_ed "Special Education"
label var lep_current "LEP"

tab year srmhs if scr_eng < .

mean scr_eng, over(year srmhs)
mean scr_read, over(year srmhs)
mean scr_math, over(year srmhs)
mean scr_sci, over(year srmhs)
mean scr_comp, over(year srmhs)
mean scr_stem, over(year srmhs)

estimates clear

eststo: xi: reg scr_eng srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school) // why add xi when everything is already indicators??
estadd ysumm
eststo: xi: reg scr_read srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school)
estadd ysumm
eststo: xi: reg scr_math srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school)
estadd ysumm
eststo: xi: reg scr_sci srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school)
estadd ysumm
eststo: xi: reg scr_comp srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school)
estadd ysumm
eststo: xi: reg scr_stem srmhs year2018_srmhs year2019_srmhs year2018 year2019 `covars', cluster(cur_school)
estadd ysumm



esttab est1 est2 est3 est4 est5 ///
using output/Tbl_PreACT.html, replace /// rtf ==> html
mtitles("English" "Reading" "Math" "Science" "Composite") ///
star(* 0.10 ** 0.05 *** 0.01) lab se sca("ymean Mean of Dep Var") nobase b(3) se(3)


log close
exit
