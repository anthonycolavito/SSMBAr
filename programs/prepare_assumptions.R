#Prepare Historical and Projected Data for SSMBAr calculator
#Author: Anthony Colavito
#Historical and projected data on program and economic parameters
#was retrieved and compiled manually from the 2024 Annual Trustee's Report
# https://www.ssa.gov/oact/TR/2024/
# Scaled earnings factors were retrieved from OACT's latest available memo
# https://www.ssa.gov/OACT/NOTES/ran3/index.html

library(tidyverse)

setwd("/Users/anthony/Desktop/SSMBAr/")

#Load files
hist <- read.csv("./data/2024TR Historical Data.csv")
hist_awi_cpi <- read.csv("./data/2024TR AWI and CPI Changes.csv")
cohort_life_expectancy <- read.csv("./data/Cohort Life Expectancy 2024TR.csv")
scaled_earning <- read.csv("./data/2024 earnings scaling factors.csv")

#Calculate historical and projected CPI using growth rate in CPI.
#Index starts at 100 in 1960
hist_awi_cpi2024<- hist_awi_cpi2024 %>% 
  arrange(year) %>% mutate(
    cpi_growth = 1 + cpi_growth/100,
    awi_growth = 1 + awi_growth/100
  ) %>% mutate(
    cpi = 100 * cumprod(cpi_growth)
  )

#Rename variables in life expectancy file to avoid confusion later on
cohort_life_expectancy2024 <- cohort_life_expectancy2024 %>% rename(
  male_le = male, female_le = female
)

#Merge files that can be merged based on year
hist_and_proj_data <- merge(hist2024, hist_awi_cpi2024, by="year", all = TRUE)
hist_and_proj_data <- merge(hist_and_proj_data, cohort_life_expectancy2024, by="year", all= TRUE)

#Project forward parameters that change with the AWI using projected growth rates
#Locate first observation where historical data is not present
awi_proj_start <- max(which(!is.na(hist_and_proj_data$awi)))

#Project forward economic and program parameters
for(i in (awi_proj_start + 1):nrow(hist_and_proj_data)) {
  #AWI Projections
  hist_and_proj_data$awi[i] <- hist_and_proj_data$awi[i-1] *
                              hist_and_proj_data$awi_growth[i]
  
  #Taxmax Projections
  hist_and_proj_data$taxmax[i] <- hist_and_proj_data$taxmax[i-1] *
                              hist_and_proj_data$awi_growth[i]
  
  #Retired Earnings Test Projections
  hist_and_proj_data$ret_exempt[i] <- hist_and_proj_data$ret_exempt[i-1] *
                                      hist_and_proj_data$awi_growth[i]
  
  #Retired Earnings Test at NRA Projections
  hist_and_proj_data$ret_exempt_nra[i] <- hist_and_proj_data$ret_exempt_nra[i-1] *
                                          hist_and_proj_data$awi_growth[i]
  
  #First PIA Bendpoint Projections
  hist_and_proj_data$bendpoint1[i] <- hist_and_proj_data$bendpoint1[i-1] *
                                      hist_and_proj_data$awi_growth[i]
  
  #Second PIA Bendpoint Projections
  hist_and_proj_data$bendpoint2[i] <- hist_and_proj_data$bendpoint2[i-1] *
                                      hist_and_proj_data$awi_growth[i]
  
  #First Family Max Bendpoint Projections
  hist_and_proj_data$f_bendpoint1[i] <- hist_and_proj_data$f_bendpoint1[i-1] *
                                        hist_and_proj_data$awi_growth[i]
  
  #Second Family Max Bendpoint Projections
  hist_and_proj_data$f_bendpoint2[i] <- hist_and_proj_data$f_bendpoint2[i-1] *
                                        hist_and_proj_data$awi_growth[i]
  
  #Third Family Max Bendpoint Projections
  hist_and_proj_data$f_bendpoint3[i] <- hist_and_proj_data$f_bendpoint3[i-1] *
                                        hist_and_proj_data$awi_growth[i]
  
  #1 QC Requirement Projections
  hist_and_proj_data$qc_req[i] <- hist_and_proj_data$qc_req[i-1] *
                                        hist_and_proj_data$awi_growth[i]
  
  #Old Law Base Projections
  hist_and_proj_data$old_law_base[i] <- hist_and_proj_data$old_law_base[i-1] *
                                  hist_and_proj_data$awi_growth[i]
  
  #OASI Tax Rate Projections (does not use AWI growth rate)
  hist_and_proj_data$oasi_tr[i] <- hist_and_proj_data$oasi_tr[i-1]
  
  #DI Tax Rate Projections (does not use AWI growth rate)
  hist_and_proj_data$di_tr[i] <- hist_and_proj_data$di_tr[i-1]
  
  #NRA by Year Turning Age 62 Projections (does not use AWI growth rate)
  hist_and_proj_data$nra_62[i] <- hist_and_proj_data$nra_62[i-1]
}

assumptions <- hist_and_proj_data %>% pivot_longer(cols = c(!year), names_to="parameter", values_to="value")

scaled_earnings <- scaled_earnings2024 %>% pivot_longer(cols = c(!age), names_to="earn_type", values_to="value")

saveRDS(assumptions, "./data/assumptions.rds")
