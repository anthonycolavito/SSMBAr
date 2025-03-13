library(tidyverse)

setwd("/Users/anthony/Desktop/SSMBAr")

#Load the prepare_assumptions function
source("./programs/prepare_assumptions.R")

#Output assumptions datasets to be used for creating hypothetical workers
prepare_assumptions()

birth_cohorts <- seq(1945, 2030, by = 5)
sexes <- c("male", "female")
earn_types <- c("none","verylow","low","medium","high","max")
ages <- 21:100

#Create hypothetical workers dataset
hypo_workers <- expand_grid(
  birth_cohort = birth_cohorts,
  sex = sexes,
  earn_type = earn_types,
  age = ages
) %>% 
  mutate(
  worker = paste0("w_",birth_cohort,"_",substr(sex,1,1),"_",earn_type),
  year = age + birth_cohorts
) 

#Load Assumptions
assumptions <- readRDS("./data/assumptions.RDS")
scaled_earnings <- read_csv("./data/2024 earnings scaling factors.csv")

#Merge scaled earnings assumptions 
hypo_workers <- merge(hypo_workers, scaled_earnings, by="age", all.x = TRUE)
