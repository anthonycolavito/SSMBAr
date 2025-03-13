library(tidyverse)

setwd("/Users/anthony/Desktop/SSMBAr")

birth_cohorts <- seq(1945, 2030, by = 5)
sexes <- c("male", "female")
earn_types <- c("none","verylow","low","med","high","max")
ages <- 21:100

hypo_workers <- expand_grid(
  birth_cohort = birth_cohorts,
  sex = sexes,
  earn_type = earn_types,
  age = ages
) %>% 
  mutate(
  worker = paste0("w_",birth_cohort,"_",substr(sex,1,1),"_",earn_type)
) 

#Load Assumptions
assumptions <- readRDS("./data/assumptions.RDS")
scaled_earnings <- read_csv("./data/2024 earnings scaling factors.csv")

