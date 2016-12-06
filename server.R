library(shiny)
library(lubridate)
library(Hmisc)
library(ggplot2)
library(tidyr)
library(dplyr)


getdat <- function(dates,elisaperday,elisaperday2,reducescreening,elisayield,elisawait,PCRyield,PCRwait,waitlist,ltfuF0F1,waitF0F1,waitbaseline,eligyield) {
  days <- seq(dates[1],dates[2],by=1)
  
  dat <- data.frame(date = as.Date(days),wday = wday(days))
  dat$ELISA <- 0
  dat$ELISA[dat$wday <= 5] <- elisaperday
  dat$ELISA[dat$date >= (reducescreening)] <- elisaperday2
  dat$PCR <- Lag(dat$ELISA*elisayield,elisawait*7)
  dat$baseline <- Lag(dat$PCR*PCRyield,PCRwait*7)
  dat$reassess_F0F1 <- Lag(dat$baseline*waitlist*(1-ltfuF0F1),waitF0F1*7)
  dat$day0 <- rowSums(cbind(Lag(dat$baseline*(1-waitlist),waitbaseline*7), Lag(dat$reassess_F0F1,waitbaseline*7)),na.rm=T)
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
  return(dat)
}

shinyServer(
  function(input, output) {
  
  dat <- eventReactive(input$run, {
    getdat(input$dates,input$elisaperday,input$elisaperday2,input$reducescreening,input$elisayield,input$elisawait,input$PCRyield,input$PCRwait,input$waitlist,input$ltfuF0F1,input$waitF0F1,input$waitbaseline,input$eligyield)
  })
  
  output$plot1 <- renderPlot({
    p <- dat() %>% gather("visit_type","n",17:21) %>% ggplot(aes(x=date,y=n,color=visit_type)) + geom_line() + theme_bw()
    
    print(p)
    
  })
  
  output$plot2 <- renderPlot({
    p <- ggplot(dat(),aes(x=date,y=ontreatment)) + geom_line() + theme_bw()
    print(p)
    
  })
  
  }
)