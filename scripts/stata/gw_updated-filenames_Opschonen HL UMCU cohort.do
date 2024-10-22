use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Stata files\Analysebestand_Simone_opgeschoond_Sandra.dta", clear

***gelijk maken van namen van variabelen
rename gebdag dgb
rename gebmnd mgb
rename gebjr jgb
rename geslacht mv
rename diagdag dbg
rename diagmnd mbg
rename diagjr jbg
rename stadium std
rename coddag cod
rename comaand com
rename cojaar coj
rename status vstat
rename roken_prehl rokendia

*rename rtprim rtp
*rename drtprim drtp
*rename mrtprim mrtp
*rename jrtprim jrtp
*rename mantelpr mantelp
*rename omgypr omgyp
*rename lhalspr lhalsp
*rename rhalspr rhalsp
*rename lsuprapr lsuprap
*rename rsuprapr rsuprap
*rename linfrapr linfrap
*rename rinfrapr rinfrap
*rename lokselpr lokselp
*rename rokselpr rokselp
*rename mediaspr mediastp
*rename llongpr llongp
*rename rlongpr rlongp
*rename parapr paraap
*rename miltpr miltp
*rename liliacpr liliacp
*rename riliacpr riliacp
*rename lliespr lliesp
*rename rliespr rliesp
*rename anderpr vanderp
*rename oanderpr nlveldp
*rename ctprim ctp
*rename dctprim dctp
*rename mctprim mctp
*rename jctprim jctp
replace jctp=1987 if jctp==4987
*rename c1ctprim c1ctp
*rename k1ctprim n1ctp
*rename o1ctprim o1ctp
*rename c2ctprim c2ctp
*rename k2ctprim n2ctp
*rename o2ctprim o2ctp
*rename c3ctprim c3ctp
*rename k3ctprim n3ctp
*rename o3ctprim o3ctp
*rename recidief rechdp
*rename drecid1 drechdp
*rename mrecid1 mrechdp
*rename jrecid1 jrechdp
*rename fupbeh brechdp
*rename rtfup rtrp
*rename drtfup drtrp
*rename mrtfup mrtrp
*rename jrtfup jrtrp
*rename mantelfp mantelrp
*rename omgyfp omgyrp
*rename lhalsfp lhalsrp
*rename rhalsfp rhalsrp
*rename lsuprafp lsuprarp
*rename rsuprafp rsuprarp
*rename linfrafp linfrarp
*rename rinfrafp rinfrarp
*rename lokselfp lokselrp
*rename rokselfp rokselrp
*rename mediasfp mediasrp
*rename llongfp llongrp
*rename rlongfp rlongrp
*rename parafp paraarp
*rename miltfp miltrp
*rename liliacfp liliacrp
*rename riliacfp riliacrp
*rename lliesfp lliesrp
*rename rliesfp rliesrp
*rename anderfp vanderrp
*rename oanderfp nlveldrp
*rename opmblz3 opmerk4p
*rename ctfup ctrp
*rename dctfup dctrp
*rename mctfup mctrp
*rename jctfup jctrp
*rename c1ctfup c1ctrp
*rename k1ctfup n1ctrp
*rename o1ctfup o1ctrp
*rename c2ctfup c2ctrp
*rename k2ctfup n2ctrp
*rename o2ctfup o2ctrp
*rename c3ctfup c3ctrp
*rename k3ctfup n3ctrp
*rename o3ctfup o3ctrp
*rename c4ctfup c4ctrp
*rename k4ctfup n4ctrp
*rename o4ctfup o4ctrp
*rename opmblz4 opmerk5p
rename hyperchol_fup hyperchol
rename hyperchol_dg dhyperch
rename hyperchol_mnd mhyperch
rename hyperchol_jr jhyperch
rename diabetes_fup diabetes
rename diab_dg ddiabet
rename diab_mnd mdiabet
rename diab_jr jdiabet
rename hypertens_fup hyperten
rename hypertens_dg dhyperte
rename hypertens_mnd mhyperte
rename hypertens_jr jhyperte
rename hyperthyr_fup hyperthy
rename hyperthyr_dg dhyperth
rename hyperthyr_mnd mhyperth
rename hyperthyr_jr jhyperth
rename hypothyr_fup hypothy
rename hypothyr_dg dhypothy
rename hypothyr_mnd mhypothy
rename hypothyr_jr jhypothy
rename roken_fup rokenfup
rename overweight_prehl overgfup
rename opmblz6 opmerk2

rename tt1_dag s1d
rename tt1_mnd s1m
rename tt1_jr s1j
rename tt1_topo st1
rename tt1_morfo m1
rename tt1_beh1 b1
rename tt2_dag s2d
rename tt2_mnd s2m
rename tt2_jr s2j
rename tt2_topo st2
rename tt2_morfo m2
rename tt2_beh1 b2
rename opmblz8 opmerk7

replace st1=(st1*10)+9 if st1<99&(m1>95903&m1<98993)
replace st2=(st2*10)+9 if st2<99&(m2>95903&m2<98993)

*** controle op tweede tumoren in zkh bestand versus NKR (koppelresultaat)
sort topo st1
destring subloc subloc_2, replace force 
replace s1d=day(incdat) if st1==.&incdat
replace s1m=month(incdat) if st1==.&incdat
replace s1j=year(incdat) if st1==.&incdat
replace m1=(morf*10)+ext if st1==.&incdat
replace b1=1 if (st1==.&incdat)&RT==1&(CT==0)
replace b1=2 if (st1==.&incdat)&CT==1&(RT==0)
replace b1=3 if (st1==.&incdat)&CT==1&RT==1
replace b1=4 if (st1==.&incdat)&b1==.&(HT==1|IT==1)
replace b1=4 if (st1==.&incdat)&b1==.&(HT==0&IT==0&CT==0&RT==0&OK==0)
replace b1=5 if (st1==.&incdat)&b1==.&(OK==1)
replace st1=(topo*10)+subloc if st1==.&incdat
sort b1
browse statusnr s1d-b1 incdat-IT if mdy(s1m, s1d, s1j)==incdat
*** correcties op tweede tumoren, NKR prevaleert!
replace st1=(topo*10)+subloc if statusnr==690380
replace m1=(morf*10)+ext if statusnr==690380
replace b1=2 if statusnr==690380 
replace b1=5 if statusnr==5054520|statusnr==690930|statusnr==860987|statusnr==790457

browse statusnr s1d-b2 incdat-IT_2 if mdy(s1m, s1d, s1j)~=incdat&incdat~=.
replace s1d=day(incdat) if statusnr==840251|statusnr==265718|statusnr==780932|statusnr==5061891|statusnr==941971
replace s1d=day(incdat) if statusnr==841426|statusnr==3063736|statusnr==871506|statusnr==3259661|statusnr==940804
replace s1d=day(incdat) if statusnr==780808|statusnr==790724|statusnr==820903|statusnr==4202542|statusnr==880913
replace s1d=day(incdat) if statusnr==44564|statusnr==8310036|statusnr==770887|statusnr==870757|statusnr==800724
replace s1d=day(incdat) if statusnr==960832|statusnr==1303071|statusnr==781112|statusnr==951141|statusnr==960292
replace s1d=day(incdat) if statusnr==941309|statusnr==881043
replace s1m=month(incdat) if statusnr==841426|statusnr==3063736|statusnr==871506|statusnr==3259661|statusnr==940804
replace s1m=month(incdat) if statusnr==780808|statusnr==790724|statusnr==4202542|statusnr==880913|statusnr==2104671
replace s1m=month(incdat) if statusnr==44564|statusnr==8310036|statusnr==770887|statusnr==800724|statusnr==960832
replace s1m=month(incdat) if statusnr==781112|statusnr==951141|statusnr==960292|statusnr==881043
replace s1j=year(incdat) if statusnr==781112|statusnr==951141|statusnr==881043
replace st1=(topo*10)+subloc if statusnr==3063736|statusnr==790724|statusnr==780932|statusnr==880913|statusnr==44564|statusnr==781112
replace st1=(topo*10)+subloc if statusnr==8310036|statusnr==770887|statusnr==870757|statusnr==800724|statusnr==960832|statusnr==1303071
replace st1=(topo*10)+subloc if statusnr==951141|statusnr==960292|statusnr==941309|statusnr==881043|statusnr==4202542
replace m1=(morf*10)+ext if statusnr==780808|statusnr==790724|statusnr==820903|statusnr==840251|statusnr==780932|statusnr==781112
replace m1=(morf*10)+ext if statusnr==4202542|statusnr==880913|statusnr==2104671|statusnr==770887|statusnr==870757|statusnr==1303071
replace m1=(morf*10)+ext if statusnr==951141|statusnr==941309|statusnr==881043

replace b1=1 if (statusnr==951141|statusnr==781112|statusnr==881043)&RT==1&(CT==0)
replace b1=2 if (statusnr==951141|statusnr==781112|statusnr==881043)&CT==1&(RT==0)
replace b1=3 if (statusnr==951141|statusnr==781112|statusnr==881043)&CT==1&RT==1
replace b1=4 if (statusnr==951141|statusnr==781112|statusnr==881043)&b1==.&(HT==1|IT==1)
replace b1=4 if (statusnr==951141|statusnr==781112|statusnr==881043)&b1==.&(HT==0&IT==0&CT==0&RT==0&OK==0)
replace b1=5 if (statusnr==951141|statusnr==781112|statusnr==881043)&b1==.&(OK==1)

replace s2d=day(incdat_2) if statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917
replace s2m=month(incdat_2) if statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917
replace s2j=year(incdat_2) if statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917
replace m2=(morf_2*10)+ext_2 if statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917
replace b2=1 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&RT_2==1&(CT_2==0)
replace b2=2 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&CT_2==1&(RT_2==0)
replace b2=3 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&CT_2==1&RT_2==1
replace b2=4 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&b2==.&(HT_2==1|IT_2==1)
replace b2=4 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&b2==.&(HT_2==0&IT_2==0&CT_2==0&RT_2==0&OK_2==0)
replace b2=5 if (statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917)&b2==.&(OK_2==1)
replace st2=(topo_2*10)+subloc_2 if statusnr==951141|statusnr==690380|statusnr==800724|statusnr==840251|statusnr==790724|statusnr==2409917

replace s2d=day(incdat) if statusnr==790614
replace s2m=month(incdat) if statusnr==790614
replace s2j=year(incdat) if statusnr==790614
replace m2=(morf*10)+ext if statusnr==790614
replace b2=1 if (statusnr==790614)&RT==1&(CT==0)
replace b2=2 if (statusnr==790614)&CT==1&(RT==0)
replace b2=3 if (statusnr==790614)&CT==1&RT==1
replace b2=4 if (statusnr==790614)&b2==.&(HT==1|IT==1)
replace b2=4 if (statusnr==790614)&b2==.&(HT==0&IT==0&CT==0&RT==0&OK==0)
replace b2=5 if (statusnr==790614)&b2==.&(OK==1)
replace st2=(topo*10)+subloc if statusnr==790614
replace m2=96733 if statusnr==790724

replace s2d=. if  statusnr==690930|statusnr==770887|statusnr==870757|statusnr==4202542|statusnr==5054520
replace s2m=. if  statusnr==690930|statusnr==770887|statusnr==870757|statusnr==4202542|statusnr==5054520
replace s2j=. if  statusnr==690930|statusnr==770887|statusnr==870757|statusnr==4202542|statusnr==5054520
replace b2=. if  statusnr==690930|statusnr==770887|statusnr==870757|statusnr==4202542|statusnr==5054520
replace st2=. if statusnr==5054520
replace m2=. if statusnr==5054520
replace b1=5 if statusnr==770887|statusnr==870757|statusnr==4202542

sort b2
browse statusnr s1d-b2 incdat-IT_2 if incdat_2~=.
browse statusnr s1d-b2 incdat-IT_2 if st2~=.

*** check op event status in database huid en benigne aandoeningen niet als event?
sort st1 st2
browse if st1~=.
browse statusnr st1 st2 event if st1~=.
replace event=. if statusnr==940121

***omcoderen doodsoorzaken als bekend
browse statusnr doz deathcause1 deathcause2 st1 st2 hvz_other if doz~=""|deathcause1~=""|deathcause2~=""
replace doz="I46.1" if statusnr==951277
replace doz="C81.9" if statusnr==950249|statusnr==941971|statusnr==911301|statusnr==2590827|statusnr==8020884|statusnr==670680|statusnr==657916|statusnr==1555755
replace doz="C20.9" if statusnr==4063637
replace doz="C25.9" if statusnr==820990
replace doz="C18.9" if statusnr==3063561
replace doz="I40.9" if statusnr==990453
replace doz="A40.3" if statusnr==841426
replace doz="R06.8" if statusnr==5061891
replace doz="J18.9" if statusnr==861235|statusnr==5324248
replace doz="K56.6" if statusnr==4065586
replace doz="I64" if statusnr==3678033


*** duplicaat records in de database?
duplicates tag dgb mgb jgb mv, gen(dubbel)
tab dubbel
sort dgb mgb jgb mv
browse if dubbel==1
drop dubbel
*** 6 potentiele dubbelen, echter ze zijn niet dubbel op basis van visuele inspectie

duplicates tag statusnr, gen(dubbel)
tab dubbel
sort statusnr dgb mgb jgb mv
browse if dubbel==1
drop dubbel

*** verschillende datums aanmaken
gen birthdat=mdy(mgb, dgb, jgb)
format birthdat  %dD-N-CY
label var birthdat "geboortedatum"

gen entry=mdy(mbg, dbg, jbg)
format entry %dD-N-CY
label var entry "diagnosedatum HL"

gen agetx=(entry-birthdat)/365.25
label var agetx "leeftijd diagnose HL"
keep if (agetx>=0&agetx<=51)

***aantal jaren follow-up berekenen
gen lmcdat=mdy(mlmc, dlmc, jlmc)
format lmcdat  %dD-N-CY
label var lmcdat "datum laatste medische contact"

gen lvsdat=mdy(mlvs, dlvs, jlvs)
format lvsdat  %dD-N-CY
label var lvsdat "datum laatste vitale status"

replace fupdat=lvsdat if (lmcdat==.&lvsdat~=.)
replace fupdat=lvsdat if (lvsdat~=.&vstat==2)

gen total_fupyrs=(fupdat-entry)/365.25
drop if total_fupyrs<5

***RT+CT datum aanmaken en vergelijken met diagnosedatum om te kijken of het een primaire patient in het UMCU betreft
gen RT_dat=mdy(mrtp, drtp, jrtp)
format RT_dat  %dD-N-CY
label var RT_dat "RT_datum primair"

gen CT_dat=mdy(mctp, dctp, jctp)
format CT_dat  %dD-N-CY
label var CT_dat "CT_datum primair"

gen RT_prim_pt=(RT_dat-entry)/365.25
gen CT_prim_pt=(CT_dat-entry)/365.25

capture drop CT_UMCU
capture drop RT_UMCU
gen RT_UMCU=0
replace RT_UMCU=1 if (zhrtprim~=1&zhrtprim~=.)
replace RT_UMCU=. if (RT_dat==.&zhrtprim==.)
gen CT_UMCU=0
replace CT_UMCU=1 if (z1ctprim~=1&z1ctprim~=.)
replace CT_UMCU=. if (CT_dat==.&z1ctprim==.)

*** selectie op primair behandeld in UMCU (voorHL dus primair of reciedief HL, niet verwezen voor tweede tumor?)
gen zhprimther=0
replace zhprimther=31 if zhrtprim==31|z1ctprim==31|z2ctprim==31|z3ctprim==31
gen zhrecther=0
replace zhrecther=31 if zhrtfup==31|z1ctfup==31|z2ctfup==31|z3ctfup==31
sort zhprimther zhrecther
*** voor wat patienten onduidelijk of in UMCU daadwerkelijk behandeld
*** voor 46 patienten GEEN bewijs dat ze in UMCU zijn behandeld RT en CT zeker elders gegeven.
*** voordeel van twijfel als onbekend in welk ziekenhuis pat is behandeld
replace zhprimther=31 if zhrtprim==999|z1ctprim==999|z2ctprim==999|z3ctprim==999
replace zhrecther=31 if zhrtfup==999|z1ctfup==999|z2ctfup==999|z3ctfup==999
replace zhprimther=31 if zhrtprim==99|z1ctprim==99|z2ctprim==99|z3ctprim==99
replace zhrecther=31 if zhrtfup==99|z1ctfup==99|z2ctfup==99|z3ctfup==99
replace zhprimther=31 if zhrtprim==88|z1ctprim==88|z2ctprim==88|z3ctprim==88
replace zhrecther=31 if zhrtfup==88|z1ctfup==88|z2ctfup==88|z3ctfup==88
sort zhprimther zhrecther
*** voor 30 patienten GEEN bewijs dat ze in UMCU zijn behandeld RT en CT zeker elders gegeven.
*** echter geen van deze patienten heeft een tweede tumor, dus geen aanwijzing voor bias.
*** Ik laat het maar zo 

*** selectie diagnosejaren tussen 1965-2000
drop if (jbg<1965|jbg>2000)
*** 74 observations deleted

*** selectie op leeftijd >=15 en jonger dan 51 
drop if age_diagnosis<15|age_diagnosis>51
*** 19 observations deleted

sort statusnr
save "E:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Stata files\UMCU opgeschoond lft 15-51.dta", replace

use "E:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Stata files\UMCU opgeschoond lft 15-51.dta", clear

**** recreeren behandelings variabelen van Marieke

**** eerst eventueel missende behandelingen oplossen adhv NKR koppeling

gen rtsuprap=.
replace rtsuprap=0 if (rtsuprap==.|rtsuprap==0|rtsuprap==1)&rtp==2	
replace rtsuprap=1 if (rtsuprap==.|rtsuprap==0)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1|rhalsp==1|lsuprap==1|rsuprap==1|linfrap==1|rinfrap==1|lokselp==1|rokselp==1|mediastp==1|llongp==1|rlongp==1)
replace rtsuprap=2 if (rtsuprap==.|rtsuprap==0|rtsuprap==1)&(mantelp==1)
replace rtsuprap=2 if (rtsuprap==.|rtsuprap==0|rtsuprap==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1&rhalsp==1)&(lsuprap==1&rsuprap==1)&(linfrap==1&rinfrap==1)&(lokselp==1&rokselp==1)&(mediastp==1)
replace rtsuprap=2 if (rtsuprap==.|rtsuprap==0|rtsuprap==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1&rhalsp==1)&(lsuprap==1&rsuprap==1)&(lokselp==1&rokselp==1)&(mediastp==1)
replace rtsuprap=1 if (rtsuprap==2&mantelp==2|mantelp==.)&(lhalsp==1|rhalsp==1|lsuprap==1|rsuprap==1|linfrap==1|rinfrap==1|lokselp==1|rokselp==1|mediastp==1|llongp==1|rlongp==1)
replace rtsuprap=9 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==1)&(vanderp==1)&(nlveldp==" onbekend  welke velden")
replace rtsuprap=0 if rtsuprap==.&(omgyp==1|paraap==1|miltp==1|liliacp==1|riliacp==1|lliesp==1|rliesp==1)
replace rtsuprap=0 if rtp==1&rtsuprap==.&(vanderp==1)&(nlveldp~="")
replace rtsuprap=9 if (nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&((mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.))
replace rtsuprap=9 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==1|rtsuprap==2)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.)
replace rtsuprap=9 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==1|rtsuprap==2)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==1)&(nlveldp=="")
replace rtsuprap=1 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==9)&(nlveldp=="Hals bdz v.h. mastoid tot aan de clavicule larnyx en myelum afgeblokt."|nlveldp=="Parotis regio rechts"|nlveldp=="Waldeyer"|nlveldp=="cervicomediastinaal"|nlveldp=="hilus long re"|nlveldp=="ring van Waldeyer"|nlveldp=="supra-diagfragmaal"|nlveldp=="beide hili"|nlveldp=="Ook groot deel van de farynx"|nlveldp=="beide longhili"|nlveldp=="borstbad"|nlveldp=="hart"|nlveldp=="li hilus"|nlveldp=="li hilus en restafwijking ventraal paracardiaal"|nlveldp=="li- hilus"|nlveldp=="long hilus re"|nlveldp=="ring van Waldeyer"|nlveldp=="th5 t/m th10"|nlveldp=="zeer hoog occipitaal")
replace rtsuprap=0 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==9)&(substr(nlveldp,2,7)=="buikbad"|nlveldp=="L4"|nlveldp=="lumbaal L2 t/m L5")
replace rtsuprap=1 if rtp==1&(rtsuprap==.|rtsuprap==0|rtsuprap==9)&(nlveldp=="ring van Waldeyer"|nlveldp=="re sulcus bicipitalis"|nlveldp=="thoraxwand li"|nlveldp=="TH 5 t/m 10"|nlveldp=="th.4 t/m 10")
replace rtsuprap=2 if statusnr==981663
label define LABL 0"no suprart" 1"incomplete mf" 2"full mf" 9"RT, but field unknown", modify
label val rtsuprap LABL
label var rtsuprap "RT above diaphragm" 		
tab rtsuprap rtp, m
tab rtsuprap, m	
sort rtsuprap
browse rtsuprap rtp mantelp-nlveldp
sort rtp rtsuprap mantelrp omgyrp

gen rtmidp=.
replace rtmidp=0 if rtmidp==.&rtp==2
replace rtmidp=1 if (rtmidp==.|rtmidp==0)&(paraap==1|miltp==1|omgyp==1)
replace rtmidp=0 if rtmidp==.&(mantelp==1|lhalsp==1|rhalsp==1|lsuprap==1|rsuprap==1|linfrap==1|rinfrap==1|lokselp==1|rokselp==1|mediastp==1|llongp==1|rlongp==1|liliacp==1|riliacp==1|lliesp==1|rliesp==1)
replace rtmidp=9 if (nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&((mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.))
replace rtmidp=9 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==1)&(vanderp==1)&(nlveldp==" onbekend  welke velden")
replace rtmidp=0 if rtp==1&rtmidp==.&(vanderp==1)&(nlveldp~="")
replace rtmidp=9 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.)
replace rtmidp=9 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==1)&(nlveldp=="")
replace rtmidp=1 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==9)&(substr(nlveldp,2,7)=="buikbad"|nlveldp=="HKINREV:intrathoracaal+paraaortaal + milt"|nlveldp=="L1 t/m L3"|nlveldp=="L4"|nlveldp=="MILTSTEEL"|nlveldp=="Miltsteel"|nlveldp=="lumbaal L2 t/m L5"|nlveldp=="milt hlus"|nlveldp=="milthilis"|nlveldp=="milthilus"|nlveldp=="milthilus (op krt:milt"|nlveldp=="milthilus en bovenbuik"|nlveldp=="milthilus en lever hilus"|nlveldp=="milthilus, re heup C"|nlveldp=="miltssteel"|nlveldp=="miltsteel"|nlveldp=="submentaal, milthilus"|nlveldp=="submentaal, milthilus, kleine bekken")
replace rtmidp=0 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==9)&(nlveldp=="Hals bdz v.h. mastoid tot aan de clavicule larnyx en myelum afgeblokt."|nlveldp=="Parotis regio rechts"|nlveldp=="Waldeyer"|nlveldp=="cervicomediastinaal"|nlveldp=="hilus long re"|nlveldp=="ring van Waldeyer"|nlveldp=="supra-diagfragmaal")
replace rtmidp=0 if rtp==1&(rtmidp==.|rtmidp==0|rtmidp==9)&(nlveldp=="re sulcus bicipitalis"|nlveldp=="thoraxwand li"|nlveldp=="TH 5 t/m 10"|nlveldp=="th.4 t/m 10")
label define LABM 0"no mid-bodyrt" 1"mid-body rt" 9"RT, but field unknown", modify
label val rtmidp LABM
label var rtmidp "RT to Para-aortal nodes/spleen" 
tab rtmidp, m
sort rtmidp rtsuprap
browse rtmidp rtsuprap rtp mantelp-nlveldp
sort rtp rtmidp mantelrp omgyrp paraap vanderp

gen rtinfrap=.
replace rtinfrap=0 if rtinfrap==.&rtp==2
replace rtinfrap=1 if (rtinfrap==.|rtinfrap==0)&(omgyp==1|liliacp==1|riliacp==1|lliesp==1|rliesp==1)
replace rtinfrap=1 if (rtinfrap==.|rtinfrap==0)&(nlveldp=="HKINREV:intrathoracaal+paraaortaal + milt"|nlveldp=="L1 t/m L3"|nlveldp=="L4"|nlveldp=="MILTSTEEL"|nlveldp=="Miltsteel"|nlveldp=="lumbaal L2 t/m L5"|nlveldp=="milt hlus"|nlveldp=="milthilis"|nlveldp=="milthilus"|nlveldp=="milthilus (op krt:milt"|nlveldp=="miltssteel"|nlveldp=="miltsteel"|nlveldp=="submentaal, milthilus")&(omgyp==1|liliacp==1|riliacp==1|lliesp==1|rliesp==1)
replace rtinfrap=0 if rtinfrap==.&(mantelp==1|lhalsp==1|rhalsp==1|lsuprap==1|rsuprap==1|linfrap==1|rinfrap==1|lokselp==1|rokselp==1|mediastp==1|llongp==1|rlongp==1|paraap==1|miltp==1)
replace rtinfrap=9 if (nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&((mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.))
replace rtinfrap=9 if rtp==1&(rtinfrap==.|rtinfrap==0|rtinfrap==1)&(vanderp==1)&(nlveldp==" onbekend  welke velden")
replace rtinfrap=0 if rtp==1&rtinfrap==.&(vanderp==1)&(nlveldp~="")
replace rtinfrap=9 if rtp==1&(rtinfrap==.|rtinfrap==0)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.)
replace rtinfrap=9 if rtp==1&(rtinfrap==.|rtinfrap==0)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==1)&(nlveldp=="")
replace rtinfrap=0 if rtp==1&(rtinfrap==.|rtinfrap==0|rtinfrap==9)&(nlveldp=="Hals bdz v.h. mastoid tot aan de clavicule larnyx en myelum afgeblokt."|nlveldp=="Parotis regio rechts"|nlveldp=="Waldeyer"|nlveldp=="cervicomediastinaal"|nlveldp=="hilus long re"|nlveldp=="ring van Waldeyer"|nlveldp=="supra-diagfragmaal")
replace rtinfrap=0 if rtp==1&(rtinfrap==.|rtinfrap==0|rtinfrap==9)&(nlveldp=="re sulcus bicipitalis"|nlveldp=="thoraxwand li"|nlveldp=="TH 5 t/m 10"|nlveldp=="th.4 t/m 10")
replace rtinfrap=1 if rtp==1&(rtinfrap==.|rtinfrap==0|rtinfrap==9)&(substr(nlveldp,2,7)=="buikbad"|nlveldp=="milthilus en lever hilus"|nlveldp=="milthilus, re heup C"|nlveldp=="submentaal, milthilus, kleine bekken"|nlveldp=="intrathoracaal, pelvic, submentaal")
label define LABN 0"no infrart" 1"rtinfra" 9"RT, but field unknown", modify
label val rtinfrap LABN
label var rtinfrap "RT below diaphragm; excludes RT limited to para-aortal/spleen" 
tab rtinfrap, m
sort rtinfrap rtmidp
browse rtinfrap rtmidp rtp mantelp-nlveldp
sort rtp rtinfrap mantelrp omgyrp paraap vanderp

gen rtneckp=.
replace rtneckp=0 if rtneckp==.&rtp==2
replace rtneckp=1 if (rtneckp==.|rtneckp==0)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==1|rsuprap==1)
replace rtneckp=2 if (rtneckp==.|rtneckp==0|rtneckp==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1|rhalsp==1)
replace rtneckp=3 if (rtneckp==.|rtneckp==0|rtneckp==1|rtneckp==2)&(mantelp==1)
replace rtneckp=3 if (rtneckp==.|rtneckp==0|rtneckp==1|rtneckp==2)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1&rhalsp==1)&(lsuprap==1&lsuprap==1)&(linfrap==1&rinfrap==1)&(lokselp==1&rokselp==1)&(mediastp==1)
replace rtneckp=3 if (rtneckp==.|rtneckp==0|rtneckp==1|rtneckp==2)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==1&rhalsp==1)&(lsuprap==1&lsuprap==1)&(lokselp==1&rokselp==1)&(mediastp==1)
replace rtneckp=1 if (rtneckp==3)&(mantelp==2|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==1|rsuprap==1)
replace rtneckp=2 if (rtneckp==3)&(mantelp==2|mantelp==.)&(lhalsp==1|rhalsp==1)
replace rtneckp=0 if rtp==1&rtneckp==.&(linfrap==1|rinfrap==1|lokselp==1|rokselp==1|mediastp==1|llongp==1|rlongp==1|omgyp==1|paraap==1|miltp==1|liliacp==1|riliacp==1|lliesp==1|rliesp==1)
replace rtneckp=9 if rtp==1&(rtneckp==.|rtneckp==0|rtneckp==1)&(vanderp==1)&(nlveldp==" onbekend  welke velden")
replace rtneckp=0 if rtp==1&(rtneckp==.|rtneckp==9)&(vanderp==1)&(nlveldp~="")
replace rtneckp=9 if (nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="klopt"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&((mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.))
replace rtneckp=9 if rtp==1&(rtneckp==.|rtneckp==0|rtneckp==9|rtneckp==1|rtneckp==2|rtneckp==3)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.)
replace rtneckp=9 if rtp==1&(rtneckp==.|rtneckp==0|rtneckp==9|rtneckp==1|rtneckp==2|rtneckp==3)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==1)&(nlveldp=="")
replace rtneckp=0 if rtp==1&(rtneckp==.|rtneckp==9)&(nlveldp=="Hals bdz v.h. mastoid tot aan de clavicule larnyx en myelum afgeblokt."|nlveldp=="ring van Waldeyer"|nlveldp=="re sulcus bicipitalis"|nlveldp=="thoraxwand li"|nlveldp=="TH 5 t/m 10"|nlveldp=="th.4 t/m 10"|nlveldp=="Parotis regio rechts"|nlveldp=="Waldeyer"|nlveldp=="hilus long re"|nlveldp=="ring van Waldeyer"|nlveldp=="supra-diagfragmaal"|substr(nlveldp,2,7)=="buikbad"|nlveldp=="L4"|nlveldp=="lumbaal L2 t/m L5"|nlveldp=="re sulcus bicipitalis"|substr(nlveldp,2,7)=="buikbad")
replace rtneckp=2 if rtp==1&(rtneckp==.|rtneckp==0|rtneckp==1|rtneckp==9)&(nlveldp=="cervicomediastinaal"|nlveldp=="cervicaal L")
label define LABO 0"no neckrt" 1"supraclav only" 2"neckrt" 3"full mf" 9"RT, but field unknown", modify
label val rtneckp LABO
label var rtneckp "RT to the neck" 		
tab rtneckp rtp, m
tab rtneckp, m	
sort rtneckp rtsuprap
browse rtneckp rtsuprap rtp mantelp-nlveldp
sort rtp rtneckp rtsuprap mantelrp omgyrp lhalsp rhalsp

gen rtcatp=.
replace rtcatp=0 if rtp==2
replace rtcatp=1 if rtsuprap==1
replace rtcatp=3 if rtsuprap==2
replace rtcatp=5 if rtmidp==1|rtinfrap==1
replace rtcatp=2 if rtsuprap==1&(rtmidp==1|rtinfrap==1)
replace rtcatp=4 if rtsuprap==2&(rtmidp==1|rtinfrap==1)
replace rtcatp=9 if (nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="klopt"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)
replace rtcatp=9 if rtp==1&(rtcatp==.|rtcatp==0|rtcatp==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.)
replace rtcatp=9 if rtp==1&(rtcatp==.|rtcatp==0|rtcatp==1)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==1)&(nlveldp=="")
label define LABP 0 "nort" 1"incomplete mf supra only" 2"incomplete mf supra+infra/mid-body rt" 3"full mf only" 4"full mf+infra/mid-body rt" 5"infra/mid-body rt only" 6"other rt" 9"RT, but field unknown", modify
label val rtcatp LABP
label var rtcatp "prim. RT categorised" 
tab rtcatp, m
sort rtcatp	nlveldp
browse rtcatp rtsuprap rtmidp rtinfrap rtneckp rtp mantelp-nlveldp

gen rtmedp=.
label var rtmedp "RT to mediastinum"
replace rtmedp=0 if rtp==2
replace rtmedp=1 if rtsuprap==2|mediastp==1
replace rtmedp=1 if nlveldp=="Hals bdz v.h. mastoid tot aan de clavicule larnyx en myelum afgeblokt"|nlveldp=="arcus aorta"|nlveldp=="bovenste gedeelte medistinaal"|nlveldp=="cervicomediastinaal"
replace rtmedp=0 if rtmedp~=1
replace rtmedp=9 if rtsuprap==9
replace rtmedp=. if rtsuprap==.		
label define rtmedp 0"no mediastinal RT" 1"mediastinal RT" 9"RT, but field unknown"
label val rtmedp rtmedp
sort rtmedp nlveldp rtsuprap
browse rtmedp rtsuprap rtneckp rtp mantelp-nlveldp
tab rtsuprap rtmedp,m


**** AANMAKEN CHEMOTHERAPIECATEGORIEN PRIMAIRE THERAPIE OP BASIS VAN PROCARBAZINE
sort ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp 
browse statusnr ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp 
replace c1ctp=81 if statusnr==990149
gen ctcat2p=.
replace ctcat2p=0 if ctcat2p==.&(ctp==0|ctp==2)
replace ctcat2p=1 if (ctcat2p==.|ctcat2p==0)&(c1ctp==2|c1ctp==3|c1ctp==33|c1ctp==47|c1ctp==48|c1ctp==80|c1ctp==83)
replace ctcat2p=1 if (ctcat2p==.|ctcat2p==0)&(c2ctp==2|c2ctp==3|c2ctp==33|c2ctp==47|c2ctp==48|c2ctp==80|c2ctp==83)
replace ctcat2p=1 if (ctcat2p==.|ctcat2p==0)&(c3ctp==2|c3ctp==3|c3ctp==33|c3ctp==47|c3ctp==48|c3ctp==80|c3ctp==83)
replace ctcat2p=2 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(c1ctp==8|c1ctp==11|c1ctp==12|c1ctp==21|c1ctp==22|c1ctp==23|c1ctp==30|c1ctp==31|c1ctp==41|c1ctp==49|c1ctp==50|c1ctp==51|c1ctp==57|c1ctp==59|c1ctp==60|c1ctp==64|c1ctp==67|c1ctp==70|c1ctp==85|c1ctp==87|c1ctp==88|c1ctp==90|c1ctp==92|c1ctp==99|c1ctp==108|c1ctp==109|c1ctp==110|c1ctp==112) 
replace ctcat2p=2 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(c2ctp==8|c2ctp==11|c2ctp==12|c2ctp==21|c2ctp==22|c2ctp==23|c2ctp==30|c2ctp==31|c2ctp==41|c2ctp==49|c2ctp==50|c2ctp==51|c2ctp==57|c2ctp==59|c2ctp==60|c2ctp==64|c2ctp==67|c2ctp==70|c2ctp==85|c2ctp==87|c2ctp==88|c2ctp==90|c2ctp==92|c2ctp==99|c2ctp==108|c2ctp==109|c2ctp==110|c2ctp==112)
replace ctcat2p=2 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(c3ctp==8|c3ctp==11|c3ctp==12|c3ctp==21|c3ctp==22|c3ctp==23|c3ctp==30|c3ctp==31|c3ctp==41|c3ctp==49|c3ctp==50|c3ctp==51|c3ctp==57|c3ctp==59|c3ctp==60|c3ctp==64|c3ctp==67|c3ctp==70|c3ctp==85|c3ctp==87|c3ctp==88|c3ctp==90|c3ctp==92|c3ctp==99|c3ctp==108|c3ctp==109|c3ctp==110|c3ctp==112) 
replace ctcat2p=9 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2)&(c1ctp==29|c1ctp==40|c1ctp==42|c1ctp==44|c1ctp==45|c1ctp==54|c1ctp==58|c1ctp==61|c1ctp==62|c1ctp==63|c1ctp==66|c1ctp==67|c1ctp==68|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==81|c1ctp==82|c1ctp==91|c1ctp==94|c1ctp==96|c1ctp==98|c1ctp==100|c1ctp==101|c1ctp==103|c1ctp==104|c1ctp==111|c1ctp==611|c1ctp==612|c1ctp==613) 
replace ctcat2p=9 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2)&(c2ctp==29|c2ctp==40|c2ctp==42|c2ctp==44|c2ctp==45|c2ctp==54|c2ctp==58|c2ctp==61|c2ctp==62|c2ctp==63|c2ctp==66|c2ctp==67|c2ctp==68|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==81|c3ctp==82|c2ctp==91|c2ctp==94|c2ctp==96|c2ctp==98|c2ctp==100|c2ctp==101|c2ctp==103|c2ctp==104|c2ctp==111|c2ctp==611|c2ctp==612|c2ctp==613)
replace ctcat2p=9 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2)&(c3ctp==29|c3ctp==40|c3ctp==42|c3ctp==44|c3ctp==45|c3ctp==54|c3ctp==58|c3ctp==61|c3ctp==62|c3ctp==63|c3ctp==66|c3ctp==67|c3ctp==68|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==81|c3ctp==82|c3ctp==91|c3ctp==94|c3ctp==96|c3ctp==98|c3ctp==100|c3ctp==101|c3ctp==103|c3ctp==104|c3ctp==111|c3ctp==611|c3ctp==612|c3ctp==613)
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c1ctp==29|c1ctp==42|c1ctp==45|c1ctp==61|c1ctp==66|c1ctp==68|c1ctp==81|c1ctp==82|c1ctp==91|c1ctp==94|c1ctp==96|c1ctp==98|c1ctp==100|c1ctp==103|c1ctp==104|c1ctp==111)&(n1ctp<=12))
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c2ctp==29|c2ctp==42|c2ctp==45|c2ctp==61|c2ctp==66|c2ctp==68|c2ctp==81|c2ctp==82|c2ctp==91|c2ctp==94|c2ctp==96|c2ctp==98|c2ctp==100|c2ctp==103|c2ctp==104|c2ctp==111)&(n2ctp<=12))
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c3ctp==29|c3ctp==42|c3ctp==45|c3ctp==61|c3ctp==66|c3ctp==68|c3ctp==81|c3ctp==82|c3ctp==91|c3ctp==94|c3ctp==96|c3ctp==98|c3ctp==100|c3ctp==103|c3ctp==104|c3ctp==111)&(n3ctp<=12))
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c1ctp==40|c1ctp==44|c1ctp==54|c1ctp==58|c1ctp==62|c1ctp==63|c1ctp==67|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==101|c1ctp==113|c1ctp==114|c1ctp==611|c1ctp==612|c1ctp==613)&(n1ctp<=6))
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c2ctp==40|c2ctp==44|c2ctp==54|c2ctp==58|c2ctp==62|c2ctp==63|c2ctp==67|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==101|c2ctp==113|c2ctp==114|c2ctp==611|c2ctp==612|c2ctp==613)&(n2ctp<=6))
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==9)&((c3ctp==40|c3ctp==44|c3ctp==54|c3ctp==58|c3ctp==62|c3ctp==63|c3ctp==67|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==101|c3ctp==113|c3ctp==114|c3ctp==611|c3ctp==612|c3ctp==613)&(n3ctp<=6))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c1ctp==29|c1ctp==42|c1ctp==45|c1ctp==61|c1ctp==66|c1ctp==68|c1ctp==81|c1ctp==82|c1ctp==94|c1ctp==96|c1ctp==98|c1ctp==100|c1ctp==103|c1ctp==104|c1ctp==111|c1ctp==611|c1ctp==612|c1ctp==613)&(n1ctp>12&(n1ctp~=88&n1ctp~=99&n1ctp~=999&n1ctp~=.)))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c2ctp==29|c2ctp==42|c2ctp==45|c2ctp==61|c2ctp==66|c2ctp==68|c2ctp==81|c2ctp==82|c2ctp==94|c2ctp==96|c2ctp==98|c2ctp==100|c2ctp==103|c2ctp==104|c2ctp==111|c2ctp==611|c2ctp==612|c2ctp==613)&(n2ctp>12&(n2ctp~=88&n2ctp~=99&n2ctp~=999&n2ctp~=.)))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c3ctp==29|c3ctp==42|c3ctp==45|c3ctp==61|c3ctp==66|c3ctp==68|c3ctp==81|c3ctp==82|c3ctp==94|c3ctp==96|c3ctp==98|c3ctp==100|c3ctp==103|c3ctp==104|c3ctp==111|c3ctp==611|c3ctp==612|c3ctp==613)&(n3ctp>12&(n3ctp~=88&n3ctp~=99&n3ctp~=999&n3ctp~=.)))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c1ctp==40|c1ctp==44|c1ctp==54|c1ctp==58|c1ctp==62|c1ctp==63|c1ctp==67|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==91|c1ctp==101|c1ctp==113|c1ctp==114)&(n1ctp>6&(n1ctp~=88&n1ctp~=99&n1ctp~=999&n1ctp~=.)))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c2ctp==40|c2ctp==44|c2ctp==54|c2ctp==58|c2ctp==62|c2ctp==63|c2ctp==67|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==91|c2ctp==101|c2ctp==113|c2ctp==114)&(n2ctp>6&(n2ctp~=88&n2ctp~=99&n2ctp~=999&n2ctp~=.)))
replace ctcat2p=4 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==2|ctcat2p==3|ctcat2p==9)&((c3ctp==40|c3ctp==44|c3ctp==54|c3ctp==58|c3ctp==62|c3ctp==63|c3ctp==67|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==91|c3ctp==101|c3ctp==113|c3ctp==114)&(n3ctp>6&(n3ctp~=88&n3ctp~=99&n3ctp~=999&n3ctp~=.)))
replace ctcat2p=2 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(o1ctp=="cisp+doxo+bleo+cyta+etop+vinc+pred")
replace ctcat2p=2 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(o1ctp=="CHOP"|o1ctp=="CHOP/Mitoxanthrone"|o1ctp=="CNOP"|o1ctp=="CAVmp-BV"|o1ctp=="MACOP-B")
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==9)&((c1ctp==110|c1ctp==111|c1ctp==12)&(c2ctp==58)&(c3ctp==.))|(o1ctp=="2*OEPA/2-4*COPP DAL-HD-90"|o1ctp=="2*OPPA/2-4*COPP DAL-HD-90")
replace ctcat2p=3 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==9)&((c1ctp==81)&(o1ctp=="6 kuren of meer"))
replace ctcat2p=99 if (ctcat2p==.|ctcat2p==0|ctcat2p==1)&(o1ctp=="other, spec"|o1ctp=="overige chemo")
replace ctcat2p=99 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==9)&(c1ctp==999&c2ctp==.)
replace ctcat2p=99 if (ctcat2p==.|ctcat2p==0|ctcat2p==1|ctcat2p==9)&(c1ctp==999&c2ctp==109)
replace ctcat2p=99 if (ctcat2p==.|ctcat2p==0)&((ctp==1&c1ctp==999)|(ctp==1&c1ctp==.))
label define LABU 0"no ct" 1"non-alkylating ct only" 2"alkylating ct without procarbazine" 3"alkylating ct with <=8.4 g/m2 procarbazine" 4"alkylating ct with >8.4 g/m2 procarbazine" 9"alkylating CT with procarbazine, amount unknown" 99"CT, but type unknown", modify
label val ctcat2p LABU
sort ctcat2p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp
browse statusnr ctcat2p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp o2ctp o3ctp
*** een paar corrrecties op chemocategorien 
replace ctcat2p=1 if statusnr==5061891
replace ctcat2p=2 if statusnr==690047|statusnr==690380|statusnr==690315|statusnr==4161516|statusnr==73044|statusnr==950792|statusnr==730449
replace ctcat2p=3 if statusnr==2907721|statusnr==700328|statusnr==9394043|statusnr==790834
replace ctcat2p=4 if statusnr==6639750|statusnr==731019|statusnr==9183169|statusnr==851593
replace ctcat2p=9 if statusnr==840589|statusnr==730975|statusnr==950249|statusnr==790614|statusnr==7856245
replace ctcat2p=99 if statusnr==891243|statusnr==890053
tab c1ctp ctcat2p, m

format ctcat2p %42.0g
gen ctcatp=ctcat2p
format ctcatp %42.0g
label define LABV 0"no ct" 1"non-alkylating ct only" 2"alkylating ct without procarbazine" 3"alkylating ct with <=4.2 g/m2 procarbazine" 4"alkylating ct with 4.2-8.4 g/m2 procarbazine" 5"alkylating ct with >8.4 g/m2 procarbazine" 9"alkylating CT with procarbazine, amount unknown" 99"CT, but type unknown", modify
label val ctcatp LABV
sort ctcat2p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp
browse statusnr ctcatp ctcat2p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp o2ctp o3ctp
replace ctcatp=ctcat2p
replace ctcatp=5 if ctcatp==4

replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c1ctp==29|c1ctp==42|c1ctp==45|c1ctp==66|c1ctp==68|c1ctp==81|c1ctp==82|c1ctp==91|c1ctp==94|c1ctp==96|c1ctp==98|c1ctp==100|c1ctp==103|c1ctp==104|c1ctp==111)&(n1ctp<=6))
replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c2ctp==29|c2ctp==42|c2ctp==45|c2ctp==66|c2ctp==68|c2ctp==81|c2ctp==82|c2ctp==91|c2ctp==94|c2ctp==96|c2ctp==98|c2ctp==100|c2ctp==103|c2ctp==104|c2ctp==111)&(n2ctp<=6))
replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c3ctp==29|c3ctp==42|c3ctp==45|c3ctp==66|c3ctp==68|c3ctp==81|c3ctp==82|c3ctp==91|c3ctp==94|c3ctp==96|c3ctp==98|c3ctp==100|c3ctp==103|c3ctp==104|c3ctp==111)&(n3ctp<=6))
replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c1ctp==40|c1ctp==44|c1ctp==54|c1ctp==58|c1ctp==61|c1ctp==62|c1ctp==63|c1ctp==67|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==101|c1ctp==113|c1ctp==114|c1ctp==611|c1ctp==612|c1ctp==613)&(n1ctp<=3))
replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c2ctp==40|c2ctp==44|c2ctp==54|c2ctp==58|c2ctp==61|c2ctp==62|c2ctp==63|c2ctp==67|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==101|c2ctp==113|c2ctp==114|c2ctp==611|c2ctp==612|c2ctp==613)&(n2ctp<=3))
replace ctcatp=3 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==9)&((c3ctp==40|c3ctp==44|c3ctp==54|c3ctp==58|c3ctp==61|c3ctp==62|c3ctp==63|c3ctp==67|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==101|c3ctp==113|c3ctp==114|c3ctp==611|c3ctp==612|c3ctp==613)&(n3ctp<=3))

replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c1ctp==29|c1ctp==42|c1ctp==45|c1ctp==66|c1ctp==68|c1ctp==81|c1ctp==82|c1ctp==91|c1ctp==94|c1ctp==96|c1ctp==98|c1ctp==100|c1ctp==103|c1ctp==104|c1ctp==111)&(n1ctp>6&n1ctp<=12))
replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c2ctp==29|c2ctp==42|c2ctp==45|c2ctp==66|c2ctp==68|c2ctp==81|c2ctp==82|c2ctp==91|c2ctp==94|c2ctp==96|c2ctp==98|c2ctp==100|c2ctp==103|c2ctp==104|c2ctp==111)&(n2ctp>6&n2ctp<=12))
replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c3ctp==29|c3ctp==42|c3ctp==45|c3ctp==66|c3ctp==68|c3ctp==81|c3ctp==82|c3ctp==91|c3ctp==94|c3ctp==96|c3ctp==98|c3ctp==100|c3ctp==103|c3ctp==104|c3ctp==111)&(n3ctp>6&n3ctp<=12))
replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c1ctp==40|c1ctp==44|c1ctp==54|c1ctp==58|c1ctp==61|c1ctp==62|c1ctp==63|c1ctp==67|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==101|c1ctp==113|c1ctp==114|c1ctp==611|c1ctp==612|c1ctp==613)&(n1ctp>3&n1ctp<=6))
replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c2ctp==40|c2ctp==44|c2ctp==54|c2ctp==58|c2ctp==61|c2ctp==62|c2ctp==63|c2ctp==67|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==101|c2ctp==113|c2ctp==114|c2ctp==611|c2ctp==612|c2ctp==613)&(n2ctp>3&n2ctp<=6))
replace ctcatp=4 if (ctcatp==.|ctcatp==0|ctcatp==1|ctcatp==2|ctcatp==3|ctcatp==9)&((c3ctp==40|c3ctp==44|c3ctp==54|c3ctp==58|c3ctp==61|c3ctp==62|c3ctp==63|c3ctp==67|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==101|c3ctp==113|c3ctp==114|c3ctp==611|c3ctp==612|c3ctp==613)&(n3ctp>3&n3ctp<=6))

sort ctcatp ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp 
browse statusnr ctcat2p ctcatp ctp c1ctp n1ctp c2ctp n2ctp o1ctp c3ctp n3ctp 
*** een paar corrrecties op chemocategorien
replace ctcatp=4 if statusnr==700328|statusnr==9394043|statusnr==790515|statusnr==1303071|statusnr==840423|statusnr==171804|statusnr==810590
replace ctcatp=5 if statusnr==851593

gen ctcat4p=.
format ctcat4p %42.0g
label def LABW 0"no/nonalk ct" 1"<=8.4 g/m2 procarbazine" 2">8.4 g/m2 procarbazine" 9"other alk/unkn ct"
label val ctcat4p LABW
sort ctcat2p ctcat4p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp o2ctp o3ctp
browse statusnr ctcat2p ctcat4p ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp o1ctp o2ctp o3ctp
replace ctcat4p=ctcat2p if ctcat4p==.
replace ctcat4p=0 if ctcat2p==1
replace ctcat4p=1 if ctcat2p==3
replace ctcat4p=2 if ctcat2p==4 
replace ctcat4p=9 if ctcat2p==2|ctcat2p==9|ctcat2p==99
tab ctcat4p ctcat2p, m

gen unknp=.
replace unknp=0 if ctcat2p<99
replace unknp=1 if ctcat2p==99
tab ctcat2p unknp, m

gen procarbp=.
replace procarbp=1 if ctcat2p>=3&ctcat2p<=9
replace procarbp=0 if ctcat2p<3|(ctcat2p>9&ctcat2p~=.)
tab ctcat2p procarbp, m

gen cyclofp=.
sort c1ctp c2ctp c3ctp cyclofp
browse c1ctp c2ctp c3ctp o1ctp o2ctp cyclofp
replace cyclofp=1 if c1ctp==11|c1ctp==49|c1ctp==50|c1ctp==58|c1ctp==65|c1ctp==71|c1ctp==78|c1ctp==82|c1ctp==100|c1ctp==104|c1ctp==105
replace cyclofp=1 if c2ctp==11|c2ctp==49|c2ctp==50|c2ctp==58|c2ctp==65|c2ctp==71|c2ctp==78|c2ctp==82|c2ctp==100|c2ctp==104|c2ctp==105
replace cyclofp=1 if c3ctp==11|c3ctp==49|c3ctp==50|c3ctp==58|c3ctp==65|c3ctp==71|c3ctp==78|c3ctp==82|c3ctp==100|c3ctp==104|c3ctp==105
replace cyclofp=1 if (o1ctp=="CHOP"|o1ctp=="CCVPP"|o1ctp=="BCVPP"|o1ctp=="Endoxan"|o1ctp=="endoxan tabletten"|o1ctp=="endoxan 1 gram intraveneus"|o1ctp=="BCVPP (part remissie met restafwijkingen in mediast)"|o1ctp=="BCVPP, 3 kuren zonder ccnu")
replace cyclofp=1 if (o2ctp=="CHOP"|o2ctp=="CCVPP"|o2ctp=="BCVPP"|o2ctp=="Endoxan"|o2ctp=="endoxan tabletten"|o2ctp=="endoxan 1 gram intraveneus"|o2ctp=="BCVPP (part remissie met restafwijkingen in mediast)"|o2ctp=="BCVPP, 3 kuren zonder ccnu")
replace cyclofp=1 if (o3ctp=="CHOP"|o3ctp=="CCVPP"|o3ctp=="BCVPP"|o3ctp=="Endoxan"|o3ctp=="endoxan tabletten"|o3ctp=="endoxan 1 gram intraveneus"|o3ctp=="BCVPP (part remissie met restafwijkingen in mediast)"|o3ctp=="BCVPP, 3 kuren zonder ccnu")
replace cyclofp=1 if (o1ctp=="2*OEPA/2-4*COPP DAL-HD-90"|o1ctp=="2*OPPA/2-4*COPP DAL-HD-90")
replace cyclofp=0 if cyclofp==.&ctcat2p~=99&ctcat2p~=.
replace cyclofp=99 if (cyclofp==.|cyclofp==0)&ctcat2p==99
sort cyclofp c1ctp c2ctp c3ctp 
browse statusnr cyclofp c1ctp c2ctp c3ctp cyclofp o1ctp o2ctp o3ctp

gen anthrap=.
sort c1ctp c2ctp c3ctp anthrap statusnr 
browse statusnr c1ctp c2ctp c3ctp o1ctp o2ctp o3ctp anthrap
replace c1ctp=40 if statusnr==7856245|statusnr==9394043
replace c2ctp=41 if statusnr==7856245|statusnr==9394043
replace c1ctp=81 if statusnr==2907721
replace anthrap=1 if c1ctp==2|c1ctp==9|c1ctp==41|c1ctp==50|c1ctp==61|c1ctp==64|c1ctp==69|c1ctp==70|c1ctp==80|c1ctp==81|c1ctp==82|c1ctp==83|c1ctp==86|c1ctp==94|c1ctp==98|c1ctp==104|c1ctp==105|c1ctp==108|c1ctp==109|c1ctp==110|c1ctp==111|c1ctp==112|c1ctp==611|c1ctp==612|c1ctp==613
replace anthrap=1 if c2ctp==2|c2ctp==9|c2ctp==41|c2ctp==50|c2ctp==61|c2ctp==64|c2ctp==69|c2ctp==70|c2ctp==80|c2ctp==81|c2ctp==82|c2ctp==83|c2ctp==86|c2ctp==94|c2ctp==98|c2ctp==104|c2ctp==105|c2ctp==108|c2ctp==109|c2ctp==110|c2ctp==111|c2ctp==112|c2ctp==611|c2ctp==612|c2ctp==613
replace anthrap=1 if c3ctp==2|c3ctp==9|c3ctp==41|c3ctp==50|c3ctp==61|c3ctp==64|c3ctp==69|c3ctp==70|c3ctp==80|c3ctp==81|c3ctp==82|c3ctp==83|c3ctp==86|c3ctp==94|c3ctp==98|c3ctp==104|c3ctp==105|c3ctp==108|c3ctp==109|c3ctp==110|c3ctp==111|c3ctp==112|c3ctp==611|c3ctp==612|c3ctp==613
replace anthrap=1 if (o1ctp=="CHOP"|o1ctp=="CHOP/Mitoxanthrone"|o1ctp=="CNOP"|o1ctp=="CAVmp-BV"|o1ctp=="MACOP-B"|o1ctp=="Onbekend CAVmP BV H8 protocol"|o1ctp=="MOPP-ABVD, alternerend"|o1ctp=="  MOPP-ABVD")
replace anthrap=0 if anthrap==.&ctcat2p~=99&ctcat2p~=.
replace anthrap=99 if (anthrap==.|anthrap==0)&ctcat2p==99
tab anthrap, m

gen cisptp=.
sort c1ctp c2ctp c3ctp cisptp statusnr 
browse statusnr c1ctp c2ctp c3ctp o1ctp o2ctp o3ctp cisptp
replace cisptp=1 if c1ctp==31|c2ctp==31|c3ctp==31
replace cisptp=1 if c1ctp==87|c2ctp==87|c3ctp==87
replace cispt=1 if c1ctp==102|c2ctp==102|c3ctp==102
replace cisptp=0 if cisptp==.&ctcat2p~=99&ctcat2p~=.
replace cisptp=99 if (cisptp==.|cisptp==0)&ctcat2p==99
tab ctcat2p cisptp, m
tab cisptp, m


*** checks op recidieven en recidiefbehandeling
sort rechdp brechdp rtrp ctrp zkh
tab zkh rechdp, row m

replace rechdp=1 if ((rechdp==.|rechdp==2|rechdp==9)&((jrechdp~=.&jrechdp~=1&jrechdp~=9999)))
replace rtrp=2 if rechdp==1&(rtrp==.&ctrp~=.)
replace rtrp=2 if rechdp==1&(rtrp==.&ctrp==.)
replace rtrp=2 if rechdp==1&(rtrp==.&ctrp~=.)
replace ctrp=2 if rechdp==1&(rtrp~=.&ctrp==.)
replace ctrp=2 if rechdp==1&(rtrp==.&ctrp==.)
replace ctrp=2 if rechdp==1&(rtrp~=.&ctrp==.)
replace rtrp=1 if (rtrp==2|rtrp==.)&((mantelrp~=9&mantelrp~=2&mantelrp~=0&mantelrp~=.)|(lhalsrp~=9&lhalsrp~=2&lhalsrp~=0&lhalsrp~=.)|(rhalsrp~=9&rhalsrp~=2&rhalsrp~=0&rhalsrp~=.)|(lsuprarp~=9&lsuprarp~=2&lsuprarp~=0&lsuprarp~=.)|(rsuprarp~=9&rsuprarp~=2&rsuprarp~=0&rsuprarp~=.)|(linfrarp~=9&linfrarp~=2&linfrarp~=0&linfrarp~=.)|(rinfrarp~=9&rinfrarp~=2&rinfrarp~=0&rinfrarp~=.)|(lokselrp~=9&lokselrp~=2&lokselrp~=0&lokselrp~=.)|(rokselrp~=9&rokselrp~=2&rokselrp~=0&rokselrp~=.)|(mediasrp~=9&mediasrp~=2&mediasrp~=0&mediasrp~=.)|(llongrp~=9&llongrp~=2&llongrp~=0&llongrp~=.)|(rlongrp~=9&rlongrp~=2&rlongrp~=0&rlongrp~=.)|(paraarp~=9&paraarp~=2&paraarp~=0&paraarp~=.)|(miltrp~=9&miltrp~=2&miltrp~=0&miltrp~=.)|(omgyrp~=9&omgyrp~=2&omgyrp~=0&omgyrp~=.)|(liliacrp~=9&liliacrp~=2&liliacrp~=0&liliacrp~=.)|(riliacrp~=9&riliacrp~=2&riliacrp~=0&riliacrp~=.)|(lliesrp~=9&lliesrp~=2&lliesrp~=0&lliesrp~=.)|(rliesrp~=9&rliesrp~=2&rliesrp~=0&rliesrp~=.)|(vanderrp~=9&vanderrp~=2&vanderrp~=0&vanderrp~=.))
replace ctrp=1 if (ctrp==2|ctrp==.)&(c1ctrp~=.|c2ctrp~=.)
replace rechdp=2 if ((rechdp==1)&((jrechdp==.|jrechdp==1|jrechdp==9999)&(rtrp~=1&ctrp~=1)))
replace brechdp=2 if ((brechdp==1)&((jrechdp==.|jrechdp==1|jrechdp==9999)&(rtrp~=1&ctrp~=1)))
replace brechdp=1 if rtrp==1|ctrp==1
replace brechdp=9 if brechdp==.
replace rtrp=2 if brechdp==1&(rtrp==.&ctrp==1)
replace rtrp=9 if brechdp==1&(rtrp==.)
replace ctrp=2 if brechdp==1&(ctrp==.&rtrp==1)
replace ctrp=9 if brechdp==1&(ctrp==.)
replace rechdp=1 if brechdp==1|ctrp==1|rtrp==1
replace brechdp=9 if (brechdp==2|brechdp==.)&((jrechdp~=.&jrechdp~=1&jrechdp~=9999)&(zkh==7|zkh==8))
replace rechdp=1 if (rechdp==2|rechdp==.)&((jrechdp~=.&jrechdp~=1&jrechdp~=9999))
replace rechdp=2 if rechdp==5|rechdp==8|rechdp==. 
sort rechdp brechdp rtrp ctrp zkh
tab zkh rechdp, row m

save "E:\Michael WORK\Morbus Hodgkin\tmp 2011.dta", replace
use "E:\Michael WORK\Morbus Hodgkin\tmp 2011.dta",clear

tab rtsuprap, m
sort rtp rtsuprap rtrp 
browse statusnr rtsuprap rtp mantelp-nlveldp rtrp mantelrp-nlveldrp
gen rtsupra=.
replace rtsupra=rtsuprap if (rtsupra==.|rtsupra==0|rtsupra==1|rtsupra==2)&((rtrp==2|rtrp==9|rtrp==.))
replace rtsupra=1 if (rtsupra==.|rtsupra==0)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1|rhalsrp==1|lsuprarp==1|rsuprarp==1|linfrarp==1|rinfrarp==1|lokselrp==1|rokselrp==1|mediasrp==1|llongrp==1|rlongrp==1))
replace rtsupra=2 if (rtsupra==.|rtsupra==0|rtsupra==1)&(mantelrp==1)
replace rtsupra=2 if (rtsupra==.|rtsupra==0|rtsupra==1)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1&rhalsrp==1)&(lsuprarp==1&lsuprarp==1)&(linfrarp==1&rinfrarp==1)&(lokselrp==1&rokselrp==1)&(mediasrp==1)
replace rtsupra=2 if (rtsupra==.|rtsupra==0|rtsupra==1)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1&rhalsrp==1)&(lsuprarp==1&lsuprarp==1)&(lokselrp==1&rokselrp==1)&(mediasrp==1)
replace rtsupra=2 if (rtsupra==.|rtsupra==0|rtsupra==1)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.))&(((lhalsrp==1)&(rhalsrp==1))&((lsuprarp==1)&(rsuprarp==1))&((linfrarp==1)&(rinfrarp==1))&((lokselrp==1)&(rokselrp==1))&((mediasrp==1))))
replace rtsupra=2 if (rtsupra==.|rtsupra==0|rtsupra==1)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(mantelp==9|mantelp==2|mantelp==0|mantelp==.))&(((lhalsp==1|lhalsrp==1)&(rhalsp==1|rhalsrp==1))&((lsuprap==1|lsuprarp==1)&(rsuprap==1|rsuprarp==1))&((linfrap==1|linfrarp==1)&(rinfrap==1|rinfrarp==1))&((lokselp==1|lokselrp==1)&(rokselp==1|rokselrp==1))&((mediastp==1|mediasrp==1))))
replace rtsupra=0 if (rtsupra==.)&((omgyrp==1|paraarp==1|miltrp==1|liliacrp==1|riliacrp==1|lliesrp==1|rliesrp==1))
replace rtsupra=rtsuprap if (rtsupra==.&rtsuprap~=9)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.))&(vanderrp==1&(nlveldrp=="L1-L5"|nlveldrp=="Leverhilus/pancreaskop"|nlveldrp=="centraal cerebraal"|nlveldrp=="klein bekken en sacrum"))
replace rtsupra=rtsuprap if (rtsupra==.&rtsuprap~=9)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.))&(vanderrp==1&(nlveldrp==""))
replace rtsupra=rtsuprap if (rtsupra==.&rtsuprap~=9)&((rtrp==1)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)))
replace rtsupra=0 if rtrp==1&rtsupra==.&(vanderrp==1)&(nlveldrp~="")
replace rtsupra=9 if (nlveldrp==" onbekend  welke velden"|nlveldrp=="VELD ONBEKEND"|nlveldrp=="VELDEN ONBEKEND"|nlveldrp=="Veld ONBEKEND"|nlveldrp=="Velden ONBEKEND"|nlveldrp=="lokaal + regionaal"|nlveldrp=="lokaal regionaal"|nlveldrp=="myelum, beenmerg, ruggemerg"|nlveldrp=="beenmerg"|nlveldrp=="onbekend"|nlveldrp=="onbekend IF"|nlveldrp=="prim lokalisatie"|nlveldrp=="primaire lokalisatie"|nlveldrp=="veld onbekend")&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.))
replace rtsupra=9 if rtrp==1&(rtsupra==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)
replace rtsupra=9 if rtrp==1&(rtsupra==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")
replace rtsupra=1 if (rtsupra==9|rtsupra==0)&rtsuprap==1
replace rtsupra=2 if (rtsupra==9|rtsupra==0|rtsupra==1)&rtsuprap==2
sort rtsuprap rtsupra
label define LABL 9"RT, but field unknown", modify
label val rtsupra LABL
label var rtsupra "RT above diaphragm prim&rec" 		
tab rtsupra rtsuprap, m
tab rtsuprap, m	
tab rtsupra, m	


sort rtmidp paraap miltp nlveldp omgyp paraarp miltrp nlveldrp omgyrp 
browse statusnr rtmidp rtp paraap miltp nlveldp omgyp rtrp paraarp miltrp nlveldrp 
gen rtmid=.
replace rtmid=rtmidp if (rtmid==.|rtmid==0|rtmid==1)&((rtrp==2|rtrp==9|rtrp==.))
replace rtmid=1 if (rtmidp==.|rtmidp==0)&((paraarp==1|miltrp==1|omgyrp==1))
replace rtmid=0 if rtmid==.&((mantelrp==1|lhalsrp==1|rhalsrp==1|lsuprarp==1|rsuprarp==1|linfrarp==1|rinfrarp==1|lokselrp==1|rokselrp==1|mediasrp==1|llongrp==1|rlongrp==1|liliacrp==1|riliacrp==1|lliesrp==1|rliesrp==1))
replace rtmid=9 if (nlveldrp==" onbekend  welke velden"|nlveldrp=="VELD ONBEKEND"|nlveldrp=="VELDEN ONBEKEND"|nlveldrp=="Veld ONBEKEND"|nlveldrp=="Velden ONBEKEND"|nlveldrp=="lokaal + regionaal"|nlveldrp=="lokaal regionaal"|nlveldrp=="myelum, beenmerg, ruggemerg"|nlveldrp=="beenmerg"|nlveldrp=="onbekend"|nlveldrp=="onbekend IF"|nlveldrp=="prim lokalisatie"|nlveldrp=="primaire lokalisatie"|nlveldrp=="veld onbekend")&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.))
replace rtmid=9 if rtrp==1&(rtmid==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)
replace rtmid=9 if rtrp==1&(rtmid==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")
replace rtmid=0 if rtrp==1&rtmid==.&(vanderrp==1)&(nlveldrp~="")
replace rtmid=9 if rtrp==1&(rtmid==.|rtmid==0)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)
replace rtmid=9 if rtrp==1&(rtmid==.|rtmid==0)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")
replace rtmid=1 if rtrp==1&(rtmid==.|rtmid==0|rtmidp==9)&((nlveldrp=="Leverhilus/pancreaskop"|nlveldrp=="L3-L4"|nlveldrp=="TH II, L4-5 S1"|nlveldrp=="Th11 t/m L3"|nlveldrp=="Th3-Th12, L1-3,Abdomen AP"|nlveldrp=="milthilus"|nlveldrp=="L3-L5"|nlveldrp=="li heup, L 5 t/m/ th 1"|nlveldrp=="linker bovenbuik en epigastrium"|nlveldrp=="miltsteel"|nlveldrp=="C1 t/m Th7, re schouder, Th11 t/m L3, re bekkenkom voor, re femur voor, re bovenbeen voor, re en li knie voor"|nlveldrp=="Th 11, 12, L1, L5"|nlveldrp=="lumbale klieren"|nlveldrp=="total body"|nlveldrp=="total body bestraling"|nlveldrp=="L1-L5"|nlveldrp=="parasternaal, paralumbaal re"|nlveldrp=="L2 t/m S2"|nlveldrp=="abdomen, buike en liezen, Th5"|nlveldrp=="buikbad"|nlveldrp=="buikbad bestraling met moving strip"|nlveldrp=="gehele lumbale wervelkolom"))
replace rtmid=rtmidp if (rtmid==.|rtmid==9)&rtmidp==0
replace rtmid=rtmidp if (rtmid==.|rtmid==9|rtmid==0)&rtmidp==1
label val rtmid LABM
label var rtmid "RT to Para-aortal nodes/spleen prim&rec" 
sort rtmid rtmidp paraap miltp nlveldp omgyp paraarp miltrp nlveldrp omgyrp 
browse statusnr rtmid rtmidp rtp paraap miltp nlveldp omgyp rtrp omgyrp paraarp miltrp nlveldrp 
tab rtmid rtmidp, m


sort rtinfrap rtp nlveldp omgyp liliacp riliacp lliesp rliesp rtrp liliacrp riliacrp lliesrp rliesrp nlveldrp omgyrp 
browse statusnr rtinfrap rtp nlveldp omgyp liliacp riliacp lliesp rliesp rtrp liliacrp riliacrp lliesrp rliesrp nlveldrp omgyrp 
gen rtinfra=.
replace rtinfra=rtinfrap if (rtinfra==.|rtinfra==0|rtinfra==1)&((rtrp==2|rtrp==9|rtrp==.))
replace rtinfra=1 if (rtinfra==.|rtinfra==0)&((omgyrp==1|liliacrp==1|riliacrp==1|lliesrp==1|rliesrp==1))
replace rtinfra=1 if (rtinfra==.|rtinfra==0)&(nlveldrp=="linker heup, li en re schouder, re fossa iliaca/inguinaal"|nlveldrp=="rug rechts onder"|nlveldrp=="klein bekken en sacrum"|nlveldrp=="L2 t/m S2"|nlveldrp=="abdomen, buike en liezen, Th5"|nlveldrp=="buikbad"|nlveldrp=="buikbad bestraling met moving strip"|nlveldrp=="gehele lumbale wervelkolom")
replace rtinfra=0 if rtinfra==.&(((mantelrp==1|lhalsrp==1|rhalsrp==1|lsuprarp==1|rsuprarp==1|linfrarp==1|rinfrarp==1|lokselrp==1|rokselrp==1|mediasrp==1|llongrp==1|rlongrp==1|paraarp==1|miltrp==1)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)))
replace rtinfra=9 if (nlveldrp==" onbekend  welke velden"|nlveldrp=="VELD ONBEKEND"|nlveldrp=="VELDEN ONBEKEND"|nlveldrp=="Veld ONBEKEND"|nlveldrp=="Velden ONBEKEND"|nlveldrp=="lokaal + regionaal"|nlveldrp=="lokaal regionaal"|nlveldrp=="myelum, beenmerg, ruggemerg"|nlveldrp=="beenmerg"|nlveldrp=="onbekend"|nlveldrp=="onbekend IF"|nlveldrp=="prim lokalisatie"|nlveldrp=="primaire lokalisatie"|nlveldrp=="veld onbekend")&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.))
replace rtinfra=9 if rtrp==1&(rtinfra==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)
replace rtinfra=9 if rtrp==1&(rtinfra==.)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")
replace rtinfra=0 if rtrp==1&rtinfra==.&(vanderrp==1)&(nlveldrp~="")
replace rtinfra=9 if rtrp==1&(rtinfra==.|rtinfra==0)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)
replace rtinfra=9 if rtrp==1&(rtinfra==.|rtinfra==0)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")
replace rtinfra=1 if (rtinfra==.|rtinfra==9|rtinfra==0)&rtinfrap==1
replace rtinfra=9 if (rtinfra==0|rtinfra==9)&rtinfrap==9
replace rtinfra=0 if statusnr==3063736
replace rtinfra=1 if statusnr==790457
label var rtinfra "RT below diaphragm prim&rec; excludes RT limited to para-aortal/spleen" 
label val rtinfra LABN
sort rtinfrap rtinfrap rtp nlveldp omgyp liliacp riliacp lliesp rliesp rtrp liliacrp riliacrp lliesrp rliesrp nlveldrp omgyrp 
browse statusnr rtinfra rtinfrap rtp nlveldp omgyp liliacp riliacp lliesp rliesp rtrp liliacrp riliacrp lliesrp rliesrp nlveldrp omgyrp 
tab rtinfra rtinfrap, m


sort rtneckp rtp mantelp lhalsp-rsuprap nlveldp rtrp mantelrp lhalsrp-rsuprarp nlveldrp
browse zoeknr rtneckp rtp mantelp lhalsp-rsuprap nlveldp rtrp mantelrp lhalsrp-rsuprarp nlveldrp
gen rtneck=.
replace rtneck=rtneckp if (rtneck==.|rtneck==0|rtneck==1)&((rtrp==2|rtrp==9|rtrp==.))
replace rtneck=1 if (rtneck==.|rtneck==9|rtneck==0)&rtneckp==1
replace rtneck=2 if (rtneck==.|rtneck==9|rtneck==0|rtneck==1)&rtneckp==2
replace rtneck=3 if (rtneck==.|rtneck==9|rtneck==0|rtneck==1|rtneck==2)&rtneckp==3
replace rtneck=1 if (rtneck==.|rtneck==0)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==1|rsuprarp==1)))
replace rtneck=2 if (rtneck==.|rtneck==0|rtneck==1)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1|rhalsrp==1)))
replace rtneck=3 if (rtneck==.|rtneck==0|rtneck==1|rtneck==2)&((mantelrp==1))
replace rtneck=3 if (rtneck==.|rtneck==0|rtneck==1|rtneck==2)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1&rhalsrp==1)&(lsuprarp==1&lsuprarp==1)&(linfrarp==1&rinfrarp==1)&(lokselrp==1&rokselrp==1)&(mediasrp==1)))
replace rtneck=3 if (rtneck==.|rtneck==0|rtneck==1|rtneck==2)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==1&rhalsrp==1)&(lsuprarp==1&lsuprarp==1)&(lokselrp==1&rokselrp==1)&(mediastp==1)))
replace rtneck=0 if (rtneck==.|rtneck==9)&(((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.))&(linfrarp==1|rinfrarp==1|lokselrp==1|rokselrp==1|mediasrp==1|llongrp==1|rlongrp==1|omgyrp==1|liliacrp==1|riliacrp==1|lliesrp==1|rliesrp==1|vanderrp==1))
replace rtneck=9 if (rtneck==.)&((rtrp==1)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.)))
replace rtneck=9 if (rtneck==.)&((rtrp==1)&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==1)&(nlveldrp=="")))
replace rtneck=9 if (rtneck==.|rtneck==0)&rtneckp==9
replace rtneck=0 if statusnr==830544
label var rtneck "RT to the neck prim&rec" 
label val rtneck LABO
sort rtneckp rtneck rtp mantelp lhalsp-rsuprap nlveldp rtrp mantelrp lhalsrp-rsuprarp nlveldrp
browse statusnr rtneckp rtneck rtp mantelp lhalsp-rsuprap nlveldp rtrp mantelrp lhalsrp-rsuprarp nlveldrp
tab rtneck rtneckp, m

gen rtcat=.
sort rtcatp rtsupra rtneck rtmid rtinfra rtp mantelp-nlveldp rtrp mantelrp-nlveldrp
browse statusnr rtcatp rtsupra rtneck rtmid rtp rtinfra mantelp-nlveldp rtrp mantelrp-nlveldrp
replace rtcat=rtcatp if (rtcat==.|rtcat==0|rtcat==9)&((rtrp==2|rtrp==9|rtrp==.))
replace rtcat=1 if rtsupra==1
replace rtcat=3 if rtsupra==2
replace rtcat=5 if rtmid==1|rtinfra==1
replace rtcat=2 if rtsupra==1&(rtmid==1|rtinfra==1)
replace rtcat=4 if rtsupra==2&(rtmid==1|rtinfra==1)
replace rtcat=9 if (rtcat~=3&rtcat~=4)&(((rtsupra==9&(rtneck==9|rtneck==0|rtneck==1|rtneck==2))|((rtsupra==9|rtsupra==0|rtsupra==1)&rtneck==9))|((rtmid==9&rtinfra==0)|(rtmid==0&rtinfra==9))|((rtsupra==0|rtsupra==1)&rtneck==9)|((rtmid==9&rtinfra==9)))
replace rtcat=9 if rtcat==.&rtp==1&((mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)&(vanderp==9|vanderp==2|vanderp==0|vanderp==.))
replace rtcat=9 if rtcat==.&rtrp==1&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.)&(vanderrp==9|vanderrp==2|vanderrp==0|vanderrp==.))
replace rtcat=9 if rtcat==.&(nlveldp==" onbekend  welke velden"|nlveldp=="VELD ONBEKEND"|nlveldp=="VELDEN ONBEKEND"|nlveldp=="Veld ONBEKEND"|nlveldp=="Velden ONBEKEND"|nlveldp=="lokaal + regionaal"|nlveldp=="lokaal regionaal"|nlveldp=="klopt"|nlveldp=="myelum, beenmerg, ruggemerg"|nlveldp=="beenmerg"|nlveldp=="onbekend"|nlveldp=="onbekend IF"|nlveldp=="prim lokalisatie"|nlveldp=="primaire lokalisatie"|nlveldp=="veld onbekend")&(mantelp==9|mantelp==2|mantelp==0|mantelp==.)&(lhalsp==9|lhalsp==2|lhalsp==0|lhalsp==.)&(rhalsp==9|rhalsp==2|rhalsp==0|rhalsp==.)&(lsuprap==9|lsuprap==2|lsuprap==0|lsuprap==.)&(rsuprap==9|rsuprap==2|rsuprap==0|rsuprap==.)&(linfrap==9|linfrap==2|linfrap==0|linfrap==.)&(rinfrap==9|rinfrap==2|rinfrap==0|rinfrap==.)&(lokselp==9|lokselp==2|lokselp==0|lokselp==.)&(rokselp==9|rokselp==2|rokselp==0|rokselp==.)&(mediastp==9|mediastp==2|mediastp==0|mediastp==.)&(llongp==9|llongp==2|llongp==0|llongp==.)&(rlongp==9|rlongp==2|rlongp==0|rlongp==.)&(paraap==9|paraap==2|paraap==0|paraap==.)&(miltp==9|miltp==2|miltp==0|miltp==.)&(omgyp==9|omgyp==2|omgyp==0|omgyp==.)&(liliacp==9|liliacp==2|liliacp==0|liliacp==.)&(riliacp==9|riliacp==2|riliacp==0|riliacp==.)&(lliesp==9|lliesp==2|lliesp==0|lliesp==.)&(rliesp==9|rliesp==2|rliesp==0|rliesp==.)
replace rtcat=9 if rtcat==.&(nlveldrp==" onbekend  welke velden"|nlveldrp=="VELD ONBEKEND"|nlveldrp=="VELDEN ONBEKEND"|nlveldrp=="Veld ONBEKEND"|nlveldrp=="Velden ONBEKEND"|nlveldrp=="lokaal + regionaal"|nlveldrp=="lokaal regionaal"|nlveldrp=="myelum, beenmerg, ruggemerg"|nlveldrp=="beenmerg"|nlveldrp=="onbekend"|nlveldrp=="onbekend IF"|nlveldrp=="prim lokalisatie"|nlveldrp=="primaire lokalisatie"|nlveldrp=="veld onbekend")&((mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(lhalsrp==9|lhalsrp==2|lhalsrp==0|lhalsrp==.)&(rhalsrp==9|rhalsrp==2|rhalsrp==0|rhalsrp==.)&(lsuprarp==9|lsuprarp==2|lsuprarp==0|lsuprarp==.)&(rsuprarp==9|rsuprarp==2|rsuprarp==0|rsuprarp==.)&(linfrarp==9|linfrarp==2|linfrarp==0|linfrarp==.)&(rinfrarp==9|rinfrarp==2|rinfrarp==0|rinfrarp==.)&(lokselrp==9|lokselrp==2|lokselrp==0|lokselrp==.)&(rokselrp==9|rokselrp==2|rokselrp==0|rokselrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)&(llongrp==9|llongrp==2|llongrp==0|llongrp==.)&(rlongrp==9|rlongrp==2|rlongrp==0|rlongrp==.)&(paraarp==9|paraarp==2|paraarp==0|paraarp==.)&(miltrp==9|miltrp==2|miltrp==0|miltrp==.)&(omgyrp==9|omgyrp==2|omgyrp==0|omgyrp==.)&(liliacrp==9|liliacrp==2|liliacrp==0|liliacrp==.)&(riliacrp==9|riliacrp==2|riliacrp==0|riliacrp==.)&(lliesrp==9|lliesrp==2|lliesrp==0|lliesrp==.)&(rliesrp==9|rliesrp==2|rliesrp==0|rliesrp==.))
label var rtcat "prim&rec RT categorised" 
label val rtcat LABP
sort rtcatp rtcat rtsupra rtneck rtmid rtinfra rtp mantelp-nlveldp rtrp mantelrp-nlveldrp
browse statusnr rtcatp rtcat rtsupra rtneck rtmid rtp rtinfra mantelp-nlveldp rtrp mantelrp-nlveldrp
tab rtcat rtcatp, m
tab rtcat,m

gen rtmed=.
sort rtmedp rtsuprap rtsupra rtp mantelp mediastp nlveldp rtrp mantelrp mediasrp nlveldrp
browse zoeknr rtmedp rtsuprap rtmed rtsupra rtp mantelp mediastp nlveldp rtrp mantelrp mediasrp nlveldrp
label var rtmed "RT to mediastinum prim&rec"
label val rtmed rtmedp
replace rtmed=rtmedp if (rtmed==.|rtmed==9|rtmed==0)&((rtrp==2|rtrp==9|rtrp==.))
replace rtmed=1 if (rtmed==.|rtmed==9|rtmed==0)&((mediasrp==1|mantelrp==1))
replace rtmed=1 if rtmedp==1
replace rtmed=0 if rtsuprap==0&rtsupra==0
replace rtmed=0 if rtmed==.&rtsupra==1
replace rtmed=0 if (rtmedp==0)&(mantelrp==9|mantelrp==2|mantelrp==0|mantelrp==.)&(mediasrp==9|mediasrp==2|mediasrp==0|mediasrp==.)
replace rtmed=1 if (rtmed==.|rtmed==9|rtmed==0)&(nlveldrp=="Epidurale lokalisatie Th4 t/m L2"|nlveldrp=="total body"|nlveldrp=="C1 t/m Th7, re schouder, Th11 t/m L3, re bekkenkom voor, re femur voor, re bovenbeen voor, re en li knie voor"|nlveldrp=="Th7 t/m 12"|nlveldrp=="sternum, thoraxwand, parasternaal, c3tmth5, C4=Th1")
replace rtmed=1 if rtmedp==9&rtsupra==2
replace rtmed=9 if rtmedp==9&rtsupra~=2
sort rtmedp rtsuprap rtmed rtsupra rtp mantelp mediastp nlveldp rtrp mantelrp mediasrp nlveldrp
browse zoeknr rtmedp rtsuprap rtmed rtsupra rtp mantelp mediastp nlveldp rtrp mantelrp mediasrp nlveldrp
tab rtmed rtmedp,m
tab rtmed,m

**** AANMAKEN CHEMOTHERAPIECATEGORIEN VOOR DE RECIDIEVEN ALS EERSTE OP BASIS VAN PROCARBAZINE
gen ctcat2a1=.
sort ctcat2a1 ctcat2p ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse statusnr zkh ctcat2a1 ctcat2p ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp o2ctrp o3ctrp
recode n1ctrp n2ctrp n3ctrp (88=999)
*** eerst een paar correcties
replace ctcat2a1=0 if ctcat2a1==.&(ctrp==0|ctrp==9|ctrp==.|ctrp==2)
replace ctcat2a1=1 if (ctcat2a1==.|ctcat2a1==0)&(c1ctrp==2|c1ctrp==3|c1ctrp==33|c1ctrp==47|c1ctrp==48|c1ctrp==80|c1ctrp==83)
replace ctcat2a1=1 if (ctcat2a1==.|ctcat2a1==0)&(c2ctrp==2|c2ctrp==3|c2ctrp==33|c2ctrp==47|c2ctrp==48|c2ctrp==80|c2ctrp==83)
replace ctcat2a1=1 if (ctcat2a1==.|ctcat2a1==0)&(c3ctrp==2|c3ctrp==3|c3ctrp==33|c3ctrp==47|c3ctrp==48|c3ctrp==80|c3ctrp==83)

replace ctcat2a1=2 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1)&(c1ctrp==8|c1ctrp==11|c1ctrp==12|c1ctrp==21|c1ctrp==22|c1ctrp==23|c1ctrp==30|c1ctrp==31|c1ctrp==41|c1ctrp==49|c1ctrp==50|c1ctrp==51|c1ctrp==57|c1ctrp==59|c1ctrp==60|c1ctrp==64|c1ctrp==67|c1ctrp==70|c1ctrp==85|c1ctrp==87|c1ctrp==88|c1ctrp==89|c1ctrp==90|c1ctrp==92|c1ctrp==99|c1ctrp==108|c1ctrp==109|c1ctrp==110|c1ctrp==112) 
replace ctcat2a1=2 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1)&(c2ctrp==8|c2ctrp==11|c2ctrp==12|c2ctrp==21|c2ctrp==22|c2ctrp==23|c2ctrp==30|c2ctrp==31|c2ctrp==41|c2ctrp==49|c2ctrp==50|c2ctrp==51|c2ctrp==57|c2ctrp==59|c2ctrp==60|c2ctrp==64|c2ctrp==67|c2ctrp==70|c2ctrp==85|c2ctrp==87|c2ctrp==88|c2ctrp==89|c2ctrp==90|c2ctrp==92|c2ctrp==99|c2ctrp==108|c2ctrp==109|c2ctrp==110|c2ctrp==112)
replace ctcat2a1=2 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1)&(c3ctrp==8|c3ctrp==11|c3ctrp==12|c3ctrp==21|c3ctrp==22|c3ctrp==23|c3ctrp==30|c3ctrp==31|c3ctrp==41|c3ctrp==49|c3ctrp==50|c3ctrp==51|c3ctrp==57|c3ctrp==59|c3ctrp==60|c3ctrp==64|c3ctrp==67|c3ctrp==70|c3ctrp==85|c3ctrp==87|c3ctrp==88|c3ctrp==89|c3ctrp==90|c3ctrp==92|c3ctrp==99|c3ctrp==108|c3ctrp==109|c3ctrp==110|c3ctrp==112) 

replace ctcat2a1=9 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2)&(c1ctrp==29|c1ctrp==40|c1ctrp==42|c1ctrp==44|c1ctrp==45|c1ctrp==54|c1ctrp==58|c1ctrp==61|c1ctrp==62|c1ctrp==63|c1ctrp==66|c1ctrp==67|c1ctrp==68|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==81|c1ctrp==82|c1ctrp==91|c1ctrp==94|c1ctrp==96|c1ctrp==98|c1ctrp==100|c1ctrp==101|c1ctrp==103|c1ctrp==104|c1ctrp==111|c1ctrp==113|c1ctrp==114|c1ctrp==611|c1ctrp==612|c1ctrp==613) 
replace ctcat2a1=9 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2)&(c2ctrp==29|c2ctrp==40|c2ctrp==42|c2ctrp==44|c2ctrp==45|c2ctrp==54|c2ctrp==58|c2ctrp==61|c2ctrp==62|c2ctrp==63|c2ctrp==66|c2ctrp==67|c2ctrp==68|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==81|c3ctrp==82|c2ctrp==91|c2ctrp==94|c2ctrp==96|c2ctrp==98|c2ctrp==100|c2ctrp==101|c2ctrp==103|c2ctrp==104|c2ctrp==111|c2ctrp==113|c2ctrp==114|c2ctrp==611|c2ctrp==612|c2ctrp==613)
replace ctcat2a1=9 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2)&(c3ctrp==29|c3ctrp==40|c3ctrp==42|c3ctrp==44|c3ctrp==45|c3ctrp==54|c3ctrp==58|c3ctrp==61|c3ctrp==62|c3ctrp==63|c3ctrp==66|c3ctrp==67|c3ctrp==68|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==81|c3ctrp==82|c3ctrp==91|c3ctrp==94|c3ctrp==96|c3ctrp==98|c3ctrp==100|c3ctrp==101|c3ctrp==103|c3ctrp==104|c3ctrp==111|c3ctrp==113|c3ctrp==114|c3ctrp==611|c3ctrp==612|c3ctrp==613)

replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c1ctrp==29|c1ctrp==42|c1ctrp==45|c1ctrp==66|c1ctrp==68|c1ctrp==81|c1ctrp==82|c1ctrp==91|c1ctrp==94|c1ctrp==96|c1ctrp==98|c1ctrp==100|c1ctrp==103|c1ctrp==104|c1ctrp==111)&(n1ctrp<=12))
replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c2ctrp==29|c2ctrp==42|c2ctrp==45|c2ctrp==66|c2ctrp==68|c2ctrp==81|c2ctrp==82|c2ctrp==91|c2ctrp==94|c2ctrp==96|c2ctrp==98|c2ctrp==100|c2ctrp==103|c2ctrp==104|c2ctrp==111)&(n2ctrp<=12))
replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c3ctrp==29|c3ctrp==42|c3ctrp==45|c3ctrp==66|c3ctrp==68|c3ctrp==81|c3ctrp==82|c3ctrp==91|c3ctrp==94|c3ctrp==96|c3ctrp==98|c3ctrp==100|c3ctrp==103|c3ctrp==104|c3ctrp==111)&(n3ctrp<=12))
replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c1ctrp==40|c1ctrp==44|c1ctrp==54|c1ctrp==58|c1ctrp==61|c1ctrp==62|c1ctrp==63|c1ctrp==67|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==101|c1ctrp==113|c1ctrp==114|c1ctrp==611|c1ctrp==612|c1ctrp==613)&(n1ctrp<=6))
replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c2ctrp==40|c2ctrp==44|c2ctrp==54|c2ctrp==58|c2ctrp==61|c2ctrp==62|c2ctrp==63|c2ctrp==67|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==101|c2ctrp==113|c2ctrp==114|c2ctrp==611|c2ctrp==612|c2ctrp==613)&(n2ctrp<=6))
replace ctcat2a1=3 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==9)&((c3ctrp==40|c3ctrp==44|c3ctrp==54|c3ctrp==58|c3ctrp==61|c3ctrp==62|c3ctrp==63|c3ctrp==67|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==101|c3ctrp==113|c3ctrp==114|c3ctrp==611|c3ctrp==612|c3ctrp==613)&(n3ctrp<=6))

replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c1ctrp==29|c1ctrp==42|c1ctrp==45|c1ctrp==66|c1ctrp==68|c1ctrp==81|c1ctrp==82|c1ctrp==94|c1ctrp==96|c1ctrp==98|c1ctrp==100|c1ctrp==103|c1ctrp==104|c1ctrp==111)&(n1ctrp>12&(n1ctrp~=99&n1ctrp~=999&n1ctrp~=.)))
replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c2ctrp==29|c2ctrp==42|c2ctrp==45|c2ctrp==66|c2ctrp==68|c2ctrp==81|c2ctrp==82|c2ctrp==94|c2ctrp==96|c2ctrp==98|c2ctrp==100|c2ctrp==103|c2ctrp==104|c2ctrp==111)&(n2ctrp>12&(n2ctrp~=99&n2ctrp~=999&n2ctrp~=.)))
replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c3ctrp==29|c3ctrp==42|c3ctrp==45|c3ctrp==66|c3ctrp==68|c3ctrp==81|c3ctrp==82|c3ctrp==94|c3ctrp==96|c3ctrp==98|c3ctrp==100|c3ctrp==103|c3ctrp==104|c3ctrp==111)&(n3ctrp>12&(n3ctrp~=99&n3ctrp~=999&n3ctrp~=.)))
replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c1ctrp==40|c1ctrp==44|c1ctrp==54|c1ctrp==58|c1ctrp==61|c1ctrp==62|c1ctrp==63|c1ctrp==67|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==91|c1ctrp==101|c1ctrp==113|c1ctrp==114|c1ctrp==611|c1ctrp==612|c1ctrp==613)&(n1ctrp>6&(n1ctrp~=99&n1ctrp~=999&n1ctrp~=.)))
replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c2ctrp==40|c2ctrp==44|c2ctrp==54|c2ctrp==58|c2ctrp==61|c2ctrp==62|c2ctrp==63|c2ctrp==67|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==91|c2ctrp==101|c2ctrp==113|c2ctrp==114|c2ctrp==611|c2ctrp==612|c2ctrp==613)&(n2ctrp>6&(n2ctrp~=99&n2ctrp~=999&n2ctrp~=.)))
replace ctcat2a1=4 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==2|ctcat2a1==3|ctcat2a1==9)&((c3ctrp==40|c3ctrp==44|c3ctrp==54|c3ctrp==58|c3ctrp==61|c3ctrp==62|c3ctrp==63|c3ctrp==67|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==91|c3ctrp==101|c3ctrp==113|c3ctrp==114|c3ctrp==611|c3ctrp==612|c3ctrp==613)&(n3ctrp>6&(n3ctrp~=99&n3ctrp~=999&n3ctrp~=.)))

*** een paar aanpassingen
replace ctcat2a1=2 if (ctcat2a1==.&o1ctrp=="leukeran")|statusnr==851547|statusnr==690380|statusnr==690315|statusnr==6063469|statusnr==820952|statusnr==8054440|statusnr==790834|statusnr==6165952|statusnr==8396724
replace ctcat2a1=3 if statusnr==4161516|statusnr==2491540|statusnr==700328
replace ctcat2a1=4 if statusnr==780149|statusnr==7198241|statusnr==4161516|statusnr==790614
replace ctcat2a1=9 if statusnr==790457
replace ctcat2a1=99 if statusnr==810149

replace ctcat2a1=99 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==9)&(c1ctrp==999&c2ctrp==.)
replace ctcat2a1=99 if (ctcat2a1==.|ctcat2a1==0|ctcat2a1==1|ctcat2a1==9)&(c1ctrp==999&c2ctrp==109)
replace ctcat2a1=99 if (ctcat2a1==.|ctcat2a1==0)&((ctrp==1&c1ctrp==999)|(ctrp==1&c1ctrp==.))
label val ctcat2a1 LABU

sort ctcat2a1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse zoeknr zkh ctcat2a1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp o2ctrp o3ctrp
tab ctcat2a1, m

***** tot hier gebleven

**** Procarbazine dosis in drie categorien
gen ctcata1=ctcat2a1
sort ctcat2a1 ctcata1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse statusnr zkh ctcat2a1 ctcata1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp o2ctrp o3ctrp
replace ctcata1=5 if ctcata1==4

replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c1ctrp==29|c1ctrp==42|c1ctrp==45|c1ctrp==66|c1ctrp==68|c1ctrp==81|c1ctrp==82|c1ctrp==91|c1ctrp==94|c1ctrp==96|c1ctrp==98|c1ctrp==100|c1ctrp==103|c1ctrp==104|c1ctrp==111)&(n1ctrp<=6))
replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c2ctrp==29|c2ctrp==42|c2ctrp==45|c2ctrp==66|c2ctrp==68|c2ctrp==81|c2ctrp==82|c2ctrp==91|c2ctrp==94|c2ctrp==96|c2ctrp==98|c2ctrp==100|c2ctrp==103|c2ctrp==104|c2ctrp==111)&(n2ctrp<=6))
replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c3ctrp==29|c3ctrp==42|c3ctrp==45|c3ctrp==66|c3ctrp==68|c3ctrp==81|c3ctrp==82|c3ctrp==91|c3ctrp==94|c3ctrp==96|c3ctrp==98|c3ctrp==100|c3ctrp==103|c3ctrp==104|c3ctrp==111)&(n3ctrp<=6))
replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c1ctrp==40|c1ctrp==44|c1ctrp==54|c1ctrp==58|c1ctrp==61|c1ctrp==62|c1ctrp==63|c1ctrp==67|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==101|c1ctrp==113|c1ctrp==114|c1ctrp==611|c1ctrp==612|c1ctrp==613)&(n1ctrp<=3))
replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c2ctrp==40|c2ctrp==44|c2ctrp==54|c2ctrp==58|c2ctrp==61|c2ctrp==62|c2ctrp==63|c2ctrp==67|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==101|c2ctrp==113|c2ctrp==114|c2ctrp==611|c2ctrp==612|c2ctrp==613)&(n2ctrp<=3))
replace ctcata1=3 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==9)&((c3ctrp==40|c3ctrp==44|c3ctrp==54|c3ctrp==58|c3ctrp==61|c3ctrp==62|c3ctrp==63|c3ctrp==67|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==101|c3ctrp==113|c3ctrp==114|c3ctrp==611|c3ctrp==612|c3ctrp==613)&(n3ctrp<=3))

replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c1ctrp==29|c1ctrp==42|c1ctrp==45|c1ctrp==61|c1ctrp==66|c1ctrp==68|c1ctrp==81|c1ctrp==82|c1ctrp==91|c1ctrp==94|c1ctrp==96|c1ctrp==98|c1ctrp==100|c1ctrp==103|c1ctrp==104|c1ctrp==111)&(n1ctrp>6&n1ctrp<=12))
replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c2ctrp==29|c2ctrp==42|c2ctrp==45|c2ctrp==61|c2ctrp==66|c2ctrp==68|c2ctrp==81|c2ctrp==82|c2ctrp==91|c2ctrp==94|c2ctrp==96|c2ctrp==98|c2ctrp==100|c2ctrp==103|c2ctrp==104|c2ctrp==111)&(n2ctrp>6&n2ctrp<=12))
replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c3ctrp==29|c3ctrp==42|c3ctrp==45|c3ctrp==61|c3ctrp==66|c3ctrp==68|c3ctrp==81|c3ctrp==82|c3ctrp==91|c3ctrp==94|c3ctrp==96|c3ctrp==98|c3ctrp==100|c3ctrp==103|c3ctrp==104|c3ctrp==111)&(n3ctrp>6&n3ctrp<=12))
replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c1ctrp==40|c1ctrp==44|c1ctrp==54|c1ctrp==58|c1ctrp==62|c1ctrp==63|c1ctrp==67|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==101|c1ctrp==611|c1ctrp==612|c1ctrp==613|c1ctrp==113|c1ctrp==114)&(n1ctrp>3&n1ctrp<=6))
replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c2ctrp==40|c2ctrp==44|c2ctrp==54|c2ctrp==58|c2ctrp==62|c2ctrp==63|c2ctrp==67|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==101|c2ctrp==611|c2ctrp==612|c2ctrp==613|c2ctrp==113|c2ctrp==114)&(n2ctrp>3&n2ctrp<=6))
replace ctcata1=4 if (ctcata1==.|ctcata1==0|ctcata1==1|ctcata1==2|ctcata1==3|ctcata1==9)&((c3ctrp==40|c3ctrp==44|c3ctrp==54|c3ctrp==58|c3ctrp==62|c3ctrp==63|c3ctrp==67|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==101|c3ctrp==611|c3ctrp==612|c3ctrp==613|c3ctrp==113|c3ctrp==114)&(n3ctrp>3&n3ctrp<=6))
label define LABV 99"CT, but type unknown", modify
label val ctcata1 LABV
*** een paar aanpassingen
replace ctcata1=2 if statusnr==851547
replace ctcata1=4 if statusnr==800414|statusnr==700328
replace ctcata1=9 if statusnr==790457
sort ctcata1 ctcat2a1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse statusnr zkh ctcata1 ctcat2a1 ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp o2ctrp o3ctrp
tab ctcat2a1 ctcata1, m
tab ctcata1, m


**** AANMAKEN CHEMOTHERAPIECATEGORIEN VOOR ZOWEL PRIMAIRE BEHANDELING ALS RECIDIEFBEHANDELING OP BASIS VAN PROCARBAZINE
gen ctcat2=.
label val ctcat2 LABU
replace ctcat2=ctcat2p
tab ctcat2, m
sort ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse statusnr zkh ctcat2 ctcat2p ctcat2a1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
replace ctcat2=0 if (ctcat2==.)&(ctcat2p==0|ctcat2a==0)
replace ctcat2=99 if (ctcat2==0|ctcat2==.)&(ctcat2p==99|ctcat2a==99)
replace ctcat2=1 if (ctcat2==0|ctcat2==99|ctcat2==.)&(ctcat2p==1|ctcat2a==1)
replace ctcat2=99 if (ctcat2==1)&((ctcat2p==1&ctcat2a==99)|(ctcat2p==99&ctcat2a==1))
replace ctcat2=2 if (ctcat2==0|ctcat2==1|ctcat2==99|ctcat2==.)&(ctcat2p==2|ctcat2a==2)
replace ctcat2=99 if (ctcat2==2)&((ctcat2p==2&ctcat2a==99)|(ctcat2p==99&ctcat2a==2))
replace ctcat2=9 if (ctcat2==0|ctcat2==1|ctcat2==2|ctcat2==3|ctcat2==99|ctcat2==.)&(ctcat2p==9|ctcat2a==9)
replace ctcat2=9 if (ctcat2==0|ctcat2==1|ctcat2==2|ctcat2==3|ctcat2==99|ctcat2==.)&(ctcat2p==3&ctcat2a==9)
replace ctcat2=9 if (ctcat2==0|ctcat2==1|ctcat2==2|ctcat2==3|ctcat2==99|ctcat2==.)&(ctcat2p==9&ctcat2a==3)
replace ctcat2=3 if (ctcat2==0|ctcat2==1|ctcat2==2|ctcat2==99|ctcat2==.)&(ctcat2p==3|ctcat2a==3)
replace ctcat2=9 if (ctcat2==3)&((ctcat2p==3&ctcat2a==99)|(ctcat2p==99&ctcat2a==3))
replace ctcat2=4 if ctcat2~=4&(ctcat2p==4|ctcat2a==4)
sort ctcat2 ctcat2p ctcat2a  ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp 
browse statusnr ZRnr zkh ctcat2 ctcat2p ctcat2a  ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp
*** een aantal aanpassingen (zowel primair als secundair minder dan 8,4 gr, echter samen meer)
replace ctcat2=4 if statusnr==4062132|statusnr==780314|statusnr==265718|statusnr==980895|statusnr==1555755|statusnr==940440|statusnr==2491540|statusnr==700328|statusnr==790457
replace ctcat2=. if ctcat2==0&ctcat2p==.
replace ctcat2p=0 if statusnr==891243&ZRnr==6616007
replace ctcat2=0 if statusnr==891243&ZRnr==6616007
sort ctcat2 ctcat2p ctcat2a ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp 
browse statusnr ZRnr ctcat2 ctcat2p ctcat2a ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp 
tab ctcat2, m
tab ctcat2p ctcat2, m

gen ctcat=.
label val ctcat LABV
replace ctcat=ctcat2
tab ctcat, m
sort ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse statusnr zkh ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
replace ctcat=5 if ctcat==4
replace ctcat=3 if (ctcatp==3|ctcata==3)&(ctcat~=5)
replace ctcat=9 if ((ctcatp==3&ctcata==9)|(ctcatp==9&ctcata==3))&(ctcat~=5)
replace ctcat=9 if ((ctcatp==3&ctcata==99)|(ctcatp==99&ctcata==3))&(ctcat~=5)
replace ctcat=4 if (ctcatp==4|ctcata==4)&(ctcat~=5)
replace ctcat=9 if ((ctcatp==4&ctcata==9)|(ctcatp==9&ctcata==4))&(ctcat~=5)
replace ctcat=9 if ((ctcatp==4&ctcata==99)|(ctcatp==99&ctcata==4))&(ctcat~=5)
sort ctcat ctcat2 ctcat2p ctcat2a1 ctcat2a ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse ctcat statusnr zkh ctcat ctcat2 ctcat2p ctcat2a1 ctcat2a ctcata1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
*** een aantal aanpassingen (zowel primair als secundair minder dan 4,2 gr, echter samen meer dan 4,2gr maar minder dan 8,4 gr)
replace ctcat=4 if statusnr==951141
tab ctcat, m
tab ctcat ctcat2,m
tab ctcat ctcatp, m 

gen unkn=.
replace unkn=unknp if unkn==.
tab ctcat unkn, m
replace unkn=0 if ctcat<99&ctcat~=0
replace unkn=1 if ctcat==99
replace unkn=0 if statusnr==891243&ZRnr==6616007
tab ctcat unkn, m
tab unknp unkn, m

tab ctcat procarbp, m
gen procarb=procarbp
replace procarb=1 if ctcata>=3&ctcata<=9
replace procarb=0 if procarb~=1&(ctcata<3|(ctcata>9&ctcata~=.))
replace procarb=8 if ctcat==0
replace procarb=99 if (procarb==.|procarb==0)&ctcat==99
label define procarb 0"no procarbazine" 1"procarbazine" 8"no ct" 99"unknown"
label val procarb procarbp procarb
tab ctcat procarb, m
tab procarbp procarb, m

tab ctcat cyclof, m
sort ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse statusnr zkh ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
gen cyclof=cyclofp
replace cyclof=1 if cyclof==0&cyclofp==1
replace cyclof=0 if cyclof==1&cyclofp==0
replace cyclof=99 if cyclof==0&cyclofp==99
replace cyclof=1 if c1ctrp==11|c1ctrp==49|c1ctrp==50|c1ctrp==58|c1ctrp==65|c1ctrp==71|c1ctrp==78|c1ctrp==82|c1ctrp==100|c1ctrp==104|c1ctrp==105
replace cyclof=1 if c2ctrp==11|c2ctrp==49|c2ctrp==50|c2ctrp==58|c2ctrp==65|c2ctrp==71|c2ctrp==78|c2ctrp==82|c2ctrp==100|c2ctrp==104|c2ctrp==105
replace cyclof=1 if c3ctrp==11|c3ctrp==49|c3ctrp==50|c3ctrp==58|c3ctrp==65|c3ctrp==71|c3ctrp==78|c3ctrp==82|c3ctrp==100|c3ctrp==104|c3ctrp==105
replace cyclof=0 if cyclof==.&ctcat~=99&ctcat~=.
replace cyclof=99 if (cyclof==.|cyclof==0)&ctcat==99
replace cyclof=1 if (o1ctrp=="CHOP"|o1ctrp=="CCVPP"|o1ctrp=="CCVP"|o1ctrp=="BCVPP"|o1ctrp=="CVB"|o1ctrp=="CBV schema"|o1ctrp=="CVP-CVB"|o1ctrp=="CVBP"|o1ctrp=="BCNU/VP16/Cyclofosfamide"|o1ctrp=="BCNU, Endoxan, VP16"|o1ctrp=="Endoxan"|o1ctrp=="endoxan tabletten"|o1ctrp=="endoxan 1 gram intraveneus"|o1ctrp=="Melfalan-Endoxan"|o1ctrp=="endoxan-natulan"|o1ctrp=="Endoxan Natulan")
replace cyclof=1 if (o2ctrp=="CHOP"|o2ctrp=="CCVPP"|o2ctrp=="CCVP"|o2ctrp=="BCVPP"|o2ctrp=="CVB"|o2ctrp=="CBV schema"|o2ctrp=="CVP-CVB"|o2ctrp=="CVBP"|o2ctrp=="BCNU/VP16/Cyclofosfamide"|o2ctrp=="BCNU, Endoxan, VP16"|o2ctrp=="Endoxan"|o2ctrp=="endoxan tabletten"|o2ctrp=="endoxan 1 gram intraveneus"|o2ctrp=="Melfalan-Endoxan"|o2ctrp=="endoxan-natulan"|o2ctrp=="Endoxan Natulan")
replace cyclof=1 if (o3ctrp=="CHOP"|o3ctrp=="CCVPP"|o3ctrp=="CCVP"|o3ctrp=="BCVPP"|o3ctrp=="CVB"|o3ctrp=="CBV schema"|o3ctrp=="CVP-CVB"|o3ctrp=="CVBP"|o2ctrp=="BCNU/VP16/Cyclofosfamide"|o3ctrp=="BCNU, Endoxan, VP16"|o3ctrp=="Endoxan"|o3ctrp=="endoxan tabletten"|o3ctrp=="endoxan 1 gram intraveneus"|o3ctrp=="Melfalan-Endoxan"|o3ctrp=="endoxan-natulan"|o3ctrp=="Endoxan Natulan")
replace cyclof=1 if (o1ctrp=="2*OEPA/2-4*COPP DAL-HD-90"|o1ctrp=="2*OPPA/2-4*COPP DAL-HD-90")
replace cyclof=8 if ctcat==0
label define cyclof 0"no cyclophophamide" 1"cyclophophamide" 8"no ct" 99"unknown"
label val cyclof cyclofp cyclof
sort  cyclofp cyclof ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse statusnr zkh cyclofp cyclof ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
*** een paar aanpassingen
tab cyclof, m
tab cyclof cyclofp, m

replace anthrap=8 if ctcatp==0
gen anthra=anthrap
sort anthrap anthra ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp c2ctp c3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctrp o2ctrp o3ctrp
browse statusnr zkh anthrap anthra ctcat ctcat2 ctcat2p ctcatp ctcat2a1 ctcata1 ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
replace anthra=1 if c1ctrp==2|c1ctrp==9|c1ctrp==50|c1ctrp==41|c1ctrp==61|c1ctrp==64|c1ctrp==70|c1ctrp==80|c1ctrp==81|c1ctrp==82|c1ctrp==83|c1ctrp==86|c1ctrp==94|c1ctrp==98|c1ctrp==104|c1ctrp==105|c1ctrp==108|c1ctrp==109|c1ctrp==110|c1ctrp==111|c1ctrp==112|c1ctrp==611|c1ctrp==612|c1ctrp==613
replace anthra=1 if c2ctrp==2|c2ctrp==9|c2ctrp==50|c2ctrp==41|c2ctrp==61|c2ctrp==64|c2ctrp==70|c2ctrp==80|c2ctrp==81|c2ctrp==82|c2ctrp==83|c2ctrp==86|c2ctrp==94|c2ctrp==98|c2ctrp==104|c2ctrp==105|c2ctrp==108|c2ctrp==109|c2ctrp==110|c2ctrp==111|c2ctrp==112|c2ctrp==611|c2ctrp==612|c2ctrp==613
replace anthra=1 if c3ctrp==2|c3ctrp==9|c3ctrp==50|c3ctrp==41|c3ctrp==61|c3ctrp==64|c3ctrp==70|c3ctrp==80|c3ctrp==81|c3ctrp==82|c3ctrp==83|c3ctrp==86|c3ctrp==94|c3ctrp==98|c3ctrp==104|c3ctrp==105|c3ctrp==108|c3ctrp==109|c3ctrp==110|c3ctrp==111|c3ctrp==112|c3ctrp==611|c3ctrp==612|c3ctrp==613
replace anthra=1 if (o1ctrp=="CHOP"|o1ctrp=="CHOP/Mitoxanthrone"|o1ctrp=="CNOP"|o1ctrp=="CAVmp-BV"|o1ctrp=="MACOP-B"|o1ctrp=="Onbekend CAVmP BV H8 protocol")
replace anthra=1 if o1ctrp=="MCAVE-CEC"|o1ctrp=="M-CAVE-CEC"|o1ctrp=="MCAVE"|o2ctrp=="MCAVE-CEC"|o2ctrp=="M-CAVE-CEC"|o2ctrp=="MCAVE"
replace anthra=99 if (anthra==.|anthra==0)&ctcat==99
replace anthra=0 if statusnr==851547
replace anthra=1 if statusnr==820952|statusnr==2491540|statusnr==8396724|statusnr==840668|statusnr==940121|statusnr==1304630|statusnr==780149
replace anthra=8 if (anthra==.|anthra==0)&ctcat==0
replace anthra=0 if (anthra==8|anthra==0)&ctcat~=0
label define anthra 0"no anthracyclines" 1"anthracyclines" 8"no ct" 99"unknown"
label val anthra anthrap anthra
tab anthra anthrap, m
sort anthrap anthra c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
browse statusnr ZRnr anthrap anthra c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
tab anthra anthrap, m

replace cisptp=8 if ctcatp==0
gen cispt=cisptp
sort cisptp cispt c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
browse statusnr ZRnr cisptp cispt c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
replace cispt=1 if cispt==0&cisptp==1
replace cispt=0 if cispt==1&cisptp==0
replace cispt=99 if cispt==0&cisptp==99
replace cispt=1 if c1ctrp==31|c2ctrp==31|c3ctrp==31
replace cispt=1 if c1ctrp==87|c2ctrp==87|c3ctrp==87
replace cispt=1 if c1ctrp==102|c2ctrp==102|c3ctrp==102
replace cispt=99 if (cispt==.|cispt==0)&ctcata==99
replace cispt=1 if o1ctrp=="cyclo+etop+bcnu+cyta+dexa+cisp"
replace cispt=8 if (cispt==.|cispt==0)&ctcat==0
replace cispt=0 if (cispt==8|cispt==0)&ctcat~=0
replace cispt=1 if statusnr==6063469
label define cispt 0"no cisplatinum" 1"cisplatinum" 8"no ct" 99"unknown"
label val cispt cisptp cispt
sort cisptp cispt c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
browse statusnr ZRnr cisptp cispt c1ctp c2ctp c3ctp c1ctrp c2ctrp c3ctrp o1ctp o2ctp o3ctp o1ctrp o2ctrp o3ctrp
tab cispt cisptp, m

tab zkh
replace codeur="10" if codeur=="Cherita"
replace codeur="11" if codeur=="ESTHER"|codeur=="Estehr"|codeur=="Esther"|codeur=="esther"
destring codeur, replace

gen sex=mv
drop mv
gen gebdat=birthdat
gen dxdat=mdy(mbg,dbg,jbg)
gen txdat=mdy(mrtp,drtp,jrtp)
replace txdat=mdy(mctp,dctp,jctp) if dctp~=.&mdy(mctp,dctp,jctp)<=mdy(mrtp,drtp,jrtp)&drtp~=.
replace txdat=mdy(mctp,dctp,jctp) if dctp~=.&drtp==.
replace txdat=dxdat if txdat==.
gen dbg5=dbg
gen mbg5=mbg
gen jbg5=jbg+5
gen statusin=1
gen codenr=statusnr+310000000
order codenr, after(statusnr)

drop cat_c1ctprim-cat_therapy

save "E:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Stata files\Analysebestand_UMCU_opgeschoond.dta", replace





