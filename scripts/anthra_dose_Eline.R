# test Eline's code

dta = read.csv('~/Watt-HL-SMN/secure_data/2024-12-12/ResearchDB_Export_from-Power-BI.csv')

primb = dta
#dosis doxubicine per kuur 1e chemotherapie
primb$dos_dox <- ifelse(primb$c1ctprim == 2 | primb$c1ctprim == 3 | primb$c1ctprim == 22 | primb$c1ctprim == 30 | primb$c1ctprim == 40, 50,
                        ifelse(primb$c1ctprim == 4 | primb$c1ctprim == 36 | primb$c1ctprim == 39, 35,
                               ifelse(primb$c1ctprim == 5, 25,
                                      ifelse(primb$c1ctprim == 17, 80,
                                             ifelse(primb$c1ctprim == 38, 60, NA)))))

#dosis doxorubicine per hele cyclus 1e chemotherapie (x aantal kuren)
#eerst tbv berekening 99 veranderen in NA.
primb$k1ctprim[primb$k1ctprim == 99] <- NA
primb$k1ctprim[primb$k1ctprim == 999] <- NA

primb$dos_doxk <- as.numeric(primb$dos_dox) * as.numeric(primb$k1ctprim)

#dosis doxorubicine per kuur 2e chemotherapie
primb$dos_dox2 <- ifelse(primb$c2ctprim == 2 | primb$c2ctprim == 3 | primb$c2ctprim == 22 | primb$c1ctprim == 30 | primb$c2ctprim == 40, 50,
                         ifelse(primb$c2ctprim == 4 | primb$c2ctprim == 36 | primb$c2ctprim == 39, 35,
                                ifelse(primb$c2ctprim == 5, 25,
                                       ifelse(primb$c2ctprim == 17, 80,
                                              ifelse(primb$c2ctprim == 38, 60, NA)))))


#dosis doxorubicine per hele cyclus 2e chemotherapie (x aantal kuren)
#eerst tbv berkeening 99 veranderen in NA.
primb$k2ctprim[primb$k2ctprim == 99] <- NA
primb$k2ctprim[primb$k2ctprim == 999] <- NA
primb$dos_doxk2 <- as.numeric(primb$dos_dox2) * as.numeric(primb$k2ctprim)


#dosis doxorubicine per kuur 3e chemotherapie
primb$dos_dox3 <- ifelse(primb$c3ctprim == 2 | primb$c3ctprim == 3 | primb$c3ctprim == 22 | primb$c3ctprim == 30 | primb$c3ctprim == 40, 50,
                         ifelse(primb$c3ctprim == 4 | primb$c3ctprim == 36 | primb$c3ctprim == 39, 35,
                                ifelse(primb$c3ctprim == 5, 25,
                                       ifelse(primb$c3ctprim == 17, 80,
                                              ifelse(primb$c3ctprim == 38, 60, NA)))))



#dosis doxorubicine per hele cyclus 3e chemotherapie (x aantal kuren)
#eerst tbv berkeening 99 veranderen in NA.
primb$k3ctprim[primb$k3ctprim == 99] <- NA
primb$k3ctprim[primb$k3ctprim == 999] <- NA
primb$dos_doxk3 <- as.numeric(primb$dos_dox3) * as.numeric(primb$k3ctprim)

#dosis doxorubicine per kuur 4e chemotherapie
primb$dos_dox4 <- ifelse(primb$c4ctprim == 2 | primb$c4ctprim == 3 | primb$c4ctprim == 22 | primb$c4ctprim == 30 | primb$c4ctprim == 40, 50,
                         ifelse(primb$c4ctprim == 4 | primb$c4ctprim == 36 | primb$c4ctprim == 39, 35,
                                ifelse(primb$c4ctprim == 5, 25,
                                       ifelse(primb$c4ctprim == 17, 80,
                                              ifelse(primb$c4ctprim == 38, 60, NA)))))

#dosis doxorubicine per hele cyclus 4e chemotherapie (x aantal kuren)
#eerst tbv berkeening 99 veranderen in NA.
primb$k4ctprim[primb$k4ctprim == 99] <- NA
primb$k4ctprim[primb$k4ctprim == 999] <- NA
primb$dos_doxk4 <- as.numeric(primb$dos_dox4) * as.numeric(primb$k4ctprim)

#dosis doxorubicine per kuur 5e chemotherapie
primb$dos_dox5 <- ifelse(primb$c5ctprim == 2 | primb$c5ctprim == 3 | primb$c5ctprim == 22 | primb$c5ctprim == 30 | primb$c5ctprim == 40, 50,
                         ifelse(primb$c5ctprim == 4 | primb$c5ctprim == 36 | primb$c5ctprim == 39, 35,
                                ifelse(primb$c5ctprim == 5, 25,
                                       ifelse(primb$c5ctprim == 17, 80,
                                              ifelse(primb$c5ctprim == 38, 60, NA)))))


#dosis doxorubicine per hele cyclus 5e chemotherapie (x aantal kuren)
#eerst tbv berekening 99 veranderen in NA.
primb$k5ctprim[primb$k5ctprim == 99] <- NA
primb$k5ctprim[primb$k5ctprim == 999] <- NA
primb$dos_doxk5 <- as.numeric(primb$dos_dox5) * as.numeric(primb$k5ctprim)


#optellen totale dosis doxorubicine van alle gegeven chemotherapieschema's

primb$dox_tot <- rowSums(primb[,c("dos_doxk", "dos_doxk2", "dos_doxk3", "dos_doxk4", "dos_doxk5")], na.rm=TRUE)



#0 veranderen in NA
primb$dox_tot[primb$dox_tot == 0 ] <- NA


#variable maken, wel/geen DOX of onbekend # kuur 1
primb$DOXK1 <- with(primb, ifelse(c1ctprim == 2 | c1ctprim == 3 | c1ctprim == 22 | c1ctprim == 30 | c1ctprim == 40
                                  | c1ctprim == 4 | c1ctprim == 36 | c1ctprim == 39 |
                                    c1ctprim == 5 | c1ctprim == 25 |
                                    c1ctprim == 17 | c1ctprim == 38, "yes",
                                  ifelse(c1ctprim == 99, "unknown", "no")))
#variable maken, wel/geen dox of onbekend # kuur 2
primb$DOXK2 <- with(primb, ifelse(c2ctprim == 2 | c2ctprim == 3 | c2ctprim == 22 | c2ctprim == 30 | c2ctprim == 40
                                  | c2ctprim == 4 | c2ctprim == 36 | c2ctprim == 39 |
                                    c2ctprim == 5 | c2ctprim == 25 |
                                    c2ctprim == 17 | c2ctprim == 38, "yes",
                                  ifelse(c2ctprim == 99, "unknown", "no")))
#variable maken, wel/geen dox of onbekend # kuur 3
primb$DOXK3 <- with(primb, ifelse(c3ctprim == 2 | c3ctprim == 3 | c3ctprim == 22 | c3ctprim == 30 | c3ctprim == 40
                                  | c3ctprim == 4 | c3ctprim == 36 | c3ctprim == 39 |
                                    c3ctprim == 5 | c3ctprim == 25 |
                                    c3ctprim == 17 | c3ctprim == 38, "yes",
                                  ifelse(c3ctprim == 99, "unknown", "no")))
#variable maken, wel/geen dox of onbekend # kuur 4
primb$DOXK4 <- with(primb, ifelse(c4ctprim == 2 | c4ctprim == 3 | c4ctprim == 22 | c4ctprim == 30 | c4ctprim == 40
                                  | c4ctprim == 4 | c4ctprim == 36 | c4ctprim == 39 |
                                    c4ctprim == 5 | c4ctprim == 25 |
                                    c4ctprim == 17 | c4ctprim == 38, "yes",
                                  ifelse(c4ctprim == 99, "unknown", "no")))
#variable maken, wel/geen dox of onbekend # kuur 5
primb$DOXK5 <- with(primb, ifelse(c5ctprim == 2 | c5ctprim == 3 | c5ctprim == 22 | c5ctprim == 30 | c5ctprim == 40
                                  | c5ctprim == 4 | c5ctprim == 36 | c5ctprim == 39 |
                                    c5ctprim == 5 | c5ctprim == 25 |
                                    c5ctprim == 17 | c5ctprim == 38, "yes",
                                  ifelse(c5ctprim == 99, "unknown", "no")))


#DOX in minstens 1 kuur
primb$DOX <- apply (primb[,c("DOXK1","DOXK2","DOXK3","DOXK4","DOXK5")], 1, function (x){
  
  ifelse ("yes" %in% x, T,
          ifelse("no" %in% x, F,       
                 ifelse ("unknown" %in% x, "unknown", NA)))
  
})

primb$DOX <- ifelse(primb$ctprim == 1 & is.na(primb$c1ctprim), "unknown", primb$DOX)

#controle
c <- primb[,c("DOXK1","DOXK2","DOXK3","DOXK4","DOXK5", "DOX")]


#DOX gehad maar aantal kuren en dus dosis onbekend
primb$dox_tot <- with(primb,  ifelse(DOXK1 == "yes" & !is.na(c1ctprim) & is.na(k1ctprim), "unknown",
                                     ifelse(DOXK2 == "yes" & !is.na(c2ctprim) & is.na(k2ctprim), "unknown",
                                            ifelse(DOXK3 == "yes" & !is.na(c3ctprim) & is.na(k3ctprim), "unknown",
                                                   ifelse(DOXK4 == "yes" & !is.na(c4ctprim) & is.na(k4ctprim), "unknown",
                                                          ifelse(DOXK5 == "yes" & !is.na(c5ctprim) & is.na(k5ctprim), "unknown",
                                                                 dox_tot))))))


#controle wel kuur gecodeerd maar aantal kuren onbekend
#kuur 1
subset(primb, !is.na(c1ctprim) & is.na(k1ctprim), select = c("evalnr", "c1ctprim","k1ctprim","o1ctprim", "c2ctprim", "k2ctprim" ,"o2ctprim" ,
                                                             "c3ctprim","k3ctprim","o3ctprim", "c4ctprim", "k4ctprim" ,"o4ctprim" ,
                                                             "c5ctprim","k5ctprim","o5ctprim", "dox_tot",
                                                             "DOXK1", "DOXK2", "DOXK3", "DOXK4", "DOXK5", "DOX"))


#dosis dox wel of niet bekend
primb$dox_tot_cat <- ifelse(primb$dox_tot != "unknown" & !is.na(primb$dox_tot), "known", primb$dox_tot)

#alleen numerieke waarden
primb$dox_tot_num <- ifelse(primb$dox_tot == "unknown", NA, primb$dox_tot) 
primb$dox_tot_num <- as.numeric(primb$dox_tot_num)
round(primb$dox_tot_num, 0)