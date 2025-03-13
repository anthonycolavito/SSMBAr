#Prepare Historical and Projected Data for SSMBAr calculator
#Author: Anthony Colavito
#Historical and projected data on program and economic parameters
#was retrieved and compiled manually from the 2024 Annual Trustee's Report
# https://www.ssa.gov/oact/TR/2024/
# Scaled earnings factors were retrieved from OACT's latest available memo
# https://www.ssa.gov/OACT/NOTES/ran3/index.html

prepare_assumptions <- function() {
  #Load files
  program_parameters <- read.csv("./data/2024TR Historical Data.csv") #Historical program parameters (AWI, bendpoints, taxmax, etc)
  hist_awi_and_cpi <- read.csv("./data/2024TR AWI and CPI Changes.csv")
  cohort_life_expectancy <- read.csv("./data/Cohort Life Expectancy 2024TR.csv")
  scaled_earnings <- read.csv("./data/2024 earnings scaling factors.csv")
  
  #Calculate historical and projected CPI using growth rate in CPI.
  #Index starts at 100 in 1960
  hist_awi_and_cpi<- hist_awi_and_cpi %>% 
    arrange(year) %>% mutate(
      cpi_growth = 1 + cpi_growth/100,
      awi_growth = 1 + awi_growth/100
    ) %>% mutate(
      cpi = 100 * cumprod(cpi_growth)
    )
  
  #Rename variables in life expectancy file to avoid confusion later on
  cohort_life_expectancy <- cohort_life_expectancy %>% rename(
    male_le = male, female_le = female
  )
  
  #Merge files that can be merged based on year
  assumptions <- merge(program_parameters, hist_awi_and_cpi, by="year", all = TRUE)
  assumptions <- merge(assumptions, cohort_life_expectancy, by="year", all= TRUE)
  
  #Project forward parameters that change with the AWI using projected growth rates
  #Locate first observation where historical data is not present
  awi_proj_start <- max(which(!is.na(assumptions$awi)))
  
  #Project forward economic and program parameters
  for(i in (awi_proj_start + 1):nrow(assumptions)) {
    #AWI Projections
    assumptions$awi[i] <- assumptions$awi[i-1] *
      assumptions$awi_growth[i]
    
    #Taxmax Projections
    assumptions$taxmax[i] <- assumptions$taxmax[i-1] *
      assumptions$awi_growth[i]
    
    #Retired Earnings Test Projections
    assumptions$ret_exempt[i] <- assumptions$ret_exempt[i-1] *
      assumptions$awi_growth[i]
    
    #Retired Earnings Test at NRA Projections
    assumptions$ret_exempt_nra[i] <- assumptions$ret_exempt_nra[i-1] *
      assumptions$awi_growth[i]
    
    #First PIA Bendpoint Projections
    assumptions$bendpoint1[i] <- assumptions$bendpoint1[i-1] *
      assumptions$awi_growth[i]
    
    #Second PIA Bendpoint Projections
    assumptions$bendpoint2[i] <- assumptions$bendpoint2[i-1] *
      assumptions$awi_growth[i]
    
    #First Family Max Bendpoint Projections
    assumptions$f_bendpoint1[i] <- assumptions$f_bendpoint1[i-1] *
      assumptions$awi_growth[i]
    
    #Second Family Max Bendpoint Projections
    assumptions$f_bendpoint2[i] <- assumptions$f_bendpoint2[i-1] *
      assumptions$awi_growth[i]
    
    #Third Family Max Bendpoint Projections
    assumptions$f_bendpoint3[i] <- assumptions$f_bendpoint3[i-1] *
      assumptions$awi_growth[i]
    
    #1 QC Requirement Projections
    assumptions$qc_req[i] <- assumptions$qc_req[i-1] *
      assumptions$awi_growth[i]
    
    #Old Law Base Projections
    assumptions$old_law_base[i] <- assumptions$old_law_base[i-1] *
      assumptions$awi_growth[i]
    
    #OASI Tax Rate Projections (does not use AWI growth rate)
    assumptions$oasi_tr[i] <- assumptions$oasi_tr[i-1]
    
    #DI Tax Rate Projections (does not use AWI growth rate)
    assumptions$di_tr[i] <- assumptions$di_tr[i-1]
    
    #NRA by Year Turning Age 62 Projections (does not use AWI growth rate)
    assumptions$nra_62[i] <- assumptions$nra_62[i-1]
  }
  
  #Output assumptions dataframe to the global environment
  assumptions <<- assumptions %>% pivot_longer(cols = c(!year), names_to="parameter", values_to="value") 
  
  #Output scaled_earnings dataframe to the global environment
  scaled_earnings <<- scaled_earnings %>% pivot_longer(cols = c(!age), names_to="earn_type", values_to="value")
  
}
