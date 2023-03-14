**** EXPLORE ALL BASELINE VARIABLES ****

foreach demog in eth employ edu apps expect {
	tab `demog'
	tab `demog' group, col chi
	}

summ age	
summ spintot_0
	
sort pid
sort group
by group: summ age
by group: summ spintot_0
by group: summ wsastot_0
by group: summ phqtot_0


**** CHECK SAFETY AND ATTRITION ****

*attrition
gen attrition_w4=1 if spintot_w4==.
replace attrition_w4=0 if spintot_w4!=.
tab attrition_w4
tab attrition_w4 group, col chi

gen attrition_w6=1 if spintot_w6==.
replace attrition_w6=0 if spintot_w6!=.
tab attrition_w6
tab attrition_w6 group, col chi

*adverse events
tab advall_w1 group, col chi
tab advall_w2 group, col chi
tab advall_w3 group, col chi
tab advall_w4 group, m col chi

tab advany
tab advany group, col chi

egen advn=rowtotal(advall_w1 advall_w2 advall_w3 advall_w4 advall_w6)
tab advn
tab advn group, col chi

tab1 advsev_w*
tab1 advqual_w*

br advqual_w1 if !missing(advqual_w1)
br advqual_w2 if !missing(advqual_w2)
br advqual_w3 if !missing(advqual_w3)
br advqual_w4 if !missing(advqual_w4)
br advqual_w6 if !missing(advqual_w6)

br advall_qual_w1 group if !missing(advall_qual_w1)
br advall_qual_w2 group if !missing(advall_qual_w2)
br advall_qual_w3 group if !missing(advall_qual_w3)
br advall_qual_w4 group if !missing(advall_qual_w4)

**** ANALYSE MENTAL HEALTH OUTCOMES ****

**SPIN**

*raw data - for graphs etc
drop spintot_auto*

summ spintot*
summ spintot* if group==0
summ spintot* if group==1

tabstat spintot*, stats(mean semean sd median) 
tabstat spintot* if group==0, stats(mean semean sd median) 
tabstat spintot* if group==1, stats(mean semean sd median) 

foreach time in spintot_w1 spintot_w2 spintot_w3 spintot_w4 spintot_w6 {
count if `time'!=. & group==1
count if `time'!=. & group==0
}



*regressions - ITT

foreach time in spintot_w1 spintot_w2 spintot_w3 spintot_w4 spintot_w6 {
	regress c.`time' i.group 
	regress c.`time' i.group c.spintot_0
}
//effect at W4 - v almost sig - p=.054

*regressions - per protocol (full completers only)

tab completed

gen complete2=completed
replace complete2=1 if group==0
tab complete2

foreach time in spintot_w1 spintot_w2 spintot_w3 spintot_w4 {
	regress c.`time' i.group if complete2==1
	regress c.`time' i.group c.spintot_0 if complete2==1
}

tabstat spintot* if group==0 & complete2==1, stats(mean semean sd median) 
tabstat spintot* if group==1 & complete2==1, stats(mean semean sd median) 
//large sig effect at W4

*also for non-completers
tabstat spintot* if group==1 & complete2==0, stats(mean semean sd median) 
gen noncomplete=.
replace noncomplete=1 if complete==0
replace noncomplete=1 if group==0
replace noncomplete=0 if complete==1
tab noncomplete

regress c.spintot_w4 i.group if noncomplete==1
//no effect


*regression adjustments
regress c.spintot_w4 i.group c.spintot_0 i.apps i.edu
regress c.spintot_w4 i.group c.spintot_0 i.apps i.edu if complete2==1

tab apps
tab apps, nolab
gen apps2=apps
recode apps2 (2=1)
label values apps2 yesno
tab apps2

tab edu
tab edu, nolab
gen edu2=edu
recode edu2 (1=0) (2=1) (3=1)
label define edu2 0 "Degree/HE" 1 "A Level/GCSE"
label values edu2 edu2
tab edu2

regress c.spintot_w4 i.group c.spintot_0 i.apps2 i.edu2
regress c.spintot_w4 i.group c.spintot_0 i.apps2 i.edu2 if complete2==1

*regressions - per protocol per week
gen complete_w1=M0M1complete
replace complete_w1=1 if group==0
tab complete_w1

foreach week in 2 3 4 {
	gen complete_w`week'=M`week'complete
	replace complete_w`week'=1 if group==0
	tab complete_w`week'
}

foreach week in 1 2 3 4 {
	regress c.spintot_w`week' i.group if complete_w`week'==1
	regress c.spintot_w`week' i.group c.spintot_0 if complete_w`week'==1
}
//no effect each week - vaguely approaching an effect at W4 but not sig - p =.077

*completers vs non-completers (within intervention group)
foreach week in 1 2 3 4 {
	regress c.spintot_w`week' i.completed
	regress c.spintot_w`week' i.completed c.spintot_0
}
//no effect (v wide confidence intervals)

*outcome by module
regress c.spintot_w4 i.M0M1complete
regress c.spintot_w4 i.M0M1complete c.spintot_0

foreach module in 2 3 4 {
	regress c.spintot_w4 i.M`module'complete
	regress c.spintot_w4 i.M`module'complete c.spintot_0
}

*predictors of final outcome
regress c.spintot_w4 i.helpseek_w4 i.group
regress c.spintot_w4 i.helpseek_w4 i.group c.spintot_0
*not a predictor

regress c.spintot_w4 i.apps i.group
regress c.spintot_w4 i.apps i.group c.spintot_0
*a trend when adj - p=.084 (more benefit for those who have used apps before)

regress c.spintot_w4 i.help_w4 i.group
regress c.spintot_w4 i.help_w4 i.group c.spintot_0
*not a predictor

regress c.spintot_w4 i.satis_w4 
regress c.spintot_w4 i.satis_w4 c.spintot_0
*not a predictor

regress c.spintot_w4 i.recc_w4
regress c.spintot_w4 i.recc_w4 c.spintot_0
*not a predictor

regress c.spintot_w4 i.expect i.group
regress c.spintot_w4 i.expect i.group c.spintot_0
*not a predictor

regress c.spintot_w4 c.audit_0 i.group
regress c.spintot_w4 c.audit_0 i.group c.spintot_0
*not a predictor

regress c.spintot_w4 c.phqtot_0 i.group
regress c.spintot_w4 c.phqtot_0 i.group c.spintot_0
*sig predictor

*helpfulness
gen helpful4=help_w4
recode helpful4(1/3=0) (4=1)
label values helpful4 yesno
tab helpful4

regress c.spintot_w4 i.helpful4 
regress c.spintot_w4 i.helpful4  c.spintot_0
logistic helpful4 c.spintot_w4

tabstat spintot* if helpful4==0, stats(mean semean sd median) 
tabstat spintot* if helpful4==1, stats(mean semean sd median) 

*change from baseline
gen spinchange=(spintot_0-spintot_w4)
replace spinchange=. if missing(spintot_w4)
tab spinchange, m

gen improved=.
replace improved=1 if spinchange>0 & spinchange!=.
replace improved=0 if spinchange<1 & spinchange!=.
tab improved, m
tab improved group, m
tab improved group, col chi
tab improved group if complete2==1, col chi


*MLM
save "/Users/taylamccloud/Dropbox/Alena/merged_long_spin.dta"
rename spintot_0 spintot0
rename spintot_w1 spintot1
rename spintot_w2 spintot2
rename spintot_w3 spintot3
rename spintot_w4 spintot4
reshape long spintot, i(pid) j(time)

mixed spintot i.group c.time || pid:, var cov(unstr)
mixed spintot i.group c.time if complete2==1 || pid:, var cov(unstr)

margins group, at(time=(0 1 2 3 4)) vsquish
marginsplot, graphregion(color(white)) x(time) title("") xtitle("Time Point") ytitle ("SPIN score") legend(order(0 "Waitlist" 1 "Intervention"))


*dose-response - objective (no of weeks they reported getting to the end of module)
tab1 end*
egen end=rowtotal(end_w*)
tab end
rename end end2
gen end=end2
replace end=. if group==0
tab end
tab end2

regress c.spintot_w4 c.end
regress c.spintot_w4 c.end2

//vague trend when waitlist included - p=.098

*dose-response - subjective (no of modules completed)
egen ncomplete=rowtotal(M0M1complete M2complete M3complete M4complete)
tab ncomplete
replace ncomplete=. if group==0
tab ncomplete

regress spintot_w4 c.ncomplete
regress spintot_w4 c.ncomplete c.spintot_0
//no sig effect

tabstat spintot_w4 if ncomplete==0, stats(mean semean) 
tabstat spintot_w4 if ncomplete==1, stats(mean semean) 
tabstat spintot_w4 if ncomplete==2, stats(mean semean) 
tabstat spintot_w4 if ncomplete==3, stats(mean semean) 
tabstat spintot_w4 if ncomplete==4, stats(mean semean) 


*reverse causation
logistic completed c.spintot_0
regress ncomplete c.spintot_0
regress end c.spintot_0

*subgroups by baseline SPIN score
summ spintot_0
tabstat spintot_0, stats(mean semean sd median) 
count if spintot_0>40
*58
count if spintot_0>40 & group==0
*29
count if spintot_0>40 & group==1
*29
gen spinhighlow=spintot_0
replace spinhighlow=0 if spinhighlow<41
replace spinhighlow=1 if spinhighlow>40
tab spinhighlow

regress c.spintot_w4 i.spinhighlow i.group
regress c.spintot_w4 i.spinhighlow if group==1

tabstat spintot* if group==1 & spinhighlow==1, stats(mean semean sd median) 
tabstat spintot* if group==1 & spinhighlow==0, stats(mean semean sd median) 

tab completed spinhighlow, col chi

regress c.spindiff4 i.spinhighlow if group==1
regress c.spindiff4 c.spintot_0 if group==1


**WSAS**

*raw data - for graphs etc
summ wsastot*
summ wsastot* if group==0
summ wsastot* if group==1


tabstat wsastot*, stats(mean semean sd median) 
tabstat wsastot* if group==0, stats(mean semean sd median) 
tabstat wsastot* if group==1, stats(mean semean sd median) 

*regressions - ITT

foreach time in wsastot_w1 wsastot_w2 wsastot_w3 wsastot_w4 {
	regress c.`time' i.group 
	regress c.`time' i.group c.wsastot_0
}
//good, sig effect at W4, slight trend at W3

*regressions - per protocol (full completers only)

tab completed
tab complete2

foreach time in wsastot_w1 wsastot_w2 wsastot_w3 wsastot_w4 {
	regress c.`time' i.group if complete2==1
	regress c.`time' i.group c.wsastot_0 if complete2==1
}

tabstat wsastot* if group==0 & complete2==1, stats(mean semean sd median) 
tabstat wsastot* if group==1 & complete2==1, stats(mean semean sd median) 
tabstat wsastot* if group==1 & complete2==0, stats(mean semean sd median) 


//trend at W4 with good effect size

*regressions - per protocol per week
gen complete_w1=M0M1complete
replace complete_w1=1 if group==0
tab complete_w1

foreach week in 2 3 4 {
	gen complete_w`week'=M`week'complete
	replace complete_w`week'=1 if group==0
	tab complete_w`week'
}

foreach week in 1 2 3 4 {
	regress c.spintot_w`week' i.group if complete_w`week'==1
	regress c.spintot_w`week' i.group c.spintot_0 if complete_w`week'==1
}
//no effect each week - vaguely approaching an effect at W4 but not sig - p =.077

*completers vs non-completers (within intervention group)
foreach week in 1 2 3 4 {
	regress c.spintot_w`week' i.completed
	regress c.spintot_w`week' i.completed c.spintot_0
}
//no effect (v wide confidence intervals)


*MLM
save "/Users/taylamccloud/Dropbox/Alena/merged_long_wsas.dta"
rename wsastot_0 wsastot0
rename wsastot_w1 wsastot1
rename wsastot_w2 wsastot2
rename wsastot_w3 wsastot3
rename wsastot_w4 wsastot4

reshape long wsastot, i(pid) j(time)

mixed wsastot i.group c.time || pid:, var cov(unstr)

***PHQ***

*raw data - for graphs etc
summ phqtot*
summ phqtot* if group==0
summ phqtot* if group==1


tabstat phqtot*, stats(mean semean sd median) 
tabstat phqtot* if group==0, stats(mean semean sd median) 
tabstat phqtot* if group==1, stats(mean semean sd median) 

*regressions - ITT

foreach time in phqtot_w1 phqtot_w2 phqtot_w3 phqtot_w4 {
	regress c.`time' i.group 
	regress c.`time' i.group c.phqtot_0
}
//slight trend at W4 - p =.073

*regressions - per protocol (full completers only)

tab completed
tab complete2

foreach time in phqtot_w1 phqtot_w2 phqtot_w3 phqtot_w4 {
	regress c.`time' i.group if complete2==1
	regress c.`time' i.group c.phqtot_0 if complete2==1
}

tabstat phqtot* if group==0 & complete2==1, stats(mean semean sd median) 
tabstat phqtot* if group==1 & complete2==1, stats(mean semean sd median) 
tabstat phqtot* if group==1 & complete2==0, stats(mean semean sd median) 

//followup
regress c.spintot_w6 i.group 
regress c.spintot_w6 i.group c.spintot_0

regress c.spintot_w6 i.group if complete2==1
regress c.spintot_w6 i.group c.spintot_0 if complete2==1

*completers vs non-completers
regress c.spintot_w6 i.completed c.spintot_0

***** EFFECT SIZES ******

**ITT
regress c.spintot_w4 i.group c.spintot_0
estat esize 
estat esize, omega 
estat esize, epsilon

*eta-squared: 0.213
*omega-squared: 0.194
*epsilon-squared: 0.196

ssc install esizereg
regress c.spintot_w4 i.group c.spintot_0, coeflegend

regress c.spintot_w4 i.group c.spintot_0 
esizereg 1.group
*Cohen's d: 0.4

beta: -4.816207
SE: 2.466952
N: 95

SD = sqrt(n)*SE
SD = sqrt(95)*2.466952 = 24.0448738025

d = -4.816207/24.0448738025 = -0.2
*Cohen's d: 0.2?

**completers only
regress c.spintot_w4 i.group c.spintot_0 if complete2==1
estat esize 

*eta-squared: 0.332
*omega-squared: 0.307
*epsilon-squared: 0.310

regress c.spintot_w4 i.group c.spintot_0 if complete2==1
esizereg 1.group
*Cohen's d: 0.7

beta: -8.901312
SE: 3.061534 
N: 65

SD = sqrt(n)*SE
SD = sqrt(65)*3.061534 = 24.6828762132

d = -8.901312/24.6828762132 = -0.4
*Cohen's d: 0.4?

***** M3E1(2) ******

*motivation var
tab howmotivatedareyoutotrydro
gen motivation=.
replace motivation=0 if howmotivatedareyoutotrydro=="not at all motivated"
replace motivation=1 if howmotivatedareyoutotrydro=="slightly motivated"
replace motivation=2 if howmotivatedareyoutotrydro=="somewhat motivated"
replace motivation=3 if howmotivatedareyoutotrydro=="very motivated"
replace motivation=4 if howmotivatedareyoutotrydro=="extremely motivated"
tab motivation

*merge in spin score
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/merged.dta", keepusing(spintot*)

drop if _m==2
drop spintot_auto*
count
*35
rename _m merge1

*merge in other bits
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/MASTER.dta", keepusing(spinchange completed complete2 complete_*)
drop if _m==2
count
*35
rename _m merge2

tab completed
sort spinchange
br
br motivation spinchange

gen spinchangebin=.
replace spinchangebin=0 if spinchange<10 & !missing(spinchange)
replace spinchangebin=1 if spinchange>9 & !missing(spinchange)
tab spinchangebin
tab motivation spinchangebin, col chi
tab motivation completed, col chi

ttest motivation, by(completed)

pwcorr spinchange motivation, sig

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M3E3 usage.dta", keepusing(didyoumanagetoattempttheex)

tab didyoumanagetoattempttheex motivation
scatter didyoumanagetoattempttheex motivation

sort didyoumanagetoattempttheex spinchange

***** DICHOTOMOUS OUTCOMES *****

//at week 4 - endpoint

*spin improved at all
gen spinchangebin=.
replace spinchangebin=1 if spinchange>0 & spinchange!=.
replace spinchangebin=0 if spinchange<1 & spinchange!=.
tab spinchangebin
tab spinchangebin group, col chi
*71.4% vs 56.5% (35 vs 26) - p=.130

*reliable change - reduction of 10
gen rci=.
replace rci=1 if spinchange>9 & spinchange!=.
replace rci=0 if spinchange<10 & spinchange!=.
tab rci, m
br spinchange spintot* if rci==.
tab rci
tab rci group, col chi
*49.0% vs 21.7% (24 vs 10) - p=.006

*below threshold - below 31
gen threshold=.
replace threshold=1 if spintot_w4<31 & spintot_w4!=.
replace threshold=0 if spintot_w4>30 & spintot_w4!=.
tab threshold, m
tab threshold
tab threshold group, col chi
*36.7% vs 23.9% (18 vs 11) - p =.175

*50% reduction - response
gen response_calc=spintot_0/2
tab response_calc
gen response=.
replace response=1 if spintot_w4==response_calc | spintot_w4<response_calc
replace response=0 if spintot_w4!=. & response==.
tab response
tab response group, col chi
*14.3% vs 6.5% (7 vs 3) - p=.218

*remission - below 19
gen remiss=.
replace remiss=1 if spintot_w4<19 & spintot_w4!=.
replace remiss=0 if spintot_w4>18 & spintot_w4!=.
tab remiss 
tab remiss group, col chi
*12.2% vs 6.5% (6 vs 3) - p=.341

*above for completers vs non-completers
tab spinchangebin completed, col chi
*89.5% vs 60% (17 vs 18) - p=.026

tab rci completed, col chi
*73.7% vs 33.3% (14 vs 10), p=.006

tab threshold completed, col chi
*47.4% vs 30% (9 vs 9), p=.219

tab response completed, col chi
*15.8% vs 13.3% (3 vs 4), p=.811

tab remiss completed, col chi
*10.5% vs 13.3% (2 vs 4), p=.770

*above for completers vs waitlist
tab spinchangebin group if complete2==1, col chi
*p =.011

tab rci group if complete2==1, col chi
*p<.001

tab threshold group if complete2==1, col chi
*p=.062

tab response group if complete2==1, col chi
*p=.240

tab remiss group if complete2==1, col chi
*p=.582

//at week 6 - follow-up

*spinchange
gen spinchange6=(spintot_0-spintot_w6)
replace spinchange6=. if missing(spintot_w6)
tab spinchange6, m

*spin improved at all
gen spinchangebin6=.
replace spinchangebin6=1 if spinchange6>0 & spinchange6!=.
replace spinchangebin6=0 if spinchange6<1 & spinchange6!=.
tab spinchangebin6
tab spinchangebin6 group, col chi
*67.4% vs 70.5% (31 vs 31) - p=.754

*reliable change - reduction of 10
gen rci6=.
replace rci6=1 if spinchange6>9 & spinchange6!=.
replace rci6=0 if spinchange6<10 & spinchange6!=.
tab rci6, m
tab rci6
tab rci6 group, col chi
*45.7% vs 34.1% (21 vs 15) - p=.263

*below threshold - below 31
gen threshold6=.
replace threshold6=1 if spintot_w6<31 & spintot_w6!=.
replace threshold6=0 if spintot_w6>30 & spintot_w6!=.
tab threshold6, m
tab threshold6
tab threshold6 group, col chi
*34.8% vs 36.4% (16 vs 16) - p =.876

*50% reduction - response
gen response6=.
replace response6=1 if spintot_w6==response_calc | spintot_w6<response_calc
replace response6=0 if spintot_w6!=. & response6==.
tab response6
tab response6 group, col chi
*21.8% vs 6.8% (10 vs 3) - p=.044

*remission - below 19
gen remiss6=.
replace remiss6=1 if spintot_w6<19 & spintot_w6!=.
replace remiss6=0 if spintot_w6>18 & spintot_w6!=.
tab remiss6 
tab remiss6 group, col chi
*10.9% vs 9.1% (5 vs 4) - p=.779

*above for completers vs non-completers
tab spinchangebin6 completed, col chi
*89.5% vs 52% (17 vs 14) - p=.007

tab rci6 completed, col chi
*73.7% vs 25.9% (14 vs 7), p=.001

tab threshold6 completed, col chi
*52.6% vs 22.2% (10 vs 6), p=.033

tab response6 completed, col chi
*26.3% vs 18.5% (5 vs 5), p=.528

tab remiss6 completed, col chi
*15.8% vs 7.4% (3 vs 2), p=.368

*above for completers vs waitlist
tab spinchangebin6 group if complete2==1, col chi
*p =.104

tab rci6 group if complete2==1, col chi
*p=.004

tab threshold6 group if complete2==1, col chi
*p=.229

tab response6 group if complete2==1, col chi
*p=.033

tab remiss6 group if complete2==1, col chi
*p=.437

**spindiff
*spindiff is the same as spinchange but a - indicates spin score has decreased and + indicates an increase
gen spindiff1=(spintot_w1-spintot_0)
replace spindiff1=. if missing(spintot_w1)
tab spindiff1, m

gen spindiff2=(spintot_w2-spintot_0)
replace spindiff2=. if missing(spintot_w2)
tab spindiff2, m

gen spindiff3=(spintot_w3-spintot_0)
replace spindiff3=. if missing(spintot_w3)
tab spindiff3, m

gen spindiff4=(spintot_w4-spintot_0)
replace spindiff4=. if missing(spintot_w4)
tab spindiff4, m

gen spindiff6=(spintot_w6-spintot_0)
replace spindiff6=. if missing(spintot_w6)
tab spindiff6, m

tabstat spindiff* if group==1, stats(mean semean sd median n) 
tabstat spindiff* if group==0, stats(mean semean sd median n) 
tabstat spindiff* if completed==1, stats(mean semean sd median n) 
tabstat spindiff* if completed==0, stats(mean semean sd median n) 

regress spindiff4 group 
regress spindiff4 group spintot_0

regress spindiff6 group 
regress spindiff6 group spintot_0

regress spindiff4 completed 
regress spindiff4 completed spintot_0

regress spindiff6 completed 
regress spindiff6 completed spintot_0

regress spindiff4 group if complete2==1
regress spindiff4 group spintot_0 if complete2==1

regress spindiff6 group if complete2==1
regress spindiff6 group spintot_0 if complete2==1


***DURATION***
drop _m

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m0e1 duration.dta", keepusing(durationsec)
rename durationsec duration_m0e1
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m0e2 duration.dta", keepusing(durationsec)
rename durationsec duration_m0e2
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m1e1 duration.dta", keepusing(durationsec)
rename durationsec duration_m1e1
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m1e2 duration.dta", keepusing(durationsec)
rename durationsec duration_m1e2
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m2e1 duration.dta", keepusing(durationsec)
rename durationsec duration_m2e1
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m2e2 duration.dta", keepusing(durationsec)
rename durationsec duration_m2e2
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m3e1 duration.dta", keepusing(durationsec)
rename durationsec duration_m3e1
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m3e2 duration.dta", keepusing(durationsec)
rename durationsec duration_m3e2
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m3e3 duration.dta", keepusing(durationsec)
rename durationsec duration_m3e3
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m4e1 duration.dta", keepusing(durationsec)
rename durationsec duration_m4e1
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/m4e2 duration.dta", keepusing(durationsec)
rename durationsec duration_m4e2
drop _m
drop if group==.


egen durationtot=rowtotal(duration_m*)
tab durationtot
replace durationtot=. if group==0

pwcorr spinchange durationtot

regress spinchange durationtot
regress spinchange durationtot spintot_0
regress spintot_w4 durationtot 
regress spintot_w4 durationtot spintot_0
regress spintot_w4 durationtot if complete2==1
regress spintot_w4 durationtot spintot_0 if complete2==1

tabstat durationtot, stats(n mean sd median)
tabstat durationtot if completed==1, stats(n mean sd median) 
