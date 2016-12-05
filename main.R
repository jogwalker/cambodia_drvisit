## 5 December 2016
# Tool to assess burden on doctors based on yield at each step

library(lubridate)
library(Hmisc)
library(ggplot2)
library(tidyr)
library(dplyr)

startdate <- as.Date("2016-12-01")
runtime <- 3 # years
elisaperday <- 30
elisayield <- 0.6
elisawait <- 7 # days
PCRyield <- 0.75
PCRwait <- 14 # days
waitlist <- 0.5
waitF0F1 <- 182 # days
ltfuF0F1 <- 0.1 #
eligyield <- 0.9
treat24weeks <- 0.2 # proportion on 24 week treatment, rest on 12 weeks
waitbaseline <- 28 # how long between PCR+ appointment and Day 0

reducescreening <- 84 # after this many days
reducescreeningby <- 0.5

days <- seq(startdate,startdate+years(runtime),by=1)

dat <- data.frame(date = as.Date(days),wday = wday(days))
dat$ELISA <- 0
dat$ELISA[dat$wday <= 5] <- elisaperday
dat$ELISA[dat$date >= (startdate+reducescreening)] <- dat$ELISA[dat$date >= (startdate+reducescreening)]*reducescreeningby
# could draw from poisson instead of multiplying
dat$PCR <- Lag(dat$ELISA*elisayield,elisawait)
dat$baseline <- Lag(dat$PCR*PCRyield,PCRwait)
dat$reassess_F0F1 <- Lag(dat$baseline*waitlist*(1-ltfuF0F1),waitF0F1)
dat$day0 <- rowSums(cbind(Lag(dat$baseline*(1-waitlist),waitbaseline), Lag(dat$reassess_F0F1,waitbaseline)),na.rm=T)
dat$day14 <- Lag(dat$day0*eligyield,14)
dat$M1 <- Lag(dat$day14,14)
dat$M2 <- Lag(dat$M1,28)
dat$M3 <- Lag(dat$M2,28) # end of treatment visit for 12 week treatment
dat$M4 <- Lag(dat$M3*treat24weeks,28)
dat$M5 <- Lag(dat$M4,28)
dat$M6 <- Lag(dat$M5,28) # end of treatment visit for 24 week treatment
dat$SVR12 <- rowSums(cbind(Lag(dat$M3,84),Lag(dat$M6,84)),na.rm=T)
dat$SVR12result <- Lag(dat$SVR12,28) # for now assuming no retreatment

dat[is.na(dat)] <- 0
dat$screeningvisit <- rowSums(cbind(dat$ELISA,dat$PCR))
dat$drvisit <- rowSums(cbind(dat[,5:16]))
dat$baselinevisit <- rowSums(cbind(dat[,5:6]))
dat$treatmentvisit <- rowSums(cbind(dat[,7:14]))
dat$followupvisit <- rowSums(cbind(dat[,15:16]))
# how many patients are on treatment at once?
dat$starttreatment <- dat$day0*eligyield
dat$treated <- cumsum(dat$starttreatment)
dat$endtreatment <- cumsum(dat$M3)*(1-treat24weeks) + cumsum(dat$M6)
dat$ontreatment <- dat$treated - dat$endtreatment
dat[dat == 0] <-  NA

# plot
dat2 <- dat %>% gather("visit_type","n",17:18)
ggplot(dat2,aes(x=date,y=n,color=visit_type)) + geom_line() 

dat3 <- dat %>% gather("visit_type","n",17:21)
ggplot(dat3,aes(x=date,y=n,color=visit_type)) + geom_line() 

# dat4 <- dat %>% gather("treated","n",22:24) %>% filter(treated=="ontreatment")
ggplot(dat,aes(x=date,y=ontreatment)) + geom_line()

