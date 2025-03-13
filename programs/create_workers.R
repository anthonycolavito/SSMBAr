library(tidyverse)

setwd("/Users/anthony/Desktop/SSMBAr")

#Load the prepare_assumptions function
source("./programs/prepare_assumptions.R")

#Output assumptions datasets to be used for creating hypothetical workers
prepare_assumptions()

birth_cohorts <- seq(1945, 2030, by = 5)
sexes <- c("male", "female")
earn_types <- c("none","verylow","low","medium","high","max")

#Create hypothetical worker types dataset
hypo_workers <- expand_grid(
  birth_cohort = birth_cohorts,
  sex = sexes,
  earn_type = earn_types
) %>% 
  mutate(
  worker = paste0("w_",birth_cohort,"_",substr(sex,1,1),"_",earn_type),
  id = row_number()
) 

for(worker in hypo_workers){
  
}

#Merge scaled earnings assumptions 
hypo_workers <- merge(hypo_workers, scaled_earnings, by="age", all.x = TRUE)
