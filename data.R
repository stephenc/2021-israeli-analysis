#   Copyright 2021 Stephen Connolly
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#

############################################################################
# Ensure all the libraries we require are installed and loaded
############################################################################
source("bootstrap.R")

# This variable controls what values to use when given an upper limit value, e.g. <5
# When TRUE we use the mid-point of the range, e.g. <5 is 1, 2, 3, or 4 so the midpoint
# is 2.5.
# When FALSE we substitute random values in the range
range_mode_midpoint <- FALSE

#' Bind the range mode into a function
#'
#' @param exclusive_upper_bound the upper bound
#' @param count how many values to return
#' @return a vector of count values between `[1,exclusive_upper_bound)` with an expected average of `exclusive_upper_bound/2`
range_mode_source <- function(exclusive_upper_bound, count) {
  if (range_mode_midpoint) {
    rep(exclusive_upper_bound / 2, count)
  } else {
    sample(seq(1, exclusive_upper_bound - 1), count, replace = TRUE)
  }
}

#' Selects the newest filename matching the supplied glob pattern
#'
#' @param glob the pattern to match
#' @return a vector with one or zero entries corresponding to the file with the newest modification timestamp.
newest_matching_file <- function(glob) {
  candidates <- file.info(Sys.glob(glob))
  candidates <- candidates[with(candidates, order(as.POSIXct(mtime))), ]
  tail(rownames(candidates), n=1)
}


#
# Process the vaccinated by day file to prepare for merging.
#
# Expected outcome should be aggregated by week and partitioned by age group to match other data sets
#
filename <- newest_matching_file("data/vaccinated-per-day-*.csv")
message("Loading ", filename)
vaccinated <- read.csv(filename)

# Clean up text values from import
vaccinated[vaccinated == "<15"] <- range_mode_source(15, sum(vaccinated == "<15"))
vaccinated[vaccinated == ""] <- "0"
vaccinated[is.na(vaccinated)] <- "0"

# Align age group for 80+ with other data sets
vaccinated$age_group <- recode(vaccinated$age_group, "80-89" = "80+", "90+" = "80+")

vaccinated <- vaccinated %>%
  mutate(
    age_group = factor(age_group),
    first_week_day = floor_date(as.Date(VaccinationDate)),
    last_week_day = as.Date(floor_date(as.Date(VaccinationDate))) + 6,
    first_dose = as.numeric(first_dose),
    second_dose = as.numeric(second_dose),
    third_dose = as.numeric(third_dose)
  ) %>%
  group_by(first_week_day, last_week_day, age_group) %>%
  summarise(
    weekly_vaccinated_first_dose = sum(first_dose),
    weekly_vaccinated_second_dose = sum(second_dose),
    weekly_vaccinated_third_dose = sum(third_dose)
  ) %>%
  group_by(age_group) %>%
  mutate(
    current_vaccinated_first_dose = cumsum(weekly_vaccinated_first_dose) - cumsum(weekly_vaccinated_second_dose),
    current_vaccinated_second_dose = cumsum(weekly_vaccinated_second_dose) - cumsum(weekly_vaccinated_third_dose),
    current_vaccinated_third_dose = cumsum(weekly_vaccinated_third_dose),
    total_vaccinated_first_dose = cumsum(weekly_vaccinated_first_dose),
    total_vaccinated_second_dose = cumsum(weekly_vaccinated_second_dose),
    total_vaccinated_third_dose = cumsum(weekly_vaccinated_third_dose),
    total_two_dose_fully_vaccinated = lag(n = 2, cumsum(weekly_vaccinated_second_dose)),
    total_three_dose_fully_vaccinated = lag(n = 2, cumsum(weekly_vaccinated_third_dose))
  )

#
# Process the population demographics
#
# Expected outcome should be the demographics partitioned into the same age buckets as the other data sets
#

filename <- newest_matching_file("data/population_age_groups*.csv")
message("Loading ", filename)
population <- read.csv(filename) %>%
  mutate(
    age_group = factor(age_group),
    male = as.numeric(male),
    female = as.numeric(female),
    total_population = male + female
  ) %>%
  rename(
    total_male_population = "male",
    total_female_population = "female"
  )

#
# Process the cases against vaccination status dataset
#
# Expected outcome should be the dataset normalized to the same age buckets as the other data sets
#

filename <- newest_matching_file("data/cases-among-vaccinated*.csv")
message("Loading ", filename)
cases <- read.csv(filename) %>%
  rename(age_group = "Age_group", positive_without_vaccination = "Sum_positive_without_vaccination")

# Clean up text values from import
cases[cases == "<5"] <- range_mode_source(5, sum(cases == "<5"))
cases[cases == ""] <- "0"
cases[is.na(cases)] <- "0"

# Align age group for 80+ with other data sets
cases$age_group <- recode(cases$age_group, "80-89" = "80+", "90+" = "80+")

cases <- cases %>%
  mutate(
    age_group = factor(age_group),
    first_week_day = as.Date(substr(Week, start = 1, stop = 10), format = "%Y-%m-%d"),
    last_week_day = as.Date(substr(Week, start = 13, stop = 23), format = "%Y-%m-%d"),
    positive_1_6_days_after_1st_dose = as.numeric(positive_1_6_days_after_1st_dose),
    positive_7_13_days_after_1st_dose = as.numeric(positive_7_13_days_after_1st_dose),
    positive_14_20_days_after_1st_dose = as.numeric(positive_14_20_days_after_1st_dose),
    positive_above_20_days_after_1st_dose = as.numeric(positive_above_20_days_after_1st_dose),
    positive_1_6_days_after_2nd_dose = as.numeric(positive_1_6_days_after_2nd_dose),
    positive_7_13_days_after_2nd_dose = as.numeric(positive_7_13_days_after_2nd_dose),
    positive_14_20_days_after_2nd_dose = as.numeric(positive_14_20_days_after_2nd_dose),
    positive_above_20_days_after_2nd_dose = as.numeric(positive_above_20_days_after_2nd_dose),
    positive_1_6_days_after_3rd_dose = as.numeric(positive_1_6_days_after_3rd_dose),
    positive_7_13_days_after_3rd_dose = as.numeric(positive_7_13_days_after_3rd_dose),
    positive_14_20_days_after_3rd_dose = as.numeric(positive_14_20_days_after_3rd_dose),
    positive_above_20_days_after_3rd_dose = as.numeric(positive_above_20_days_after_3rd_dose),
    positive_without_vaccination = as.numeric(positive_without_vaccination)
  ) %>%
  select(
    -Week,
  ) %>%
  mutate(
    positive_total_after_1st_dose = positive_1_6_days_after_1st_dose +
      positive_7_13_days_after_1st_dose +
      positive_14_20_days_after_1st_dose +
      positive_above_20_days_after_1st_dose,
    positive_total_after_2nd_dose = positive_1_6_days_after_2nd_dose +
      positive_7_13_days_after_2nd_dose +
      positive_14_20_days_after_2nd_dose +
      positive_above_20_days_after_2nd_dose,
    positive_total_after_3rd_dose = positive_1_6_days_after_3rd_dose +
      positive_7_13_days_after_3rd_dose +
      positive_14_20_days_after_3rd_dose +
      positive_above_20_days_after_3rd_dose,
    positive_total_partial_2nd_dose = positive_1_6_days_after_2nd_dose +
      positive_7_13_days_after_2nd_dose,
    positive_total_partial_3rd_dose = positive_1_6_days_after_3rd_dose +
      positive_7_13_days_after_3rd_dose,
    positive_total_full_2nd_dose = positive_14_20_days_after_2nd_dose +
      positive_above_20_days_after_2nd_dose,
    positive_total_full_3rd_dose = positive_14_20_days_after_3rd_dose +
      positive_above_20_days_after_3rd_dose,
    positive_total = positive_total_after_1st_dose +
      positive_total_after_2nd_dose +
      positive_total_after_3rd_dose +
      positive_without_vaccination
  ) %>%
  group_by(first_week_day, last_week_day, age_group) %>%
  summarise(
    positive_1_6_days_after_1st_dose = sum(positive_1_6_days_after_1st_dose),
    positive_7_13_days_after_1st_dose = sum(positive_7_13_days_after_1st_dose),
    positive_14_20_days_after_1st_dose = sum(positive_14_20_days_after_1st_dose),
    positive_above_20_days_after_1st_dose = sum(positive_above_20_days_after_1st_dose),
    positive_total_after_1st_dose = sum(positive_total_after_1st_dose),
    positive_1_6_days_after_2nd_dose = sum(positive_1_6_days_after_2nd_dose),
    positive_7_13_days_after_2nd_dose = sum(positive_7_13_days_after_2nd_dose),
    positive_14_20_days_after_2nd_dose = sum(positive_14_20_days_after_2nd_dose),
    positive_above_20_days_after_2nd_dose = sum(positive_above_20_days_after_2nd_dose),
    positive_total_after_2nd_dose = sum(positive_total_after_2nd_dose),
    positive_total_partial_2nd_dose = sum(positive_total_partial_2nd_dose),
    positive_total_full_2nd_dose = sum(positive_total_full_2nd_dose),
    positive_1_6_days_after_3rd_dose = sum(positive_1_6_days_after_3rd_dose),
    positive_7_13_days_after_3rd_dose = sum(positive_7_13_days_after_3rd_dose),
    positive_14_20_days_after_3rd_dose = sum(positive_14_20_days_after_3rd_dose),
    positive_above_20_days_after_3rd_dose = sum(positive_above_20_days_after_3rd_dose),
    positive_total_after_3rd_dose = sum(positive_total_after_3rd_dose),
    positive_total_partial_3rd_dose = sum(positive_total_partial_3rd_dose),
    positive_total_full_3rd_dose = sum(positive_total_full_3rd_dose),
    positive_without_vaccination = sum(positive_without_vaccination),
    positive_total = sum(positive_total)
  )

#
# Process the events among vaccinated dataset
#
# Expected outcome should be the dataset normalized to the same age buckets as the other data sets with deaths and
# hospitalizations moved from rows to columns
#

filename <- newest_matching_file("data/event-among-vaccinated-*.csv")
message("Loading ", filename)
events <- read.csv(filename) %>%
  rename(age_group = "Age_group")

# Clean up text values from import
events[events == "<5"] <- range_mode_source(5, sum(events == "<5"))
events[events == ""] <- "0"
events[is.na(events)] <- "0"

# Align age group for 80+ with other data sets
events$age_group <- recode(events$age_group, "80-89" = "80+", "90+" = "80+")

events <- events %>%
  mutate(
    age_group = factor(age_group),
    Type_of_event = factor(Type_of_event),
    first_week_day = as.Date(substr(Week, start = 1, stop = 10), format = "%Y-%m-%d"),
    last_week_day = as.Date(substr(Week, start = 13, stop = 23), format = "%Y-%m-%d"),
    event_after_1st_dose = as.numeric(event_after_1st_dose),
    event_after_2nd_dose = as.numeric(event_after_2nd_dose),
    event_after_3rd_dose = as.numeric(event_after_3rd_dose),
    event_for_not_vaccinated = as.numeric(event_for_not_vaccinated)
  ) %>%
  select(
    -Week,
  )

# Filter out the rows for each type of event
events_deaths <- events %>% filter(Type_of_event == "Death")
events_hospit <- events %>% filter(Type_of_event == "Hospitalization")

# Join the two tables using distinct columns for the event data
events_all <- left_join(events_deaths, events_hospit, by = c("first_week_day", "last_week_day", "age_group"), suffix = c("_deaths", "_hospit")) %>%
  select(
    -Type_of_event_deaths,
    -Type_of_event_hospit
  ) %>%
  group_by(first_week_day, last_week_day, age_group) %>%
  summarise(
    hospitalization_after_1st_dose = sum(event_after_1st_dose_hospit),
    hospitalization_after_2nd_dose = sum(event_after_2nd_dose_hospit),
    hospitalization_after_3rd_dose = sum(event_after_3rd_dose_hospit),
    hospitalization_for_not_vaccinated = sum(event_for_not_vaccinated_hospit),
    deaths_after_1st_dose = sum(event_after_1st_dose_deaths),
    deaths_after_2nd_dose = sum(event_after_2nd_dose_deaths),
    deaths_after_3rd_dose = sum(event_after_3rd_dose_deaths),
    deaths_for_not_vaccinated = sum(event_for_not_vaccinated_deaths)
  )

#
# Process the age and gender data set
#
# Expected outcome should be the dataset normalized to the same age buckets as the other data sets with gender
# moved from rows to columns
#

filename <- newest_matching_file("data/corona_age_and_gender_ver_*.csv")
message("Loading ", filename)
ages <- read.csv(filename)

# Translate Gender into english
ages$gender <- recode(ages$gender, "זכר" = "male", "לא ידוע" = "unknown", "נקבה" = "female")

# Clean up text values from import
ages[ages == "<15"] <- range_mode_source(15, sum(ages == "<15"))

# Convert an age group of NULL to NA
ages$age_group[ages$age_group == "NULL"] <- NA

# Age groups are in 5y buckets, combine to 10y buckets for merging with other data sets
ages$age_group <- recode(
  ages$age_group,
  "20-24" = "20-29",
  "25-29" = "20-29",
  "30-34" = "30-39",
  "35-39" = "30-39",
  "40-44" = "40-49",
  "45-49" = "40-49",
  "50-54" = "50-59",
  "55-59" = "50-59",
  "60-64" = "60-69",
  "65-69" = "60-69",
  "70-74" = "70-79",
  "75-79" = "70-79",
)

ages <- ages %>%
  mutate(
    age_group = factor(age_group),
    weekly_tests_num = as.numeric(weekly_tests_num),
    weekly_cases = as.numeric(weekly_cases),
    weekly_deceased = as.numeric(weekly_deceased),
    first_week_day = as.Date(first_week_day, format = "%Y-%m-%d"),
    last_week_day = as.Date(last_week_day, format = "%Y-%m-%d"),
  ) %>%
  mutate(
    weekly_female_tests_num = ifelse(gender == "female", weekly_tests_num, 0),
    weekly_male_tests_num = ifelse(gender == "male", weekly_tests_num, 0),
    weekly_female_cases = ifelse(gender == "female", weekly_cases, 0),
    weekly_male_cases = ifelse(gender == "male", weekly_cases, 0),
    weekly_female_deceased = ifelse(gender == "female", weekly_deceased, 0),
    weekly_male_deceased = ifelse(gender == "male", weekly_deceased, 0),
  )

# Aggregate rows to align with other data sets
ages_agg <- ages %>%
  select(-gender) %>%
  group_by(first_week_day, last_week_day, age_group) %>%
  summarise(
    weekly_tests_num = sum(weekly_tests_num),
    weekly_cases = sum(weekly_cases),
    weekly_deceased = sum(weekly_deceased),
    weekly_female_tests_num = sum(weekly_female_tests_num),
    weekly_female_cases = sum(weekly_female_cases),
    weekly_female_deceased = sum(weekly_female_deceased),
    weekly_male_tests_num = sum(weekly_male_tests_num),
    weekly_male_cases = sum(weekly_male_cases),
    weekly_male_deceased = sum(weekly_male_deceased)
  )

#
# Process the details on positive cases
#
# Expected outcome should be the dataset normalized to the same age buckets as the other data sets
#

filename <- newest_matching_file("data/positive-cases*.csv")
message("Loading ", filename)
positives <- read.csv(filename) %>%
  rename(
    age_group = "Age_group",
    positives_tests_num = "Tests_num",
    positives_not_recovered_at_least_2_doses = "Not_recovered_at_least_2_doses",
    positives_not_recovered_partially_vaccinated = "Not_recovered_partially_vaccinated",
    positives_not_recovered_not_vaccinated = "Not_recovered_not_vaccinated",
    positives_cases_among_recovered = "Cases_among_recovered")

# Clean up text values from import
positives[positives == "<5"] <- range_mode_source(5, sum(positives == "<5"))
positives[positives == ""] <- "0"
positives[is.na(positives)] <- "0"

# Align age group for 80+ with other data sets
positives$age_group <- recode(positives$age_group, "80-89" = "80+", "90+" = "80+")

positives <- positives %>%
  mutate(
    age_group = factor(age_group),
    first_week_day = as.Date(substr(Week, start = 1, stop = 10), format = "%Y-%m-%d"),
    last_week_day = as.Date(substr(Week, start = 13, stop = 23), format = "%Y-%m-%d"),
    positives_tests_num = as.numeric(positives_tests_num),
    positives_not_recovered_at_least_2_doses = as.numeric(positives_not_recovered_at_least_2_doses),
    positives_not_recovered_partially_vaccinated = as.numeric(positives_not_recovered_partially_vaccinated),
    positives_not_recovered_not_vaccinated = as.numeric(positives_not_recovered_not_vaccinated),
    positives_cases_among_recovered = as.numeric(positives_cases_among_recovered)
  ) %>%
  select(
    -Week,
  )

#
# Combine all the data sets
#
# Expected outcome, all the data sets are merged, with some useful derived columns added and then the output written
# to a file for subsequent analysis.
#

# Combine data
message("Joining datasets...")
data <- ages_agg %>%
  left_join(., events_all, by = c("first_week_day", "last_week_day", "age_group")) %>%
  left_join(., cases, by = c("first_week_day", "last_week_day", "age_group")) %>%
  left_join(., vaccinated, by = c("first_week_day", "last_week_day", "age_group")) %>%
  left_join(., positives, by = c("first_week_day", "last_week_day", "age_group")) %>%
  inner_join(., population, byte = c("age_group")) %>%
  mutate(
    total_unvaccinated = total_population - ifelse(is.na(total_vaccinated_first_dose), 0, total_vaccinated_first_dose),
    fraction_unvaccinated = total_unvaccinated / total_population,
    fraction_vaccinacted_first_dose = ifelse(is.na(total_vaccinated_first_dose), 0, total_vaccinated_first_dose / total_population),
    fraction_vaccinacted_second_dose = ifelse(is.na(total_vaccinated_first_dose), 0, total_vaccinated_second_dose / total_population),
    fraction_vaccinacted_third_dose = ifelse(is.na(total_vaccinated_first_dose), 0, total_vaccinated_third_dose / total_population),
    fraction_vaccinacted_first_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, (total_vaccinated_first_dose - total_vaccinated_second_dose) / total_population),
    fraction_vaccinacted_second_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, (total_vaccinated_second_dose - total_vaccinated_third_dose) / total_population),
    fraction_vaccinacted_third_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, total_vaccinated_third_dose / total_population),
    fraction_partially_vaccinacted_second_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, (total_vaccinated_second_dose - total_two_dose_fully_vaccinated) / total_population),
    fraction_partially_vaccinacted_third_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, (total_vaccinated_third_dose - total_three_dose_fully_vaccinated) / total_population),
    fraction_fully_vaccinacted_second_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, (total_two_dose_fully_vaccinated - total_vaccinated_third_dose) / total_population),
    fraction_fully_vaccinacted_third_dose_only = ifelse(is.na(total_vaccinated_first_dose), 0, total_three_dose_fully_vaccinated / total_population),
  )

# Save results
message("Writing ", sub(".R", ".csv", script.name))
write.csv(data, file = sub(".R", ".csv", script.name), row.names = FALSE, quote = TRUE)

