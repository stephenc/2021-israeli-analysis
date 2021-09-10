# Introduction 
        
This repository collects data from the [data.gov.il](https://data.gov.il/dataset/covid-19) and then combines the data sets for subsequent analysis.

* Please ignore the LaTeX stuff as I just cloned a repository I had with working bootstrap of an R environment and I have not had time to clean out the unnecessary distractions (plus I am thinking about producing PDF reports so I don;t want to rush to remove it!)

## Common tasks

* To generate the latest combined dataset run `make data.csv`.

* To generate the Z-score analysis of case numbers by vaccination status run `Rscript analysis.R`

## `data.csv` columns

This is a partial list of the columns and their sources

* `first_week_day` - the first date (inclusive) of the date bucket
* `last_week_day` - the last date (inclusive) of the date bucket
* `age_group` - the age group
* `weekly_tests_num` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_cases` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_deceased` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_female_tests_num` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_female_cases` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_female_deceased` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_male_tests_num` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_male_cases` - (from the `corona_age_and_gender_ver__N__.csv`)
* `weekly_male_deceased` - (from the `corona_age_and_gender_ver__N__.csv`)
* `hospitalization_after_1st_dose` - (from the `event-among-vaccinated-__N__.csv`)
* `hospitalization_after_2nd_dose` - (from the `event-among-vaccinated-__N__.csv`)
* `hospitalization_for_not_vaccinated` - (from the `event-among-vaccinated-__N__.csv`)
* `deaths_after_1st_dose` - (from the `event-among-vaccinated-__N__.csv`)
* `deaths_after_2nd_dose` - (from the `event-among-vaccinated-__N__.csv`)
* `deaths_for_not_vaccinated` - (from the `event-among-vaccinated-__N__.csv`)
* `positive_1_6_days_after_1st_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_7_13_days_after_1st_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_14_20_days_after_1st_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_above_20_days_after_1st_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_total_after_1st_dose` - Sum of the preceding 4 columns
* `positive_1_6_days_after_2nd_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_7_13_days_after_2nd_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_14_20_days_after_2nd_dose` - (from the `cases-among-vaccinated-__N__.csv`)
* `positive_total_after_2nd_dose` - Sum of the preceding 3 columns
* `positive_without_vaccination` - (from the `cases-among-vaccinated-__N__.csv`)
* `weekly_vaccinated_first_dose` - how many received their first dose this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `weekly_vaccinated_second_dose` - how many received their second dose this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `weekly_vaccinated_third_dose` - how many receieved their third dose this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `current_vaccinated_first_dose` - current number of people that have exactly one dose this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `current_vaccinated_second_dose` - current number of people that have exactly two doses this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `current_vaccinated_third_dose` - current number of people that have exactly three doses this week(from
  the `vaccinated-per-day-__YMD__.csv`)
* `total_vaccinated_first_dose` - how many have received at least one dose up to the end of this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `total_vaccinated_second_dose` - how many have received at least two doses up to the end of this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `total_vaccinated_third_dose` - how many have received at least three doses up to the end of this week (from
  the `vaccinated-per-day-__YMD__.csv`)
* `total_fully_vaccinated` - how many have received at least two doses up to the end of two weeks prior (from
  the `vaccinated-per-day-__YMD__.csv`)
* `positives_tests_num` - how many tests this week (from `positive-cases-__N__.csv`, expected similar
  to `weekly_tests_num` column)
* `positives_not_recovered_at_least_2_doses` -  (from `positive-cases-__N__.csv`)
* `positives_not_recovered_partially_vaccinated` - (from `positive-cases-__N__.csv`)
* `positives_not_recovered_not_vaccinated` - (from `positive-cases-__N__.csv`)
* `positives_cases_among_recovered` - (from `positive-cases-__N__.csv`)
* `total_male_population` - the number of males in this age group (from `population_age_groups.csv`)
* `total_female_population` - the number of females in this age group (from `population_age_groups.csv`)
* `total_population` - the number of people in this age group (from `population_age_groups.csv`)
* `total_unvaccinated` - the `total_population` after subtracting `total_vaccinated_first_dose`
* `fraction_vaccinated_first_dose` - the `total_vaccinated_first_dose` divided by `total_population`
* `fraction_vaccinated_second_dose` - the `total_vaccinated_second_dose` divided by `total_population`
* `fraction_vaccinated_third_dose` - the `total_vaccinated_third_dose` divided by `total_population`

# Toolchain

* [GNU Make](https://www.gnu.org/software/make/) for orchestration
* [R](https://www.r-project.org/) for data analysis and visualizations
* [Graphviz](https://graphviz.org/) for schematic diagrams
* [LaTeX](https://www.latex-project.org/) for presentation

# Quick Start

## First time setup

```
make init
```

## Generate the PDFs of the paper

```
make
```

## Clean-up

```
make clean
```
