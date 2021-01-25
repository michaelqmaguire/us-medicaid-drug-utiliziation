#-----------------------------------------------------------------------------------------------------------------#
#                                                                                                                 #
# PROJECT: US MEDICAID DRUG UTILIZATION                                                                           #
# AUTHOR: MICHAEL MAGUIRE, MS, DMA II                                                                             #
# INSTITUTION: UNIVERSITY OF FLORIDA, COLLEGE OF PHARMACY                                                         #
# DEPARTMENT: PHARMACEUTICAL OUTCOMES AND POLICY                                                                  #
# SUPERVISORS: AMIE GOODIN, PHD MPP | JUAN HINCAPIE-CASTILLO, PHARMD PHD MS                                       #
#                                                                                                                 #
#-----------------------------------------------------------------------------------------------------------------#

## Load packages

library(httr)
library(jsonlite)
library(dplyr)
library(purrr)
library(tidylog)

## Connect to the API

medicaid <- 
  GET(
    url = "https://data.medicaid.gov/resource/va5y-jhsv.json"
  )
