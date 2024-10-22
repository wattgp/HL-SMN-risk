****** Figuren met achtergrond incidentie (met dood als competing risk)


*** 5-jaar survivors	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event1_skin=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)

gen all=1

capture drop age
capture drop incjr
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(exit-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cancer_inc_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end p_star cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort fup
save "F:\Attained_age\population expected cancer incidence.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

gen all=1

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)
capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(exit-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cause_mortality_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort fup
save "F:\Attained_age\population expected survival.dta", replace

use "F:\Attained_age\population expected cancer incidence.dta", clear
merge fup using "F:\Attained_age\population expected survival.dta"
save "F:\Attained_age\bereken cumulatieve incidentie.dta", replace

use "F:\Attained_age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
gen event=(1-p_star)*expected_overall_survival
local a=0
local b=fupmax
while `a'<=`b' {
  capture assert fup[_`a']>=`a'
  if _rc~=9 {
    gen lagx`a'=event[_n-`a']
    }
	else if _rc==9 {
    local a=`a'	
}
local a=`a'+1	
}

egen exp_cuminc5= rowtotal(event lagx1-lagx`b')
replace exp_cuminc5=exp_cuminc5*100

drop _merge-lagx`b'
save "F:\Attained_age\bereken cumulatieve incidentie all SMN.dta", replace

replace fup=fup+5 if fup~=0
twoway line exp_cuminc5 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any SMN (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort fup
replace fup=5 if fup==0
save "F:\Attained_age\population expected cumulative incidence and cumulative risk 5yr.dta", replace	

*** 15-jaar survivors	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event1_skin=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)

gen all=1

capture drop age
capture drop incjr
gen age=((entry+(15*365.25))-birthdat)/365.25
gen incjr=year(entry+(15*365.25))
gen fup2=(exit-(entry+(15*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cancer_inc_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end p_star cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort fup
save "F:\Attained_age\population expected cancer incidence.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

gen all=1

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)
capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(15*365.25))-birthdat)/365.25
gen incjr=year(entry+(15*365.25))
gen fup2=(exit-(entry+(15*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cause_mortality_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort fup
save "F:\Attained_age\population expected survival.dta", replace

use "F:\Attained_age\population expected cancer incidence.dta", clear
merge fup using "F:\Attained_age\population expected survival.dta"
save "F:\Attained_age\bereken cumulatieve incidentie.dta", replace

use "F:\Attained_age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
gen event=(1-p_star)*expected_overall_survival
local a=0
local b=fupmax
while `a'<=`b' {
  capture assert fup[_`a']>=`a'
  if _rc~=9 {
    gen lagx`a'=event[_n-`a']
    }
	else if _rc==9 {
    local a=`a'	
}
local a=`a'+1	
}

egen exp_cuminc15= rowtotal(event lagx1-lagx`b')
replace exp_cuminc15=exp_cuminc15*100

drop _merge-lagx`b'
save "F:\Attained_age\bereken cumulatieve incidentie all SMN.dta", replace

replace fup=fup+15 if fup~=0
twoway line exp_cuminc15 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any SMN (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort fup
replace fup=15 if fup==0
save "F:\Attained_age\population expected cumulative incidence and cumulative risk 15yr.dta", replace	


*** 25-jaar survivors	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event1_skin=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)

gen all=1

capture drop age
capture drop incjr
gen age=((entry+(25*365.25))-birthdat)/365.25
gen incjr=year(entry+(25*365.25))
gen fup2=(exit-(entry+(25*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cancer_inc_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end p_star cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort fup
save "F:\Attained_age\population expected cancer incidence.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

gen all=1

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)
capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(25*365.25))-birthdat)/365.25
gen incjr=year(entry+(25*365.25))
gen fup2=(exit-(entry+(25*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cause_mortality_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort fup
save "F:\Attained_age\population expected survival.dta", replace

use "F:\Attained_age\population expected cancer incidence.dta", clear
merge fup using "F:\Attained_age\population expected survival.dta"
save "F:\Attained_age\bereken cumulatieve incidentie.dta", replace

use "F:\Attained_age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
gen event=(1-p_star)*expected_overall_survival
local a=0
local b=fupmax
while `a'<=`b' {
  capture assert fup[_`a']>=`a'
  if _rc~=9 {
    gen lagx`a'=event[_n-`a']
    }
	else if _rc==9 {
    local a=`a'	
}
local a=`a'+1	
}

egen exp_cuminc25= rowtotal(event lagx1-lagx`b')
replace exp_cuminc25=exp_cuminc25*100

drop _merge-lagx`b'
save "F:\Attained_age\bereken cumulatieve incidentie all SMN.dta", replace

replace fup=fup+25 if fup~=0
twoway line exp_cuminc25 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any SMN (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort fup
replace fup=25 if fup==0
save "F:\Attained_age\population expected cumulative incidence and cumulative risk 25yr.dta", replace	



*** 35-jaar survivors	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event1_skin=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)

gen all=1

capture drop age
capture drop incjr
gen age=((entry+(35*365.25))-birthdat)/365.25
gen incjr=year(entry+(35*365.25))
gen fup2=(exit-(entry+(35*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cancer_inc_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end p_star cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort fup
save "F:\Attained_age\population expected cancer incidence.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

gen all=1

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)
capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(35*365.25))-birthdat)/365.25
gen incjr=year(entry+(35*365.25))
gen fup2=(exit-(entry+(35*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "F:\Attained_age\all_cause_mortality_1965_2014", br(0(1)45) mergeby(_year sex _age) by(all) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) savgroup(F:\Attained_age\grouped, replace)
use F:\Attained_age\grouped, clear

keep all end cp_e2
set obs 162
replace all = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
sort end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort fup
save "F:\Attained_age\population expected survival.dta", replace

use "F:\Attained_age\population expected cancer incidence.dta", clear
merge fup using "F:\Attained_age\population expected survival.dta"
save "F:\Attained_age\bereken cumulatieve incidentie.dta", replace

use "F:\Attained_age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
gen event=(1-p_star)*expected_overall_survival
local a=0
local b=fupmax
while `a'<=`b' {
  capture assert fup[_`a']>=`a'
  if _rc~=9 {
    gen lagx`a'=event[_n-`a']
    }
	else if _rc==9 {
    local a=`a'	
}
local a=`a'+1	
}

egen exp_cuminc35= rowtotal(event lagx1-lagx`b')
replace exp_cuminc35=exp_cuminc35*100

drop _merge-lagx`b'
save "F:\Attained_age\bereken cumulatieve incidentie all SMN.dta", replace

replace fup=fup+35 if fup~=0
twoway line exp_cuminc35 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any SMN (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort fup
replace fup=35 if fup==0
save "F:\Attained_age\population expected cumulative incidence and cumulative risk 35yr.dta", replace	



use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

replace exit=.
replace exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
tab vstat if event1_skin~=.
tab vstat if event1_skin==.

replace event1_dat=event1_skin_dat if codenr==9510895
replace event1_is_dat=event1_skin_dat if codenr==9510895

replace event=. if codenr==20801149	

tab sex
capture drop cause
gen cause=0
replace cause=1 if event1_skin~=.
replace cause=2 if (cause==0&vstat_end==2)
tab cause

capture drop id
gen id=_n
stset fup,fail(cause=1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi , compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

list fup CI if cause==1

label var fup "Follow-up time in years"

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of any SMN (%)" " ") legend(off) scheme(s1manual)

append using "F:\Attained_age\population expected cumulative incidence and cumulative risk.dta"
twoway line CI exp_cuminc fup if cause==1, sort xla(0(5)45) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	 lpattern(solid dash) connect(stairstep line) lcolor(gs0 gs0) yti("Cumulative incidence of any SMN (%)" " ") legend(ring(0) pos(11) col(1) order(1 2 3) label(1 "1965-1976") label(2 "1977-1988") label(3 "1989-2000"))  ///
     scheme(s1manual)
sort fup	  
list fup CI exp_cuminc if cause==1	  
