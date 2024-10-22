**** gebruik de file die wordt aangemaakt met de do-file "Inlezen en opschonen rookdata" 

clear
clear matrix
set memory 200m
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014 update roken en tweede tumoren.dta", clear

replace mp40=7 if mp40==.&sex==1
replace mp40=99 if mp40==.&sex==2
tab mp40 sex,m

tab agekt4,m

**** ik maak een variabele aan voor mechlorethamine (ja/nee) timedependent
gen mechp=1
replace mechp=2 if c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==81|c1ctp==92|c1ctp==94|c1ctp==103
replace mechp=2 if o1ctp=="injekties notrogen/mustard"|o1ctp=="MOPP-CHVP"
replace mechp=2 if c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==81|c2ctp==92|c2ctp==94|c2ctp==103
replace mechp=2 if o2ctp=="MVPP-ABV"|o2ctp=="schema v. nicholson MOPP zonder prednison ivm psychose agv prednison"|o2ctp=="MVEPP"
replace mechp=2 if c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==81|c3ctp==92|c3ctp==94|c3ctp==103
replace mechp=2 if o3ctp=="MOPP-Bleomycine ipv procarbazinena tweede kuur"
replace mechp=2 if c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==81|c4ctp==92|c4ctp==94|c4ctp==103
replace mechp=2 if o3ctp=="MOPP-Bleomycine ipv procarbazinena tweede kuur"
sort mechp c1ctp c2ctp c3ctp c4ctp
tab mechp
replace mechp=99 if ctcatp==99
replace mechp=0 if ctcatp==0

gen mech=1
replace mech=2 if mechp==2
replace mech=2 if c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==81|c1ctrp==92|c1ctrp==94|c1ctrp==103
replace mech=2 if o1ctrp=="Nicholson schema: pred/natulan/velbe/mitoxine"|o1ctrp=="injekties nitrogen/mustard"|o1ctrp=="Mitoxine,velbe,natulan,prednison"|o1ctrp=="MOPP-ABVD"
replace mech=2 if c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==81|c2ctrp==92|c2ctrp==94|c2ctrp==103
replace mech=2 if o2ctrp=="MEPP = mitoxine etoposide natulan prednison"|o2ctrp=="MVePP"
replace mech=2 if c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==81|c3ctrp==92|c3ctrp==94|c3ctrp==103
replace mech=2 if c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==81|c4ctrp==92|c4ctrp==94|c4ctrp==103
replace mech=2 if c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==81|c5ctrp==92|c5ctrp==94|c5ctrp==103

replace mech=2 if c1ctfupx==23|c1ctfupx==40|c1ctfupx==59|c1ctfupx==60|c1ctfupx==61|c1ctfupx==67|c1ctfupx==68|c1ctfupx==71|c1ctfupx==72|c1ctfupx==81|c1ctfupx==92|c1ctfupx==94|c1ctfupx==103
replace mech=2 if c2ctfupx==23|c2ctfupx==40|c2ctfupx==59|c2ctfupx==60|c2ctfupx==61|c2ctfupx==67|c2ctfupx==68|c2ctfupx==71|c2ctfupx==72|c2ctfupx==81|c2ctfupx==92|c2ctfupx==94|c2ctfupx==103
replace mech=2 if c3ctfupx==23|c3ctfupx==40|c3ctfupx==59|c3ctfupx==60|c3ctfupx==61|c3ctfupx==67|c3ctfupx==68|c3ctfupx==71|c3ctfupx==72|c3ctfupx==81|c3ctfupx==92|c3ctfupx==94|c3ctfupx==103
sort mech c1ctrp c2ctrp c3ctrp c4ctrp
tab mech
replace mech=99 if ctcat==99
replace mech=0 if ctcat==0

replace mech=99 if codenr==48667374
replace anthrap=8 if codenr==7000891244|codenr==50005589
replace anthra=8 if codenr==7000891244|codenr==50005589
replace anthra=99 if codenr==7000810149

**** ik maak een variabele aan voor mechlorethamine (met dosis) time-dependent
**** primaire therapie
sort mechp ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp
browse zoeknr mechp ctcatp ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp
gen mechdosep=0 if ctcatp==0
replace mechp=0 if zoeknr==5589
replace mechdosep=0 if zoeknr==5589
replace mechdosep=1 if mechp==1&mechdosep==.
replace mechdosep=2 if mechdosep==.&mechp==2&((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp<=3))
replace mechdosep=2 if mechdosep==.&mechp==2&((c1ctp==81)&(n1ctp<=6))
replace mechdosep=3 if mechdosep==.&mechp==2&((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>3&n1ctp~=.&n1ctp<88))
replace mechdosep=3 if mechdosep==.&mechp==2&((c1ctp==81)&(n1ctp>6&n1ctp~=.&n1ctp<88))
replace mechdosep=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>6&n1ctp~=.&n1ctp<88))
replace mechdosep=3 if (mechdosep==1)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp<=6&n2ctp~=.&n2ctp<88))
replace mechdosep=3 if (mechdosep==2)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp<=3&n2ctp~=.&n2ctp<88))
replace mechdosep=4 if (mechdosep==2)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp>6&n2ctp~=.&n2ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp>3&n2ctp~=.&n2ctp<88))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp<=3))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp>3&n2ctp<=6))
replace mechdosep=4 if (mechdosep==.|mechdosep==1|mechdosep==2|mechdosep==3)&((c2ctp==23|c2ctp==40|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==67|c2ctp==68|c2ctp==71|c2ctp==72|c2ctp==92|c2ctp==94|c2ctp==103)&(n2ctp>6&n2ctp~=.&n2ctp<88))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c2ctp==81)&(n2ctp<=6))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c2ctp==81)&(n2ctp>6&n2ctp~=.&n2ctp<88))
replace mechdosep=4 if (mechdosep==2)&((c2ctp==81)&(n2ctp>12&n2ctp~=.&n2ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c2ctp==81)&(n2ctp>6&n2ctp~=.&n2ctp<88))
replace mechdosep=3 if ((c1ctp==40&n1ctp==3)&((c2ctp==40|c2ctp==72)&n2ctp==3))|((c1ctp==40&n1ctp==3)&((c2ctp==40|c2ctp==72)&n2ctp==2))|((c1ctp==40&n1ctp==3)&((c2ctp==40|c2ctp==72)&n2ctp==1))
replace mechdosep=4 if ((c1ctp==40&n1ctp==6)&((c2ctp==40|c2ctp==72)&n2ctp>=1))|((c1ctp==40&n1ctp==5)&((c2ctp==40|c2ctp==72)&n2ctp>=2))|((c1ctp==40&n1ctp==4)&((c2ctp==40|c2ctp==72)&n2ctp>=3))
replace mechdosep=4 if ((c1ctp==40&n1ctp==6)&(c2ctp==81&n2ctp>=1))|((c1ctp==40&n1ctp==5)&(c2ctp==81&n2ctp>=3))|((c1ctp==40&n1ctp==4)&(c2ctp==81&n2ctp>=5))
replace mechdosep=3 if (mechdosep==1)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp<=6&n3ctp~=.&n3ctp<88))
replace mechdosep=3 if (mechdosep==2)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp<=3&n3ctp~=.&n3ctp<88))
replace mechdosep=4 if (mechdosep==.|mechdosep==1|mechdosep==2|mechdosep==3)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp>6&n3ctp~=.&n3ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp>3&n3ctp~=.&n3ctp<88))
replace mechdosep=4 if (mechdosep==2)&((c3ctp==81)&(n3ctp>12&n3ctp~=.&n3ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c3ctp==81)&(n3ctp>6&n3ctp~=.&n3ctp<88))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp<=3))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp>3&n2ctp<=6))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c3ctp==81)&(n3ctp<=6&n3ctp~=.&n3ctp<88))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c3ctp==81)&(n3ctp>6&n3ctp~=.&n3ctp<88))
replace mechdosep=4 if (mechdosep==.|mechdosep==1|mechdosep==2|mechdosep==3)&((c3ctp==23|c3ctp==40|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==67|c3ctp==68|c3ctp==71|c3ctp==72|c3ctp==92|c3ctp==94|c3ctp==103)&(n3ctp>6&n3ctp~=.&n3ctp<88))
replace mechdosep=3 if (mechdosep==1)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp<=6&n4ctp~=.&n4ctp<88))
replace mechdosep=3 if (mechdosep==2)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp<=3&n4ctp~=.&n4ctp<88))
replace mechdosep=4 if (mechdosep==.|mechdosep==1|mechdosep==2|mechdosep==3)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp>6&n4ctp~=.&n4ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp>3&n4ctp~=.&n4ctp<88))
replace mechdosep=4 if (mechdosep==2)&((c4ctp==81)&(n4ctp>12&n4ctp~=.&n4ctp<88))
replace mechdosep=4 if (mechdosep==3)&((c4ctp==81)&(n4ctp>6&n4ctp~=.&n4ctp<88))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp<=3))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp>3&n4ctp<=6))
replace mechdosep=2 if (mechdosep==.|mechdosep==1)&((c4ctp==81)&(n4ctp<=6&n4ctp~=.&n4ctp<88))
replace mechdosep=3 if (mechdosep==.|mechdosep==1)&((c4ctp==81)&(n4ctp>6&n4ctp~=.&n4ctp<88))
replace mechdosep=4 if (mechdosep==.|mechdosep==1)&((c4ctp==23|c4ctp==40|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==67|c4ctp==68|c4ctp==71|c4ctp==72|c4ctp==92|c4ctp==94|c4ctp==103)&(n4ctp>6&n4ctp~=.&n4ctp<88))

replace mechdosep=2 if zoeknr==782068|zoeknr==9540222
replace mechdosep=3 if zoeknr==700182|zoeknr==700399|zoeknr==670495|zoeknr==911036|zoeknr==812966|zoeknr==832324|zoeknr==742641|zoeknr==573628|zoeknr==842791|zoeknr==930536|zoeknr==523197|zoeknr==730301|zoeknr==731371
replace mechdosep=3 if zoeknr==801149|zoeknr==841627|zoeknr==883220|zoeknr==830350|zoeknr==85936|zoeknr==883761|zoeknr==903647|zoeknr==7000690380
replace mechdosep=4 if zoeknr==52624|zoeknr==821320|zoeknr==811428|zoeknr==845168|zoeknr==751961|zoeknr==730301|zoeknr==804055|zoeknr==883761|zoeknr==780392|zoeknr==7000731019|zoeknr==7009183169
replace mechdosep=2 if mechp==2&mechdosep==.&(c1ctp==81)&o1ctp=="6 kuren of meer"
replace mechdosep=3 if mechp==2&mechdosep==.&(c1ctp==40|c1ctp==61)&o1ctp=="6 kuren of meer"&ctcatp==4
replace mechdosep=4 if mechp==2&mechdosep==.&(c1ctp==40|c1ctp==61)&o1ctp=="6 kuren of meer"&ctcatp==5
replace mechdosep=9 if mechp==2&mechdosep==.
replace mechdosep=99 if mechp==99&mechdosep==.
sort mechdosep mechp ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp
label def chloormethine 0"geen CT" 1"geen chloormethine" 2"chloormethine <=36 mg/m2" 3"chloormethine 36-72 mg/m2" 4"chloormethine >72 mg/m2" 9"chloormethine, amount unknown" 99"CT, but type unknown" 
label val mechdosep chloormethine

**** recidief therapie
sort mech mechp ctcat ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse zoeknr mechp mech mechdosep ctcat ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp o1ctrp o2ctrp
gen mechdose=0 if ctcat==0
replace mechdose=mechdosep if ctrp==2|ctrp==.
replace mechdose=1 if mech==1&mechdose==.
replace mechdose=4 if mechdosep==4
replace mechdose=2 if (mechdosep==0|mechdosep==1)&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp<=3))
replace mechdose=2 if (mechdosep==0|mechdosep==1)&((c1ctrp==81)&(n1ctrp<=6))
replace mechdose=3 if (mechdosep==0|mechdosep==1)&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>3&n1ctrp~=.&n1ctrp<88))
replace mechdose=3 if (mechdosep==0|mechdosep==1)&((c1ctrp==81)&(n1ctrp>6&n1ctrp~=.&n1ctrp<88))
replace mechdose=4 if ((c1ctrp==81)&(n1ctrp>12&n1ctrp~=.&n1ctrp<88))
replace mechdose=4 if ((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>6&n1ctrp~=.&n1ctrp<88))
replace mechdose=3 if (mechdosep==0&mechdose==1)&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp<=6&n2ctrp~=.&n2ctrp<88))
replace mechdose=3 if (mechdosep==0&mechdose==2)&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp<=3&n2ctrp~=.&n2ctrp<88))
replace mechdose=4 if ((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>6&n2ctrp~=.&n2ctrp<88))
replace mechdose=4 if ((c2ctrp==81)&(n2ctrp>12&n2ctrp~=.&n2ctrp<88))
replace mechdose=4 if (mechdosep==0&mechdose==3)&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>3&n2ctrp~=.&n2ctrp<88))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp<=3))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>3&n2ctrp<=6))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c2ctrp==81)&(n2ctrp<=6))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c2ctrp==81)&(n2ctrp>6&n2ctrp~=.&n2ctrp<88))
replace mechdose=4 if (mechdosep==0|mechdosep==1)&mechdose==3&((c2ctrp==81)&(n2ctrp>6&n2ctrp~=.&n2ctrp<88))
replace mechdose=3 if mechdose==.&mechdosep==0&((c1ctrp==40&n1ctrp==3)&((c2ctrp==40|c2ctrp==72)&n2ctrp==3))|((c1ctrp==40&n1ctrp==3)&((c2ctrp==40|c2ctrp==72)&n2ctrp==2))|((c1ctrp==40&n1ctrp==3)&((c2ctrp==40|c2ctrp==72)&n2ctrp==1))
replace mechdose=4 if mechdose==.&mechdosep==0&((c1ctrp==40&n1ctrp==6)&((c2ctrp==40|c2ctrp==72)&n2ctrp>=1))|((c1ctrp==40&n1ctrp==5)&((c2ctrp==40|c2ctrp==72)&n2ctrp>=2))|((c1ctrp==40&n1ctrp==4)&((c2ctrp==40|c2ctrp==72)&n2ctrp>=3))
replace mechdose=4 if mechdose==.&mechdosep==0&((c1ctrp==40&n1ctrp==6)&(c2ctrp==81&n2ctrp>=1))|((c1ctrp==40&n1ctrp==5)&(c2ctrp==81&n2ctrp>=3))|((c1ctrp==40&n1ctrp==4)&(c2ctrp==81&n2ctrp>=5))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==1)&((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp<=6&n3ctrp~=.&n3ctrp<88))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==2)&((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp<=3&n3ctrp~=.&n3ctrp<88))
replace mechdose=4 if ((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp>6&n3ctrp~=.&n3ctrp<88))
replace mechdose=4 if ((c3ctrp==81)&(n3ctrp>12&n3ctrp~=.&n3ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp>3&n3ctrp~=.&n3ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c3ctrp==81)&(n3ctrp>6&n3ctrp~=.&n3ctrp<88))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp<=3))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c3ctrp==23|c3ctrp==40|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==67|c3ctrp==68|c3ctrp==71|c3ctrp==72|c3ctrp==92|c3ctrp==94|c3ctrp==103)&(n3ctrp>3&n2ctrp<=6))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c3ctrp==81)&(n3ctrp<=6&n3ctrp~=.&n3ctrp<88))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c3ctrp==81)&(n3ctrp>6&n3ctrp~=.&n3ctrp<88))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==1)&((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp<=6&n4ctrp~=.&n4ctrp<88))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==2)&((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp<=3&n4ctrp~=.&n4ctrp<88))
replace mechdose=4 if ((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp>6&n4ctrp~=.&n4ctrp<88))
replace mechdose=4 if ((c4ctrp==81)&(n4ctrp>12&n4ctrp~=.&n4ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp>3&n4ctrp~=.&n4ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c4ctrp==81)&(n4ctrp>6&n4ctrp~=.&n4ctrp<88))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp<=3))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c4ctrp==23|c4ctrp==40|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==67|c4ctrp==68|c4ctrp==71|c4ctrp==72|c4ctrp==92|c4ctrp==94|c4ctrp==103)&(n4ctrp>3&n4ctrp<=6))
replace mechdose=2 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c4ctrp==81)&(n4ctrp<=6&n4ctrp~=.&n4ctrp<88))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c4ctrp==81)&(n4ctrp>6&n4ctrp~=.&n4ctrp<88))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==1)&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp<=6&n5ctrp~=.&n5ctrp<88))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==2)&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp<=3&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==1|mechdose==2|mechdose==3)&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp>6&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp>3&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((mechdosep==0|mechdosep==1)&mechdose==3)&((c5ctrp==81)&(n5ctrp>6&n5ctrp~=.&n5ctrp<88))
replace mechdose=2 if ((mechdosep==0|mechdosep==1)&mechdose==1)&mechdosep==0&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp<=3))
replace mechdose=3 if ((mechdosep==0|mechdosep==1)&mechdose==1)&mechdosep==0&((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp>3&n5ctrp<=6))
replace mechdose=2 if ((mechdosep==0|mechdosep==1)&mechdose==1)&mechdosep==0&((c5ctrp==81)&(n5ctrp<=6&n5ctrp~=.&n5ctrp<88))
replace mechdose=3 if (mechdose==.|mechdose==1)&(mechdosep==0|mechdosep==1)&((c5ctrp==81)&(n5ctrp>6&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((c5ctrp==23|c5ctrp==40|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==67|c5ctrp==68|c5ctrp==71|c5ctrp==72|c5ctrp==92|c5ctrp==94|c5ctrp==103)&(n5ctrp>6&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((c5ctrp==81)&(n5ctrp>12&n5ctrp~=.&n5ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=6&n1ctp<88))&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>=1&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=5&n1ctp<88))&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>=2&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=4&n1ctp<88))&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>=3&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=3&n1ctp<88))&((c1ctrp==23|c1ctrp==40|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==67|c1ctrp==68|c1ctrp==71|c1ctrp==72|c1ctrp==92|c1ctrp==94|c1ctrp==103)&(n1ctrp>=4&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=6&n1ctp<88))&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>=1&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=5&n1ctp<88))&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>=2&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=4&n1ctp<88))&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>=3&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=3&n1ctp<88))&((c2ctrp==23|c2ctrp==40|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==67|c2ctrp==68|c2ctrp==71|c2ctrp==72|c2ctrp==92|c2ctrp==94|c2ctrp==103)&(n2ctrp>=4&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=6&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=1&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=5&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=3&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=4&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=5&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=3&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=7&n1ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=6&n1ctp<88))&((c2ctrp==81)&(n2ctrp>=1&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=5&n1ctp<88))&((c2ctrp==81)&(n2ctrp>=3&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=4&n1ctp<88))&((c2ctrp==81)&(n2ctrp>=5&n2ctrp<88))
replace mechdose=4 if ((c1ctp==23|c1ctp==40|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==67|c1ctp==68|c1ctp==71|c1ctp==72|c1ctp==92|c1ctp==94|c1ctp==103)&(n1ctp>=3&n1ctp<88))&((c2ctrp==81)&(n2ctrp>=7&n2ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=8&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=5&n1ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=7&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=6&n1ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=6&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=7&n1ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=7&n1ctp<88))&((c1ctrp==81)&(n1ctrp>=8&n1ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=8&n2ctp<88))&((c2ctrp==81)&(n2ctrp>=5&n2ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=7&n2ctp<88))&((c2ctrp==81)&(n2ctrp>=6&n2ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=6&n2ctp<88))&((c2ctrp==81)&(n2ctrp>=7&n2ctrp<88))
replace mechdose=4 if ((c1ctp==81)&(n1ctp>=5&n2ctp<88))&((c2ctrp==81)&(n2ctrp>=8&n2ctrp<88))
replace mechdose=9 if mechdose==.&(mechp==0|mechp==1)&mech==2

replace mechdose=2 if zoeknr==57203|zoeknr==910303|zoeknr==864992|zoeknr==7002491540
replace mechdose=3 if zoeknr==7000800414|zoeknr==812033|zoeknr==680597|zoeknr==841796|zoeknr==900397|zoeknr==62079|zoeknr==7004161516|zoeknr==7000700328|zoeknr==752199|zoeknr==791427|zoeknr==902352 ///
|zoeknr==9540493|zoeknr==7000951141|zoeknr==910652|zoeknr==9540528|zoeknr==791094|zoeknr==882465|statusnr==3228679|zoeknr==920834|zoeknr==901896|zoeknr==921831|zoeknr==911507|zoeknr==851100|zoeknr==40458|zoeknr==41562|zoeknr==89361|zoeknr==7000171804
replace mechdose=4 if zoeknr==700186|zoeknr==723178|zoeknr==760984|zoeknr==660623|zoeknr==7000780149|zoeknr==741733|zoeknr==861412|zoeknr==82663|zoeknr==841796|zoeknr==921506|zoeknr==895596|zoeknr==100016|zoeknr==75189 ///
|zoeknr==863192|zoeknr==7000020591|zoeknr==690432|zoeknr==7000690380|zoeknr==761406|zoeknr==670495|zoeknr==690476|zoeknr==753538|zoeknr==72223|zoeknr==984586|zoeknr==730920|zoeknr==862819|zoeknr==700182 ///
|zoeknr==822964|zoeknr==70731|zoeknr==46778|zoeknr==7000790457|zoeknr==7004062132|zoeknr==97098|zoeknr==802486|zoeknr==47734|zoeknr==960023|zoeknr==7000790614|zoeknr==84119|zoeknr==764797|zoeknr==703102|zoeknr==703477 ///
|zoeknr==871011|zoeknr==780600|zoeknr==772078|zoeknr==800597|zoeknr==792302|zoeknr==5499253|zoeknr==1017686|zoeknr==61891|zoeknr==102658|zoeknr==790282|zoeknr==59299|zoeknr==810057|zoeknr==872850|zoeknr==95639|zoeknr==700399|zoeknr==891376|zoeknr==89361|zoeknr==7000700328
replace mechdose=9 if zoeknr==7096659|zoeknr==700399|zoeknr==41562|zoeknr==831747|zoeknr==9570047|zoeknr==830173|zoeknr==773360|zoeknr==804877
replace mechdose=99 if zoeknr==712328|zoeknr==703049|zoeknr==662360|zoeknr==672326|zoeknr==851366|zoeknr==842419|zoeknr==703189
replace mechdose=1 if statusnr==1970754
replace mech=1 if statusnr==1970754

replace mechdose=mechdosep if mechdose==.
replace mechdose=99 if mechdose==0&ctcat==99
label val mechdose chloormethine
sort mechdose mechdosep ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp 
browse zoeknr statusnr mechp mech mechdosep mechdose ctcat  c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp o1ctrp o2ctrp

sort c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx o1ctfupx mech mechp ctcat ctrp 
browse statusnr zoeknr mechp mech mechdose mechdosep ctcat ctrp c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx o1ctfupx

*** wat aanpassingen op basis van ctfupx
replace mechdose=2 if statusnr==1970754|zoeknr==842419
replace mech=2 if statusnr==1970754
replace mechdose=4 if zoeknr==854733|zoeknr==885684|statusnr==5344151
replace mechdose=9 if zoeknr==703189

sort ctcat mechdose mech c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx o1ctfupx mech mechp ctcat c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp c5ctp n5ctp c6ctp n6ctp o1ctp o2ctp o3ctp o4ctp
browse zoeknr statusnr  ctcat mechdose mech c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx o1ctfupx mech mechp ctcat c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp o1ctrp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp c5ctp n5ctp c6ctp n6ctp o1ctp o2ctp o3ctp o4ctp

** een paar correcties 
replace ctcatp=4 if zoeknr==43068|zoeknr==44278|zoeknr==801149
replace ctcatp=5 if statusnr==8590919
replace ctcatp=9 if zoeknr==6259

replace ctcat=2 if zoeknr==700791
replace ctcat=4 if zoeknr==43068|zoeknr==44278|zoeknr==801149|zoeknr==790017|zoeknr==823274
replace ctcat=5 if zoeknr==760984|statusnr==8590919|zoeknr==95639
browse zoeknr statusnr ctcatp ctcat mechdose mech c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx o1ctfupx mech mechp ctcat c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp o1ctrp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp c5ctp n5ctp c6ctp n6ctp o1ctp o2ctp o3ctp o4ctp if zoeknr==700791|zoeknr==43068|zoeknr==44278|zoeknr==801149|zoeknr==790017|zoeknr==823274|zoeknr==760984|statusnr==8590919|zoeknr==95639


**** ik maak een variabele aan voor aantal kuren met alkylerende middelen (mechlorethamine, cyclophosphamide, chloorambucil, procarbazine, dacarbazine (dosis-equivalent, min of meer) time-dependent
**** primaire therapie

sort ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp o1ctp
browse statusnr zoeknr mechp ctcatp ctcat ctp c1ctp n1ctp c2ctp n2ctp c3ctp n3ctp c4ctp n4ctp c5ctp n5ctp c6ctp n6ctp o1ctp o2ctp o3ctp o4ctp o5ctp o6ctp
format c1ctp c2ctp c3ctp c4ctp %30.0g
format zoeknr %12.0g

*** eerst eerste CT
gen alkyl_cyclep1=0
replace alkyl_cyclep1=n1ctp if (c1ctp==6|c1ctp==8|c1ctp==11|c1ctp==21|c1ctp==22|c1ctp==23|c1ctp==28|c1ctp==29|c1ctp==40|c1ctp==42|c1ctp==45|c1ctp==47|c1ctp==49|c1ctp==50|c1ctp==51|c1ctp==54|c1ctp==58|c1ctp==59|c1ctp==60|c1ctp==61|c1ctp==64|c1ctp==65|c1ctp==66|c1ctp==67|c1ctp==68|c1ctp==69|c1ctp==71|c1ctp==72|c1ctp==73|c1ctp==74|c1ctp==82|c1ctp==84|c1ctp==88|c1ctp==89|c1ctp==90|c1ctp==91|c1ctp==92|c1ctp==93|c1ctp==94|c1ctp==99|c1ctp==101|c1ctp==103|c1ctp==108|c1ctp==111|c1ctp==113|c1ctp==114|c1ctp==115)|(c1ctp==12|c1ctp==41|c1ctp==61)
replace alkyl_cyclep1=n1ctp*2 if (c1ctp==61)&(n1ctp~=88&n1ctp~=99&n1ctp~=999&n1ctp~=.)
replace alkyl_cyclep1=n1ctp/2 if (c1ctp==81)&(n1ctp~=88&n1ctp~=99&n1ctp~=999&n1ctp~=.)
replace alkyl_cyclep1=999 if (c1ctp==81)& alkyl_cyclep1==0
replace alkyl_cyclep1=999 if alkyl_cyclep1==.
order alkyl_cyclep1, after(n1ctp)
sort ctp alkyl_cyclep1 c1ctp
**** een paar correcties
replace alkyl_cyclep1=999 if zoeknr==9510862|zoeknr==5844738|zoeknr==51620|zoeknr==7000790614|zoeknr==9510869|zoeknr==7004161516|(n1ctp==88|n1ctp==99|n1ctp==888)
replace alkyl_cyclep1=4 if zoeknr==670495|zoeknr==700182|zoeknr==700399|codenr==44056138
replace alkyl_cyclep1=n1ctp if zoeknr==9540691|zoeknr==9540103|zoeknr==7000690047|zoeknr==9540452|zoeknr==9681577|zoeknr==7000700328|zoeknr==9540410|zoeknr==7000730449|zoeknr==7000730975|zoeknr==7000690380

*** tweede CT
gen alkyl_cyclep2=0
replace c2ctp=41 if zoeknr==9570153
replace alkyl_cyclep2=n2ctp if (c2ctp==6|c2ctp==8|c2ctp==11|c2ctp==21|c2ctp==22|c2ctp==23|c2ctp==28|c2ctp==29|c2ctp==40|c2ctp==42|c2ctp==45|c2ctp==47|c2ctp==49|c2ctp==50|c2ctp==51|c2ctp==54|c2ctp==58|c2ctp==59|c2ctp==60|c2ctp==61|c2ctp==64|c2ctp==65|c2ctp==66|c2ctp==67|c2ctp==68|c2ctp==69|c2ctp==71|c2ctp==72|c2ctp==73|c2ctp==74|c2ctp==82|c2ctp==84|c2ctp==88|c2ctp==89|c2ctp==90|c2ctp==91|c2ctp==92|c2ctp==93|c2ctp==94|c2ctp==99|c2ctp==101|c2ctp==103|c2ctp==108|c2ctp==111|c2ctp==113|c2ctp==114|c2ctp==115)|(c2ctp==12|c2ctp==41|c2ctp==61)
replace alkyl_cyclep2=n2ctp*2 if (c2ctp==61)&(n2ctp~=88&n2ctp~=99&n2ctp~=999&n2ctp~=.)
replace alkyl_cyclep2=n2ctp/2 if (c2ctp==81)&(n2ctp~=88&n2ctp~=99&n2ctp~=999&n2ctp~=.)
replace alkyl_cyclep2=999 if (c2ctp==81)& alkyl_cyclep2==0
replace alkyl_cyclep2=999 if alkyl_cyclep2==.
order alkyl_cyclep2, after(n2ctp)
sort ctp alkyl_cyclep2 c2ctp
**** een paar correcties
replace alkyl_cyclep2=999 if zoeknr==7000730975|zoeknr==7000740962|zoeknr==66444|zoeknr==89115|zoeknr==9540752|zoeknr==59241|zoeknr==902352|(n2ctp==88|n2ctp==99|n2ctp==888)
replace alkyl_cyclep2=n2ctp if zoeknr==85581|zoeknr==7004113286|zoeknr==2823481|zoeknr==7009183169|zoeknr==7000171804|zoeknr==7000731019|zoeknr==7000790834
replace alkyl_cyclep2=1 if zoeknr==85581
replace alkyl_cyclep2=2 if codenr==72823481

*** derde CT
gen alkyl_cyclep3=0
replace alkyl_cyclep3=n3ctp if (c3ctp==6|c3ctp==8|c3ctp==11|c3ctp==21|c3ctp==22|c3ctp==23|c3ctp==28|c3ctp==29|c3ctp==40|c3ctp==42|c3ctp==45|c3ctp==47|c3ctp==49|c3ctp==50|c3ctp==51|c3ctp==54|c3ctp==58|c3ctp==59|c3ctp==60|c3ctp==61|c3ctp==64|c3ctp==65|c3ctp==66|c3ctp==67|c3ctp==68|c3ctp==69|c3ctp==71|c3ctp==72|c3ctp==73|c3ctp==74|c3ctp==82|c3ctp==84|c3ctp==88|c3ctp==89|c3ctp==90|c3ctp==91|c3ctp==92|c3ctp==93|c3ctp==94|c3ctp==99|c3ctp==101|c3ctp==103|c3ctp==108|c3ctp==111|c3ctp==113|c3ctp==114|c3ctp==115)|(c3ctp==12|c3ctp==41|c3ctp==61)
replace alkyl_cyclep3=n3ctp*2 if (c3ctp==61)&(n3ctp~=88&n3ctp~=99&n3ctp~=999&n3ctp~=.)
replace alkyl_cyclep3=n3ctp/2 if (c3ctp==81)&(n3ctp~=88&n3ctp~=99&n3ctp~=999&n3ctp~=.)
replace alkyl_cyclep3=999 if (c3ctp==81)& alkyl_cyclep3==0
replace alkyl_cyclep3=999 if alkyl_cyclep3==.
order alkyl_cyclep3, after(n3ctp)
sort ctp alkyl_cyclep3 c3ctp
**** een paar correcties
replace alkyl_cyclep3=999 if zoeknr==2823481|statusnr==4418589|zoeknr==2823481|statusnr==516429|(n3ctp==88|n3ctp==99|n3ctp==888)
replace alkyl_cyclep3=n3ctp if zoeknr==7000790834

*** vierde CT
gen alkyl_cyclep4=0
replace alkyl_cyclep4=n4ctp if (c4ctp==6|c4ctp==8|c4ctp==11|c4ctp==21|c4ctp==22|c4ctp==23|c4ctp==28|c4ctp==29|c4ctp==40|c4ctp==42|c4ctp==45|c4ctp==47|c4ctp==49|c4ctp==50|c4ctp==51|c4ctp==54|c4ctp==58|c4ctp==59|c4ctp==60|c4ctp==61|c4ctp==64|c4ctp==65|c4ctp==66|c4ctp==67|c4ctp==68|c4ctp==69|c4ctp==71|c4ctp==72|c4ctp==73|c4ctp==74|c4ctp==82|c4ctp==84|c4ctp==88|c4ctp==89|c4ctp==90|c4ctp==91|c4ctp==92|c4ctp==93|c4ctp==94|c4ctp==99|c4ctp==101|c4ctp==103|c4ctp==108|c4ctp==111|c4ctp==113|c4ctp==114|c4ctp==115)|(c4ctp==12|c4ctp==41|c4ctp==61)
replace alkyl_cyclep4=n4ctp*2 if (c4ctp==61)&(n4ctp~=88&n4ctp~=99&n4ctp~=999&n4ctp~=.)
replace alkyl_cyclep4=n4ctp/2 if (c4ctp==81)&(n4ctp~=88&n4ctp~=99&n4ctp~=999&n4ctp~=.)
replace alkyl_cyclep4=999 if (c4ctp==81)& alkyl_cyclep4==0
replace alkyl_cyclep4=999 if alkyl_cyclep4==.
order alkyl_cyclep4, after(n4ctp)
sort ctp alkyl_cyclep4 c4ctp
**** een paar correcties
replace alkyl_cyclep4=999 if zoeknr==85936|(n4ctp==88|n4ctp==99|n4ctp==888)

*** vijfde CT
gen alkyl_cyclep5=0
replace alkyl_cyclep5=n5ctp if (c5ctp==6|c5ctp==8|c5ctp==11|c5ctp==21|c5ctp==22|c5ctp==23|c5ctp==28|c5ctp==29|c5ctp==40|c5ctp==42|c5ctp==45|c5ctp==47|c5ctp==49|c5ctp==50|c5ctp==51|c5ctp==54|c5ctp==58|c5ctp==59|c5ctp==60|c5ctp==61|c5ctp==64|c5ctp==65|c5ctp==66|c5ctp==67|c5ctp==68|c5ctp==69|c5ctp==71|c5ctp==72|c5ctp==73|c5ctp==74|c5ctp==82|c5ctp==84|c5ctp==88|c5ctp==89|c5ctp==90|c5ctp==91|c5ctp==92|c5ctp==93|c5ctp==94|c5ctp==99|c5ctp==101|c5ctp==103|c5ctp==108|c5ctp==111|c5ctp==113|c5ctp==114|c5ctp==115)|(c5ctp==12|c5ctp==41|c5ctp==61)
replace alkyl_cyclep5=n5ctp*2 if (c5ctp==61)&(n5ctp~=88&n5ctp~=99&n5ctp~=999&n5ctp~=.)
replace alkyl_cyclep5=n5ctp/2 if (c5ctp==81)&(n5ctp~=88&n5ctp~=99&n5ctp~=999&n5ctp~=.)
replace alkyl_cyclep5=999 if (c5ctp==81)& alkyl_cyclep5==0
replace alkyl_cyclep5=999 if alkyl_cyclep5==.
order alkyl_cyclep5, after(n5ctp)
sort ctp alkyl_cyclep5 c5ctp
**** een paar correcties

*** zesde CT
gen alkyl_cyclep6=0
replace alkyl_cyclep6=n6ctp if (c6ctp==6|c6ctp==8|c6ctp==11|c6ctp==21|c6ctp==22|c6ctp==23|c6ctp==28|c6ctp==29|c6ctp==40|c6ctp==42|c6ctp==45|c6ctp==47|c6ctp==49|c6ctp==50|c6ctp==51|c6ctp==54|c6ctp==58|c6ctp==59|c6ctp==60|c6ctp==61|c6ctp==64|c6ctp==65|c6ctp==66|c6ctp==67|c6ctp==68|c6ctp==69|c6ctp==71|c6ctp==72|c6ctp==73|c6ctp==74|c6ctp==82|c6ctp==84|c6ctp==88|c6ctp==89|c6ctp==90|c6ctp==91|c6ctp==92|c6ctp==93|c6ctp==94|c6ctp==99|c6ctp==101|c6ctp==103|c6ctp==108|c6ctp==111|c6ctp==113|c6ctp==114|c6ctp==115)|(c6ctp==12|c6ctp==41|c6ctp==61)
replace alkyl_cyclep6=n6ctp*2 if (c6ctp==61)&(n6ctp~=88&n6ctp~=99&n6ctp~=999&n6ctp~=.)
replace alkyl_cyclep6=n6ctp/2 if (c6ctp==81)&(n6ctp~=88&n6ctp~=99&n6ctp~=999&n6ctp~=.)
replace alkyl_cyclep6=999 if (c6ctp==81)& alkyl_cyclep6==0
replace alkyl_cyclep6=999 if alkyl_cyclep6==.
order alkyl_cyclep6, after(n6ctp)
sort ctp alkyl_cyclep6 c6ctp
**** een paar correcties

*** sommatie cyclus 1 to 5, zonder onbekende cycli aantallen
gen alkyl_cycle1_6=alkyl_cyclep1+alkyl_cyclep2+alkyl_cyclep3+alkyl_cyclep4+alkyl_cyclep5+alkyl_cyclep6 if (alkyl_cyclep1~=999&alkyl_cyclep2~=999&alkyl_cyclep3~=999&alkyl_cyclep4~=999&alkyl_cyclep5~=999&alkyl_cyclep6~=999)
order alkyl_cycle1_6, after(ctp)
sort ctp alkyl_cycle1_6 c1ctp c2ctp c3ctp c4ctp c5ctp c6ctp n1ctp n2ctp n3ctp n4ctp n5ctp n6ctp alkyl_cycle1_6 alkyl_cyclep1 alkyl_cyclep2 alkyl_cyclep3 alkyl_cyclep4 alkyl_cyclep5 alkyl_cyclep6

replace alkyl_cycle1_6=alkyl_cyclep1+alkyl_cyclep2+alkyl_cyclep3 if alkyl_cycle1_6==.&(alkyl_cyclep1~=999&alkyl_cyclep2~=999&alkyl_cyclep3~=999&(alkyl_cyclep1~=0|alkyl_cyclep2~=0|alkyl_cyclep3~=0))
replace alkyl_cycle1_6=alkyl_cyclep2+alkyl_cyclep3 if alkyl_cycle1_6==.&(alkyl_cyclep1==999&alkyl_cyclep2~=999&alkyl_cyclep3~=999&(alkyl_cyclep2~=0|alkyl_cyclep3~=0))
replace alkyl_cycle1_6=alkyl_cyclep1+alkyl_cyclep3 if alkyl_cycle1_6==.&(alkyl_cyclep1~=999&alkyl_cyclep2==999&alkyl_cyclep3~=999&(alkyl_cyclep1~=0|alkyl_cyclep3~=0))
replace alkyl_cycle1_6=alkyl_cyclep1 if alkyl_cycle1_6==.&(alkyl_cyclep1~=999&alkyl_cyclep2==999&alkyl_cyclep3==999&alkyl_cyclep1~=0)
replace alkyl_cycle1_6=alkyl_cyclep2 if alkyl_cycle1_6==.&(alkyl_cyclep1==999&alkyl_cyclep2~=999&alkyl_cyclep3==999&alkyl_cyclep2~=0)
replace alkyl_cycle1_6=alkyl_cyclep3 if alkyl_cycle1_6==.&(alkyl_cyclep1==999&alkyl_cyclep2==999&alkyl_cyclep3~=999&alkyl_cyclep3~=0)
replace alkyl_cycle1_6=5 if statusnr==4418589

replace alkyl_cycle1_6=999 if zoeknr==692025|zoeknr==702154|zoeknr==701381|zoeknr==771542|zoeknr==7000730975
replace alkyl_cycle1_6=6 if alkyl_cycle1_6==.&o1ctp=="6 kuren of meer"
replace alkyl_cycle1_6=3 if alkyl_cycle1_6==6&o1ctp=="6 kuren of meer"&c1ctp==81
replace alkyl_cycle1_6=999 if alkyl_cycle1_6==.
replace alkyl_cycle1_6=888 if alkyl_cycle1_6==999
replace alkyl_cycle1_6=0 if zoeknr==9511038|zoeknr==9511053|zoeknr==9510857|zoeknr==9510950|zoeknr==9510836|zoeknr==9510904
replace alkyl_cycle1_6=999 if ctcatp==99
replace ctp=1 if statusnr==4286408
sort ctp alkyl_cycle1_6 c1ctp c2ctp c3ctp c4ctp c5ctp n1ctp n2ctp n3ctp n4ctp

**** ik maak een variabele aan voor aantal kuren met anthracycline (mechlorethamine, cyclophosphamide, chloorambucil, procarbazine (dosis-equivalent, min of meer) time-dependent; dacarbazine apart
**** recidief therapie

sort ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp o1ctrp
browse statusnr zoeknr mech ctcat ctrp c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp o1ctrp o2ctrp o3ctrp o4ctrp o5ctrp o6ctrp
format c1ctrp c2ctrp c3ctrp c4ctrp c5ctrp c6ctrp %30.0g

*** eerst eerste recidief CT
gen alkyl_cyclerp1=0|c1ctrp==103
replace alkyl_cyclerp1=n1ctrp if (c1ctrp==4|c1ctrp==6|c1ctrp==8|c1ctrp==11|c1ctrp==17|c1ctrp==20|c1ctrp==21|c1ctrp==22|c1ctrp==23|c1ctrp==29|c1ctrp==40|c1ctrp==42|c1ctrp==44|c1ctrp==45|c1ctrp==47|c1ctrp==49|c1ctrp==50|c1ctrp==51|c1ctrp==54|c1ctrp==56|c1ctrp==57|c1ctrp==58|c1ctrp==59|c1ctrp==60|c1ctrp==61|c1ctrp==63|c1ctrp==64|c1ctrp==65|c1ctrp==66|c1ctrp==67|c1ctrp==68|c1ctrp==69|c1ctrp==71|c1ctrp==72|c1ctrp==73|c1ctrp==74|c1ctrp==76|c1ctrp==82|c1ctrp==84|c1ctrp==85|c1ctrp==88|c1ctrp==89|c1ctrp==90|c1ctrp==91|c1ctrp==92|c1ctrp==93|c1ctrp==94|c1ctrp==99|c1ctrp==101|c1ctrp==103|c1ctrp==104|c1ctrp==105|c1ctrp==108|c1ctrp==111|c1ctrp==113|c1ctrp==114|c1ctrp==115)|(c1ctrp==12|c1ctrp==41|c1ctrp==61)
replace alkyl_cyclerp1=n1ctrp/2 if (c1ctrp==81)&(n1ctrp~=88&n1ctrp~=99&n1ctrp~=999&n1ctrp~=.)
replace alkyl_cyclerp1=999 if (c1ctrp==81)& alkyl_cyclerp1==0
replace alkyl_cyclerp1=999 if alkyl_cyclerp1==.
order alkyl_cyclerp1, after(n1ctrp)
sort ctrp alkyl_cyclerp1 c1ctrp
**** een paar correcties
replace alkyl_cyclerp1=999 if alkyl_cyclerp1==99|alkyl_cyclerp1==.
replace alkyl_cyclerp1=n1ctrp if c1ctrp==888
replace alkyl_cyclerp1=6 if zoeknr==9540185

*** tweede recidief CT
gen alkyl_cyclerp2=0
replace alkyl_cyclerp2=n2ctrp if (c2ctrp==4|c2ctrp==6|c2ctrp==8|c2ctrp==11|c2ctrp==17|c2ctrp==20|c2ctrp==21|c2ctrp==22|c2ctrp==23|c2ctrp==29|c2ctrp==40|c2ctrp==42|c2ctrp==44|c2ctrp==45|c2ctrp==47|c2ctrp==49|c2ctrp==50|c2ctrp==51|c2ctrp==54|c2ctrp==56|c2ctrp==57|c2ctrp==58|c2ctrp==59|c2ctrp==60|c2ctrp==61|c2ctrp==63|c2ctrp==64|c2ctrp==65|c2ctrp==66|c2ctrp==67|c2ctrp==68|c2ctrp==69|c2ctrp==71|c2ctrp==72|c2ctrp==73|c2ctrp==74|c2ctrp==76|c2ctrp==82|c2ctrp==84|c2ctrp==85|c2ctrp==88|c2ctrp==89|c2ctrp==90|c2ctrp==91|c2ctrp==92|c2ctrp==93|c2ctrp==94|c2ctrp==99|c2ctrp==101|c2ctrp==103|c2ctrp==104|c2ctrp==105|c2ctrp==108|c2ctrp==111|c2ctrp==113|c2ctrp==114|c2ctrp==115)|(c2ctrp==12|c2ctrp==41|c2ctrp==61)
replace alkyl_cyclerp2=n2ctrp/2 if (c2ctrp==81)&(n2ctrp~=88&n2ctrp~=99&n2ctrp~=999&n2ctrp~=.)
replace alkyl_cyclerp2=999 if (c2ctrp==81)& alkyl_cyclerp2==0
replace alkyl_cyclerp2=999 if alkyl_cyclerp2==.
order alkyl_cyclerp2, after(n2ctrp)
sort ctrp alkyl_cyclerp2 c2ctrp
**** een paar correcties
replace alkyl_cyclerp2=999 if alkyl_cyclerp2==99|alkyl_cyclerp2==.|zoeknr==783083|zoeknr==7455625|zoeknr==7681541
replace alkyl_cyclerp2=n2ctrp if zoeknr==62307|zoeknr==7000800414|zoeknr==7008396724|zoeknr==3720800|zoeknr==6730978|zoeknr==7001465825|zoeknr==7000790457|zoeknr==7004161516|zoeknr==9591034|zoeknr==1093820|zoeknr==7007856245|zoeknr==7000690380|zoeknr==7008054440|zoeknr==7455625|zoeknr==7002491540|zoeknr==7681541|zoeknr==88062|zoeknr==783083
replace o2ctrp="Mc  ELWAIN (ChVePP)" if zoeknr==1093820
replace alkyl_cyclerp2=2 if zoeknr==9570327 //2 maal ABVD
replace alkyl_cyclerp2=6 if zoeknr==9570153 // 6 maal MOPP


*** derde recidief CT
gen alkyl_cyclerp3=0
replace alkyl_cyclerp3=n3ctrp if (c3ctrp==4|c3ctrp==6|c3ctrp==8|c3ctrp==11|c3ctrp==17|c3ctrp==20|c3ctrp==21|c3ctrp==22|c3ctrp==23|c3ctrp==29|c3ctrp==40|c3ctrp==42|c3ctrp==44|c3ctrp==45|c3ctrp==47|c3ctrp==49|c3ctrp==50|c3ctrp==51|c3ctrp==54|c3ctrp==56|c3ctrp==57|c3ctrp==58|c3ctrp==59|c3ctrp==60|c3ctrp==61|c3ctrp==63|c3ctrp==64|c3ctrp==65|c3ctrp==66|c3ctrp==67|c3ctrp==68|c3ctrp==69|c3ctrp==71|c3ctrp==72|c3ctrp==73|c3ctrp==74|c3ctrp==76|c3ctrp==82|c3ctrp==84|c3ctrp==85|c3ctrp==88|c3ctrp==89|c3ctrp==90|c3ctrp==91|c3ctrp==92|c3ctrp==93|c3ctrp==94|c3ctrp==99|c3ctrp==101|c3ctrp==103|c3ctrp==104|c3ctrp==105|c3ctrp==107|c3ctrp==108|c3ctrp==111|c3ctrp==113|c3ctrp==114|c3ctrp==115)|(c3ctrp==12|c3ctrp==41|c3ctrp==61)
replace alkyl_cyclerp3=n3ctrp/2 if (c3ctrp==81)&(n3ctrp~=88&n3ctrp~=99&n3ctrp~=999&n3ctrp~=.)
replace alkyl_cyclerp3=999 if (c3ctrp==81)& alkyl_cyclerp3==0
replace alkyl_cyclerp3=999 if alkyl_cyclerp3==.
order alkyl_cyclerp3, after(n3ctrp)
sort ctrp alkyl_cyclerp3 c3ctrp
**** een paar correcties
replace alkyl_cyclerp3=999 if alkyl_cyclerp3==99|alkyl_cyclerp3==.
replace alkyl_cyclerp3=n3ctrp if zoeknr==1093820|zoeknr==7008054440|zoeknr==7000911813|zoeknr==7000790457|zoeknr==76875|zoeknr==690404
replace alkyl_cyclerp3=1 if zoeknr==700791|zoeknr==782064

*** vierde recidief CT
gen alkyl_cyclerp4=0
replace alkyl_cyclerp4=n4ctrp if (c4ctrp==4|c4ctrp==6|c4ctrp==8|c4ctrp==11|c4ctrp==17|c4ctrp==20|c4ctrp==21|c4ctrp==22|c4ctrp==23|c4ctrp==29|c4ctrp==40|c4ctrp==42|c4ctrp==44|c4ctrp==45|c4ctrp==47|c4ctrp==49|c4ctrp==50|c4ctrp==51|c4ctrp==54|c4ctrp==56|c4ctrp==57|c4ctrp==58|c4ctrp==59|c4ctrp==60|c4ctrp==61|c4ctrp==62|c4ctrp==63|c4ctrp==64|c4ctrp==65|c4ctrp==66|c4ctrp==67|c4ctrp==68|c4ctrp==69|c4ctrp==71|c4ctrp==72|c4ctrp==73|c4ctrp==74|c4ctrp==76|c4ctrp==82|c4ctrp==84|c4ctrp==85|c4ctrp==88|c4ctrp==89|c4ctrp==90|c4ctrp==91|c4ctrp==92|c4ctrp==93|c4ctrp==94|c4ctrp==96|c4ctrp==98|c4ctrp==99|c4ctrp==101|c4ctrp==103|c4ctrp==104|c4ctrp==105|c4ctrp==107|c4ctrp==108|c4ctrp==111|c4ctrp==113|c4ctrp==114|c4ctrp==115)|(c4ctrp==12|c4ctrp==41|c4ctrp==61)
replace alkyl_cyclerp4=n4ctrp/2 if (c4ctrp==81)&(n4ctrp~=88&n4ctrp~=99&n4ctrp~=999&n4ctrp~=.)
replace alkyl_cyclerp4=999 if (c4ctrp==81)& alkyl_cyclerp4==0
replace alkyl_cyclerp4=999 if alkyl_cyclerp4==.
order alkyl_cyclerp4, after(n4ctrp)
sort ctrp alkyl_cyclerp4 c4ctrp
**** een paar correcties
replace alkyl_cyclerp4=999 if alkyl_cyclerp4==90|alkyl_cyclerp4==99|alkyl_cyclerp4==.
replace alkyl_cyclerp4=n4ctrp if zoeknr==7000790457
replace alkyl_cyclerp4=4 if zoeknr==901292

*** vijfde recidief CT
gen alkyl_cyclerp5=0
replace alkyl_cyclerp5=n5ctrp if (c5ctrp==4|c5ctrp==6|c5ctrp==8|c5ctrp==11|c5ctrp==17|c5ctrp==20|c5ctrp==21|c5ctrp==22|c5ctrp==23|c5ctrp==29|c5ctrp==40|c5ctrp==42|c5ctrp==44|c5ctrp==45|c5ctrp==47|c5ctrp==49|c5ctrp==50|c5ctrp==51|c5ctrp==54|c5ctrp==56|c5ctrp==57|c5ctrp==58|c5ctrp==59|c5ctrp==60|c5ctrp==61|c5ctrp==62|c5ctrp==63|c5ctrp==64|c5ctrp==65|c5ctrp==66|c5ctrp==67|c5ctrp==68|c5ctrp==69|c5ctrp==71|c5ctrp==72|c5ctrp==73|c5ctrp==74|c5ctrp==76|c5ctrp==82|c5ctrp==84|c5ctrp==85|c5ctrp==88|c5ctrp==89|c5ctrp==90|c5ctrp==91|c5ctrp==92|c5ctrp==93|c5ctrp==94|c5ctrp==96|c5ctrp==98|c5ctrp==99|c5ctrp==101|c5ctrp==103|c5ctrp==104|c5ctrp==105|c5ctrp==107|c5ctrp==108|c5ctrp==111|c5ctrp==113|c5ctrp==114|c5ctrp==115)|(c5ctrp==12|c5ctrp==41|c5ctrp==61)
replace alkyl_cyclerp5=n5ctrp/2 if (c5ctrp==81)&(n5ctrp~=88&n5ctrp~=99&n5ctrp~=999&n5ctrp~=.)
replace alkyl_cyclerp5=999 if (c5ctrp==81)& alkyl_cyclerp5==0
replace alkyl_cyclerp5=999 if alkyl_cyclerp5==.
order alkyl_cyclerp5, after(n5ctrp)
sort ctrp alkyl_cyclerp5 c5ctrp
**** een paar correcties
replace alkyl_cyclerp5=999 if alkyl_cyclerp5==90|alkyl_cyclerp5==99|alkyl_cyclerp5==.

*** zesde recidief CT
gen alkyl_cyclerp6=0
replace alkyl_cyclerp6=n6ctrp if (c6ctrp==4|c6ctrp==6|c6ctrp==8|c6ctrp==11|c6ctrp==17|c6ctrp==20|c6ctrp==21|c6ctrp==22|c6ctrp==23|c6ctrp==29|c6ctrp==40|c6ctrp==42|c6ctrp==44|c6ctrp==45|c6ctrp==47|c6ctrp==49|c6ctrp==50|c6ctrp==51|c6ctrp==54|c6ctrp==56|c6ctrp==57|c6ctrp==58|c6ctrp==59|c6ctrp==60|c6ctrp==61|c6ctrp==62|c6ctrp==63|c6ctrp==64|c6ctrp==65|c6ctrp==66|c6ctrp==67|c6ctrp==68|c6ctrp==69|c6ctrp==71|c6ctrp==72|c6ctrp==73|c6ctrp==74|c6ctrp==76|c6ctrp==82|c6ctrp==84|c6ctrp==85|c6ctrp==88|c6ctrp==89|c6ctrp==90|c6ctrp==91|c6ctrp==92|c6ctrp==93|c6ctrp==94|c6ctrp==96|c6ctrp==98|c6ctrp==99|c6ctrp==100|c6ctrp==101|c6ctrp==103|c6ctrp==104|c6ctrp==105|c6ctrp==107|c6ctrp==108|c6ctrp==111|c6ctrp==113|c6ctrp==114|c6ctrp==115)|(c6ctrp==12|c6ctrp==41|c6ctrp==61)
replace alkyl_cyclerp6=n6ctrp/2 if (c6ctrp==81)&(n6ctrp~=88&n6ctrp~=99&n6ctrp~=999&n6ctrp~=.)
replace alkyl_cyclerp6=999 if (c6ctrp==81)& alkyl_cyclerp6==0
replace alkyl_cyclerp6=999 if alkyl_cyclerp6==.
order alkyl_cyclerp6, after(n6ctrp)
sort ctrp alkyl_cyclerp6 c6ctrp
**** een paar correcties
replace alkyl_cyclerp6=999 if alkyl_cyclerp6==90|alkyl_cyclerp6==99|alkyl_cyclerp6==.

*** sommatie cyclus 1 to 6, zonder onbekende cycli aantallen
gen alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp2+alkyl_cyclerp3+alkyl_cyclerp4+alkyl_cyclerp5+alkyl_cyclerp6 if (alkyl_cyclerp1~=999&alkyl_cyclerp2~=999&alkyl_cyclerp3~=999&alkyl_cyclerp4~=999&alkyl_cyclerp5~=999&alkyl_cyclerp6~=999)
order alkyl_cyclerp1_6, after(ctrp)
sort ctp alkyl_cyclerp1_6 c1ctrp c2ctrp c3ctrp c4ctrp c5ctrp n1ctrp n2ctrp n3ctrp n4ctrp n5ctrp n6ctrp

replace alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp2+alkyl_cyclerp3+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2~=999&alkyl_cyclerp3~=999&alkyl_cyclerp4~=999&(alkyl_cyclerp1~=0|alkyl_cyclerp2~=0|alkyl_cyclerp3~=0|alkyl_cyclerp4~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp2+alkyl_cyclerp3 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2~=999&alkyl_cyclerp3~=999&alkyl_cyclerp4==999&(alkyl_cyclerp2~=0|alkyl_cyclerp3~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp3+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2==999&alkyl_cyclerp3~=999&alkyl_cyclerp4~=999&(alkyl_cyclerp1~=0|alkyl_cyclerp3~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp2+alkyl_cyclerp3+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2~=999&alkyl_cyclerp3~=999&alkyl_cyclerp4~=999&(alkyl_cyclerp2~=0|alkyl_cyclerp4~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp2+alkyl_cyclerp3 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2~=999&alkyl_cyclerp3~=999&alkyl_cyclerp4==999&(alkyl_cyclerp2~=0|alkyl_cyclerp3~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp3 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2==999&alkyl_cyclerp3~=999&alkyl_cyclerp4==999&(alkyl_cyclerp1~=0|alkyl_cyclerp3~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp2+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2~=999&alkyl_cyclerp3==999&alkyl_cyclerp4~=999&(alkyl_cyclerp2~=0|alkyl_cyclerp4~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp1+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2==999&alkyl_cyclerp3==999&alkyl_cyclerp4~=999&(alkyl_cyclerp1~=0|alkyl_cyclerp4~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp3+alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2==999&alkyl_cyclerp3~=999&alkyl_cyclerp4~=999&(alkyl_cyclerp3~=0|alkyl_cyclerp4~=0))
replace alkyl_cyclerp1_6=alkyl_cyclerp1 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1~=999&alkyl_cyclerp2==999&alkyl_cyclerp3==999&alkyl_cyclerp4==999&alkyl_cyclerp1~=0)
replace alkyl_cyclerp1_6=alkyl_cyclerp2 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2~=999&alkyl_cyclerp3==999&alkyl_cyclerp4==999&alkyl_cyclerp2~=0)
replace alkyl_cyclerp1_6=alkyl_cyclerp3 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2==999&alkyl_cyclerp3~=999&alkyl_cyclerp4==999&alkyl_cyclerp3~=0)
replace alkyl_cyclerp1_6=alkyl_cyclerp4 if alkyl_cyclerp1_6==.&(alkyl_cyclerp1==999&alkyl_cyclerp2==999&alkyl_cyclerp3==999&alkyl_cyclerp4==999&alkyl_cyclerp4~=0)

replace alkyl_cyclerp1_6=1 if zoeknr==9570311
replace alkyl_cyclerp1_6=3 if zoeknr==97098|zoeknr==88062|zoeknr==7002491540
replace alkyl_cyclerp1_6=4 if zoeknr==660463
replace alkyl_cyclerp1_6=6 if zoeknr==856339|zoeknr==95639
replace alkyl_cyclerp1_6=7 if zoeknr==960023
replace alkyl_cyclerp1_6=8 if zoeknr==62307|zoeknr==734000
replace alkyl_cyclerp1_6=10 if zoeknr==912742
replace alkyl_cyclerp1_6=12 if zoeknr==854733
replace alkyl_cyclerp1_6=16 if zoeknr==81361
replace alkyl_cyclerp1_6=23 if zoeknr==76875
replace alkyl_cyclerp1_6=25 if zoeknr==102658

replace alkyl_cyclerp1_6=888 if zoeknr==671359
replace alkyl_cyclerp1_6=12 if zoeknr==692446|zoeknr==733148|zoeknr==99607 //hoge dosis procarbazine en/of cyclofosfamide, exacte dosis niet bekend

replace alkyl_cyclerp1_6=999 if alkyl_cyclerp1_6==.
replace alkyl_cyclerp1_6=888 if alkyl_cyclerp1_6==999
replace alkyl_cyclerp1_6=999 if alkyl_cyclerp1_6==0&c1ctrp==999
sort ctp alkyl_cyclerp1_6 c1ctp c2ctp c3ctp c4ctp c5ctp n1ctp n2ctp n3ctp n4ctp

sort ctrp alkyl_cyclerp1_6 n1ctrp c1ctrp n1ctrp n2ctrp c2ctrp n2ctrp n3ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp ctcat ctcatp
browse statusnr zoeknr ctrp mech ctcatp ctcat alkyl_cyclerp1_6 c1ctrp n1ctrp alkyl_cyclerp1 o1ctrp c2ctrp n2ctrp alkyl_cyclerp2 o2ctrp c3ctrp n3ctrp alkyl_cyclerp3 o3ctrp c4ctrp n4ctrp alkyl_cyclerp4 o4ctrp c5ctrp n5ctrp alkyl_cyclerp5 o5ctrp c6ctrp n6ctrp alkyl_cyclerp6 o6ctrp  

**** samenvoegen alkyl_cycle1_6 met alkyl_cyclerp1_6
sort alkyl_cyclerp1_6 alkyl_cycle1_6
browse zoeknr statusnr alkyl_cyclerp1_6 alkyl_cycle1_6 ctcatp ctcat
gen alkyl_cycletot=alkyl_cycle1_6+alkyl_cyclerp1_6 if (alkyl_cycle1_6~=888&alkyl_cycle1_6~=999&alkyl_cyclerp1_6~=888&alkyl_cyclerp1_6~=999)
replace alkyl_cycletot=888 if (alkyl_cycle1_6==888&(alkyl_cyclerp1_6==0|alkyl_cyclerp1_6==888))|(alkyl_cycle1_6==0&alkyl_cyclerp1_6==888)
replace alkyl_cycletot=999 if (alkyl_cycle1_6==999&(alkyl_cyclerp1_6==0|alkyl_cyclerp1_6==999))|(alkyl_cycle1_6==0&alkyl_cyclerp1_6==999)

*** handmatige checks op alkylerende CT op basis van ctfupx (geen zin om dat te programmeren)
sort c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx
browse codenr statusnr ctcat ctcatp jrechdp alkyl_cycletot c1ctrp n1ctrp c2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp c1ctp c2ctp c3ctp c4ctp c5ctp n1ctp n2ctp n3ctp n4ctp c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx c5ctfupx n5ctfupx c6ctfupx  n6ctfupx

replace alkyl_cycletot=alkyl_cycletot+1 if codenr==46151039
replace alkyl_cycletot=alkyl_cycletot+2 if codenr==10824381|codenr==9540516|codenr==22954192
replace alkyl_cycletot=alkyl_cycletot+2.5 if codenr==41970754
replace alkyl_cycletot=alkyl_cycletot+3 if codenr==21821317|codenr==22885684|codenr==20391018
replace alkyl_cycletot=alkyl_cycletot+4 if codenr==10780419|codenr==48740328|codenr==22902419|codenr==11842419
replace alkyl_cycletot=alkyl_cycletot+5 if codenr==43228679|codenr==11840080
replace alkyl_cycletot=alkyl_cycletot+6 if codenr==20354317|codenr==22960023|codenr==10822964|codenr==24801685
replace alkyl_cycletot=alkyl_cycletot+7 if codenr==29317628
replace alkyl_cycletot=alkyl_cycletot+8 if codenr==10791415
replace alkyl_cycletot=alkyl_cycletot+10 if codenr==21854733
replace alkyl_cycletot=alkyl_cycletot+17 if codenr==45344151
replace alkyl_cycletot=alkyl_cycletot+19 if codenr==20780305
replace alkyl_cycletot=alkyl_cycletot+2 if codenr==21810057  // aantal extra kuren niet bekend, maar zat al op 11 kuren, nog kuren MOPP/ABV, ga er maar vanuit dat dat er 3 of meer waren

replace alkyl_cycletot=888 if codenr==9510984|codenr==9511153|codenr==9511098|codenr==9510869

gen noimpute_alkyl_cycle1_6_=alkyl_cycle1_6
gen noimpute_alkyl_cyclerp1_6=alkyl_cyclerp1_6
gen noimpute_alkyl_cycletot=alkyl_cycletot

**** wat te doen als een maal CT type onbekend? Negeer ik als >3 kuren, onderschat dan deels het probleem
replace alkyl_cycletot=alkyl_cycle1_6 if (alkyl_cycle1_6>3&(alkyl_cyclerp1_6==999))
replace alkyl_cycletot=alkyl_cyclerp1_6 if (alkyl_cyclerp1_6>3&(alkyl_cycle1_6==999))
**** wat te doen als een maal aantal cycli onbekend, maar bekend dat akylerende is gegeven? Ik voeg het mediane aantal kuren (voor drie perioden, gebaseerd op of datum HL of datum recidief HL) voor alle patienten toe
recode jrechdp (1965/1976=1) (1977/1988=2) (1989/2010=3), gen(treat_rec_per)
bysort treat_rec_per: tabstat alkyl_cyclerp1_6 if alkyl_cyclerp1_6>0&alkyl_cyclerp1_6<888, stat(median) 
replace alkyl_cycletot=alkyl_cycle1_6+8 if (alkyl_cycle1_6<888&(alkyl_cyclerp1_6==888)&treat_rec_per==1)
replace alkyl_cycletot=alkyl_cycle1_6+7 if (alkyl_cycle1_6<888&(alkyl_cyclerp1_6==888)&treat_rec_per==2)
replace alkyl_cycletot=alkyl_cycle1_6+3 if (alkyl_cycle1_6<888&(alkyl_cyclerp1_6==888)&treat_rec_per==3)

bysort treat_per: tabstat alkyl_cycle1_6 if alkyl_cycle1_6>0&alkyl_cycle1_6<888, stat(median)  
replace alkyl_cycletot=alkyl_cyclerp1_6+6 if (alkyl_cyclerp1_6<888&(alkyl_cycle1_6==888)&treat_per==1)
replace alkyl_cycletot=alkyl_cyclerp1_6+6 if (alkyl_cyclerp1_6<888&(alkyl_cycle1_6==888)&treat_per==2)
replace alkyl_cycletot=alkyl_cyclerp1_6+3 if (alkyl_cyclerp1_6<888&(alkyl_cycle1_6==888)&treat_per==3)

**** categoriseren alkylerende chemotherapie
gen alkylp=1 if alkyl_cycle1_6==0
replace alkylp=2 if alkyl_cycle1_6>0&alkyl_cycle1_6<=3
replace alkylp=3 if alkyl_cycle1_6>3&alkyl_cycle1_6<=6
replace alkylp=4 if alkyl_cycle1_6>6&alkyl_cycle1_6<=9
replace alkylp=5 if alkyl_cycle1_6>9&alkyl_cycle1_6<99
replace alkylp=888 if alkyl_cycle1_6==888
** median imputatie naar periode 
replace alkylp=3 if alkylp==888&treat_per==1
replace alkylp=3 if alkylp==888&treat_per==2
replace alkylp=2 if alkylp==888&treat_per==3
replace alkylp=999 if alkyl_cycle1_6==999

gen alkyl=1 if alkyl_cycletot==0
replace alkyl=2 if alkyl_cycletot>0&alkyl_cycletot<=3
replace alkyl=3 if alkyl_cycletot>3&alkyl_cycletot<=6
replace alkyl=4 if alkyl_cycletot>6&alkyl_cycletot<=9
replace alkyl=5 if alkyl_cycletot>9&alkyl_cycletot<99
replace alkyl=888 if alkyl_cycletot==888|alkyl_cycletot==.
replace alkyl=999 if alkyl_cycletot==999

label def alkyl 0"no ct"  1"no alkylating CT" 2"<=3 alkylating cycles" 3"4-6 alkylating cycles" 4"7-9 alkylating cycles" 5"10-12 alkylating cycles" 6">12 alkylating cycles" 888"unknown No of alkylating cycles" 999"unknown CT type"      
label val alkylp alkyl alkyl

*** nog wat handmatige checks op alkylerende CT (geen zin om dat te programmeren)
sort alkyl alkylp alkyl_cycletot ctcat ctcatp
browse codenr statusnr alkyl_cycletot alkylp alkyl ctcat ctcatp jrechdp c1ctrp n1ctrp o1ctrp c2ctrp o2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp c1ctp c2ctp c3ctp c4ctp c5ctp n1ctp n2ctp n3ctp n4ctp o1ctp o2ctp c1ctfupx c2ctfupx c3ctfupx c4ctfupx c5ctfupx c6ctfupx n1ctfupx n2ctfupx n3ctfupx n4ctfupx n5ctfupx n6ctfupx
replace alkylp=2 if codenr==9510869|codenr==9511153|codenr==9510984|codenr==9511098 // ABVD, aantal kuren onbekend, in laagste categorie geplaatst
replace alkyl=2 if codenr==9510869|codenr==9511153|codenr==9510984|codenr==9511098|codenr==20713263
replace alkyl=2 if codenr==9510862|codenr==75844738
replace alkylp=2 if codenr==9510862|codenr==75844738
replace alkyl_cycletot=4 if codenr==44056138
replace alkyl_cycletot=6 if codenr==72823481
replace alkylp=3 if codenr==72823481
replace alkyl=3 if codenr==44056138|codenr==72823481|codenr==20690404
replace alkyl=4 if codenr==20700186|codenr==20753802|codenr==72823481|codenr==10782084|codenr==11851100|codenr==9570393|codenr==21825365
replace alkylp=4 if codenr==20753802|codenr==72823481
replace alkyl=5 if codenr==48740328|codenr==10671359|codenr==44033785|codenr==68601584367|codenr==68901676368|codenr==68801652870|codenr==68301460994|codenr==49288736
replace alkylp=5 if codenr==68601584367|codenr==68901676368|codenr==68801652870|codenr==68301460994|codenr==49288736
replace alkyl=3 if alkyl==2&alkylp==3
replace alkylp=3 if alkyl==3&alkylp==6
replace alkyl=888 if codenr==20703189|codenr==10782084|codenr==11851100|codenr==20713263
replace alkylp=0 if codenr==50005589
replace alkyl=999 if codenr==20672326|codenr==11851366|codenr==20703189|codenr==7000810149

replace alkylp=0 if alkylp==1&ctcatp==0
replace alkyl=0 if alkyl==1&ctcat==0
order alkylp, after(ctcatp)
order alkyl, after(ctcat)
sort ctcatp alkylp
sort ctcat alkyl

*** aanpassen ctcatp en ctcat, imputeren waar nodig 
replace ctcat=3 if zoeknr==670648 // procarbazine voor recidief 
replace ctcat=5 if zoeknr==733148 // jaar procarbazine
replace ctcat=5 if zoeknr==690265 // bijna 2 jaar procarbazine
replace ctcat=5 if codenr==46062072 // bijna 1 jaar procarbazine
replace ctcat=2 if codenr==20805150|codenr==21812172|codenr==20774038 // primaire ct is onbekend, zet ze op alkylerend zonder procarbazine op basis van recidief ct 

gen noimpute_ctcatp=ctcatp
gen noimpute_ctcata1=ctcata1
gen noimpute_ctcat=ctcat
** single mean imputatie procarbazine dosis primair, indien bekend dat procarbazine is gegeven (missende dosis bij 11 pat in 1965-1976, 11 pat 1977-1988 en 76 pat 1989-2000) 
tab ctcatp treat_per
tab ctcatp treat_per if ctcatp>2&ctcatp<9, col
replace ctcatp=4 if (treat_per==1|treat_per==2)&ctcatp==9
replace ctcatp=3 if (treat_per==3)&ctcatp==9
tab ctcatp treat_per

** single mean imputatie procarbazine dosis voor recidief, indien bekend dat procarbazine is gegeven (missende dosis bij 15 pat met recidief in 1965-1976, 14 pat 1977-1988 en 15 pat 1989-2010) 
tab ctcata1 treat_rec_per
tab ctcata1 treat_rec_per if ctcata1>2&ctcata1<9, col
replace ctcata1=5 if (treat_rec_per==1)&ctcata1==9
replace ctcata1=4 if (treat_rec_per==2)&ctcata1==9
replace ctcata1=3 if (treat_rec_per==3)&ctcata1==9
tab ctcata1 treat_rec_per

replace ctcat=ctcata1 if ctcatp==0&ctcat==9&ctcata1~=9
replace ctcat=ctcata1 if (ctcatp==1|ctcatp==2)&ctcat==9&ctcata1~=9
replace ctcat=ctcatp if (ctcat==9)&ctcatp~=9&(ctcata1==0|ctcata1==1|ctcata1==2)
replace ctcat=4 if ctcat==9&ctcatp==3&ctcata1==3
replace ctcat=5 if ctcat==9&(ctcatp==4|ctcata1==4)
replace ctcat=5 if ctcat==9&(ctcatp==5|ctcata1==5)

** een paar handmatige aanpassingen
replace ctcat=1 if codenr==20711761
replace ctcata1=1 if codenr==20711761
replace ctcata1=3 if codenr==12881207|codenr==44033785
replace ctcat=3 if codenr==9570495|codenr==75633032|codenr==47254083|codenr==20761268
replace ctcatp=3 if codenr==20700937 // 2 weken natulan, ga uit van 100mg/dag 
replace ctcatp=3 if codenr==75633032 // bij 2de kuur procarb vervangen door chloorambucil
replace ctcatp=3 if codenr==47254083 // natulan 3 weken, ga uit van 100mg/dag
replace ctcatp=3 if codenr==20761268 // natulan werd niet verdragen, onbekend hoeveel gegeven maar gezien opmerking op lagere dosis gezet
replace ctcatp=5 if codenr==46119385 // 10 maanden natulan
replace ctcat=4 if codenr==11830173|codenr==20804877|codenr==20763360|codenr==48667374|codenr==21864992|codenr==45121418|codenr==1788899|codenr==44033785|codenr==20771542|codenr==68601584367|codenr==68401506972|codenr==68601586416|codenr==68401508195
replace ctcatp=4 if codenr==45121418|codenr==1788899|codenr==68601584367|codenr==68401506972|codenr==68601586416|codenr==68401508195
replace ctcata1=4 if codenr==21864992|codenr==10761090|codenr==7004113286
replace ctcat=5 if codenr==20801476|codenr==20753538|codenr==7004113286
replace ctcata1=5 if codenr==46062072|codenr==20801476|codenr==20690265|codenr==10780419|codenr==10760984|codenr==10752726|codenr==21854733|codenr==22885684|codenr==20733148|codenr==12900397

sort ctcat ctcatp ctcata1 noimpute_ctcatp noimpute_ctcata1 c1ctp c2ctp c3ctp c4ctp c1ctrp c2ctrp c3ctrp c4ctrp
browse codenr statusnr alkyl_cycletot alkylp alkyl ctcat ctcata1 ctcatp noimpute_ctcatp noimpute_ctcata1 noimpute_ctcat jrechdp c1ctp n1ctp o1ctp c2ctp n2ctp o2ctp c3ctp n3ctp c4ctp n4ctp  c5ctp c1ctrp n1ctrp o1ctrp c2ctrp o2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx c5ctfupx n5ctfupx c6ctfupx n6ctfupx

sort alkyl_cycletot alkyl alkylp noimpute_alkyl_cyclerp1_6 noimpute_alkyl_cycle1_6_ ctcat ctcatp ctcata1 c1ctp c2ctp c3ctp c4ctp c1ctrp c2ctrp c3ctrp c4ctrp
browse codenr statusnr alkyl_cycletot alkylp alkyl ctcat ctcata1 ctcatp noimpute_alkyl_cyclerp1_6 noimpute_alkyl_cycle1_6_ jrechdp c1ctp n1ctp o1ctp c2ctp n2ctp o2ctp c3ctp n3ctp c4ctp n4ctp  c5ctp c1ctrp n1ctrp o1ctrp c2ctrp o2ctrp n2ctrp c3ctrp n3ctrp c4ctrp n4ctrp c5ctrp n5ctrp c6ctrp n6ctrp c1ctfupx n1ctfupx c2ctfupx n2ctfupx c3ctfupx n3ctfupx c4ctfupx n4ctfupx c5ctfupx n5ctfupx c6ctfupx n6ctfupx


*** aanmaken variabele dacarbazine
gen dacarbp=0
replace dacarbp=2 if (c1ctp==12|c1ctp==41|c1ctp==61)|(c2ctp==12|c2ctp==41|c2ctp==61)|(c3ctp==12|c3ctp==41|c3ctp==61)|(c4ctp==12|c4ctp==41|c4ctp==61)|(c5ctp==12|c5ctp==41|c5ctp==61)|(c6ctp==12|c6ctp==41|c6ctp==61)
replace dacarbp=1 if ctp==1&dacarbp==0
replace dacarbp=99 if ctcatp==99
tab dacarbp ctcatp
tab dacarbp anthrap
gen dacarb=0
replace dacarb=2 if dacarbp==2
replace dacarb=2 if (c1ctrp==12|c1ctrp==41|c1ctrp==61)|(c2ctrp==12|c2ctrp==41|c2ctrp==61)|(c3ctrp==12|c3ctrp==41|c3ctrp==61)|(c4ctrp==12|c4ctrp==41|c4ctrp==61)|(c5ctrp==12|c5ctrp==41|c5ctrp==61)|(c6ctrp==12|c6ctrp==41|c6ctrp==61)
replace dacarb=2 if (c1ctfupx==12|c1ctfupx==41|c1ctfupx==61)|(c2ctfupx==12|c2ctfupx==41|c2ctfupx==61)|(c3ctfupx==12|c3ctfupx==41|c3ctfupx==61)|(c4ctfupx==12|c4ctfupx==41|c4ctfupx==61)|(c5ctfupx==12|c5ctfupx==41|c5ctfupx==61)|(c6ctfupx==12|c6ctfupx==41|c6ctfupx==61)
replace dacarb=1 if (ctp==1|ctrp==1)&dacarb==0
replace dacarb=99 if ctcat==99
replace dacarb=2 if codenr==11851366
replace dacarb=99 if codenr==48667374|codenr==20804877
replace dacarbp=1 if codenr==50005589
replace dacarb=1 if codenr==50005589
tab dacarb ctcat
tab dacarb anthra
sort dacarb anthra dacarbp anthrap ctcat ctcatp

capture drop ctcat_norec ctcat_5jrec
gen ctcat_norec=ctcatp
replace ctcat_norec=ctcat if relapse==1
gen ctcat_5jrec=ctcat
order ctcat_norec ctcat_5jrec,after(rtcat_5jrec)

gen dacarb_norec=dacarbp
replace dacarb_norec=dacarb if relapse==1
gen dacarb_5jrec=dacarb
order dacarb_norec dacarb_5jrec,after(ctcat_5jrec)

gen mech_norec=mechp
replace mech_norec=mech if relapse==1
gen mech_5jrec=mech
order mech_norec mech_5jrec,after(ctcat_5jrec)

gen mechdose_norec=mechdosep
replace mechdose_norec=mechdose if relapse==1
gen mechdose_5jrec=mechdose
order mechdose_norec mechdose_5jrec,after(mech_5jrec)

gen alkyl_norec=alkylp
replace alkyl_norec=alkyl if relapse==1
gen alkyl_5jrec=alkyl
order alkyl_norec alkyl_5jrec,after(mechdose_5jrec)

gen anthra_norec=anthrap
replace anthra_norec=anthra if relapse==1
gen anthra_5jrec=anthra
order anthra_norec anthra_5jrec,after(mech_5jrec)

*** maak nieuwe RT variabelen
gen para_spleenp=0
replace para_spleenp=2 if omgyp==1|paraap==1|liliacp==1|riliacp==1|niliac==1|lliesp==1|rliesp==1|nliesp==1|vabdomp==1
replace para_spleenp=2 if nlveldp=="bestraling onder diafragma t/m 4de lumbale wervel."|nlveldp=="intrathoracaal, pelvic, submentaal"|nlveldp=="lumbaal L2 t/m L5"|nlveldp=="milthilus en bovenbuik"|nlveldp=="re bekkenhelft + proximale femur)"|nlveldp=="klierrest mesenterium"
replace para_spleenp=1 if miltp==1&(omgyp==1|paraap==1)
replace para_spleenp=1 if nlveldp=="en milt streek" 
sort para_spleenp nlveldp
browse para_spleenp nlveldp

gen para_spleen=para_spleenp
replace para_spleen=1 if miltrp==1|milt==1
replace para_spleen=2 if para_spleen==0&(omgyrp==1|paraarp==1|liliacrp==1|riliacrp==1|niliacrp==1|lliesrp==1|rliesrp==1|nliesrp==1|vabdomrp==1)
replace para_spleen=2 if para_spleen==0&(omgeky==1|paraa==1|liliac==1|riliac==1|niliac==1|llies==1|rlies==1|nlies==1|vabdom==1)
replace para_spleen=2 if para_spleen==0&(nlveldrp=="C1 t/m Th7, re schouder, Th11 t/m L3, re bekkenkom voor, re femur voor, re bovenbeen voor, re en li knie voor"|nlveldrp=="L1-L5"|nlveldrp=="L2 t/m S2"|nlveldrp=="L2-L3, Th9, Th12+L1, li femurkop en omgeving, abdomen li, re+li bekken"|nlveldrp=="L3-L4" ///
|nlveldrp=="L3-L5"|nlveldrp=="Leverhilus/pancreaskop"|nlveldrp=="Lwk voor Th11 t/m L2"|nlveldrp=="TH II, L4-5 S1"|nlveldrp=="Th 11, 12, L1, L5"|nlveldrp=="Th11 t/m L3"|nlveldrp=="Th12tm L5"|nlveldrp=="Th3-Th12, L1-3,Abdomen AP"|nlveldrp=="Th6-9 + rechter buikhelft"|nlveldrp=="abdomen, buike en liezen, Th5"|nlveldrp=="lokaal op osileum beetje onduidelijk (bekken re)" ///
|nlveldrp=="abdomen, deels"|nlveldrp=="buikbad"|nlveldrp=="buikbad bestraling met moving strip"|nlveldrp=="hilus long re, lever"|nlveldrp=="iliaca re"|nlveldrp=="inguinaal rechts"|nlveldrp=="klein bekken en sacrum"|nlveldrp=="lever, Th 10 - L2"|nlveldrp=="leverhilus"|nlveldrp=="leverhilus"|nlveldrp=="li bekkenhelft en coecumgebied" ///
|nlveldrp=="li heup"|nlveldrp=="li heup, L 5 t/m/ th 1"|nlveldrp=="li long, lever (18-06-1-86)"|nlveldrp=="linker bovenbuik en epigastrium"|nlveldrp=="linkerbeen"|nlveldrp=="milt hilus"|nlveldrp=="milthilus"|nlveldrp=="miltsteel"|nlveldrp=="rechterheup"|nlveldrp=="rug rechts onder"|nlveldrp=="nlveldrp"|nlveldrp=="total body"|nlveldrp=="total body bestraling")
sort para_spleen nlveldrp
browse para_spleen nlveldrp

gen paraspleen_norec=para_spleenp
replace paraspleen_norec=para_spleen if relapse==1
gen paraspleen_5jrec=para_spleen
order paraspleen_norec paraspleen_5jrec,after(rtcat_5jrec)

gen supra_norec=rtcat_norec
replace supra_norec=1 if supra_norec==2
replace supra_norec=2 if supra_norec==3|supra_norec==4
replace supra_norec=9 if supra_norec==5
gen supra_5jrec=rtcat_5jrec
replace supra_5jrec=1 if supra_5jrec==2
replace supra_5jrec=2 if supra_5jrec==3|supra_5jrec==4
replace supra_5jrec=9 if supra_5jrec==5
order supra_norec supra_5jrec,after(rtcat_5jrec)

*** nu aanpassing supra_norec en supra_5jrec, splitsing supra other in met en zonder axilla
sort relapse rtcatp rtcat supra_norec supra_5jrec  
browse codenr rtcat rtcatp lokselp rokselp nokselp lokselrp rokselrp nokselrp loksel roksel noksel supra_norec supra_5jrec relapse
recode supra_norec supra_5jrec (2=3)
replace supra_5jrec=2 if supra_5jrec==1&((lokselp==1|rokselp==1|nokselp==1)|(lokselrp==1|rokselrp==1|nokselrp==1)|(loksel==1|roksel==1|noksel==1))
replace supra_norec=2 if supra_norec==1&(lokselp==1|rokselp==1|nokselp==1)
replace supra_norec=2 if supra_norec==1&relapse==1&((lokselp==1|rokselp==1|nokselp==1)|(lokselrp==1|rokselrp==1|nokselrp==1)|(loksel==1|roksel==1|noksel==1))

replace ctcat_norec=0 if ctcat_norec==.

sort relapse rtcat_norec rtcat_5jrec
sort relapse ctcat_norec ctcat_5jrec

*** aanpassen roken (never, previous, current, unknown). Als gestopt voor diagnose HL en diagnose HL <25 dan bij never
sort rokendia agehl rokenfup smoke_age smoke_stop_age
gen rokenooit2=0
replace rokenooit2=1 if rokenfup==3|rokenooit==1
replace rokenooit2=2 if rokenfup==1
replace rokenooit2=9 if rokenooit==9
replace rokenooit2=1 if ((year(birthdat)+smoke_stop_age)<2008)&(smoke_stop_age<90)
replace rokenooit2=0 if smoke_stop_age<25
order rokenooit2, after(rokenooit)
sort rokenooit2 rokenooit rokenfup rokendia
** een paar correcties
replace rokenooit2=1 if codenr==20771721
tab rokenooit2 rokenooit

*** aanpassen doodsoorzaken
replace doz="07999" if doz=="5"|doz=="7"|doz=="8"|doz=="9"|doz=="8888"|doz=="88888"|doz=="999"|doz=="9999"|doz=="X"
replace doz="00382" if doz=="A40.3"
replace doz="01490" if doz=="C14.0"
replace doz="01539" if doz=="C18.9"
replace doz="01541" if doz=="C20.9"
replace doz="01579" if doz=="C25.9"
replace doz="01629" if doz=="C34"
replace doz="01622" if doz=="C34.0"
replace doz="01882" if doz=="C672"
replace doz="02015" if doz=="C81.1"
replace doz="02019" if doz=="C81.9"
replace doz="02029" if doz=="C85.9"
replace doz="02280" if doz=="D18.00"
replace doz="023875" if doz=="D46.9"
replace doz="04229" if doz=="I40.9"
replace doz="04275" if doz=="I46.1"
replace doz="04289" if doz=="I50.9"
replace doz="04349" if doz=="I64"
replace doz="04411" if doz=="I71.1"
replace doz="04869" if doz=="J18.9"
replace doz="05609" if doz=="K56.6"
replace doz="07869" if doz=="R06.8"
replace doz="01889" if doz=="81306"

**** na afspraak met Floor haal ik alle patienten jonger dan 15 jaar eruit
tab agekt4
tab agehl agekt4 if agekt4==1
drop if agehl<15
tab agekt4

**** alleen patienten behandeld tussen 1965 en 2000
drop if txyear<1965|txyear>2000

tab rtct
replace rtct=1 if rtcat~=0
replace rtct=2 if rtcat==0&ctcat~=0
replace rtct=3 if rtcat~=0&ctcat~=0
tab rtcat rtct
tab ctcat rtct
tab rtct

** een paar correcties op relapse, geen datum relapse. Na bekijken pat alsnog ingedeeld
replace relapse=1 if codenr==20692972
replace relapse=1 if codenr==20740752
replace relapse=2 if codenr==40104031

tab sex, m
tab zkh, m
tab agekt4, m
tabstat agehl, stat(p50) m

tab treat_periode, m
capture drop fupnew
gen fupnew=((exitdat-txdat)/365.25)
tabstat fupnew, stat (p50 min max)
capture drop fup_cat
capture drop fup_cat
recode fupnew (5/9.99999=1) (10/14.99999=2) (15/19.99999=3) (20/24.99999=4) (25/29.99999=5) (30/34.99999=6) (35/39.99999=7) (40/max=8), gen(fup_cat)
*label def fup_cat 1"5-9" 2"10-14" 3"15-19" 4"20-24" 5"25-29" 6"30-34" 7"35-39" 8"40+"
label val fup_cat fup_cat
tab fup_cat, m

capture drop age_end
gen age_end=agehl+fupnew
tabstat age_end, stat(median min max)
bysort treat_periode:tabstat age_end, stat(median min max)

tab rtct, m
tab rtcat, m
tab ctcat, m
tab ctcatp, m

replace anthra=1 if codenr==23380416|codenr==25992551|codenr==7000851547|codenr==12881207
tab anthra ctcat, m
tab anthra,m

tab relapse, m
capture drop vstat_end 
recode vstat (1 4=1) (2 5=2) (3 6 7=3), gen(vstat_end)
label val vstat_end vstat
tab vstat vstat_end, m
tab vstat_end, m

tab rtct treat_periode, m
tab rtct treat_periode, nofreq col m chi
tab rtcat treat_periode, m
tab rtcat treat_periode, nofreq col m chi
tab ctcat treat_periode, m
tab ctcat treat_periode, nofreq col m chi
tab ctcatp treat_periode, m
tab ctcat anthra, m
tab anthra treat_periode, m
tab anthra treat_periode, nofreq col m chi

tab alkyl
tab dacarb

tab rtcat treat_periode if rtcat~=9, m
tab rtcat treat_periode if rtcat~=9, nofreq col m chi
tab ctcat treat_periode if ctcat~=99, m
tab ctcat treat_periode if ctcat~=99, nofreq col m chi
tab ctcatp treat_periode, m
tab anthra treat_periode if anthra~=99, m
tab anthra treat_periode if anthra~=99, nofreq col m chi

replace splenectomy=9 if splenectomy==.

**** Klaarmaken file voor koppelen aan algemene bevolkingscijfers
format birthdat %tdDD-NN-CCYY

capture drop entry
gen entry=txdat
format entry %tdDD-NN-CCYY

sort sex event1
replace event1=1749 if event1==1759
replace event1_is=1749 if event1_is==1759
replace event2=1749 if event2==1759
replace event2_is=1749 if event2_is==1759
replace event3=1749 if event3==1759
replace event3_is=1749 if event3_is==1759
tab event1 sex

capture drop exit
gen exit=event1_skin_dat if event1_skin~=.
replace exit=exitdat if exit==.
format exit %tdDD-NN-CCYY

capture drop event
tostring event1_skin, gen(event)
replace event=substr(event,1,3)
destring event, replace force

replace event1_skin=. if codenr==20801149
replace exit=fupdat if codenr==20801149

tab event1_skin
capture drop fup
gen fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_skin if fup<5
tab event1_skin if fup>=5
*** 9 tumoren in eerste 5 jaar, verwijder ik hieronder

replace event1_skin=event2_skin if fup<5
replace event1_skin_dat=event2_skin_dat if fup<5
replace event2_skin=event3_skin if fup<5
replace event2_skin_dat=event3_skin_dat if fup<5
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tab event1_skin if fup<5
tab event1_skin if fup>=5
browse if codenr==9510895

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5
*** 8 tumoren in eerste 5 jaar, verwijder ik hieronder

replace event1=event2 if fup<5
replace exit=event2_dat if fup<5
replace event2=event3 if fup<5
replace event2_dat=event3_dat if fup<5
replace exit=fupdat if exit==.

replace exit=.
replace exit=event1_is_dat if event1_is~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_is if fup<5
tab event1_is if fup>=5
*** 8 tumoren in eerste 5 jaar, verwijder ik hieronder

*** een tweede tumore is eigenlijk eerste tumir (AML blijkbaar, wij hebben de pat ook met een MDS iets later? codenr=12872338). Ik verwijder de AML
replace event2=. if codenr==12872338
replace event2_dat=. if codenr==12872338
replace event2_is=. if codenr==12872338
replace event2_is_dat=. if codenr==12872338
replace event2_skin=. if codenr==12872338
replace event2_skin_dat=. if codenr==12872338

replace event1_is=event2_is if fup<5
replace exit=event2_is_dat if fup<5
replace event2_is=event3_is if fup<5
replace event2_is_dat=event3_is_dat if fup<5
replace exit=fupdat if exit==.

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

replace event1_skin=2050 if (event1_skin==2053|event1_skin==2059)&(m1==98403|m1==98613|m1==98713|m1==98723|m1==98733|m1==98743|m1==99203)
replace event1_skin=2051 if (event1_skin==2050|event1_skin==2051|event1_skin==2053|event1_skin==2059)&(m1==98633)
replace event2_skin=2050 if (event2_skin==2053|event2_skin==2059)&(m2==98403|m2==98613|m2==98713|m2==98723|m2==98733|m2==98743|m2==99203)
replace event2_skin=2051 if (event2_skin==2050|event2_skin==2051|event2_skin==2053|event2_skin==2059)&(m2==98633)
replace event3_skin=2050 if (event3_skin==2053|event3_skin==2059)&(m3==98403|m3==98613|m3==98713|m3==98723|m3==98733|m3==98743|m3==99203)
replace event3_skin=2051 if (event3_skin==2050|event3_skin==2051|event3_skin==2053|event3_skin==2059)&(m3==98633)

replace event1_skin=topo_smn1 if event1_skin==.&event~=.
replace event1_skin_dat=st1dat if event1_skin==.&event~=.

*** voor een paar tumoren (via huisarts?) heb ik (nog) geen incidentiedatum.
*** ik verwijder deze tumoren
replace event=. if codenr==20771721|codenr==20721797|codenr==20801149
replace event1=. if codenr==20771721|codenr==20721797|codenr==20801149
replace event1_is=. if codenr==20771721|codenr==20721797|codenr==20801149
replace event1_skin=. if codenr==20771721|codenr==20721797|codenr==20801149

*** een paar tumoren vastgesteld binnen eerste 5 jaar, eventstatus en data wijzigen
replace event1_dat=. if codenr==40026881|codenr==9511043|codenr==77613537|codenr==9511026|codenr==41434861|codenr==20477369|codenr==78843882|codenr==11860130
replace event1_is_dat=. if codenr==40026881|codenr==9511043|codenr==77613537|codenr==9511026|codenr==41434861|codenr==20477369|codenr==78843882|codenr==11860130
replace event1_skin=. if codenr==40026881|codenr==9511043|codenr==77613537|codenr==9511026|codenr==41434861|codenr==20477369|codenr==78843882|codenr==11860130
replace event=. if codenr==40026881|codenr==9511043|codenr==77613537|codenr==9511026|codenr==41434861|codenr==20477369|codenr==78843882|codenr==11860130
replace event1_skin_dat=. if codenr==11860130

save "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", replace

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
keep sex birthdat entry exit event1_skin rtcat agekt4 ctcat treat_periode fup
*keep sex birthdat entry exit event exposure treat_periode treat_cat anthra
gen total_fupyrs5_9=0
replace total_fupyrs5_9=((exit-(entry+(4.999999*365.25)))/(365.25)) if (fup>=5&fup<10) 
replace total_fupyrs5_9=5 if (fup>=10) 
gen total_fupyrs10_14=0
replace total_fupyrs10_14=((exit-(entry+(9.999999*365.25)))/(365.25)) if (fup>=10&fup<15) 
replace total_fupyrs10_14=5 if (fup>=15) 
gen total_fupyrs15_19=0
replace total_fupyrs15_19=((exit-(entry+(14.999999*365.25)))/(365.25)) if (fup>=15&fup<20) 
replace total_fupyrs15_19=5 if (fup>=20) 
gen total_fupyrs20_24=0
replace total_fupyrs20_24=((exit-(entry+(19.999999*365.25)))/(365.25)) if (fup>=20&fup<25) 
replace total_fupyrs20_24=5 if (fup>=25) 
gen total_fupyrs25_29=0
replace total_fupyrs25_29=((exit-(entry+(24.999999*365.25)))/(365.25)) if (fup>=25&fup<30) 
replace total_fupyrs25_29=5 if (fup>=30) 
gen total_fupyrs30_34=0
replace total_fupyrs30_34=((exit-(entry+(29.999999*365.25)))/(365.25)) if (fup>=30&fup<35) 
replace total_fupyrs30_34=5 if (fup>=35) 
gen total_fupyrs35plus=0
replace total_fupyrs35plus=((exit-(entry+(34.999999*365.25)))/(365.25)) if (fup>=35) 
tabstat total_fupyrs5_9 total_fupyrs10_14 total_fupyrs15_19 total_fupyrs20_24 total_fupyrs25_29 total_fupyrs30_34 total_fupyrs35plus, stat(sum)

save "C:\PYA\PYAstata\ca_inc\Pya_Input_CI.dta", replace
save "C:\PYA\PYAstata\Attained age\ca_inc\Pya_Input_CI.dta", replace
*do "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Hodgkin GI\pyamain hodgkin nejm.do"


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

**** analyses voor eerste tekst deel
tab sex
tab rtcat rtct
tab ctcat rtct
tab ctcat rtct, col nofreq
tab alkyl rtct
tab alkyl rtct, col nofreq
tab rtct
tabstat agehl, stat(p50 p25 p75)
tabstat fupnew, stat(p50 p25 p75 min max)
tab fup_cat
bysort treat_periode:  tabstat fupnew, stat(p50 p25 p75)
tab fupnew
tabstat age_end, stat(p50 p25 p75 min max)
bysort treat_periode:  tabstat age_end, stat(p50 p25 p75)
sort event3_skin event2_skin event1_skin
tab event1_skin
tab event2_skin
tab event3_skin
tab vstat vstat_end
tab vstat if event1_skin~=.
tab vstat if event1_skin==.
replace vstat=7 if vstat==1&exitdat<mdy(12,31,2008)
replace vstat_end=3 if vstat==7&exitdat<mdy(12,31,2008)
tab vstat
tab vstat_end
sort vstat exitdat
tab zkh vstat
tab relapse 
tab splenectomy
tab rtct
tab rtcat
tab ctcat
tab anthra

tab rtct treat_periode
tab rtct treat_periode, nofreq col chi
tab rtcat treat_periode
tab rtcat treat_periode, nofreq col chi
tab ctcat treat_periode
tab ctcat treat_periode, nofreq col chi
tab mechdose treat_periode
tab mechdose treat_periode, nofreq col chi
tab anthra treat_periode
tab anthra treat_periode, nofreq col
tab splenectomy treat_periode
tab splenectomy treat_periode, nofreq col chi

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing risk mamma nieuw, op 3 manieren, alleen dood competing risk, multivariaat met tijdsafhankelijke variabele voor behandeling
keep if sex==2

gen cause=0
replace cause=1 if event1>=1740&event1<=1749
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab agekt4 cause
tab treat_periode cause
tab splenectomy cause
tab rokenooit cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

recode rokenooit (1=2) (2=1)

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (4=3) (2=1)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.relapse_end i.splenectomy i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3
test _Isplenecto_1 _Isplenecto_9 

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing risk mamma nieuw, op 3 manieren, alleen dood competing risk, multivariaat met tijdsafhankelijke variabele voor behandeling
keep if sex==2

gen cause=0
replace cause=1 if event1_skin>=1740&event1_skin<=1749
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1_skin~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab agekt4 cause
tab treat_periode cause
tab splenectomy cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (5=0) (4=3) (2=1)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

recode ctcat_end (4 5=4)
xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_9 _Ictcat_end_99

recode rtcat_end (3=0) (0=2)
xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_2  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_9 _Ictcat_end_99

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing risk mamma nieuw, op 3 manieren, alleen dood competing risk, multivariaat met tijdsafhankelijke variabele voor behandeling
keep if sex==2

gen event_tumorsite=.
replace event_tumorsite=event1_is if event1_is>=1740&event1_is<=1759
gen event_tumorsite_dat=event1_is_dat if event_tumorsite~=.
replace event_tumorsite=event2_is if event_tumorsite==.&(event2_is>=1740&event2_is<=1759)
replace event_tumorsite_dat=event2_is_dat if event_tumorsite_dat==.&event_tumorsite~=.
replace event_tumorsite=event3_is if event_tumorsite==.&(event3_is>=1740&event3_is<=1759)
replace event_tumorsite_dat=event3_is_dat if event_tumorsite_dat==.&event_tumorsite~=.
sort event_tumorsite event1_is event2_is event3_is 
format event_tumorsite_dat %dD-N-CY

replace exit=.
replace exit=event_tumorsite_dat if event_tumorsite~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event_tumorsite if fup<5
tab event_tumorsite if fup>=5
tab vstat if event_tumorsite~=.
tab vstat if event_tumorsite==.

gen cause=0
replace cause=1 if event_tumorsite>=1740&event_tumorsite<=1759
replace cause=2 if (cause==0&vstat_end==2)
tab event1 cause

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
tab relapse
sort relapse

tab agekt4 cause

tab treat_periode cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (5=0) (4=3) (2=1)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing risk mamma nieuw, op 3 manieren, alleen dood competing risk, multivariaat met tijdsafhankelijke variabele voor behandeling
keep if sex==2

replace exit=.
gen cause=0
replace cause=1 if event1_is>=1740&event1_is<=1749
replace exit=event1_is_dat if event1_is>=1740&event1_is<=1749
replace cause=1 if cause==0&(event2_is>=1740&event2_is<=1749)
replace exit=event2_is_dat if cause==1&exit==.
replace cause=1 if cause==0&(event2_is>=1740&event2_is<=1749)
replace exit=event3_is_dat if cause==1&exit==.
replace cause=2 if (cause==0&vstat_end==2)
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1_is if fup<5
tab event1_is if fup>=5

***welke zijn de in-situ events, wat is leeftijd bij in-situ/invasief en hoe verloopt dit over de tijd. PAS OP, patienten zijn bij inclusie gemiddeld ouder in de laatste periode
gen cause_is=0
replace cause_is=1 if (event1_skin==.&cause==1)|(((event1_skin<1740|(event1_skin>1749&event1_skin~=.))&(event2_skin<1740|(event2_skin>1749&event2_skin~=.)))&cause==1)
replace cause_is=1 if codenr==10792476
sort cause cause_is

gen ageBC=(exit-birthdat)/365.25 if cause==1
gen periodBC=0
replace periodBC=1 if cause==1&year(exit)<1985 
replace periodBC=2 if cause==1&(year(exit)>=1985&year(exit)<1990) 
replace periodBC=3 if cause==1&(year(exit)>=1990&year(exit)<1995)
replace periodBC=4 if cause==1&(year(exit)>=1995&year(exit)<2000)
replace periodBC=5 if cause==1&(year(exit)>=2000&year(exit)<2005)
replace periodBC=6 if cause==1&(year(exit)>=2005&year(exit)<2010)
replace periodBC=7 if cause==1&(year(exit)>=2010)
tab periodBC if cause==1
tab periodBC if cause==1&cause_is==0

sort periodBC ageBC
by periodBC: list ageBC if cause==1
by periodBC: tabstat ageBC if cause==1, stat(p50)
by periodBC: tabstat ageBC if cause==1&cause_is==0, stat(p50)

recode periodBC (1 2=1) (3 4=2) (5=3) (6=4) (7=5), gen(periodBC2)
label def periodBC 1"BC<1990" 2"BC 1990-1999" 3"BC 2000-2004" 4"BC 2005-2009" 5"BC >=2010" 
label val periodBC2 periodBC
tabstat ageBC if cause==1&cause_is==0, stat(n p50)  
bysort periodBC2: tabstat ageBC if cause==1&cause_is==0, stat(n p50)
tabstat ageBC if cause==1&cause_is==1, stat(n p50)    
bysort periodBC2: tabstat ageBC if cause==1&cause_is==1, stat(n p50) 
bysort periodBC2: tabstat ageBC if cause==1, stat(n p50)
tabstat ageBC if cause==1, stat(n p50)

bysort treat_periode: tabstat ageBC if cause==1&cause_is==0, stat(n p50)

capture drop attainedage2
gen attainedage2=(mdy(01,01,1985)-birthdat)/365.25 if entry<=mdy(01,01,1985)&exit>mdy(01,01,1985)
tabstat attainedage2, stat(n p50)
capture drop attainedage2
gen attainedage2=(mdy(01,01,1995)-birthdat)/365.25 if entry<=mdy(01,01,1995)&exit>mdy(01,01,1995)
tabstat attainedage2, stat(n p50)
capture drop attainedage2
gen attainedage2=(mdy(06,30,2003)-birthdat)/365.25 if exit>mdy(06,30,2003)
tabstat attainedage2, stat(n p50)
capture drop attainedage2
gen attainedage2=(mdy(06,30,2009)-birthdat)/365.25 if exit>mdy(06,30,2009)
tabstat attainedage2, stat(n p50)
capture drop attainedage2
gen attainedage2=(mdy(06,30,2011)-birthdat)/365.25 if exit>mdy(06,30,2011)
tabstat attainedage2, stat(n p50)

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

bysort treat_periode: tabstat ageBC if cause==1&cause_is==0, stat(n p50)
bysort treat_periode: tabstat ageBC if cause==1&cause_is==1, stat(n p50)
bysort treat_periode: tabstat ageBC if cause==1, stat(n p50)

tab treat_periode cause

*** analyse naar attained age, inclusief in situ
gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(birthdat) id(id) scale(365.25)

replace cause=0 if cause==1&cause_is==0
stset exit, f(cause==1) entry(entrydat) origin(birthdat) id(id) scale(365.25)

replace cause=0 if cause==1&cause_is==1
stset exit, f(cause==1) entry(entrydat) origin(birthdat) id(id) scale(365.25)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1&treat_periode==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) 
sort  _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list  _t CI lowlim hilim if cause==1&treat_periode==2

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1&treat_periode==3

gen id=_n
replace cause=0 if cause==1&cause_is==0|ageBC>=50
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)

replace cause=0 if cause==1&cause_is==1|ageBC>=50
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)

replace cause=0 if ageBC>=50
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1&treat_periode==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) 
sort  _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list  _t CI lowlim hilim if cause==1&treat_periode==2

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) 
sort _t
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list _t CI lowlim hilim if cause==1&treat_periode==3



stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (5=0) (4=3) (2=1)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode, compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end i.treat_periode i.agekt4*i.treat_periode, compete(cause==2)

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing all non-breast solid, op 3 manieren, alleen dood competing risk, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1_skin>=1400&event1_skin<1740)|(event1_skin>1749&event1_skin<=1999)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1_skin~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<=fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<=fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<=fup_relapse))  

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_2 _Irtcat_end_3 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.agekt4*i.treat_periode,compete(cause==2)
test _IageXtre_2_2 _IageXtre_3_2 _IageXtre_2_3 _IageXtre_3_3


xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_1_2 _IrtcXtre_2_2 _IrtcXtre_3_2 _IrtcXtre_4_2 _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_1_3 _IrtcXtre_2_3 _IrtcXtre_3_3 _IrtcXtre_4_3 _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

recode ctcat_end (4 5=4)
xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_9 _Ictcat_end_99


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing all non-breast solid, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1>=1400&event1<1740)|(event1>1749&event1<=1999)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 
recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_2 _Irtcat_end_3 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_1_2 _IrtcXtre_2_2 _IrtcXtre_3_2 _IrtcXtre_4_2 _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_1_3 _IrtcXtre_2_3 _IrtcXtre_3_3 _IrtcXtre_4_3 _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing lung, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1>=1620&event1<=1629)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
bysort zkh: tab txyear rokendia 
bysort zkh: tab txyear rokendia, nofreq row 
recode rokendia (2=1) (1=2)
*replace rokendia=1 if (rokendia==9|rokendia==.)&(zkh==1&txyear<=1995|zkh==2|zkh==4|zkh==6|zkh==7)
tab rokendia cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (1 2=1) (3 4=3)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))   

tab sex treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 
tab rtcat_end treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))   
tab ctcat_end treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_3 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Irtcat_end_1 _Irtcat_end_3 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_1_2 _IrtcXtre_3_2 _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_1_3 _IrtcXtre_3_3 _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode i.rtcat_end*i.treat_periode i.ctcat_end*i.treat_periode,compete(cause==2)

test _IsexXtre_2_2  _IsexXtre_2_3

test _IrtcXtre_1_2 _IrtcXtre_3_2 _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_1_3 _IrtcXtre_3_3 _IrtcXtre_5_3 _IrtcXtre_9_3
	
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform	
	
lincom _Irtcat_end_1 + _IrtcXtre_1_2, eform	 
lincom _Irtcat_end_3 + _IrtcXtre_3_2, eform
lincom _Irtcat_end_5 + _IrtcXtre_5_2, eform
lincom _Irtcat_end_9 + _IrtcXtre_9_2, eform

lincom _Irtcat_end_1 + _IrtcXtre_1_3, eform	 
lincom _Irtcat_end_3 + _IrtcXtre_3_3, eform
lincom _Irtcat_end_5 + _IrtcXtre_5_3, eform
lincom _Irtcat_end_9 + _IrtcXtre_9_3, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform
 
test _IrtcXtre_1_2 _IrtcXtre_3_2 _IrtcXtre_5_2 _IrtcXtre_9_2 _Irtcat_end_1 _Irtcat_end_3 _Irtcat_end_5 _Irtcat_end_9 
test _IrtcXtre_1_3 _IrtcXtre_3_3 _IrtcXtre_5_3 _IrtcXtre_9_3 _Irtcat_end_1 _Irtcat_end_3 _Irtcat_end_5 _Irtcat_end_9 

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.rokendia i.treat_periode if (zkh==1|zkh==2|zkh==4|zkh==6|zkh==7),compete(cause==2)
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.rokendia i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_3 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3
test _Irokendia_2 _Irokendia_9
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.rokendia i.treat_periode i.sex*i.treat_periode i.rtcat_end*i.treat_periode i.ctcat_end*i.treat_periode,compete(cause==2)

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing gastrointestinal, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1_skin>=1510&event1_skin<=1599)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1_skin~=.)
tab event1_skin cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (0 1 3=0) (2 4 5=5)
tab rtcat_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab sex treat_periode if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab ctcat_end treat_periode if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

recode ctcat_end (4 5=4)
xi: stcrreg i.agekt4 i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test  _Irtcat_end_1  _Irtcat_end_3  _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_9 _Ictcat_end_99

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing leukemia MDS, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1>=2040&event1<=2299)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (1 3=1) (2 4=4)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

tab sex treat_periode if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab rtcat_end treat_periode if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab ctcat_end treat_periode if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** competing NHL, multivariaat met tijdsafhankelijke variabele voor behandeling

gen cause=0
replace cause=1 if (event1>=2000&event1<=2029)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1~=.)
tab event1 cause

replace exit=.
replace exit=event1_dat if event1~=.
replace exit=exitdat if exit==.
replace fup=(exit-entry)/365.25
tabstat fup, stat(median sum)
tab event1 if fup<5
tab event1 if fup>=5

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab ctcat cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)
stsplit rec, at(0) after(_t=fup_relapse)
replace rec=1 if rec==0&_t0>5
replace rec=0 if rec==-1

order rtcat, before(rtcat_norec) 
gen rtcat_end=rtcat_norec
replace rtcat_end=rtcat if rec==1
order rtcat, before(rtcat_end) 
label val rtcat_end LABP

gen ctcat_end=ctcat_norec
replace ctcat_end=ctcat if rec==1
label val ctcat_end LABV

*gen relapse_end=relapse if (relapse==0|relapse==1) 
*replace relapse_end=1 if rec==1
*replace relapse_end=0 if relapse_end==.
*tab relapse relapse_end
*tab relapse_end if cause==1&((rec==0&relapse==0|relapse==1)|(rec==1&relapse==2)) 

gen relapse_end=0
replace relapse_end=1 if relapse==1

recode rtcat_end (1 3=1) (2 4=4)
tab rtcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse)) 

recode ctcat_end (1 2=1)
tab ctcat_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

tab relapse_end if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

tab sex treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab rtcat_end treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  
tab ctcat_end treat_periode if cause==1&((rec==0&(relapse==0|relapse==1))|(rec==1&relapse==2)|(rec==0&relapse==2&fup<fup_relapse))  

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end,compete(cause==2)
test _Iagekt4_2 _Iagekt4_3
test _Isplenecto_1 _Isplenecto_9 
test _Irtcat_end_1 _Irtcat_end_4 _Irtcat_end_5 _Irtcat_end_9
test _Ictcat_end_3 _Ictcat_end_4 _Ictcat_end_5 _Ictcat_end_9 _Ictcat_end_99

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.sex*i.treat_periode,compete(cause==2)
test _IsexXtre_2_2  _IsexXtre_2_3
lincom  _Isex_2 + _IsexXtre_2_2, eform
lincom  _Isex_2 + _IsexXtre_2_3, eform

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.rtcat_end*i.treat_periode, compete(cause==2)
test _IrtcXtre_5_2 _IrtcXtre_9_2 ///
     _IrtcXtre_5_3 _IrtcXtre_9_3
	 
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat_end i.ctcat_end i.relapse_end i.treat_periode i.ctcat_end*i.treat_periode, compete(cause==2)
test _IctcXtre_1_2 _IctcXtre_3_2 _IctcXtre_4_2 _IctcXtre_5_2 _IctcXtre_9_2 _IctcXtre_99_2 ///
     _IctcXtre_1_3 _IctcXtre_3_3 _IctcXtre_4_3 _IctcXtre_5_3 _IctcXtre_9_3 _IctcXtre_99_3
	 
lincom _Ictcat_end_1 + _IctcXtre_1_2, eform
lincom _Ictcat_end_3 + _IctcXtre_3_2, eform
lincom _Ictcat_end_4 + _IctcXtre_4_2, eform
lincom _Ictcat_end_5 + _IctcXtre_5_2, eform
lincom _Ictcat_end_9 + _IctcXtre_9_2, eform
lincom _Ictcat_end_99 + _IctcXtre_99_2, eform	 

lincom _Ictcat_end_1 + _IctcXtre_1_3, eform
lincom _Ictcat_end_3 + _IctcXtre_3_3, eform
lincom _Ictcat_end_4 + _IctcXtre_4_3, eform
lincom _Ictcat_end_5 + _IctcXtre_5_3, eform
lincom _Ictcat_end_9 + _IctcXtre_9_3, eform
lincom _Ictcat_end_99 + _IctcXtre_99_3, eform	


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie naar behandelperiode
** competing risk: dood of andere vorm van kanker

capture drop cause
gen cause=0
replace cause=1 if (event1_skin>=1400&event1_skin<=1999)
replace cause=2 if (cause==0&vstat_end==2)|(cause==0&event1_skin~=.)
tab event cause

gen double entrydat=txdat+1826.25

tab relapse
sort relapse

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab ctcat cause

gen id=_n
stset exit, f(cause==1) entry(entrydat) origin(txdat) id(id) scale(365.25)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_treat_periode1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_treat_periode2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_treat_periode3=CI if cause==1

list fup CI_treat_periode1 CI_treat_periode2 CI_treat_periode3 if cause==1

twoway line CI_treat_periode1 CI_treat_periode2 CI_treat_periode3 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)	

tab cause
gen newfup=fup
replace cause=0 if cause~=0&newfup>=20
replace newfup=19.9999 if newfup>=20
tab cause
tab newfup
		
capture drop id
gen id=_n
stset newfup, f(cause==1) id(id)
	
xi: stcrreg i.treat_periode,compete(cause==2 3)
test _Itreat_per_2 _Itreat_per_3
	







 
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear 
*** competing risk: dood of andere vorm van kanker

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==2)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5
tabstat fup_periode, stat(median min max)
bysort treat_periode:tabstat fup_periode, stat(median min max)

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40, labsize(medlarge)) yla(0(10)50,format(%9.1fc) angle(horizontal) labsize(medlarge)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)", size(large)) yti("Cumulative incidence (%)" " ", size(large)) legend(off) scheme(s1manual)

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==2)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

capture drop cause
gen cause=0
replace cause=1 if event>=81&event~=.
replace cause=2 if event<=80&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)	
		
capture drop cause
gen cause=0
replace cause=1 if event>=82&event<=88
replace cause=2 if event<=80&event~=.|event>=89&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
capture drop cause
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)			
	
capture drop cause
gen cause=0
replace cause=1 if event>=15&event<=26
replace cause=2 if event<15|(event>=27&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)			
	
capture drop cause
gen cause=0
replace cause=1 if event==15
replace cause=2 if event<15|(event>=16&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
capture drop cause
gen cause=0
replace cause=1 if event==16
replace cause=2 if event<16|(event>=17&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
	
capture drop cause
gen cause=0
replace cause=1 if event>=18&event<=20
replace cause=2 if event<18|(event>=21&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event<34|(event>=35&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
	
capture drop cause
gen cause=0
replace cause=1 if event>=64&event<=68
replace cause=2 if event<63|(event>=69&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)
	
twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)
	
capture drop cause
gen cause=0
replace cause=1 if event==73
replace cause=2 if event<73|(event>=74&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)
	
twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)	
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie naar leeftijd
** competing risk: dood of andere vorm van kanker

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) ///
	text(38 38 "<20", place(e)) text(42 38.5 "20-29", place(e)) text(52 38 "30-39", place(e)) text(35 37 "40-50", place(e)) scheme(s1manual)

capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=81&event~=.
replace cause=2 if event<=80&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=82&event<=88
replace cause=2 if event<=80&event~=.|event>=89&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=15&event<=26
replace cause=2 if event<15|(event>=27&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)			
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event==15
replace cause=2 if event<15|(event>=16&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event==16
replace cause=2 if event<16|(event>=17&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				
	

capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=18&event<=20
replace cause=2 if event<18|(event>=21&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)			
	
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event<34|(event>=35&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event>=64&event<=68
replace cause=2 if event<63|(event>=69&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				
		
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event==73
replace cause=2 if event<73|(event>=74&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				
		
		
capture drop cause
gen cause=0
replace cause=1 if event==50
replace cause=2 if event<50|(event>=51&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause
keep if sex==2

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)

twoway line CI fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)		
	
capture drop CI_age1 CI_age2 CI_age3 CI_age4	
	
capture drop cause
gen cause=0
replace cause=1 if event==50
replace cause=2 if event<50|(event>=51&event~=.)
replace cause=3 if event==.&(vstat_end==1)
tab cause
keep if sex==2

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if agekt4==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1

twoway line CI_age1 CI_age2 CI_age3 CI_age4 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick) ///
	connect(stairstep stairstep stairstep stairstep) xti("follow-up (years)") yti("Cumulative incidence (%)" " ") legend(off) scheme(s1manual)				

*************************************
*** uitsplitsing naar behandelperiode
*************************************

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"

twoway line CI_periode1 CI_periode2 CI_periode3  fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(6 19 "1990-2000", place(e)) text(34 21 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)

*append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta"
*twoway line CI_periode1 CI_periode2 CI_periode3 cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
*	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
*      text(17 12 "1990-2000", place(e)) text(34 20 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)

capture drop cause CI_periode1 CI_periode2 CI_periode3 CI lowlim hilim
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"

twoway line CI_periode1 CI_periode2 CI_periode3 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of any solid cancer (%)" " ") legend(off)  ///
      text(17 12 "1990-2000", place(e)) text(34 20 "1980-1989", place(e)) text(39 25 "1965-1979", place(e)) scheme(s1manual)	

capture drop cause CI_periode1 CI_periode2 CI_periode3 CI lowlim hilim
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"

set obs 1601
replace CI_periode3=0.1628664 in 1601
replace fup=20 in 1601
replace cause=1 in 1601

set obs 1602
replace CI_periode3=0 in 1602
replace fup=5 in 1602
replace cause=1 in 1602

set obs 1603
replace CI_periode1=2.526412 in 1603
replace fup=40 in 1603
replace cause=1 in 1603

set obs 1604
replace CI_periode2=0.8660501 in 1604
replace fup=31 in 1604
replace cause=1 in 1604

set obs 1605
replace CI_periode2=0 in 1605
replace fup=5 in 1605
replace cause=1 in 1605

set obs 1606
replace CI_periode1=0 in 1606
replace fup=5 in 1606
replace cause=1 in 1606

twoway line CI_periode1 CI_periode2 CI_periode3 fup if cause==1, sort xla(0(5)40) yla(0(1)5,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(0.4 12 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	
	
*capture drop cause	
capture drop cause CI_periode1 CI_periode2 CI_periode3 CI lowlim hilim
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

replace event=. if fup>20
replace fup=20 if fup>20	

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)	

xi: stcrreg i.sex age i.treat_periode,compete(cause==2 3)

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)	

xi: stcrreg i.sex age i.treat_periode,compete(cause==2)

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)	

xi: stcrreg i.sex age i.treat_periode,compete(cause==2 3)

capture drop cause
gen cause=0
replace cause=1 if (event==50)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)	

xi: stcrreg age i.treat_periode if sex==2,compete(cause==2 3)
	
***Uitsplitsing naar RT en anthra en RT	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear
recode rtcat (0=0) (1 3=1) (2 4=2) (5=3), gen(rtcat_recoded)
tab rtcat rtcat_recoded

tab anthra
gen anthra_recoded1=1 if anthra==0&(rtcat_recoded==0|rtcat_recoded==3)
replace anthra_recoded1=2 if anthra==1&(rtcat_recoded==0|rtcat_recoded==3)
replace anthra_recoded1=3 if anthra==0&(rtcat_recoded==1|rtcat_recoded==2)
replace anthra_recoded1=4 if anthra==1&(rtcat_recoded==1|rtcat_recoded==2)
replace anthra_recoded1=9 if anthra==99|anthra==.|rtcat_recoded==9
tab anthra_recoded1 rtcat_recoded

gen anthra_recoded2=1 if anthra==0&(rtcat_recoded==0|rtcat_recoded==1)
replace anthra_recoded2=2 if anthra==1&(rtcat_recoded==0|rtcat_recoded==1)
replace anthra_recoded2=3 if anthra==0&(rtcat_recoded==2|rtcat_recoded==3)
replace anthra_recoded2=4 if anthra==1&(rtcat_recoded==2|rtcat_recoded==3)
replace anthra_recoded2=9 if anthra==99|anthra==.|rtcat_recoded==9
tab anthra_recoded2 rtcat_recoded

gen anthra_recoded3=1 if anthra==0&(rtcat_recoded==0)
replace anthra_recoded3=2 if anthra==1&(rtcat_recoded==0)
replace anthra_recoded3=3 if anthra==0&(rtcat_recoded==1|rtcat_recoded==2|rtcat_recoded==3|rtcat_recoded==9)
replace anthra_recoded3=4 if anthra==1&(rtcat_recoded==1|rtcat_recoded==2|rtcat_recoded==3|rtcat_recoded==9)
replace anthra_recoded3=9 if anthra==99|anthra==.
tab anthra_recoded3 rtcat_recoded

capture drop exposure
rename rtcat_recoded exposure
format birthdat %tdDD-NN-CCYY
format entry %tdDD-NN-CCYY 
format exit %tdDD-NN-CCYY

tab sex
recode sex (1=2) (2=1)
	
keep sex birthdat entry exit event exposure anthra_recoded1 anthra_recoded2 anthra_recoded3
save "C:\PYA\PYAstata\ca_inc\Pya_Input_CI.dta", replace	
	

****************************************************************
**** anthra&Radiotherapy
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2014.dta", clear
recode rtcat (0=0) (1 3=1) (2 4=2) (5=3), gen(rtcat_recoded)
tab rtcat rtcat_recoded

tab anthra
gen anthra_recoded1=1 if anthra==0&(rtcat_recoded==0|rtcat_recoded==3)
replace anthra_recoded1=2 if anthra==1&(rtcat_recoded==0|rtcat_recoded==3)
replace anthra_recoded1=3 if anthra==0&(rtcat_recoded==1|rtcat_recoded==2)
replace anthra_recoded1=4 if anthra==1&(rtcat_recoded==1|rtcat_recoded==2)
replace anthra_recoded1=9 if anthra==99|anthra==.|rtcat_recoded==9
tab anthra_recoded1 rtcat_recoded

gen anthra_recoded2=1 if anthra==0&(rtcat_recoded==0|rtcat_recoded==1)
replace anthra_recoded2=2 if anthra==1&(rtcat_recoded==0|rtcat_recoded==1)
replace anthra_recoded2=3 if anthra==0&(rtcat_recoded==2|rtcat_recoded==3)
replace anthra_recoded2=4 if anthra==1&(rtcat_recoded==2|rtcat_recoded==3)
replace anthra_recoded2=9 if anthra==99|anthra==.|rtcat_recoded==9
tab anthra_recoded2 rtcat_recoded

gen anthra_recoded3=1 if anthra==0&(rtcat_recoded==0)
replace anthra_recoded3=2 if anthra==1&(rtcat_recoded==0)
replace anthra_recoded3=3 if anthra==0&(rtcat_recoded==1|rtcat_recoded==2|rtcat_recoded==3|rtcat_recoded==9)
replace anthra_recoded3=4 if anthra==1&(rtcat_recoded==1|rtcat_recoded==2|rtcat_recoded==3|rtcat_recoded==9)
replace anthra_recoded3=9 if anthra==99|anthra==.
tab anthra_recoded3 rtcat_recoded

capture drop exposure
rename rtcat_recoded exposure

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab cause anthra_recoded3

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded3==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded3==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded3==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded3==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

list fup CI_age1 CI_age2 CI_age3 CI_age4 if cause==1
xi: stcrreg i.anthra_recoded3, compete(cause==2)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4
xi: stcrreg i.anthra_recoded3 if anthra_recoded3~=9, compete(cause==2)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4
	
capture drop CI_age1-CI_age4
capture drop cause
gen cause=0
replace cause=1 if (event>=00&event<=15)|(event>=30&event<=39)|event==50|event==73|event==69|event==70|event==71
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded1 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded1 if anthra_recoded1~=9, compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause 
gen cause=0
replace cause=1 if (event==15)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded1 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

recode anthra_recoded1 (1=4) (4=1), gen(anthra_recodedx)
xi: stcrreg i.anthra_recodedx if anthra_recodedx~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4
xi: stcrreg i.anthra_recoded1 if anthra_recoded1~=9&anthra_recoded1~=1&anthra_recoded1~=2,compete(cause==2 3)
test _Ianthra_re_3 _Ianthra_re_4
drop anthra_recodedx

xi: stcrreg i.exposure2 if exposure2~=9, compete(cause==2 3)

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if (event==34)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded1 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded1 if anthra_recoded1~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if (event==50)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded1 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==1&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==2&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==3&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded1==4&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded1 if anthra_recoded1~=9&anthra_recoded1~=1&anthra_recoded1~=2&sex==2,compete(cause==2 3)
test _Ianthra_re_4

capture drop CI_age1-CI_age4
capture drop cause
gen cause=0
replace cause=1 if (event>=16&event<=26)|(event>=51&event<=68)|event==74|event==75
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded2 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded2 if anthra_recoded2~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if event==16
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded2 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded2 if anthra_recoded2~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if event>=18&event<=20
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded2 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded2 if anthra_recoded2~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4

capture drop CI_age1 CI_age2 CI_age3 CI_age4
capture drop cause
gen cause=0
replace cause=1 if event>=64&event<=68
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab anthra_recoded2 cause 

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age1=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age2=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age3=CI if cause==1

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if anthra_recoded2==4, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_age4=CI if cause==1

xi: stcrreg i.anthra_recoded2 if anthra_recoded2~=9,compete(cause==2 3)
test _Ianthra_re_2 _Ianthra_re_3 _Ianthra_re_4




*** aanmaken multivariaat model
*** competing risk: dood of andere vorm van kanker

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab sex
tab agekt4
tab splenectomy
tab treat_periode
tab rtcat
tab ctcat
tab anthra

recode rtcat (0 5=0)(1 2 3 4=1) (9 . =9), gen(rt_abovedia)
tab rtcat rt_abovedia
recode rtcat (0 1 3=0)(2 4 5=1) (9 . =9), gen(rt_belowdia)
tab rtcat rt_belowdia
recode ctcat (0 1 2=0) (3=1) (4 5=2) (9=3) (99 . =4), gen(procarbazin)
tab ctcat procarbazin
recode ctcat (0 1 2=0) (3=1) (4=2) (5=3) (9=4) (99 . =5), gen(procarbazin2)
tab ctcat procarbazin2
recode ctcat (0 1 2=0) (3 4 5 9=1) (99 . =2), gen(procarbazin3)
tab ctcat procarbazin3

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==50&sex==2
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
replace splenectomy=9 if splenectomy==.
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab ctcat cause
tab ctcat2 cause,m
tab ctcat ctcat2,m
replace ctcat2=0 if ctcat==0&ctcat2==.
tab ctcat2 cause,m
tab procarbazin cause, m
tab anthra cause

recode rtcat (3 4=0) (1 2=1) (5=2) (0=3) (9=5), gen(rt_mf2) 
recode rtcat (0=0) (1 2=1) (3 4=2) (5=3) (9=5), gen(rt_mf) 
tab rtcat cause if anthra==0, col nofreq
tab rtcat cause if anthra==1, col nofreq
tab rtcat cause if anthra==0, row nofreq
tab rtcat cause if anthra==1, row nofreq

xi: stcrreg i.sex i.agekt4 i.treat_periode i.rt_abovedia i.rt_belowdia i.anthra i.procarbazin,compete(cause==2 3 4)

xi: stcrreg i.sex i.agekt4 i.treat_periode i.splenectomy i.rtcat i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Itreat_per_2 _Itreat_per_3
test _Isplenecto_1 _Isplenecto_9
test _Irtcat_1 _Irtcat_2 _Irtcat_3 _Irtcat_4 _Irtcat_5 _Irtcat_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

*recode sex (1=2) (2=1)
*xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat i.anthra i.procarbazin,compete(cause==2 3 4)
xi: stcrreg i.sex age i.splenectomy i.rtcat i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irtcat_1 _Irtcat_2 _Irtcat_3 _Irtcat_4 _Irtcat_5 _Irtcat_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

recode rt_mf (0=0) (1 2 3 5=1), gen(rtmfz)
xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtmfz i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4
drop rtmfz

xi: stcrreg i.sex i.agekt4 i.rtcat i.anthra i.procarbazin2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irtcat_1 _Irtcat_2 _Irtcat_3 _Irtcat_4 _Irtcat_5 _Irtcat_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.agekt4 i.rt_mf2 i.anthra i.procarbazin2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

capture drop cause
gen cause=0
replace cause=1 if event>=0&event<=15|event>=30&event<=39|event==50|event>=69&event<=71|event==73
replace cause=1 if event==72&topo_2==725|(event==49&(topo_2==490|topo_2==491|topo_2==493))|(event==47&(topo_2==470|topo_2==471|topo_2==473))|(event==43&(event_1==1720|event_1==1721|event_1==1722|event_1==1723|event_1==1724|event_1==1726))|(event==40&(topo_2==400))
replace cause=2 if event~=.&cause~=1
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause
tab event cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab treat_periode cause
tab rtcat cause
tab ctcat cause
tab procarbazin cause
tab anthra cause

xi: stcrreg i.sex i.agekt4 i.treat_periode i.rt_abovedia i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Itreat_per_2 _Itreat_per_3
test _Irt_aboved_1 _Irt_aboved_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.treat_periode i.splenectomy i.rt_abovedia i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Itreat_per_2 _Itreat_per_3
test _Isplenecto_1 _Isplenecto_9
test _Irt_aboved_1 _Irt_aboved_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.splenectomy i.rtcat i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irtcat_1 _Irtcat_2 _Irtcat_3 _Irtcat_4 _Irtcat_5 _Irtcat_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

capture drop cause
gen cause=0
replace cause=2 if event>=0&event<=15|event>=30&event<=39|event==50|event>=69&event<=71|event==73|event==80
replace cause=2 if event==72&topo_2==725|(event==49&(topo_2==490|topo_2==491|topo_2==493))|(event==47&(topo_2==470|topo_2==471|topo_2==473))|(event==43&(event_1==1720|event_1==1721|event_1==1722|event_1==1723|event_1==1724|event_1==1726))|(event==40&(topo_2==400))
replace cause=1 if event~=.&cause~=2
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause
tab event cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab treat_periode cause
tab rtcat cause
tab ctcat cause
tab anthra cause

xi: stcrreg i.sex i.agekt4 i.treat_periode i.rt_belowdia i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Itreat_per_2 _Itreat_per_3
test _Irt_belowd_1 _Irt_belowd_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4


capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=.&cause~=1
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab rt_mf cause
tab ctcat cause
tab procarbazin cause
tab anthra cause

recode sex (1=2) (2=1)
recode rt_mf (0 3=0) (1=1) (2=2) (5=.), gen(rt_mfx)

xi: stcrreg i.sex i.agekt4 i.rt_mf i.splenectomy i.anthra i.procarbazin2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.rt_mf i.splenectomy i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.rt_mf i.anthra i.procarbazin2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex age i.rt_mfx i.splenectomy i.anthra i.procarbazin,compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex age i.rt_mfx i.splenectomy i.anthra i.procarbazin i.treat_periode,compete(cause==2 3 4) 
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4
test _Itreat_per_2 _Itreat_per_3

xi: stcrreg i.sex age i.rt_mfx i.splenectomy i.anthra i.procarbazin i.treat_periode i.treat_periode*i.sex,compete(cause==2 3 4) 
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4
test _Itreat_per_2 _Itreat_per_3
test _ItreXsex_2_2 _ItreXsex_3_2

lincom _Itreat_per_2+_ItreXsex_2_2, eform
lincom _Itreat_per_3+_ItreXsex_3_2, eform

gen treatperiod=0 if treat_periode==1&sex==1
replace treatperiod=1 if treat_periode==2&sex==1
replace treatperiod=2 if treat_periode==3&sex==1
replace treatperiod=3 if treat_periode==1&sex==2
replace treatperiod=4 if treat_periode==2&sex==2
replace treatperiod=5 if treat_periode==3&sex==2

xi: stcrreg age i.rt_mfx i.splenectomy i.anthra i.procarbazin i.treatperiod,compete(cause==2 3 4) 
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4
test _Itreatperi_1 _Itreatperi_2 _Itreatperi_3 _Itreatperi_4 _Itreatperi_5


capture drop cause
gen cause=0
replace cause=1 if event==16|(event>=17&event<=20)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab rt_belowdia cause
tab rtcat rt_belowdia
tab rt_mf cause
tab ctcat cause
tab procarbazin cause
tab anthra cause

xi: stcrreg i.sex i.agekt4 i.rt_belowdia i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_belowd_1 _Irt_belowd_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.rt_belowdia i.splenectomy i.anthra i.procarbazin,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_belowd_1 _Irt_belowd_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex age i.rt_belowdia i.splenectomy i.anthra i.procarbazin,compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Irt_belowd_1 _Irt_belowd_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex age i.rt_belowdia i.splenectomy i.anthra i.procarbazin if rt_belowdia~=9&procarbazin~=3&procarbazin~=4,compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Irt_belowd_1 _Irt_belowd_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex age i.rt_belowdia i.procarbazin if rt_belowdia~=9&procarbazin~=3&procarbazin~=4,compete(cause==2 3 4)
test _Irt_belowd_1 
test _Iprocarbaz_1 _Iprocarbaz_2

capture drop cause
gen cause=0
replace cause=1 if event==50&sex==2
replace cause=2 if event~=.&cause~=1
replace cause=3 if event>=81&event~=.
replace cause=4 if event==.&(vstat_end==1)
tab cause
tab cause if sex==2

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup if sex==2, f(cause==1) id(id)

tab agekt4 cause if sex==2
tab rt_mf cause if sex==2
tab rt_mf2 cause if sex==2
tab ctcat cause if sex==2 
tab anthra cause if sex==2
tab procarbazin cause if sex==2
tab splenectomy cause if sex==2

xi: stcrreg i.agekt4 i.splenectomy i.rt_mf i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.agekt4 i.rt_mf i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

recode rt_mf (0 3=0) (1 2=1) (5=2), gen(rtmfy)
tab rt_mf rtmfy if sex==2
xi: stcrreg i.agekt4 i.splenectomy i.rtmfy i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

*keep if rt_mf==1|rt_mf==2
*recode rt_mf (2=0)
xi: stcrreg i.agekt4 i.splenectomy i.rt_mf i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.agekt4 i.rt_mf2 i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.agekt4 i.splenectomy i.rt_mf2 i.anthra i.procarbazin if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg age i.splenectomy i.rt_mf2 i.anthra i.procarbazin if sex==2,collinear compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg age i.splenectomy i.rt_mf2 i.anthra i.procarbazin if sex==2&rt_mf2~=5&procarbazin~=3&procarbazin~=4,collinear compete(cause==2 3 4)
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.agekt4 i.rt_mf2 i.anthra i.procarbazin2 if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4 _Iprocarbaz_5 

xi: stcrreg i.agekt4 i.rt_mf2 i.splenectomy i.anthra i.procarbazin2 if sex==2,compete(cause==2 3 4)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf2_1 _Irt_mf2_2 _Irt_mf2_3 _Irt_mf2_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4 _Iprocarbaz_5 


capture drop cause
gen cause=0
replace cause=1 if event>=91&event~=.
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab rt_belowdia cause
tab rtcat rt_belowdia
tab rt_mf cause
tab ctcat cause
tab procarbazin cause
tab anthra cause

xi: stcrreg i.sex i.agekt4 i.rt_mf i.anthra i.procarbazin,compete(cause==2 3)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.rt_mf i.splenectomy i.anthra i.procarbazin,compete(cause==2 3)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

recode rtcat (0=5) (1 3=0) (2 4=1) (5=2) (9=4), gen(rt_mf3)
tab rtcat rt_mf3
tab rt_mf3 cause 
xi: stcrreg i.sex age i.rt_mf3 i.splenectomy i.anthra i.procarbazin,compete(cause==2 3)
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf3_1 _Irt_mf3_2 _Irt_mf3_4 _Irt_mf3_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

capture drop cause
gen cause=0
replace cause=1 if event>=82&event<=85&event~=.
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab sex cause
tab agekt4 cause
tab splenectomy cause
tab treat_periode cause
tab rtcat cause
tab rt_belowdia cause
tab rtcat rt_belowdia
tab rt_mf cause
tab ctcat cause
tab procarbazin cause
tab anthra cause

xi: stcrreg i.sex i.agekt4 i.rt_mf i.anthra i.procarbazin,compete(cause==2 3)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

xi: stcrreg i.sex i.agekt4 i.rt_mf i.splenectomy i.anthra i.procarbazin,compete(cause==2 3)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

recode rt_mf (0=0) (1 2 3 5=1), gen(rtmfz)
recode procarbazin (0=0) (1 2 3 4=1), gen(chemz)
tab rt_mf rtmfz
tab procarbazin chemz

xi: stcrreg i.sex i.agekt4 i.rtmfz i.splenectomy i.chemz,compete(cause==2 3)
test _Iagekt4_2 _Iagekt4_3 _Iagekt4_4
test _Isplenecto_1 _Isplenecto_9
test _Irt_mf_1 _Irt_mf_2 _Irt_mf_3 _Irt_mf_5
test _Ianthra_1 _Ianthra_9
test _Iprocarbaz_1 _Iprocarbaz_2 _Iprocarbaz_3 _Iprocarbaz_4

keep sex birthdat entry exit event exposure anthra_recoded1 anthra_recoded2 anthra_recoded3
save "C:\PYA\PYAstata\ca_inc\Pya_Input_CI.dta", replace

**** bepalen incidentie derde tumoren
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear
keep if event~=.
tab event

*** aanmaken event codes voor persoonsjarenanalyse

gen event_new=substr(st2,2,4)
replace event_new=substr(st3,2,4) if codenr==20660463
destring event_new, replace force
replace event_new=1729 if (event_new>=1730&event_new<=1739)&(m2>=87200&m2<87999)

replace event_new=1449 if event_new==1446
replace event_new=1541 if event_new==1549
replace event_new=1550 if event_new==1559
replace event_new=1799 if event_new==1790
replace event_new=1820 if event_new==1829
replace event_new=1859 if event_new==1850
replace event_new=1963 if event_new==1983

tab sex, m
capture drop event_1 topo_2 id
rename event_new event_1
sort event_1
capture drop _merge id
gen id=_n
merge event_1 using "V:\Ttp\Testis\artikel\contralateral testicular cancer\topoconversie event.dta"
drop if _merge==2
drop _merge

capture drop x
sort id
by id:egen x=rank(id), unique
tab x
drop if x>=2&x~=.
drop x
tab sex

rename event_1 event_new_1
rename topo_2 event_new
sort st2
replace event_new=430 if event_new_1>=1720&event_new_1<=1729
replace event_new=430 if (event_new_1>=1720&event_new_1<=1729)&(m1>=8720&m1<87903)

tostring event_new, replace force
replace event_new=substr(event_new,1,2)
destring event_new, replace force
replace event_new=81 if event_new_1>=2010&event_new_1<=2019
replace event_new=82 if event_new_1==2002|event_new_1==2029|event_new_1==2039|event_new_1==2041
replace event_new=83 if event_new_1==2028
replace event_new=84 if event_new_1==2000|event_new_1==2001|event_new_1==2009
replace event_new=90 if event_new_1==2030
replace event_new=91 if event_new_1==2049
replace event_new=92 if event_new_1==2050|event_new_1==2051|event_new_1==2053|event_new_1==2059
replace event_new=96 if event_new_1==2040|event_new_1==2079
replace event_new=97 if event_new_1==2290|event_new_1==2298|event_new_1==2299

capture drop ttpmorf1
gen ttpmorf1=m2
tostring ttpmorf1, replace force
replace ttpmorf1=substr(ttpmorf1,1,4)
destring ttpmorf1, replace force
capture drop morf_1
gen morf_1=ttpmorf1

replace event_new=81 if (((ttpmorf1>=9650&ttpmorf1<=9667)&ttpmorf1~=9659&ttpmorf1~=9660)|((morf_1>=9650&morf_1<=9667)&morf_1~=9659&morf_1~=9660))
replace event_new=82 if (((ttpmorf1==9659|ttpmorf1==9660)|(ttpmorf1>=9690&ttpmorf1<=9698)|(ttpmorf1>=9670&ttpmorf1<=9699))|((morf_1==9659|morf_1==9660)|(morf_1>=9690&morf_1<=9698)|(morf_1>=9670&morf_1<=9699)))
replace event_new=83 if (((ttpmorf1==9670|ttpmorf1==9689)|ttpmorf1==9593|ttpmorf1==9595) |((morf_1==9670|morf_1==9689)|morf_1==9593|morf_1==9595)) 
replace event_new=84 if ((ttpmorf1>=9700&ttpmorf1<=9719)|(morf_1>=9700&morf_1<=9719))
replace event_new=85 if (((ttpmorf1>=9590&ttpmorf1<=9592)|ttpmorf1==9594|(ttpmorf1>=9710&ttpmorf1<=9719))|((morf_1>=9590&morf_1<=9592)|morf_1==9594|(morf_1>=9710&morf_1<=9719)))
replace event_new=88 if ((ttpmorf1>=9760&ttpmorf1<=9769)|(morf_1>=9760&morf_1<=9769))
replace event_new=90 if (((ttpmorf1>=9730&ttpmorf1<=9734|ttpmorf1==9830)&ttpmorf1~=9731)|((morf_1>=9730&morf_1<=9734|morf_1==9830)&morf_1~=9731))
replace event_new=91 if (((ttpmorf1>=9820&ttpmorf1<=9829)|(ttpmorf1>=9940&ttpmorf1<=9941))|((morf_1>=9820&morf_1<=9829)|(morf_1>=9940&morf_1<=9941))) 
replace event_new=92 if (((ttpmorf1>=9860&ttpmorf1<=9889)|(ttpmorf1>=9840&ttpmorf1<=9849)|(ttpmorf1==9930)|(morf_1>=9840&morf_1<=9849)|(morf_1>=9860&morf_1<=9889)|(morf_1==9930)))
replace event_new=93 if ((ttpmorf1>=9890&ttpmorf1<=9899)|(morf_1>=9890&morf_1<=9899))
replace event_new=94 if (((ttpmorf1>=9931&ttpmorf1<=9932)|(ttpmorf1==9850|ttpmorf1==9900|ttpmorf1==9910))|((morf_1>=9931&morf_1<=9932)|(morf_1==9850|morf_1==9900|morf_1==9910)))
replace event_new=95 if ((ttpmorf1>=9800&ttpmorf1<=9809)|(morf_1>=9800&morf_1<=9809))
replace event_new=96 if (((ttpmorf1>=9720&ttpmorf1<=9729)|(ttpmorf1>=9740&ttpmorf1<=9749))|((morf_1>=9720&morf_1<=9729)|(morf_1>=9740&morf_1<=9749)))
replace event_new=96 if (((ttpmorf1>=9900&ttpmorf1<=9949)|(ttpmorf1>=9960&ttpmorf1<=9969))|((morf_1>=9900&morf_1<=9949)|(morf_1>=9960&morf_1<=9969)))
replace event_new=97 if ((ttpmorf1>=9980&ttpmorf1<=9989)|(morf_1>=9980&morf_1<=9989))
format event_new %2.0f

replace event_new=15 if codenr==39417773
replace ttpmorf1=m3 if codenr==39417773

replace exit=fupdat if codenr==20713030
replace event_new=. if codenr==20713030
replace ttpmorf1=. if codenr==20713030
tab event_new

replace event_new=. if codenr==10750053|codenr==12872338|codenr==12901896

sort event_new event_new_1

tab sex
recode sex (1=2) (2=1)
tab sex
		
replace event_new=. if event_new==event&st2dat==exit
replace entry=exit
replace exit=st2dat if event_new~=.
replace exit=st3dat if codenr==39417773
replace exit=st3dat if codenr==20660463
replace exit=fupdat if event_new==.	
replace exit=overlijd_dat if event_new==.&(overlijd_dat~=fupdat)&overlijd_dat~=.	

capture drop fup_event
gen fup_event=(exit-entry)/365.25
sort fup_event
tab event_new
			
capture drop cause
gen cause=0
replace cause=1 if event_new~=.
replace cause=2 if event_new==.&(vitale_status==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

tab fup cause

capture drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1

twoway line CI lowlim hilim fup if cause==1, sort xla(0(5)40, labsize(medlarge)) yla(0(10)50,format(%9.1fc) angle(horizontal) labsize(medlarge)) clw(thick thin thin) ///
	connect(stairstep stairstep stairstep) xti("follow-up (years)", size(large)) yti("Cumulative incidence (%)" " ", size(large)) legend(off) scheme(s1manual)
			
replace event=event_new		
keep sex birthdat entry exit event rtcat agekt4 ctcat treat_periode
save "C:\PYA\PYAstata\ca_inc\Pya_Input_CI.dta", replace		
	
	
	

****** Figuren met achtergrond incidentie (met dood als competing risk)
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cancer_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta", replace	


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"

twoway line CI_periode1 CI_periode2 CI_periode3  fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(6 19 "1990-2000", place(e)) text(34 21 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)

append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta"
twoway line CI_periode1 CI_periode2 CI_periode3 cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(17 11 "1990-2000", place(e)) text(34 20 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)
	  
	  
	  
	  
	  
	  
	  
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\solid_cancer_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta", replace	


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event~=.
replace cause=2 if event>=81&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"

twoway line CI_periode1 CI_periode2 CI_periode3  fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(6 19 "1990-2000", place(e)) text(34 21 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)

append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta"
twoway line CI_periode1 CI_periode2 CI_periode3 cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(17 12 "1990-2000", place(e)) text(34 20 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)	  

	  
	  
	  
	  
	  
	  
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab sex
keep if sex==2
capture drop cause
gen cause=0
replace cause=1 if (event==50)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\breast_cancer_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

keep if sex==2
capture drop cause
gen cause=0
replace cause=1 if (event==50)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta", replace	


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

keep if sex==2
capture drop cause
gen cause=0
replace cause=1 if (event==50)
replace cause=2 if event~=.&cause~=1
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"
drop if sex==.

twoway line CI_periode1 CI_periode2 CI_periode3  fup if cause==1, sort xla(0(5)40) yla(0(10)50,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of breast cancer (%)" " ") legend(off)  ///
      text(6 19 "1990-2000", place(e)) text(34 21 "1980-1989", place(e)) text(44 30 "1965-1979", place(e)) scheme(s1manual)

append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta"
twoway line CI_periode1 CI_periode2 CI_periode3 cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of breast cancer (%)" " ") legend(off)  ///
      text(17 12 "1990-2000", place(e)) text(20 20 "1980-1989", place(e)) text(20 30 "1965-1979", place(e)) scheme(s1manual)	  
	  
	  
	  
	  
	  
	  
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab sex
capture drop cause
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\leukemia_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode.dta", replace	
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*gen age=(entry-birthdat)/365.25
*gen incjr=year(entry)
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta", replace	




use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event>=91&event<=97
replace cause=2 if event<=90&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3=CI if cause==1

list fup CI_periode1 CI_periode2 CI_periode3 if cause==1

label var fup "Follow-up time in years"
drop if sex==.

twoway line CI_periode1 CI_periode2 CI_periode3  fup if cause==1, sort xla(0(5)40) yla(0(1)5,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(0.4 12 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	

append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode.dta"
twoway line CI_periode1 CI_periode2 CI_periode3 cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(1)5,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(0.4 12 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	 
	  
	  
	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab sex
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=34&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*** males only
keep if sex==1
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\lung_cancer_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode for males.dta", replace	

	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab event
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=34&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*** males only
keep if sex==1
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode for males.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1m=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2m=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3m=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode for males.dta", replace	

use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab sex
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=34&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*** females only
keep if sex==2
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\lung_cancer_inc_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end p_star cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace p_star = 1 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace p_star = 1 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen exp_cumrisk=100*(1-cp_e2)
gen cause=1
drop if fup==.

sort treat_periode fup
save "G:\Attained age\population expected cancer incidence naar periode for females.dta", replace	

	
use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

tab event
capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=34&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)

capture drop age
capture drop incjr
*** females only
keep if sex==2
gen age=((entry+(5*365.25))-birthdat)/365.25
gen incjr=year(entry+(5*365.25))
gen fup2=(cutoff_competingrisk-(entry+(5*365.25)))/365.25
stset fup2, f(cause==1) id(id)
strs using "G:\Attained age\all_cause_mortality_1965_2010", br(0(1)40) mergeby(_year sex _age) by(treat_periode) diagage(age) diagyear(incjr) attage(_age) attyear(_year) survprob(prob) save(replace)
use grouped, replace

keep treat_periode end cp_e2
set obs 162
set obs 163
set obs 164
replace treat_periode = 1 in 162
replace end = 0 in 162
replace cp_e2 = 1 in 162
replace treat_periode = 2 in 163
replace end = 0 in 163
replace cp_e2 = 1 in 163
replace treat_periode = 3 in 164
replace end = 0 in 164
replace cp_e2 = 1 in 164
sort treat_periode end
rename end fup
gen cause=1
drop if fup==.
rename cp_e2 expected_overall_survival

sort treat_periode fup
save "G:\Attained age\population expected survival naar periode.dta", replace

use "G:\Attained age\population expected cancer incidence naar periode for females.dta", clear
merge treat_periode fup using "G:\Attained age\population expected survival naar periode.dta"
save "G:\Attained age\bereken cumulatieve incidentie.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==1
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
*egen exp_cuminc= rowtotal(event lagx1-lagx36)
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
*drop _merge-lagx36
save "G:\Attained age\bereken cumulatieve incidentie periode1.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==2
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
*drop cause _merge fupmax lagx0-lagx`b'
*rename p_star interval_specific_survival
*rename cp_e2 cumulative_survival

drop _merge-lagx`b'
save "G:\Attained age\bereken cumulatieve incidentie periode2.dta", replace

use "G:\Attained age\bereken cumulatieve incidentie.dta", clear
egen fupmax=max(fup)
keep if treat_periode==3
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

egen exp_cuminc= rowtotal(event lagx1-lagx`b')
replace exp_cuminc=exp_cuminc*100
drop _merge-lagx`b'
append using "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
append using "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode1.dta"
erase "G:\Attained age\bereken cumulatieve incidentie periode2.dta"
sort treat_periode fup


replace fup=fup+5 if fup~=0
twoway line exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1965-1988", place(e)) scheme(s1manual)
twoway line exp_cuminc exp_cumrisk fup if cause==1&treat_periode==2, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
gen cuminc1f=exp_cuminc if cause==1&treat_periode==1	 
gen cuminc2f=exp_cuminc if cause==1&treat_periode==2	
gen cuminc3f=exp_cuminc if cause==1&treat_periode==3	
twoway line cuminc1 cuminc2 cuminc3 fup if cause==1, sort xla(0(5)40) yla(0(5)25,format(%9.1fc) angle(horizontal)) clw(thick thick thick) ///
	  connect(line line) yti("Cumulative incidence of any second cancer (%)" " ") legend(off)  ///
      text(10 18 "1989-2000", place(e)) scheme(s1manual)
sort treat_periode fup
save "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode for females.dta", replace	


use "D:\Michael WORK\Morbus Hodgkin\Hodgkin GI\Hodgkin NEJM\Analyses nejm 2011.dta", clear

capture drop cause
gen cause=0
replace cause=1 if event==34
replace cause=2 if event~=34&event~=.
replace cause=3 if event==.&(vstat_end==1)
tab cause

capture drop cutoff_competingrisk
gen cutoff_competingrisk=exit

capture drop fup_periode
gen fup_periode=(cutoff_competingrisk-entry)/365.25
tab cause if fup_periode<5

format cutoff_competingrisk %dD-N-CY
capture drop fup
gen fup=(cutoff_competingrisk-entry)/365.25

capture drop id
gen id=_n
stset fup, f(cause==1) id(id)
	
*** plaatje maken voor periode en alle tumoren cumulatieve incidentie
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1&sex==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1m=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2&sex==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2m=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3&sex==1, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3m=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==1&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode1f=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==2&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode2f=CI if cause==1

drop CI lowlim hilim
stcompet CI = ci lowlim = lo hilim = hi if treat_periode==3&sex==2, compet1(2) compet2(3)
sort fup
replace CI=100*CI
replace lowlim=100*lowlim
replace hilim=100*hilim
list fup CI lowlim hilim if cause==1
gen CI_periode3f=CI if cause==1

list fup CI_periode1m CI_periode2m CI_periode3m CI_periode1f CI_periode2f CI_periode3f if cause==1

label var fup "Follow-up time in years"
drop if sex==.

twoway line CI_periode1m CI_periode2m CI_periode3m  fup if cause==1, sort xla(0(5)40) yla(0(1)5,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(0.4 12 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	

append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode for males.dta"
append using "G:\Attained age\population expected cumulative incidence and cumulative risk naar periode for females.dta"
twoway line CI_periode1m CI_periode2m CI_periode3m cuminc1m cuminc2m cuminc3m fup if cause==1, sort xla(0(5)40) yla(0(2)12,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(4 5 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	 
	  
twoway line CI_periode1f CI_periode2f CI_periode3f  fup if cause==1, sort xla(0(5)40) yla(0(1)5,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep) yti("Cumulative incidence of leukemia (%)" " ") legend(off)  ///
      text(0.4 12 "1990-2000", place(e)) text(3.4 20 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)	

twoway line CI_periode1f CI_periode2f CI_periode3f cuminc1f cuminc2f cuminc3f fup if cause==1, sort xla(0(5)40) yla(0(2)12,format(%9.1fc) angle(horizontal)) clw(thick thick thick thick thick thick) ///
	connect(stairstep stairstep stairstep line line line ) yti("Cumulative incidence of lung cancer (%)" " ") legend(off)  ///
      text(2.4 5 "1990-2000", place(e)) text(3.4 15 "1980-1989", place(e)) text(4 30 "1965-1979", place(e)) scheme(s1manual)		  	  
	  	  
