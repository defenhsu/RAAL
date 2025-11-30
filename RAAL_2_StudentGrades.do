*** FILE OF ALL COURSES THAT HAVE GRADES (REAL COURSES) FOR 9TH GRADERS FROM 2017-2019 -- 
***  OK TO HAVE DUPLICATE ENTRIES FOR COURSES, NOT OK TO HAVE FAKE CLASSES ***
*** GRADE FILE IS EASIER TO DETERMINE REAL COURSES FROM OTHER TYPES OF COURSES ****
*** 10.08.2020 MSM -- Trying again ***

cls
clear all
capture log close
set more off
pwd

cd "G:\Shared drives\AANP&RAAL\MSAP_RAAL"
log using log/RAAL_StudentGrades.txt, text replace

**************************
**** AY 2018-19 **********
**************************

use rawdata/history_of_grade_for_high_2020.dta, clear

drop if curr_school == 1
drop if curr_school == .

** ONLY THE FINAL GRADE ***
keep if reporting == "F1"
*sort random_sid course_number course_year section_start
*list if random_sid == 229007

/*** KEEP THE CORRECT COURSE YEAR AY2018-19 ****/
** course year should be 2018 even for spring 2019 classes for some reason...
tab section_startdate
gen temp = substr(section_startdate, 4, 3)
tab temp
gen section_start_month = month(date(temp, "M"))
tab section_start_month
drop temp

gen temp = substr(section_startdate, 8, 2)
destring temp, replace
gen section_start_year = 2000 + temp
drop temp

tab section_start_year course_year

gen section_start_day = substr(section_startdate, 1, 2)
tab section_start_day 
destring section_start_day, replace

gen section_start_fmt = mdy(section_start_month, section_start_day, section_start_year)
format section_start_fmt %td


gen temp = substr(section_enddate, 4, 3)
gen section_end_month = month(date(temp, "M"))
tab section_end_month
drop temp

gen temp = substr(section_enddate, 8, 2)
destring temp, replace
gen section_end_year = 2000+ temp
drop temp

gen section_end_day = substr(section_enddate, 1, 2)
destring section_end_day, replace

tab section_end_year course_year

gen section_end_fmt = mdy(section_end_month, section_end_day, section_end_year)
format section_end_fmt %td

************** main purpose >> only keep data from 18-19 AY
sort section_start_fmt
gen ay2019 = (section_start_fmt >= mdy(7, 1, 2018)) & (section_end_fmt < mdy(7, 1, 2019))
tab course_year ay2019, missing

keep if ay2019 == 1

tab course_grdlvl
keep if course_grdlvl == "9" // finished 9th grade course??

tab curr_grdlvl
keep if curr_grdlvl == 10


**** KEEP ALL COURSES THAT HAVE A VALID GRADE ****
drop if grade == ""
drop if strpos(course_name, "Curriculum Assistance") > 0 // keep if has "Curriculum Assistance" in course name
drop if course_schoolname == "eym" // what does this mean??
keep if enroll_status == 0

tab credit_earned
*tab course_name if credit_earned == 0
*tab grade if credit_earned == 0
list grade in 1/20
*tab grade
*tab reporting
*** STUDENTS 9TH GRADE ENGLISH -- ALL STUDENTS SHOULD HAVE SOME 9TH GRADE ENGLISH CLASS AND A CORRESPONDING GRADE ***
*** COURSE CODE CAN YIELD INSIGHT ON WHAT IS AN ENGLISH / READING COURSE ***
/** COURSE CODE INFORMATION DIFFERS BY YEAR -- RIGHT NOW JUST LOOK AT 2018-19 SCHOOL YEAR ***
The first four digits indicate the course. The first digit of the four digits represents the academic area as follows:
0 = nonspecific subject
1 = English/Language Arts; World Languages; Public Speaking
2 = Mathematics
3 = Science
4 = Social Studies
5 = Arts
6 = Health/PE
9 = Occupational Course of Study; ROTC; Approved Online Vendor Courses; Special Interest Topics; Teacher Cadet; SAT Prep; ACT Prep; Pre-K
Alpha = Career and Technical Education courses
When there is a number in the first digit and a letter in the second of the four digits, the letter indicates a special course type that is different from the NC Standard Course of Study.
C = Community College
U = University or College
A = Advanced Placement (AP)
I = International Baccalaureate (IB)
****/

gen subject = substr(course_number, 1, 1)
tab subject
*** foreign language courses start with 1 too!***

gen sub_eng = strpos(course_name, "English") > 0
gen sub_read = strpos(course_name, "Reading") > 0
gen sub_lang = strpos(course_name, "Lang") > 0
gen sub_lit = strpos(course_name, "Literacy") > 0

gen english = sub_eng + sub_read + sub_lang + sub_lit // equal to the following row
*gen english2 = sub_eng==1 | sub_read==1 | sub_lang==1 | sub_lit==1
tab english

tab course_name english, missing row
count if course_name == ""

duplicates report
duplicates report random* course_* section_number grade, gen(dup)

*** list of teachers, merge on to RAAL teachers, keep the school where trained in case it differs from school where courses taken ****
keep random* course_* grade section_start_fmt section_end_fmt curr_school

save WorkingData/Courses_2019, replace

*** collapse to the student level, have they taken a course with an RAAL trained teacher ***
duplicates report random_sid // see if report same student(?) twice
duplicates report random_sid random_personid // what's the difference between these 2 id?? >> might means how many class you take from the same teacher
gen num_classes = 1

collapse (sum) num_classes, by(random_sid random_personid course_schoolname curr_school) // how many classes student i take from specific teacher in school j

merge m:1 random_personid using WorkingData/RAAL_teachers
drop if _merge == 2 // drop teacher info if not use
gen RAAL_trained = (_merge == 3)
gen RAAL_trained_before = (trained_before == 1)
drop _merge
sum 

collapse (sum) RAAL_trained* num_classes, by(random_sid curr_school)
*collapse (sum) RAAL_trained* num_classes, by(random_sid // same results as above
sum

save WorkingData/Training_x_Student_2019, replace


log close
exit
**************************
**** AY 2017-18 **********
**************************

use "../history_of_grade_for_high_2019.dta", clear
tab course_grdlvl
keep if course_grdlvl == "9"
tab course_year
keep if course_year == 2018
tab curr_grdlvl
keep if curr_grdlvl == 9

**** KEEP ALL COURSES THAT HAVE A VALID GRADE ****
drop if grade == ""
drop if strpos(course_name, "Curriculum Assistance") > 0
keep if reporting == "F1"


tab course_name
count if course_name == ""
tab credit_earned, missing

*** list of teachers, merge on to RAAL teachers, keep the school where trained in case it differs from school where courses taken ****
keep random* course_* grade
duplicates report
duplicates drop

duplicates report random_sid

save ../WorkingData/Courses_2018, replace

use ../workingdata/courses_2018, clear
*** collapse to the student level, have they taken a course with an RAAL trained teacher ***
duplicates report random_sid
duplicates report random_sid random_personid
gen num_classes = 1

collapse (sum) num_classes, by(random_sid random_personid course_schoolname)

*** temporary
keep random_sid course_schoolname
duplicates drop
duplicates report random_sid
gen score = course_schoolname == "SCORE Academy"
drop dup
duplicates tag random_sid score, gen(dup)
tab course_schoolname if dup == 1

/*
merge m:1 random_personid using ../WorkingData/RAAL_teachers
drop if _merge == 2
gen RAAL_trained = (_merge == 3)


collapse (max) RAAL_trained, by(random_sid)

save ../WorkingData/Training_x_Student_2018, replace
sum




use "../history_of_grade_for_high_2018.dta", clear
tab course_grdlvl
keep if course_grdlvl == "9"
tab course_year
keep if course_year == 2017
tab curr_grdlvl
keep if curr_grdlvl == 9

**** KEEP ALL COURSES THAT HAVE A VALID GRADE ****
drop if grade == ""

tab course_name
count if course_name == ""
tab credit_earned, missing

*** list of teachers, merge on to RAAL teachers, keep the school where trained in case it differs from school where courses taken ****
keep random* course_* grade

save ../WorkingData/Courses_2017, replace

