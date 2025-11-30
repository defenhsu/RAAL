*** 10.08.2020 MSM -- trying this out -- all students are required to take pre-ACT in 10th grade.  Find all students taking this exam in AY2018-2019, see whether they had any RAAL trained teachers in a real course (with a grade) in AY2017-18 or AY2018-19 ***

cls
clear all
capture log close
set more off
pwd

cd "G:\Shared drives\AANP&RAAL\MSAP_RAAL"
log using log/RAAL_StudentDemos.txt, text replace

******************************************************************
use RawData/students_grade9_2017-2020.dta, clear
tab year
tab active_status
drop active_status

tab cur_school_code
*drop if cur_school_code == 1
gen srmhs = (cur_school_code == 562)

tab nextgrade grade_level, missing
tab cur grade_level, missing
tab race_new


duplicates report
duplicates report random_sid year

/**
sort random_sid year
list in 1/5

use ../WorkingData/RAAL_PreACT, clear

sort random_sid year
list in 1/5
***/

merge 1:1 random_sid year using WorkingData/RAAL_PreACT
tab cur_school _merge, missing
tab nextgrade _merge, missing
tab year _merge, missing

gen has_act = (_merge == 3)
drop if _merge == 2 // drop data that only has pre act but no school grade info
drop _merge

save WorkingData/RAAL_sample_v1, replace

*log close
*exit

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

log close
exit

use workingdata/raal_preact, clear
keep if year == 2018
duplicates report random_sid

merge 1:1 random_sid using WorkingData/Courses_2018
