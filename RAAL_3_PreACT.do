*** 10.08.2020 MSM -- trying this out -- all students are required to take pre-ACT in 10th grade.  Find all students taking this exam in AY2018-2019, see whether they had any RAAL trained teachers in a real course (with a grade) in AY2017-18 or AY2018-19 ***

cls
clear all
capture log close
set more off
pwd

cd "G:\Shared drives\AANP&RAAL\MSAP_RAAL"
log using log/RAAL_PreACT.txt, text replace
***********************************************************************************

use RawData/students_grade10_preact.dta, clear
tab testdate
tab test

*** pre-ACT is given in the fall semester of 10th grade, so OK to just focus on 9th grade teachers?****
*** 2019 dates are AY2019-2020, etc.***
gen year = substr(testdate, 1, 4)
tab year
destring year, replace

drop if year == 2016
sum scr_eng, detail
tab scr_eng
tab scr_comp
tab scr_comp, missing

destring scr_*, replace ignore("*-")


duplicates report
duplicates report random_sid
duplicates tag random_sid, gen(duplicate_act)
gsort random_sid - testdate - scr_comp // keep later date and higher score >>why keep later dates not earlier dates?
list if duplicate_act == 1 in 1/10

duplicates drop random_sid, force
list if duplicate_act == 1 in 1/10

save WorkingData/RAAL_PreACT, replace

*******************************************************************
**** MERGE WITH RAAL TEACHERS -- LATER ONCE THE DATA ARE FIXED *****

log close
exit

**********************************


*** merge with data on whether the student had trained teachers ***
use workingdata/raal_preact, clear
keep if year == 2019
duplicates report random_sid

merge 1:1 random_sid using WorkingData/Training_x_Student_2019

*** should have non-matches between 9th grade 2018-19 and ACT given in Fall 2019 (about 10% range)
** merge == 1 students with pre-ACT but no 9th grade course data (new students in 10th grade)
** merge == 2 students with 9th grade course data but no pre-ACT (attrition, retention, missing test scores)

keep if _merge == 3
drop _merge

*** NEED TO GET SCHOOL AND STUDENT DEMOGRAPHICS FOR FALL 2019 OR SPRING 2019...***
*** curr school from historical grade files *** get demographics later...


gen srmhs = curr_school == 562

tab RAAL_trained srmhs, missing
tab RAAL_trained_before srmhs, missing

*STUDENTS WHO MOVE SCHOOLS
*list if RAAL_trained == 0 & srmhs == 1
* RANDOM_SID 35643

gen had_RAAL = RAAL_trained_before > 0 if RAAL_trained_before < .

mean scr_comp, over(had_RAAL srmhs)



use ../workingdata/raal_preact, clear
keep if year == 2018
duplicates report random_sid

merge 1:1 random_sid using ∂../WorkingData/Courses_2018
