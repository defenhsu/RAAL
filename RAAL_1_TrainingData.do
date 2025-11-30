
*** 10.21.2020 MSM -- new teacher training file ***
*** 10.08.2020 MSM - new teacher training file has no duplicates -- prepare the file for merging onto course information ***
*** saved as RAAL_teachers ****

cls
clear all
capture log close
set more off
pwd

cd "G:\Shared drives\AANP&RAAL\MSAP_RAAL"

capture log close
log using log/trainingdata.txt, text replace

*******************************************************
********* Step 1: teacher training data ***************
*******************************************************

*use rawdata/employees_ratrained_20201021, clear
use rawdata/employees_ratrained_20210910, clear
tab whentrained
replace whentrained = "01may2018" if whentrained ==  "May-18"

gen train_date = date(whentrained, "DMY")
format train_date %td

*tab train_date
*tab school_code
*list in 1/2

gen srmhs = school_code == 562
* check if there's teacher got trainned twice >> No 
duplicates report random_personid
duplicates report random_personid train_date

tab coursecode // Reading Apprenticeship for Secondary Schools
tab coursetitle // Reading Apprenticeship for Secondary Schools
tab session // course session
tab reg_status // attend the training or not?
tab hoursattended // hours this specific teacher has been trained
tab train_date hoursatt // trainning date
* check if all primary school is the same as training school >> yes
rename school_code RAAL_training_school_code
tab primarylocation
gen school_code_primary = substr(primarylocation, 1, 3) // only keep the code (the first 3 letters)
destring school_code_primary, ignore("cen eas nor wes sou") replace // keep only numerical values
gen diff = school_code_primary ~= school_code // gen indicator showing primary school is not the same as training school
tab school_code_primary school_code if diff == 1 // no observations >> all primary school is the same as training school
drop diff

keep random RAAL train_date school_code_primary primarylocation srmhs // random is id


*** distinguish those trained before/after the AY2018-19 ***
gen trained_before = (train_date <= mdy(8, 1, 2018))
tab train_date trained_before, missing

tab train_date srmhs

save WorkingData/RAAL_teachers, replace

*** are the 17 trainees in June 2019 new teachers or Cohort 1? ***
*** does this line up with the demographics file?

*******************************************************
************** teacher demographics data **************
*******************************************************

use RawData/employee_demogs_2019.dta, clear
*SOME SCHOOLS DO NOT HAVE SCHOOL IN THE TITLE!  keep if strpos(organization, "School") > 0 >>keep if has school name in the title
gen school_code_demos = substr(organization, -3 , 3) if organization ~= "" // only keep numerical value
*gen school_code_demos = substr(organization, strlen(organization) - 2, 3) if organization ~= "" // space doesnt count as string

destring school_code, replace

list school_code organization in 1/5
*list if strpos(organization, "/") > 0
gen multischool = (strpos(organization, "/") > 0) // find out which order  / is in this string >> and check if XXX/XXX exist
duplicates report // there's some completely same data
*duplicates tag, gen(dup)
duplicates drop

duplicates tag random_personid organization, gen(dup) 
drop if step == . & dup > 0 // what does step mean? years spend in the school??
duplicates list random_personid organization
drop dup

rename ethnicity teacher_ethnicity
rename sex teacher_sex

duplicates report random_personid
duplicates tag random_personid, gen(teacher_num_schools) // here is simply number of duplicates not number of schools
tab teacher_num_schools
replace teacher_num_schools = teacher_num_schools+1

merge m:1 random_personid using workingdata/raal_teachers //we are not going to do something with merge file??
tab school_code_primary if _merge == 2
tab train_date _merge, missing

capture drop diff
gen diff = school_code_demos ~= school_code_primary if _merge == 3
tab diff
*a lot of data mismatch their primary school and trainning school
count if school_code_primary ==. & diff == 1
tab school_code_primary train_date if diff ==1, missing
list *school_code* primary* if diff == 1 & train_date == mdy(12, 1, 2019), abb(30) // why combine with train date?? ==> because a lot of mismatch is in 12/01/2019


log close


exit

*** reshape so we have a dummy for each training date
drop coursecode session reg_status credits hours whentrained

reshape wide train_date reg_type, i(random_personid school_code) j(train_date) 

exit
** KEEP FIRST TRAINING DATE ***
sort random_personid train_date
duplicates tag random_personid, gen(dup)
list random_personid coursecode whentrained school_code reg_type if dup == 1
duplicates drop random_personid, force

tab train_date srmhs, row

codebook school_code∂
replace school_code = 920000 + school_code

save ../WorkingData/RAAL_teachers, replace
duplicates report random_personid school_code
