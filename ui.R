library(shiny)
library(lubridate)
library(Hmisc)
library(ggplot2)
library(tidyr)
library(dplyr)

fluidPage(
  
  titlePanel("MSF HCV Appointment Simulation"),
  
  sidebarPanel(
    
    dateRangeInput("dates", label = "Start and end date of simulation",start="2017-01-01", end="2019-01-01"),
    
    sliderInput('elisaperday', 'Antibody tests/day', min=1, max=200,
                value=20, step=1, round=0),
    
    dateInput('reducescreening','Date from which screening rate changes'),
    
    sliderInput('elisaperday2', 'Antibody tests/day phase 2', min=0, max=200,
                value=20, step=1, round=0),
    
    sliderInput('elisayield', 'Proportion of antibody tests positive', min=0, max=1,  value=0.5, step=0.01, round=0),
    
    sliderInput('elisawait', 'Waiting time for antibody test result (weeks)', min=0, max=52,  value=1, step=1, round=0),
    
    sliderInput('PCRyield', 'Proportion of PCR tests positive', min=0, max=1,  value=0.5, step=0.01, round=0),
    
    sliderInput('PCRwait', 'Waiting time for PCR test result (weeks)', min=0, max=52,  value=2, step=1, round=0),
    
    sliderInput('waitbaseline', 'Waiting time for treatment initiation (weeks)', min=0, max=52,  value=4, step=1, round=0),
    
    sliderInput('eligyield', 'Proportion of chronic infections eligible for treatment', min=0, max=1,  value=0.9, step=0.01, round=0),
    
    sliderInput('treat24weeks', 'Proportion of patients on 24 week treatment', min=0, max=1,  value=0.5, step=0.01, round=0),
    
    
    sliderInput('waitlist', 'Proportion of patients on waiting list', min=0, max=1,  value=0.5, step=0.01, round=0),
    
    sliderInput('waitF0F1', 'Time on waiting list (weeks)', min=0, max=100,  value=26, step=1, round=0),
    
    sliderInput('ltfuF0F1', 'Proportion of patients on waiting list LTFU', min=0, max=1,  value=0.1, step=0.01, round=0),
    
    actionButton("run","Run Simulation")
  ),
  
  mainPanel(
    plotOutput('plot1',width=700,height=400),
    plotOutput('plot2',width=600,height=400)
    # text of treatment numbers or display on plot?
  )
)