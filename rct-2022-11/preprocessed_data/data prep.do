**** IMPORT BASELINE DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/baseline questionnaire.xlsx", sheet("tidy version") firstrow

save "/Users/taylamccloud/Dropbox/Alena/baseline.dta"

**** PREPARE ALL BASELINE VARIABLES ****
br
des

gen group=.
replace group=1 if Group=="Intervention"
replace group=0 if Group=="Waitlist"
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group
tab group, nolab
drop Group

destring(Howoldareyou), replace
egen age= Howoldareyou
tab age
rename Howoldareyou age
tab age
summ age

tab Whatisyourethnicgroup
gen eth=.
replace eth=0 if Whatisyourethnicgroup=="White/White British"
replace eth=1 if Whatisyourethnicgroup=="Mixed/Multiple ethnic groups"
replace eth=2 if Whatisyourethnicgroup=="Black/Black British"
replace eth=3 if Whatisyourethnicgroup=="Asian/Asian British"
label define eth 0 "White/White British" 1 "Mixed/Multiple ethnic groups" 2 "Black/Black British" 3 "Asian/Asian British"
label values eth eth
tab eth
rename Whatisyourethnicgroup eth_original

tab Whatisyouremploymentstatus
rename Whatisyouremploymentstatus employ_original
gen employ=.
replace employ=0 if employ_original=="Working full-time"
replace employ=1 if employ_original=="Working part-time" 
replace employ=2 if employ_original=="Student"
replace employ=3 if employ_original=="Unemployed"
replace employ=4 if employ_original=="Unable to work due to disability or any other reason"
replace employ=5 if employ_original=="Temporarily away from work due to illness, maternity leave, or another reason"
label define employ 0 "FT" 1 "PT" 2 "Student" 3 "Unemployed" 4 "Unable to work" 5 "Temp leave"
label values employ employ
tab employ

tab Whatisthehighestlevelofe
rename Whatisthehighestlevelofe edu_original
gen edu=.
replace edu=0 if edu_original=="Degree or equivalent"
replace edu=1 if edu_original=="Apprenticeship, higher education diploma or equivalent"
replace edu=2 if edu_original=="A Level or equivalent"
replace edu=3 if edu_original=="GCSE or equivalent"
label define edu 0 "Degree" 1 "HE" 2 "A Level" 3 "GCSE"
label values edu edu
tab edu 

tab Haveyoueverusedanymentalhe
rename Haveyoueverusedanymentalhe apps_original
gen apps=.
replace apps=0 if apps_original=="No"
replace apps=1 if apps_original=="Yes"
replace apps=2 if apps_original=="I don't know"
label define apps 0 "No" 1 "Yes" 2 "I don't know"
label values apps apps
tab apps

tab Haveyoueverhadanytherapyfo
rename Haveyoueverhadanytherapyfo thpy_original
gen thpy=.
replace thpy=0 if thpy_original=="No"
replace thpy=1 if thpy_original=="Yes"
replace thpy=2 if thpy_original=="I don't know"
label define thpy 0 "No" 1 "Yes" 2 "I don't know"
label values thpy thpy
tab thpy

tab Howsuccessfuldoyouexpectthe
rename Howsuccessfuldoyouexpectthe expect_original
gen expect=.
replace expect=0 if expect_original=="Quite unsuccessful"
replace expect=1 if expect_original=="Neither successful nor unsuccessful"
replace expect=2 if expect_original=="Quite successful"
label define expect 0 "Quite unsuccessful" 1 "Neither successful nor unsuccessful" 2 "Quite successful"
label values expect expect
tab expect

*wsas
tab Becauseofmysocialanxietymy
rename Becauseofmysocialanxietymy wsas1
summ wsas1

tab K
rename K wsas2
summ wsas2

tab L
rename L wsas3
summ wsas3

tab M 
rename M wsas4
summ wsas4

tab N
rename N wsas5
summ wsas5

destring WSAStotal, replace
rename WSAStotal wsastot

*phq
tab Pleaseindicatehowoftenyouha
rename Pleaseindicatehowoftenyouha phq1
summ phq1

tab P
rename P phq2
summ phq2

tab Q
rename Q phq3
summ phq3

tab R
rename R phq4
summ phq4

tab S
rename S phq5
summ phq5

tab T
rename T phq6
summ phq6

tab U
rename U phq7
summ phq7

tab V
rename V phq8
summ phq8

tab W
rename W phq9
summ phq9

destring PHQtotal, replace
rename PHQtotal phqtot

drop Z AA AB

rename wsas* wsas*_0
rename phq* phq*_0

save "/Users/taylamccloud/Dropbox/Alena/baseline.dta"

**** IMPORT SCREENING DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/screening study_main.xlsx", sheet("raw data") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/screening.dta"

**** PREPARE ALL SCREENING VARIABLES ****
br
des

drop a

*check consent
count if missing(iconfirmthatiamover18year)
count if missing(myenglishlanguageskillsareg)
count if missing(ihavereadtheparticipantinfo)
count if missing(ihavebeengiventheopportunit)
count if missing(iunderstandthatmyresponsesw)
count if missing(iunderstandthatiamfreetow)
count if missing(igivemyconsenttoparticipate)
*all fully consented
drop iconfirmthatiamover18year-igivemyconsenttoparticipate

tab doyouhavedailyaccesstoana
rename doyouhavedailyaccesstoana iphone_original
gen iphone=.
replace iphone=0 if iphone_original=="No"
replace iphone=1 if iphone_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values iphone yesno
tab iphone

tab doyouhavedailyaccesstoani
rename doyouhavedailyaccesstoani internet_original
gen internet=.
replace internet=0 if internet_original=="No"
replace internet=1 if internet_original=="Yes"
label values internet yesno
tab internet

tab areyoucurrentlytakinganymed
rename areyoucurrentlytakinganymed meds_original
gen meds=.
replace meds=0 if meds_original=="No"
replace meds=1 if meds_original=="Yes"
label values meds yesno
tab meds

tab haveyouchangedyourusualment
rename haveyouchangedyourusualment medchange_original
gen medchange=.
replace medchange=0 if medchange_original=="No"
replace medchange=1 if medchange_original=="Yes"
label values medchange yesno
tab medchange

tab areyoucurrentlyundergoingany
rename areyoucurrentlyundergoingany therapy_original
gen therapy=.
replace therapy=0 if therapy_original=="No"
replace therapy=1 if therapy_original=="Yes"
label values therapy yesno
tab therapy

tab howoftendoyouhaveadrinkco
rename howoftendoyouhaveadrinkco audit1_original
gen audit1=.
replace audit1=0 if audit1_original=="Never"
replace audit1=1 if audit1_original=="Monthly or less"
replace audit1=2 if audit1_original=="2-4 times per month"
replace audit1=3 if audit1_original=="2-3 times per week"
replace audit1=4 if audit1_original=="4 or more times a week"
label define audit1 0 "Never" 1 "Monthly or less" 2 "2-4 times per month" 3 "2-3 times per week" 4 "4 or more times a week"
label values audit1 audit1
tab audit1

tab howmanystandarddrinkscontain
rename howmanystandarddrinkscontain audit2_original
gen audit2=.
replace audit2=0 if audit2_original=="0 to 2"
replace audit2=1 if audit2_original=="3 to 4"
replace audit2=2 if audit2_original=="5 to 6"
replace audit2=3 if audit2_original=="7 to 9"
label define audit2 0 "0 to 2" 1 "3 to 4" 2 "5 to 6" 3 "7 to 9"
label values audit2 audit2
tab audit2

tab howoftenhaveyouhad6ormore
rename howoftenhaveyouhad6ormore audit3_original
gen audit3=.
replace audit3=0 if audit3_original=="Never"
replace audit3=1 if audit3_original=="Less than monthly"
replace audit3=2 if audit3_original=="Monthly"
replace audit3=3 if audit3_original=="Weekly"
replace audit3=4 if audit3_original=="Daily or almost daily"
label define audit3 0 "Never" 1 "Less than monthly" 2 "Monthly" 3 "Weekly" 4 "Daily or almost daily"
label values audit3 audit3
tab audit3

rename substance audit_auto
egen audit=rowtotal(audit1-audit3)
tab audit
pwcorr audit_auto audit

tab haveyouusedanyrecreationald
rename haveyouusedanyrecreationald drugs1_original
gen drugs1=.
replace drugs1=0 if drugs1_original=="No"
replace drugs1=1 if drugs1_original=="Yes"
label values drugs1 yesno
tab drugs1

tab inthelastthreemonthshavey
rename inthelastthreemonthshavey drugs2_original
gen drugs2=.
replace drugs2=0 if drugs2_original=="No"
replace drugs2=1 if drugs2_original=="Yes"
label values drugs2 yesno
tab drugs2

tab inthelastthreemonthshasan
rename inthelastthreemonthshasan drugs3_original
gen drugs3=.
replace drugs3=0 if drugs3_original=="No"
replace drugs3=1 if drugs3_original=="Yes"
label values drugs3 yesno
tab drugs3

gen drugs=.
replace drugs=1 if (drugs2==1 | drugs3==1)
replace drugs=0 if (drugs2==0 & drugs3==0)
replace drugs=0 if drugs==.
tab drugs

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
tab iambotheredbyblushinginfro
rename iambotheredbyblushinginfro spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

drop tags networkid

tab exclusions screening
drop exclusions screening

gen eligible=.
replace eligible=0 if spintot<31
replace eligible=0 if audit>7
replace eligible=0 if drugs==1
replace eligible=0 if medchange==1
replace eligible=0 if therapy==1
replace eligible=0 if internet==0
replace eligible=0 if iphone==0
replace eligible=1 if eligible==.
tab eligible

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
br pid dup startdateutc submitdateutc if dup>0
*take the first submission
drop if dup==1

rename * *_0
rename pid_0 pid


**** IMPORT EXTRA SCREENING DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/screening study_main.xlsx", sheet("raw_extra") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/screening_extra.dta"

**** PREPARE ALL EXTRA SCREENING VARIABLES ****
br
des

drop a

*check consent
count if missing(iconfirmthatiamover18year)
count if missing(myenglishlanguageskillsareg)
count if missing(ihavereadtheparticipantinfo)
count if missing(ihavebeengiventheopportunit)
count if missing(iunderstandthatmyresponsesw)
count if missing(iunderstandthatiamfreetow)
count if missing(igivemyconsenttoparticipate)
*all fully consented
drop iconfirmthatiamover18year-igivemyconsenttoparticipate

tab doyouhavedailyaccesstoana
rename doyouhavedailyaccesstoana iphone_original
gen iphone=.
replace iphone=0 if iphone_original=="No"
replace iphone=1 if iphone_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values iphone yesno
tab iphone

tab doyouhavedailyaccesstoani
rename doyouhavedailyaccesstoani internet_original
gen internet=.
replace internet=0 if internet_original=="No"
replace internet=1 if internet_original=="Yes"
label values internet yesno
tab internet

tab areyoucurrentlytakinganymed
rename areyoucurrentlytakinganymed meds_original
gen meds=.
replace meds=0 if meds_original=="No"
replace meds=1 if meds_original=="Yes"
label values meds yesno
tab meds

tab haveyouchangedyourusualment
rename haveyouchangedyourusualment medchange_original
gen medchange=.
replace medchange=0 if medchange_original=="No"
replace medchange=1 if medchange_original=="Yes"
label values medchange yesno
tab medchange

tab areyoucurrentlyundergoingany
rename areyoucurrentlyundergoingany therapy_original
gen therapy=.
replace therapy=0 if therapy_original=="No"
replace therapy=1 if therapy_original=="Yes"
label values therapy yesno
tab therapy

tab howoftendoyouhaveadrinkco
rename howoftendoyouhaveadrinkco audit1_original
gen audit1=.
replace audit1=0 if audit1_original=="Never"
replace audit1=1 if audit1_original=="Monthly or less"
replace audit1=2 if audit1_original=="2-4 times per month"
replace audit1=3 if audit1_original=="2-3 times per week"
replace audit1=4 if audit1_original=="4 or more times a week"
label define audit1 0 "Never" 1 "Monthly or less" 2 "2-4 times per month" 3 "2-3 times per week" 4 "4 or more times a week"
label values audit1 audit1
tab audit1

tab howmanystandarddrinkscontain
rename howmanystandarddrinkscontain audit2_original
gen audit2=.
replace audit2=0 if audit2_original=="0 to 2"
replace audit2=1 if audit2_original=="3 to 4"
replace audit2=2 if audit2_original=="5 to 6"
replace audit2=3 if audit2_original=="7 to 9"
label define audit2 0 "0 to 2" 1 "3 to 4" 2 "5 to 6" 3 "7 to 9"
label values audit2 audit2
tab audit2

tab howoftenhaveyouhad6ormore
rename howoftenhaveyouhad6ormore audit3_original
gen audit3=.
replace audit3=0 if audit3_original=="Never"
replace audit3=1 if audit3_original=="Less than monthly"
replace audit3=2 if audit3_original=="Monthly"
replace audit3=3 if audit3_original=="Weekly"
replace audit3=4 if audit3_original=="Daily or almost daily"
label define audit3 0 "Never" 1 "Less than monthly" 2 "Monthly" 3 "Weekly" 4 "Daily or almost daily"
label values audit3 audit3
tab audit3

rename substance audit_auto
egen audit=rowtotal(audit1-audit3)
tab audit
pwcorr audit_auto audit

tab haveyouusedanyrecreationald
rename haveyouusedanyrecreationald drugs1_original
gen drugs1=.
replace drugs1=0 if drugs1_original=="No"
replace drugs1=1 if drugs1_original=="Yes"
label values drugs1 yesno
tab drugs1

tab inthelastthreemonthshavey
rename inthelastthreemonthshavey drugs2_original
gen drugs2=.
replace drugs2=0 if drugs2_original=="No"
replace drugs2=1 if drugs2_original=="Yes"
label values drugs2 yesno
tab drugs2

tab inthelastthreemonthshasan
rename inthelastthreemonthshasan drugs3_original
gen drugs3=.
replace drugs3=0 if drugs3_original=="No"
replace drugs3=1 if drugs3_original=="Yes"
label values drugs3 yesno
tab drugs3

gen drugs=.
replace drugs=1 if (drugs2==1 | drugs3==1)
replace drugs=0 if (drugs2==0 & drugs3==0)
replace drugs=0 if drugs==.
tab drugs

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
tab iambotheredbyblushinginfr
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

drop tags networkid

tab exclusions screening
drop exclusions screening

gen eligible=.
replace eligible=0 if spintot<31
replace eligible=0 if audit>7
replace eligible=0 if drugs==1
replace eligible=0 if medchange==1
replace eligible=0 if therapy==1
replace eligible=0 if internet==0
replace eligible=0 if iphone==0
replace eligible=1 if eligible==.
tab eligible

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
br pid dup startdateutc submitdateutc if dup>0
*no dups
drop dup

rename * *_0
rename pid_0 pid

save "/Users/taylamccloud/Dropbox/Alena/screening_extra.dta", replace

**** COMBINE SCREENING DATA ****

use "/Users/taylamccloud/Dropbox/Alena/screening.dta"

rename startdateutc_0 startdateutc_0_1
rename submitdateutc_0 submitdateutc_0_1

append using "/Users/taylamccloud/Dropbox/Alena/screening_extra.dta"

save "/Users/taylamccloud/Dropbox/Alena/screening_final.dta"

**** IMPORT WEEK 1 APP GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/Week 1_app group.xlsx", sheet("Week 1_app group") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week1_app.dta"

**** PREPARE APP VARIABLES ****

des
br
drop a tags networkid 

tab howsatisfiedordissatisfiedar
rename howsatisfiedordissatisfiedar satis_original
gen satis=.
replace satis=4 if satis_original=="Very satisfied"
replace satis=3 if satis_original=="Somewhat satisfied"
replace satis=2 if satis_original=="Neither satisfied nor dissatisfied"
replace satis=1 if satis_original=="Somewhat dissatisfied"
replace satis=0 if satis_original=="Very dissatisfied"
label define satis 0 "Very dissatisfied" 1 "Somewhat dissatisfied" 2 "Neither satisfied nor dissatisfied" 3 "Somewhat satisfied" 4 "Very satisfied"
label values satis satis
tab satis

tab howhelpfulhaveyoufoundthea
rename howhelpfulhaveyoufoundthea help_original
gen help=.
replace help=4 if help_original=="Very helpful"
replace help=3 if help_original=="Somewhat helpful"
replace help=2 if help_original=="Neither helpful nor unhelpful"
replace help=1 if help_original=="Somewhat unhelpful"
replace help=0 if help_original=="Very unhelpful"
label define help 0 "Very unhelpful" 1 "Somewhat unhelpful" 2 "Neither helpful nor unhelpful" 3 "Somewhat helpful" 4 "Very helpful"
label values help help
tab help

tab howlikelyareyoutorecommend
rename howlikelyareyoutorecommend recc_original
gen recc=.
replace recc=4 if recc_original=="Very likely"
replace recc=3 if recc_original=="Somewhat likely"
replace recc=2 if recc_original=="Neither likely nor unlikely"
replace recc=1 if recc_original=="Somewhat unlikely"
replace recc=0 if recc_original=="Very unlikely"
label define recc 0 "Very unlikely" 1 "Somewhat unlikely" 2 "Neither likely nor unlikely" 3 "Somewhat likely" 4 "Very likely"
label values recc recc
tab recc

tab howeasytousehaveyoufoundt
rename howeasytousehaveyoufoundt easy_original
gen easy=.
replace easy=4 if easy_original=="Very easy to use"
replace easy=3 if easy_original=="Somewhat easy to use"
replace easy=2 if easy_original=="Neither easy to use nor difficult to use"
replace easy=1 if easy_original=="Somewhat difficult to use"
replace easy=0 if easy_original=="Very difficult to use"
label define easy 0 "Very difficult to use" 1 "Somewhat difficult to use" 2 "Neither easy to use nor difficult to use" 3 "Somewhat easy to use" 4 "Very easy to use"
label values easy easy
tab easy 

tab didyougettotheendofthisw
rename didyougettotheendofthisw end_original
gen end=.
replace end=0 if end_original=="No"
replace end=1 if end_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values end yesno
tab end

tab nothingicompletedtheexerci
rename nothingicompletedtheexerci nothing
replace nothing="1" if nothing=="Nothing - I completed the exercises"
replace nothing="0" if missing(nothing)
tab nothing

tab ididnotfeellikeitwashelpi
rename ididnotfeellikeitwashelpi nohelp
replace nohelp="1" if nohelp=="I did not feel like it was helping or would help me"
replace nohelp="0" if missing(nohelp)
tab nohelp

tab iforgottouseit
rename iforgottouseit forgot
replace forgot="1" if forgot=="I forgot to use it"
replace forgot="0" if missing(forgot)
tab forgot

tab iexperiencedtechnicaldifficul
rename iexperiencedtechnicaldifficul tech
replace tech="1" if tech=="I experienced technical difficulties (e.g. the app crashed)"
replace tech="0" if missing(tech)
tab tech

tab ifounditboring
rename ifounditboring boring
replace boring="1" if boring=="I found it boring"
replace boring="0" if missing(boring)
tab boring

tab theappwasnotenjoyabletouse
rename theappwasnotenjoyabletouse enjoy
replace enjoy="1" if enjoy=="The app was not enjoyable to use (e.g. too repetitive)"
replace enjoy="0" if missing(enjoy)
tab enjoy

tab ididnothaveaccesstoasmart
rename ididnothaveaccesstoasmart phone
replace phone="1" if phone=="I did not have access to a smartphone or the internet"
replace phone="0" if missing(phone)
tab phone

tab iwastoobusyordidnäôthave
rename iwastoobusyordidnäôthave busy
replace busy="1" if busy=="I was too busy or didn‚Äôt have time"
replace busy="0" if missing(busy)
tab busy

tab ididnotfeelemotionallyable
rename ididnotfeelemotionallyable emo
replace emo="1" if emo=="I did not feel emotionally able to complete it"
replace emo="0" if missing(emo)
tab emo

tab ifoundittoohardchallenging
rename ifoundittoohardchallenging hard
replace hard="1" if hard=="I found it too hard/challenging to complete"
replace hard="0" if missing(hard)
tab hard

tab ijustdidnäôtfeellikeit
rename ijustdidnäôtfeellikeit feellike
replace feellike="1" if feellike=="I just didn‚Äôt feel like it"
replace feellike="0" if missing(feellike)
tab feellike

*fix naming to group them
rename nothing nofin_nothing
rename nohelp nofin_nohelp
rename forgot nofin_forgot
rename tech nofin_tech
rename boring nofin_boring
rename enjoy nofin_enjoy
rename phone nofin_phone
rename busy nofin_busy
rename emo nofin_emo
rename hard nofin_hard
rename feellike nofin_feellike
rename other nofin_other

br nofin* if nofin_nothing=="1"
*NB: nothing option wasn't exclusive - some people saying nothing did select other options

*adverse events
tab haveyouexperiencedanynegativ
rename haveyouexperiencedanynegativ adverse_original
gen adverse=.
replace adverse=0 if adverse_original=="No"
replace adverse=1 if adverse_original=="I'm not sure"
replace adverse=2 if adverse_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values adverse adverse
tab adverse 

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

tab pleaseratetheseverityofthe
rename pleaseratetheseverityofthe advsev_original
gen advsev=.
replace advsev=0 if advsev_original=="Very mild"
replace advsev=1 if advsev_original=="Mild"
replace advsev=2 if advsev_original=="Moderate"
replace advsev=3 if advsev_original=="Severe"
replace advsev=4 if advsev_original=="Very severe"
label define advsev 0 "Very mild" 1 "Mild" 2 "Moderate" 3 "Severe" 4 "Very severe"
label values advsev advsev
tab advsev

tab doyouhaveanycommentsorfeed
rename doyouhaveanycommentsorfeed feedback

tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab bc
rename bc advall_qual

gen advany=0
replace advany=1 if (advall_w1==1 | advall_w2==1 | advall_w3==1 | advall_w4==1 | advall_w6==1)
replace advany=1 if (advall_w1==2 | advall_w2==2 | advall_w3==2 | advall_w4==2 | advall_w6==2)
replace advany=1 if (adverse_w1==1 | adverse_w2==1 | adverse_w3==1 | adverse_w4==1)
tab advany
br adv* advany

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab ao
rename ao wsas2
summ wsas2

tab ap
rename ap wsas3
summ wsas3

tab aq 
rename aq wsas4
summ wsas4

tab ar
rename ar wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename at phq2
rename au phq3
rename av phq4
rename aw phq5
rename ax phq6
rename ay phq7
rename az phq8
rename ba phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week1
rename * *_w1
rename pid_w1 pid


**** IMPORT WEEK 1 WAITLIST GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/Week 1_waitlist group.xlsx", sheet("Week 1_waitlist group") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week1_waitlist.dta"

**** PREPARE WAITLIST VARIABLES ****

des
br
drop a tags networkid 

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week1
rename * *_w1
rename pid_w1 pid

*combine week 1 datasets

append using "/Users/taylamccloud/Dropbox/Alena/week1_app.dta", generate(group)

save "/Users/taylamccloud/Dropbox/Alena/week1.dta"

br

tab group
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group
tab group satis_w1, m

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
br pid dup startdateutc submitdateutc if dup>0
*take the first submission
drop if dup==2

**** IMPORT WEEK 2 APP GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/Week 2_app group.xlsx", sheet("responses (22)") firstrow case(lower)

save "/Users/taylamccloud/Dropbox/Alena/week2_app.dta"

**** PREPARE APP VARIABLES ****

des
br
drop a tags networkid 

tab howsatisfiedordissatisfiedar
rename howsatisfiedordissatisfiedar satis_original
gen satis=.
replace satis=4 if satis_original=="Very satisfied"
replace satis=3 if satis_original=="Somewhat satisfied"
replace satis=2 if satis_original=="Neither satisfied nor dissatisfied"
replace satis=1 if satis_original=="Somewhat dissatisfied"
replace satis=0 if satis_original=="Very dissatisfied"
label define satis 0 "Very dissatisfied" 1 "Somewhat dissatisfied" 2 "Neither satisfied nor dissatisfied" 3 "Somewhat satisfied" 4 "Very satisfied"
label values satis satis
tab satis

tab howhelpfulhaveyoufoundthea
rename howhelpfulhaveyoufoundthea help_original
gen help=.
replace help=4 if help_original=="Very helpful"
replace help=3 if help_original=="Somewhat helpful"
replace help=2 if help_original=="Neither helpful nor unhelpful"
replace help=1 if help_original=="Somewhat unhelpful"
replace help=0 if help_original=="Very unhelpful"
label define help 0 "Very unhelpful" 1 "Somewhat unhelpful" 2 "Neither helpful nor unhelpful" 3 "Somewhat helpful" 4 "Very helpful"
label values help help
tab help

tab howlikelyareyoutorecommend
rename howlikelyareyoutorecommend recc_original
gen recc=.
replace recc=4 if recc_original=="Very likely"
replace recc=3 if recc_original=="Somewhat likely"
replace recc=2 if recc_original=="Neither likely nor unlikely"
replace recc=1 if recc_original=="Somewhat unlikely"
replace recc=0 if recc_original=="Very unlikely"
label define recc 0 "Very unlikely" 1 "Somewhat unlikely" 2 "Neither likely nor unlikely" 3 "Somewhat likely" 4 "Very likely"
label values recc recc
tab recc

tab howeasytousehaveyoufoundt
rename howeasytousehaveyoufoundt easy_original
gen easy=.
replace easy=4 if easy_original=="Very easy to use"
replace easy=3 if easy_original=="Somewhat easy to use"
replace easy=2 if easy_original=="Neither easy to use nor difficult to use"
replace easy=1 if easy_original=="Somewhat difficult to use"
replace easy=0 if easy_original=="Very difficult to use"
label define easy 0 "Very difficult to use" 1 "Somewhat difficult to use" 2 "Neither easy to use nor difficult to use" 3 "Somewhat easy to use" 4 "Very easy to use"
label values easy easy
tab easy 

tab didyougettotheendofthisw
rename didyougettotheendofthisw end_original
gen end=.
replace end=0 if end_original=="No"
replace end=1 if end_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values end yesno
tab end

tab nothingicompletedtheexerci
rename nothingicompletedtheexerci nothing
replace nothing="1" if nothing=="Nothing - I completed the exercises"
replace nothing="0" if missing(nothing)
tab nothing

tab ididnotfeellikeitwashelpi
rename ididnotfeellikeitwashelpi nohelp
replace nohelp="1" if nohelp=="I did not feel like it was helping or would help me"
replace nohelp="0" if missing(nohelp)
tab nohelp

tab iforgottouseit
rename iforgottouseit forgot
replace forgot="1" if forgot=="I forgot to use it"
replace forgot="0" if missing(forgot)
tab forgot

tab iexperiencedtechnicaldifficul
rename iexperiencedtechnicaldifficul tech
replace tech="1" if tech=="I experienced technical difficulties (e.g. the app crashed)"
replace tech="0" if missing(tech)
tab tech

tab ifounditboring
rename ifounditboring boring
replace boring="1" if boring=="I found it boring"
replace boring="0" if missing(boring)
tab boring

tab theappwasnotenjoyabletouse
rename theappwasnotenjoyabletouse enjoy
replace enjoy="1" if enjoy=="The app was not enjoyable to use (e.g. too repetitive)"
replace enjoy="0" if missing(enjoy)
tab enjoy

tab ididnothaveaccesstoasmart
rename ididnothaveaccesstoasmart phone
replace phone="1" if phone=="I did not have access to a smartphone or the internet"
replace phone="0" if missing(phone)
tab phone

tab iwastoobusyordidnäôthave
rename iwastoobusyordidnäôthave busy
replace busy="1" if busy=="I was too busy or didn‚Äôt have time"
replace busy="0" if missing(busy)
tab busy

tab ididnotfeelemotionallyable
rename ididnotfeelemotionallyable emo
replace emo="1" if emo=="I did not feel emotionally able to complete it"
replace emo="0" if missing(emo)
tab emo

tab ifoundittoohardchallenging
rename ifoundittoohardchallenging hard
replace hard="1" if hard=="I found it too hard/challenging to complete"
replace hard="0" if missing(hard)
tab hard

tab ijustdidnäôtfeellikeit
rename ijustdidnäôtfeellikeit feellike
replace feellike="1" if feellike=="I just didn‚Äôt feel like it"
replace feellike="0" if missing(feellike)
tab feellike

*fix naming to group them
rename nothing nofin_nothing
rename nohelp nofin_nohelp
rename forgot nofin_forgot
rename tech nofin_tech
rename boring nofin_boring
rename enjoy nofin_enjoy
rename phone nofin_phone
rename busy nofin_busy
rename emo nofin_emo
rename hard nofin_hard
rename feellike nofin_feellike
rename other nofin_other

br nofin* if nofin_nothing=="1"
*NB: nothing option wasn't exclusive - some people saying nothing did select other options

*adverse events
tab haveyouexperiencedanynegativ
rename haveyouexperiencedanynegativ adverse_original
gen adverse=.
replace adverse=0 if adverse_original=="No"
replace adverse=1 if adverse_original=="I'm not sure"
replace adverse=2 if adverse_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values adverse adverse
tab adverse 

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

tab pleaseratetheseverityofthe
rename pleaseratetheseverityofthe advsev_original
gen advsev=.
replace advsev=0 if advsev_original=="Very mild"
replace advsev=1 if advsev_original=="Mild"
replace advsev=2 if advsev_original=="Moderate"
replace advsev=3 if advsev_original=="Severe"
replace advsev=4 if advsev_original=="Very severe"
label define advsev 0 "Very mild" 1 "Mild" 2 "Moderate" 3 "Severe" 4 "Very severe"
label values advsev advsev
tab advsev

tab doyouhaveanycommentsorfeed
rename doyouhaveanycommentsorfeed feedback

tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab bc
rename bc advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab ao
rename ao wsas2
summ wsas2

tab ap
rename ap wsas3
summ wsas3

tab aq 
rename aq wsas4
summ wsas4

tab ar
rename ar wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename at phq2
rename au phq3
rename av phq4
rename aw phq5
rename ax phq6
rename ay phq7
rename az phq8
rename ba phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week2
rename * *_w2
rename pid_w2 pid

**** IMPORT WEEK 2 WAITLIST GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/Week 2_waitlist group.xlsx", sheet("f7esq3Bd") firstrow case(lower)

save "/Users/taylamccloud/Dropbox/Alena/week2_waitlist.dta"

**** PREPARE WAITLIST VARIABLES ****

des
br
drop a tags networkid 

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week2
rename * *_w2
rename pid_w2 pid

*combine week 2 datasets
rename startdateutc_w2 startdateutc_w2_0

use "/Users/taylamccloud/Dropbox/Alena/week2_app.dta", clear
rename startdateutc_w2 startdateutc_w2_1
rename submitdateutc_w2 submitdateutc_w2_1

use "/Users/taylamccloud/Dropbox/Alena/week2_waitlist.dta"
rename startdateutc_w2 startdateutc_w2_0
rename submitdateutc_w2 submitdateutc_w2_0

append using "/Users/taylamccloud/Dropbox/Alena/week2_app.dta", generate(group)

save "/Users/taylamccloud/Dropbox/Alena/week2.dta"

br

tab group
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group
tab group satis_w2, m

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*no dups


**** IMPORT WEEK 3 APP GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/week3_app.xlsx", sheet("xwu2CK9q") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week3_app.dta"

**** PREPARE APP VARIABLES ****
	
des
br
drop a tags networkid 

tab howsatisfiedordissatisfiedar
rename howsatisfiedordissatisfiedar satis_original
gen satis=.
replace satis=4 if satis_original=="Very satisfied"
replace satis=3 if satis_original=="Somewhat satisfied"
replace satis=2 if satis_original=="Neither satisfied nor dissatisfied"
replace satis=1 if satis_original=="Somewhat dissatisfied"
replace satis=0 if satis_original=="Very dissatisfied"
label define satis 0 "Very dissatisfied" 1 "Somewhat dissatisfied" 2 "Neither satisfied nor dissatisfied" 3 "Somewhat satisfied" 4 "Very satisfied"
label values satis satis
tab satis

tab howhelpfulhaveyoufoundthea
rename howhelpfulhaveyoufoundthea help_original
gen help=.
replace help=4 if help_original=="Very helpful"
replace help=3 if help_original=="Somewhat helpful"
replace help=2 if help_original=="Neither helpful nor unhelpful"
replace help=1 if help_original=="Somewhat unhelpful"
replace help=0 if help_original=="Very unhelpful"
label define help 0 "Very unhelpful" 1 "Somewhat unhelpful" 2 "Neither helpful nor unhelpful" 3 "Somewhat helpful" 4 "Very helpful"
label values help help
tab help

tab howlikelyareyoutorecommend
rename howlikelyareyoutorecommend recc_original
gen recc=.
replace recc=4 if recc_original=="Very likely"
replace recc=3 if recc_original=="Somewhat likely"
replace recc=2 if recc_original=="Neither likely nor unlikely"
replace recc=1 if recc_original=="Somewhat unlikely"
replace recc=0 if recc_original=="Very unlikely"
label define recc 0 "Very unlikely" 1 "Somewhat unlikely" 2 "Neither likely nor unlikely" 3 "Somewhat likely" 4 "Very likely"
label values recc recc
tab recc

tab howeasytousehaveyoufoundt
rename howeasytousehaveyoufoundt easy_original
gen easy=.
replace easy=4 if easy_original=="Very easy to use"
replace easy=3 if easy_original=="Somewhat easy to use"
replace easy=2 if easy_original=="Neither easy to use nor difficult to use"
replace easy=1 if easy_original=="Somewhat difficult to use"
replace easy=0 if easy_original=="Very difficult to use"
label define easy 0 "Very difficult to use" 1 "Somewhat difficult to use" 2 "Neither easy to use nor difficult to use" 3 "Somewhat easy to use" 4 "Very easy to use"
label values easy easy
tab easy 

tab didyougettotheendofthisw
rename didyougettotheendofthisw end_original
gen end=.
replace end=0 if end_original=="No"
replace end=1 if end_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values end yesno
tab end

tab nothingicompletedtheexerci
rename nothingicompletedtheexerci nothing
replace nothing="1" if nothing=="Nothing - I completed the exercises"
replace nothing="0" if missing(nothing)
tab nothing

tab ididnotfeellikeitwashelpi
rename ididnotfeellikeitwashelpi nohelp
replace nohelp="1" if nohelp=="I did not feel like it was helping or would help me"
replace nohelp="0" if missing(nohelp)
tab nohelp

tab iforgottouseit
rename iforgottouseit forgot
replace forgot="1" if forgot=="I forgot to use it"
replace forgot="0" if missing(forgot)
tab forgot

tab iexperiencedtechnicaldifficul
rename iexperiencedtechnicaldifficul tech
replace tech="1" if tech=="I experienced technical difficulties (e.g. the app crashed)"
replace tech="0" if missing(tech)
tab tech

tab ifounditboring
rename ifounditboring boring
replace boring="1" if boring=="I found it boring"
replace boring="0" if missing(boring)
tab boring

tab theappwasnotenjoyabletouse
rename theappwasnotenjoyabletouse enjoy
replace enjoy="1" if enjoy=="The app was not enjoyable to use (e.g. too repetitive)"
replace enjoy="0" if missing(enjoy)
tab enjoy

tab ididnothaveaccesstoasmart
rename ididnothaveaccesstoasmart phone
replace phone="1" if phone=="I did not have access to a smartphone or the internet"
replace phone="0" if missing(phone)
tab phone

tab iwastoobusyordidnthaveti
rename iwastoobusyordidnthaveti busy
replace busy="1" if busy=="I was too busy or didn‚Äôt have time"
replace busy="0" if missing(busy)
tab busy

tab ididnotfeelemotionallyable
rename ididnotfeelemotionallyable emo
replace emo="1" if emo=="I did not feel emotionally able to complete it"
replace emo="0" if missing(emo)
tab emo

tab ifoundittoohardchallenging
rename ifoundittoohardchallenging hard
replace hard="1" if hard=="I found it too hard/challenging to complete"
replace hard="0" if missing(hard)
tab hard

tab ijustdidntfeellikeit
rename ijustdidntfeellikeit feellike
replace feellike="1" if feellike=="I just didn‚Äôt feel like it"
replace feellike="0" if missing(feellike)
tab feellike

*fix naming to group them
rename nothing nofin_nothing
rename nohelp nofin_nohelp
rename forgot nofin_forgot
rename tech nofin_tech
rename boring nofin_boring
rename enjoy nofin_enjoy
rename phone nofin_phone
rename busy nofin_busy
rename emo nofin_emo
rename hard nofin_hard
rename feellike nofin_feellike
rename other nofin_other

br nofin* if nofin_nothing=="1"
*NB: nothing option wasn't exclusive - some people saying nothing did select other options

*adverse events
tab haveyouexperiencedanynegativ
rename haveyouexperiencedanynegativ adverse_original
gen adverse=.
replace adverse=0 if adverse_original=="No"
replace adverse=1 if adverse_original=="I'm not sure"
replace adverse=2 if adverse_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values adverse adverse
tab adverse 

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

tab pleaseratetheseverityofthe
rename pleaseratetheseverityofthe advsev_original
gen advsev=.
replace advsev=0 if advsev_original=="Very mild"
replace advsev=1 if advsev_original=="Mild"
replace advsev=2 if advsev_original=="Moderate"
replace advsev=3 if advsev_original=="Severe"
replace advsev=4 if advsev_original=="Very severe"
label define advsev 0 "Very mild" 1 "Mild" 2 "Moderate" 3 "Severe" 4 "Very severe"
label values advsev advsev
tab advsev

tab doyouhaveanycommentsorfeed
rename doyouhaveanycommentsorfeed feedback

tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab bc
rename bc advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab ao
rename ao wsas2
summ wsas2

tab ap
rename ap wsas3
summ wsas3

tab aq 
rename aq wsas4
summ wsas4

tab ar
rename ar wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename at phq2
rename au phq3
rename av phq4
rename aw phq5
rename ax phq6
rename ay phq7
rename az phq8
rename ba phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week 3
rename * *_w3
rename pid_w3 pid


**** IMPORT WEEK 3 WAITLIST GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/week3_waitlist.xlsx", sheet("H1TGzJeS") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week3_waitlist.dta"

**** PREPARE WAITLIST VARIABLES ****

des
br
drop a tags networkid 

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week 3
rename * *_w3
rename pid_w3 pid

*combine week 3 datasets

use "/Users/taylamccloud/Dropbox/Alena/week3_app.dta", clear
rename startdateutc_w3 startdateutc_w3_1
rename submitdateutc_w3 submitdateutc_w3_1

use "/Users/taylamccloud/Dropbox/Alena/week3_waitlist.dta"
rename startdateutc_w3 startdateutc_w3_0
rename submitdateutc_w3 submitdateutc_w3_0

append using "/Users/taylamccloud/Dropbox/Alena/week3_app.dta", generate(group)

save "/Users/taylamccloud/Dropbox/Alena/week3.dta"

br

tab group
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group
tab group satis_w3, m

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*1 dup - take earliest
br if dup>0
drop if dup==2
drop dup

**** IMPORT WEEK 4 APP GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/week4_app.xlsx", sheet("n5q5P0rc") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week4_app.dta"

**** PREPARE APP VARIABLES ****
	
des
br
drop a tags networkid 

tab howsatisfiedordissatisfiedar
rename howsatisfiedordissatisfiedar satis_original
gen satis=.
replace satis=4 if satis_original=="Very satisfied"
replace satis=3 if satis_original=="Somewhat satisfied"
replace satis=2 if satis_original=="Neither satisfied nor dissatisfied"
replace satis=1 if satis_original=="Somewhat dissatisfied"
replace satis=0 if satis_original=="Very dissatisfied"
label define satis 0 "Very dissatisfied" 1 "Somewhat dissatisfied" 2 "Neither satisfied nor dissatisfied" 3 "Somewhat satisfied" 4 "Very satisfied"
label values satis satis
tab satis

tab howhelpfulhaveyoufoundthea
rename howhelpfulhaveyoufoundthea help_original
gen help=.
replace help=4 if help_original=="Very helpful"
replace help=3 if help_original=="Somewhat helpful"
replace help=2 if help_original=="Neither helpful nor unhelpful"
replace help=1 if help_original=="Somewhat unhelpful"
replace help=0 if help_original=="Very unhelpful"
label define help 0 "Very unhelpful" 1 "Somewhat unhelpful" 2 "Neither helpful nor unhelpful" 3 "Somewhat helpful" 4 "Very helpful"
label values help help
tab help

tab howlikelyareyoutorecommend
rename howlikelyareyoutorecommend recc_original
gen recc=.
replace recc=4 if recc_original=="Very likely"
replace recc=3 if recc_original=="Somewhat likely"
replace recc=2 if recc_original=="Neither likely nor unlikely"
replace recc=1 if recc_original=="Somewhat unlikely"
replace recc=0 if recc_original=="Very unlikely"
label define recc 0 "Very unlikely" 1 "Somewhat unlikely" 2 "Neither likely nor unlikely" 3 "Somewhat likely" 4 "Very likely"
label values recc recc
tab recc

tab howeasytousehaveyoufoundt
rename howeasytousehaveyoufoundt easy_original
gen easy=.
replace easy=4 if easy_original=="Very easy to use"
replace easy=3 if easy_original=="Somewhat easy to use"
replace easy=2 if easy_original=="Neither easy to use nor difficult to use"
replace easy=1 if easy_original=="Somewhat difficult to use"
replace easy=0 if easy_original=="Very difficult to use"
label define easy 0 "Very difficult to use" 1 "Somewhat difficult to use" 2 "Neither easy to use nor difficult to use" 3 "Somewhat easy to use" 4 "Very easy to use"
label values easy easy
tab easy 

tab didyougettotheendofthisw
rename didyougettotheendofthisw end_original
gen end=.
replace end=0 if end_original=="No"
replace end=1 if end_original=="Yes"
label define yesno 0 "No" 1 "Yes"
label values end yesno
tab end

tab nothingicompletedtheexerci
rename nothingicompletedtheexerci nothing
replace nothing="1" if nothing=="Nothing - I completed the exercises"
replace nothing="0" if missing(nothing)
tab nothing

tab ididnotfeellikeitwashelpi
rename ididnotfeellikeitwashelpi nohelp
replace nohelp="1" if nohelp=="I did not feel like it was helping or would help me"
replace nohelp="0" if missing(nohelp)
tab nohelp

tab iforgottouseit
rename iforgottouseit forgot
replace forgot="1" if forgot=="I forgot to use it"
replace forgot="0" if missing(forgot)
tab forgot

tab iexperiencedtechnicaldifficul
rename iexperiencedtechnicaldifficul tech
replace tech="1" if tech=="I experienced technical difficulties (e.g. the app crashed)"
replace tech="0" if missing(tech)
tab tech

tab ifounditboring
rename ifounditboring boring
replace boring="1" if boring=="I found it boring"
replace boring="0" if missing(boring)
tab boring

tab theappwasnotenjoyabletouse
rename theappwasnotenjoyabletouse enjoy
replace enjoy="1" if enjoy=="The app was not enjoyable to use (e.g. too repetitive)"
replace enjoy="0" if missing(enjoy)
tab enjoy

tab ididnothaveaccesstoasmart
rename ididnothaveaccesstoasmart phone
replace phone="1" if phone=="I did not have access to a smartphone or the internet"
replace phone="0" if missing(phone)
tab phone

tab iwastoobusyordidnthaveti
rename iwastoobusyordidnthaveti busy
replace busy="1" if busy=="I was too busy or didn‚Äôt have time"
replace busy="0" if missing(busy)
tab busy

tab ididnotfeelemotionallyable
rename ididnotfeelemotionallyable emo
replace emo="1" if emo=="I did not feel emotionally able to complete it"
replace emo="0" if missing(emo)
tab emo

tab ifoundittoohardchallenging
rename ifoundittoohardchallenging hard
replace hard="1" if hard=="I found it too hard/challenging to complete"
replace hard="0" if missing(hard)
tab hard

tab ijustdidntfeellikeit
rename ijustdidntfeellikeit feellike
replace feellike="1" if feellike=="I just didn‚Äôt feel like it"
replace feellike="0" if missing(feellike)
tab feellike

*fix naming to group them
rename nothing nofin_nothing
rename nohelp nofin_nohelp
rename forgot nofin_forgot
rename tech nofin_tech
rename boring nofin_boring
rename enjoy nofin_enjoy
rename phone nofin_phone
rename busy nofin_busy
rename emo nofin_emo
rename hard nofin_hard
rename feellike nofin_feellike
rename other nofin_other

br nofin* if nofin_nothing=="1"
*NB: nothing option wasn't exclusive - some people saying nothing did select other options

*adverse events
tab haveyouexperiencedanynegativ
rename haveyouexperiencedanynegativ adverse_original
gen adverse=.
replace adverse=0 if adverse_original=="No"
replace adverse=1 if adverse_original=="I'm not sure"
replace adverse=2 if adverse_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values adverse adverse
tab adverse 

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

tab pleaseratetheseverityofthe
rename pleaseratetheseverityofthe advsev_original
gen advsev=.
replace advsev=0 if advsev_original=="Very mild"
replace advsev=1 if advsev_original=="Mild"
replace advsev=2 if advsev_original=="Moderate"
replace advsev=3 if advsev_original=="Severe"
replace advsev=4 if advsev_original=="Very severe"
label define advsev 0 "Very mild" 1 "Mild" 2 "Moderate" 3 "Severe" 4 "Very severe"
label values advsev advsev
tab advsev

tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

drop bn

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab az
rename az wsas2
summ wsas2

tab ba
rename ba wsas3
summ wsas3

tab bb
rename bb wsas4
summ wsas4

tab bc
rename bc wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename be phq2
rename bf phq3
rename bg phq4
rename bh phq5
rename bi phq6
rename bj phq7
rename bk phq8
rename bl phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week 4
rename * *_w4
rename pid_w4 pid

*final week vars

tab wereyoupreviouslylookingfor
tab w 
*w var is 'other' option - no obs
drop w
rename wereyoupreviouslylookingfor helpseek_original
gen helpseek=.
replace helpseek=0 if helpseek_original=="No"
replace helpseek=1 if helpseek_original=="I was considering it"
replace helpseek=2 if helpseek_original=="Yes"
label define helpseek 0 "No" 1 "I was considering it" 2 "Yes"
label values helpseek helpseek
tab helpseek

tab howlikelyisitthatyouwould
rename howlikelyisitthatyouwould applikely

tab ifyouhaveeversoughthelpwit
rename ifyouhaveeversoughthelpwit prevhelp

tab didusingthealenaappaffectt 
rename didusingthealenaappaffectt impact_qual

tab whatisonethingthatwouldmak
rename whatisonethingthatwouldmak moreeffect_qual

tab ifyoudidnotcompleteallfo
rename ifyoudidnotcompleteallfo nocomplete_qual

tab whatisonethingthatwouldnee
rename whatisonethingthatwouldnee morecomplete_qual

tab whatdidyoufindthemosthelpf
rename whatdidyoufindthemosthelpf mosthelpful_qual

tab whatisthemostimportantthing
rename whatisthemostimportantthing improve_qual

tab pleasedescribeanyofthethera
rename pleasedescribeanyofthethera toochallenge_qual

tab arethereanyothercommentsor
rename arethereanyothercommentsor feedback

**** IMPORT WEEK 4 WAITLIST GROUP DATA ****

import excel "/Users/taylamccloud/Dropbox/Alena/week4_waitlist.xlsx", sheet("LKcAoaXJ") firstrow case(lower) clear

save "/Users/taylamccloud/Dropbox/Alena/week4_waitlist.dta"

**** PREPARE WAITLIST VARIABLES ****

des
br
drop a tags networkid 

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advall_qual

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*rename everything for week 4
rename * *_w4
rename pid_w4 pid

*combine week 4 datasets

use "/Users/taylamccloud/Dropbox/Alena/week4_app.dta", clear
rename startdateutc_w4 startdateutc_w4_1
rename submitdateutc_w4 submitdateutc_w4_1

use "/Users/taylamccloud/Dropbox/Alena/week4_waitlist.dta"
rename startdateutc_w4 startdateutc_w4_0
rename submitdateutc_w4 submitdateutc_w4_0

append using "/Users/taylamccloud/Dropbox/Alena/week4_app.dta", generate(group)

save "/Users/taylamccloud/Dropbox/Alena/week4.dta"

br

tab group
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group
tab group satis_w4, m

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*11 dups - take earliest
br pid start* submit* prevhelp* feedback *qual* if dup>0 & group==0

*manually combine qual answers so no data is lost
br pid start* submit* prevhelp* feedback *qual* dup if dup>0 & group==1

drop dup

**** ADD OBJECTIVE USAGE DATA ****

*week 1
import excel "/Users/taylamccloud/Dropbox/Alena/M0C1 usage.xlsx", sheet("bP5Z5yuX") firstrow case(lower) clear
rename uid pid
gen M0E1=.
replace M0E1=1 if !missing(b) 
save "/Users/taylamccloud/Dropbox/Alena/M0E1 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M0C2 usage.xlsx", sheet("vjL4D08L") firstrow case(lower) clear
rename uid pid
gen M0E2=.
replace M0E2=1 if !missing(ifalenaworkedreallywellwha) 
save "/Users/taylamccloud/Dropbox/Alena/M0E2 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M1E1 usage.xlsx", sheet("tfpbA8be") firstrow case(lower) clear
rename uid pid
gen M1E1=.
replace M1E1=1 if !missing(tostartnamethesituationyou) 
save "/Users/taylamccloud/Dropbox/Alena/M1E1 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M1E2 usage.xlsx", sheet("eq8ufVYK") firstrow case(lower) clear
rename uid pid
gen M1E2=.
replace M1E2=1 if !missing(pleasedescribethesituationbr) 
save "/Users/taylamccloud/Dropbox/Alena/M1E2 usage.dta"

*week 2
import excel "/Users/taylamccloud/Dropbox/Alena/M2E1 usage.xlsx", sheet("pYZfy1l9") firstrow case(lower) clear
rename uid pid
gen M2E1=.
replace M2E1=1 if !missing(whattypeofsituationwasit) 
save "/Users/taylamccloud/Dropbox/Alena/M2E1 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M2E2 usage.xlsx", sheet("zxxFWonm") firstrow case(lower) clear
rename uid pid
gen M2E2=.
replace M2E2=1 if !missing(howeasyorharddidyoufindit) 
save "/Users/taylamccloud/Dropbox/Alena/M2E2 usage.dta"

*week 3
import excel "/Users/taylamccloud/Dropbox/Alena/M3E1 usage.xlsx", sheet("Xoefba9G") firstrow case(lower) clear
rename uid pid
gen M3E1=.
replace M3E1=1 if !missing(thinkingaboutasituationwhere) 
save "/Users/taylamccloud/Dropbox/Alena/M3E1 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M3E2 usage.xlsx", sheet("eXHjtq8o") firstrow case(lower) clear
rename uid pid
gen M3E2=.
replace M3E2=1 if !missing(pleasedescribethesituationbr) 
save "/Users/taylamccloud/Dropbox/Alena/M3E2 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M3E3 usage.xlsx", sheet("LONY55XK") firstrow case(lower) clear
rename uid pid
gen M3E3=.
replace M3E3=1 if !missing(didyoumanagetoattempttheex) 
save "/Users/taylamccloud/Dropbox/Alena/M3E3 usage.dta"

*week 4
import excel "/Users/taylamccloud/Dropbox/Alena/M4E1 usage.xlsx", sheet("MDTs4wck") firstrow case(lower) clear
rename uid pid
gen M4E1=.
replace M4E1=1 if !missing(doesspirallingintonegativeru) 
save "/Users/taylamccloud/Dropbox/Alena/M4E1 usage.dta"

import excel "/Users/taylamccloud/Dropbox/Alena/M4E2 usage.xlsx", sheet("Zt3zexns") firstrow case(lower) clear
rename uid pid
gen M4E2=.
replace M4E2=1 if !missing(doyourelatetoexperiencingme) 
save "/Users/taylamccloud/Dropbox/Alena/M4E2 usage.dta"

*merge into baseline
use "/Users/taylamccloud/Dropbox/Alena/baseline.dta"
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M0E1 usage.dta", keepusing(M0E1)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M0E2 usage.dta", keepusing(M0E2)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M1E1 usage.dta", keepusing(M1E1)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M1E2 usage.dta", keepusing(M1E2)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M2E1 usage.dta", keepusing(M2E1)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M2E2 usage.dta", keepusing(M2E2)
*NB: has dups - needed to dedup
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M3E1 usage.dta", keepusing(M3E1)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M3E2 usage.dta", keepusing(M3E2)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M3E3 usage.dta", keepusing(M3E3)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M4E1 usage.dta", keepusing(M4E1)
drop _m
merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/M4E2 usage.dta", keepusing(M4E2)
drop _m

foreach var in M0E1 M0E2 M1E1 M1E2 M2E1 M2E2 M3E1 M3E2 M3E3 M4E1 M4E2 {
replace `var'=0 if missing(`var')
replace `var'=. if group==0
}

*create completion vars
egen M0M1tot=rowtotal(M0E1 M0E2 M1E1 M1E2)
replace M0M1tot=. if group==0
tab M0M1tot

gen M0M1complete=.
replace M0M1complete=1 if M0M1tot==4
replace M0M1complete=0 if M0M1tot!=4 & group==1
tab M0M1complete

egen M2tot=rowtotal(M2E1 M2E2)
replace M2tot=. if group==0
tab M2tot

gen M2complete=.
replace M2complete=1 if M2tot==2
replace M2complete=0 if M2tot!=2 & group==1
tab M2complete

egen M3tot=rowtotal(M3E1 M3E2 M3E3)
replace M3tot=. if group==0
tab M3tot

gen M3complete=.
replace M3complete=1 if M3tot==3
replace M3complete=0 if M3tot!=3 & group==1
tab M3complete

egen M4tot=rowtotal(M4E1 M4E2)
replace M4tot=. if group==0
tab M4tot

gen M4complete=.
replace M4complete=1 if M4tot==2
replace M4complete=0 if M4tot!=2 & group==1
tab M4complete

gen completed=.
replace completed=1 if M4complete==1 & M3complete==1 & M2complete==1 & M0M1complete==1
replace completed=0 if group==1 & missing(completed)
tab completed

*also add var for app downloaded - manually from data from Omar
gen appdownloaded=1 if group==1
replace appdownloaded=0 if pid=="5cf510ccb0bafb00161ffd56"
replace appdownloaded=0 if pid=="62a71ce6a09aa213bd5c3de9"
tab appdownloaded
label values appdownloaded yesno

*weird issue fix 
drop if group==.

**** LINK ALL DATA ****

use "/Users/taylamccloud/Dropbox/Alena/baseline.dta"

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/screening.dta"
*247 not matched from using, 0 not matched from master, 102 matched

rename _m merge1
tab merge1

*drop people who were screened out or didn't participate
sort merge1
br
drop if merge1==2

save "/Users/taylamccloud/Dropbox/Alena/merged.dta"

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/week1.dta"
*0 not matched from using, 2 not matched from master, 100 matched

rename _m merge2
tab merge2

save "/Users/taylamccloud/Dropbox/Alena/merged.dta", replace

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/week2.dta"
*0 not matched from using, 4 not matched from master, 98 matched

rename _m merge3
tab merge3

save "/Users/taylamccloud/Dropbox/Alena/merged.dta", replace

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/week3.dta"
*0 not matched from using, 2 not matched from master, 100 matched

rename _m merge4
tab merge4

save "/Users/taylamccloud/Dropbox/Alena/merged.dta", replace

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/week4.dta"
*0 not matched from using, 7 not matched from master, 95 matched

rename _m merge5
tab merge5

save "/Users/taylamccloud/Dropbox/Alena/merged.dta", replace

**** ADD FOLLOWUP ****  

//waitlist               

import excel "/Users/taylamccloud/Dropbox/Alena/followup_waitlist.xlsx", sheet("responses") firstrow case(lower)
save "/Users/taylamccloud/Dropbox/Alena/followup_waitlist.dta"

drop a networkid tags

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
tab iambotheredbyblushinginfr
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*no dups
drop dup

rename * *_w6
rename pid_w6 pid

//intervention

import excel "/Users/taylamccloud/Dropbox/Alena/followup_app.xlsx", sheet("responses (1)") firstrow case(lower) clear
save "/Users/taylamccloud/Dropbox/Alena/followup_app.dta"

drop a networkid tags

*spin
tab iamafraidofpeopleinauthori
rename iamafraidofpeopleinauthori spin1
tab iambotheredbyblushinginfr
rename iambotheredbyblushinginfr spin2
rename partiesandsocialeventsscare spin3
rename iavoidtalkingtopeopleidon spin4
rename beingcriticizedscaresmealot spin5
rename iavoiddoingthingsorspeaking spin6
rename sweatinginfrontofpeoplecaus spin7
rename iavoidgoingtoparties spin8
rename iavoidactivitiesinwhichiam spin9
rename talkingtostrangersscaresme spin10
rename iavoidhavingtogivespeeches spin11
rename iwoulddoanythingtoavoidbei spin12
rename heartpalpitationsbothermewhe spin13
rename iamafraidofdoingthingswhen spin14
rename beingembarrassedorlookingstu spin15
rename iavoidspeakingtoanyoneinau spin16
rename tremblingorshakinginfrontof spin17
rename spin* spin*_original

foreach n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 { 
	gen spin`n'=.
	replace spin`n'=0 if spin`n'_original=="Not at all"
	replace spin`n'=1 if spin`n'_original=="A little bit"
	replace spin`n'=2 if spin`n'_original=="Somewhat"
	replace spin`n'=3 if spin`n'_original=="Very much"
	replace spin`n'=4 if spin`n'_original=="Extremely"
	tab spin`n'
}

egen spintot=rowtotal(spin1-spin17)
summ spintot
pwcorr spintot score
rename score spintot_auto

*wsas
tab becauseofmysocialanxietymy
rename becauseofmysocialanxietymy wsas1
summ wsas1

tab t
rename t wsas2
summ wsas2

tab u
rename u wsas3
summ wsas3

tab v 
rename v wsas4
summ wsas4

tab w
rename w wsas5
summ wsas5

egen wsastot=rowtotal(wsas1-wsas5)
summ wsastot

*phq 
rename pleaseindicatehowoftenyouha phq1
rename y phq2
rename z phq3
rename aa phq4
rename ab phq5
rename ac phq6
rename ad phq7
rename ae phq8
rename af phq9
rename phq* phq*_original

foreach n in 1 2 3 4 5 6 7 8 9 {
	gen phq`n'=.
	replace phq`n'=0 if phq`n'_original=="Not at all"
	replace phq`n'=1 if phq`n'_original=="Several days"
	replace phq`n'=2 if phq`n'_original=="More than half the days"
	replace phq`n'=3 if phq`n'_original=="Nearly every day"
	tab phq`n'
}

egen phqtot=rowtotal(phq1-phq9)
summ phqtot

*adverse events
tab haveyouexperiencedanynew
rename haveyouexperiencedanynew advall_original
gen advall=.
replace advall=0 if advall_original=="No"
replace advall=1 if advall_original=="I'm not sure"
replace advall=2 if advall_original=="Yes"
label define adverse 0 "No" 1 "I'm not sure" 2 "Yes"
label values advall adverse
tab advall

tab wearesorrytohearthispleas
rename wearesorrytohearthispleas advqual

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*no dups
drop dup

rename * *_w6
rename pid_w6 pid

*combine followup datasets

use "/Users/taylamccloud/Dropbox/Alena/followup_app.dta", clear
rename startdateutc_w6 startdateutc_w6_1
rename submitdateutc_w6 submitdateutc_w6_1

use "/Users/taylamccloud/Dropbox/Alena/followup_waitlist.dta"
rename startdateutc_w6 startdateutc_w6_0
rename submitdateutc_w6 submitdateutc_w6_0

append using "/Users/taylamccloud/Dropbox/Alena/followup_app.dta", generate(group)

save "/Users/taylamccloud/Dropbox/Alena/followup.dta"

br

tab group
label define group 1 "Intervention" 0 "Waitlist"
label values group group
tab group

*dedup
sort pid
quietly by pid:  gen dup = cond(_N==1,0,_n)
tab dup
*no dups
drop dup

*fix issue with ppt with no pid
tab pid
tab pid, m
replace pid="5b6cd747a1fda800015ff9ba" if missing(pid)


//merge into main file

use "/Users/taylamccloud/Dropbox/Alena/merged.dta"

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/followup.dta"
*0 not matched from using, 12 not matched from master, 90 matched

rename _m merge6
tab merge6

save "/Users/taylamccloud/Dropbox/Alena/merged.dta", replace

//merge into my MASTER file
use "/Users/taylamccloud/Dropbox/Alena/MASTER.dta"

merge 1:1 pid using "/Users/taylamccloud/Dropbox/Alena/followup.dta"
*0 not matched from using, 12 not matched from master, 90 matched

rename _m merge6
tab merge6





