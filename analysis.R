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

ggqrcode <- function(text, colour="black", alpha=1) {
  x <- qrcode_gen(text, plotQRcode = F, dataOutput = T)
  x <- as.data.frame(x)

  y <- x
  y$id <- rownames(y)
  y <- gather(y, "key", "value", colnames(y)[-ncol(y)])
  y$key <- factor(y$key, levels = rev(colnames(x)))
  y$id <- factor(y$id, levels = rev(rownames(x)))

  ggplot(y, aes_(x = ~id, y = ~key)) +
    geom_tile(aes_(fill = ~value), alpha = alpha) +
    scale_fill_gradient(low = "white", high = colour) +
    theme_void() +
    coord_fixed() +
    theme(legend.position = 'none', plot.margin = unit(c(1, 1, 1.5, 1.2), "cm"))
}

# Read in the data
data <- read.csv('data.csv') %>%
  mutate(
    age_group = factor(age_group),
    first_week_day = as.Date(first_week_day),
    last_week_day = as.Date(last_week_day)
  )

target_week <- data %>%
  filter(!is.na(positive_total)) %>%
  summarize(first_week_day = max(first_week_day), last_week_day = max(last_week_day))

target_data <- data %>% filter(first_week_day == target_week[['first_week_day']])

# current_vaccinated_third_dose, current_vaccinated_second_dose, current_vaccinated_first_dose, total_unvaccinated, total_population

case_numbers <- target_data %>%
  select(
    age_group, positive_total_full_3rd_dose, positive_total_partial_3rd_dose, positive_total_full_2nd_dose, positive_total_after_1st_dose, positive_without_vaccination, positive_total
  ) %>%
  rename(
    "Age Group" = "age_group",
    "Case numbers\nFully Vaccinated\n(3 doses)" = "positive_total_full_3rd_dose",
    "Case numbers\nPartially Vaccinated\n(3 doses)" = "positive_total_partial_3rd_dose",
    "Case numbers\nFully Vaccinated\n(2 doses)" = "positive_total_full_2nd_dose",
    "Case numbers\nPartially Vaccinated\n(1 doses)" = "positive_total_after_1st_dose",
    "Case numbers\nUnvaccinated" = "positive_without_vaccination",
    "Total" = "positive_total"
  )

case_rates <- target_data %>%
  mutate(
    rate_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, positive_total_full_3rd_dose /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    rate_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, positive_total_partial_3rd_dose /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    rate_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, positive_total_full_2nd_dose /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    rate_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, positive_total_after_1st_dose /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    rate_without_vaccination = ifelse(total_unvaccinated <= 0, 0, positive_without_vaccination /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    rate_total = positive_total / total_population * 100000
  ) %>%
  mutate(
    rate_full_3rd_dose = round(rate_full_3rd_dose, 1),
    rate_partial_3rd_dose = round(rate_partial_3rd_dose, 1),
    rate_full_2nd_dose = round(rate_full_2nd_dose, 1),
    rate_partial_1st_dose = round(rate_partial_1st_dose, 1),
    rate_without_vaccination = round(rate_without_vaccination, 1),
    rate_total = round(rate_total, 1)
  ) %>%
  select(
    age_group, rate_full_3rd_dose, rate_partial_3rd_dose, rate_full_2nd_dose, rate_partial_1st_dose, rate_without_vaccination, rate_total
  ) %>%
  rename(
    "Age Group" = "age_group",
    "Cases per 100k\nFully Vaccinated\n(3 doses)" = "rate_full_3rd_dose",
    "Cases per 100k\nPartially Vaccinated\n(3 doses)" = "rate_partial_3rd_dose",
    "Cases per 100k\nFully Vaccinated\n(2 doses)" = "rate_full_2nd_dose",
    "Cases per 100k\nPartially Vaccinated\n(1 doses)" = "rate_partial_1st_dose",
    "Cases per 100k\nUnvaccinated" = "rate_without_vaccination",
    "Cases per 100k\nTotal" = "rate_total"
  )

z_scores_vs_without_vaccination <- target_data %>%
  mutate(
    rate_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, positive_total_full_3rd_dose /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    rate_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, positive_total_partial_3rd_dose /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    rate_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, positive_total_full_2nd_dose /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    rate_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, positive_total_after_1st_dose /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    rate_without_vaccination = ifelse(total_unvaccinated <= 0, 0, positive_without_vaccination /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    rate_total = positive_total / total_population * 100000,
    stdev_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, sqrt(positive_total_full_3rd_dose) /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    stdev_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, sqrt(positive_total_partial_3rd_dose) /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    stdev_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, sqrt(positive_total_full_2nd_dose) /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    stdev_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, sqrt(positive_total_after_1st_dose) /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    stdev_without_vaccination = ifelse(total_unvaccinated <= 0, 0, sqrt(positive_without_vaccination) /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    z_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, NA, (rate_full_3rd_dose - rate_without_vaccination) / (stdev_full_3rd_dose + stdev_without_vaccination)),
    z_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, NA, (rate_partial_3rd_dose - rate_without_vaccination) / (stdev_partial_3rd_dose + stdev_without_vaccination)),
    z_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, NA, (rate_full_2nd_dose - rate_without_vaccination) / (stdev_full_2nd_dose + stdev_without_vaccination)),
    z_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, NA, (rate_partial_1st_dose - rate_without_vaccination) / (stdev_partial_1st_dose + stdev_without_vaccination))
  ) %>%
  select(
    age_group, z_full_3rd_dose, z_partial_3rd_dose, z_full_2nd_dose, z_partial_1st_dose
  ) %>%
  mutate(
    z_full_3rd_dose = round(z_full_3rd_dose, 1),
    z_partial_3rd_dose = round(z_partial_3rd_dose, 1),
    z_full_2nd_dose = round(z_full_2nd_dose, 1),
    z_partial_1st_dose = round(z_partial_1st_dose, 1),
  ) %>%
  rename(
    "Age Group" = "age_group",
    "Z-score\nFully Vaccinated\n(3 doses)\nvs\nUnvaccinated" = "z_full_3rd_dose",
    "Z-score\nPartially Vaccinated\n(3 doses)\nvs\nUnvaccinated" = "z_partial_3rd_dose",
    "Z-score\nFully Vaccinated\n(2 doses)\nvs\nUnvaccinated" = "z_full_2nd_dose",
    "Z-score\nPartially Vaccinated\n(1 doses)\nvs\nUnvaccinated" = "z_partial_1st_dose",
  )


z_scores_vs_full_2nd_dose <- target_data %>%
  mutate(
    rate_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, positive_total_full_3rd_dose /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    rate_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, positive_total_partial_3rd_dose /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    rate_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, positive_total_full_2nd_dose /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    rate_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, positive_total_after_1st_dose /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    rate_without_vaccination = ifelse(total_unvaccinated <= 0, 0, positive_without_vaccination /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    rate_total = positive_total / total_population * 100000,
    stdev_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, sqrt(positive_total_full_3rd_dose) /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    stdev_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, sqrt(positive_total_partial_3rd_dose) /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    stdev_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, sqrt(positive_total_full_2nd_dose) /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    stdev_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, sqrt(positive_total_after_1st_dose) /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    stdev_without_vaccination = ifelse(total_unvaccinated <= 0, 0, sqrt(positive_without_vaccination) /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    z_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, NA, (rate_full_3rd_dose - rate_full_2nd_dose) / (stdev_full_3rd_dose + stdev_full_2nd_dose)),
    z_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, NA, (rate_partial_3rd_dose - rate_full_2nd_dose) / (stdev_partial_3rd_dose + stdev_full_2nd_dose)),
    z_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, NA, (rate_partial_1st_dose - rate_full_2nd_dose) / (stdev_partial_1st_dose + stdev_full_2nd_dose)),
    z_without_vaccination = ifelse(total_unvaccinated <= 0, NA, (rate_without_vaccination - rate_full_2nd_dose) / (stdev_without_vaccination + stdev_full_2nd_dose))
  ) %>%
  select(
    age_group, z_full_3rd_dose, z_partial_3rd_dose, z_partial_1st_dose, z_without_vaccination
  ) %>%
  mutate(
    z_full_3rd_dose = round(z_full_3rd_dose, 1),
    z_partial_3rd_dose = round(z_partial_3rd_dose, 1),
    z_partial_1st_dose = round(z_partial_1st_dose, 1),
    z_without_vaccination = round(z_without_vaccination, 1),
  ) %>%
  rename(
    "Age Group" = "age_group",
    "Z-score\nFully Vaccinated\n(3 doses)\nvs\nFully Vaccinated\n(2 doses)" = "z_full_3rd_dose",
    "Z-score\nPartially Vaccinated\n(3 doses)\nvs\nFully Vaccinated\n(2 doses)" = "z_partial_3rd_dose",
    "Z-score\nPartially Vaccinated\n(1 doses)\nvs\nFully Vaccinated\n(2 doses)" = "z_partial_1st_dose",
    "Z-score\nUnvaccinated\nvs\nFully Vaccinated\n(2 doses)" = "z_without_vaccination",
  )

png(paste0("analysis-", target_week[['first_week_day']],".png"), width = 2400, height = 1350)
grid.arrange(
  ggplot(data = target_data %>%
    select(
      age_group, positive_total_full_3rd_dose, positive_total_partial_3rd_dose, positive_total_full_2nd_dose, positive_total_after_1st_dose, positive_without_vaccination
    ) %>%
    pivot_longer(starts_with("positive_")), aes(x = factor(age_group), y = value, group = name, fill = name)) +
    geom_col(position = "dodge2") +
    labs(x="Age group", y="Positive test results",fill="Vaccination status", title=paste("Case numbers for the week", target_week[['first_week_day']], "to", target_week[['last_week_day']])) +
    scale_fill_discrete(labels=c(
      positive_total_full_3rd_dose="Fully Vaccinated\n(3 doses)",
      positive_total_partial_3rd_dose="Partially Vaccinated\n(3 doses)",
      positive_total_full_2nd_dose="Fully Vaccinated\n(2 doses)",
      positive_total_after_1st_dose="Partially Vaccinated\n(1 dose)",
      positive_without_vaccination="Unvaccinated"
    )) +
    theme_bw()
  ,
  ggplot(data = target_data %>% mutate(
    rate_full_3rd_dose = ifelse(fraction_fully_vaccinated_third_dose_only <= 0, 0, positive_total_full_3rd_dose /
      fraction_fully_vaccinated_third_dose_only /
      total_population * 100000),
    rate_partial_3rd_dose = ifelse(fraction_partially_vaccinated_third_dose_only <= 0, 0, positive_total_partial_3rd_dose /
      fraction_partially_vaccinated_third_dose_only /
      total_population * 100000),
    rate_full_2nd_dose = ifelse(fraction_fully_vaccinated_second_dose_only <= 0, 0, positive_total_full_2nd_dose /
      fraction_fully_vaccinated_second_dose_only /
      total_population * 100000),
    rate_partial_1st_dose = ifelse(fraction_vaccinated_first_dose_only <= 0, 0, positive_total_after_1st_dose /
      fraction_vaccinated_first_dose_only /
      total_population * 100000),
    rate_without_vaccination = ifelse(total_unvaccinated <= 0, 0, positive_without_vaccination /
      fraction_unvaccinated /
      total_unvaccinated * 100000),
    ) %>%
    select(
      age_group, rate_full_3rd_dose, rate_partial_3rd_dose, rate_full_2nd_dose, rate_partial_1st_dose, rate_without_vaccination
    ) %>%
    pivot_longer(starts_with("rate_")), aes(x = factor(age_group), y = value, group = name, fill = name)) +
    geom_col(position = "dodge2") +
    labs(x = "Age group", y = "Positive test results per 100,000", fill = "Vaccination status", title = paste("Case rates per 100,000 for the week", target_week[['first_week_day']], "to", target_week[['last_week_day']])) +
    scale_fill_discrete(labels = c(
      rate_full_3rd_dose = "Fully Vaccinated\n(3 doses)",
      rate_partial_3rd_dose = "Partially Vaccinated\n(3 doses)",
      rate_full_2nd_dose = "Fully Vaccinated\n(2 doses)",
      rate_partial_1st_dose = "Partially Vaccinated\n(1 dose)",
      rate_without_vaccination = "Unvaccinated"
    )) +
    theme_bw()
  ,
  tableGrob(format(case_numbers, decimal.mark = ".", big.mark = ",", nsmall = 0, scientific = FALSE), rows = NULL),
  tableGrob(format(case_rates, decimal.mark = ".", big.mark = ",", nsmall = 1, scientific = FALSE), rows = NULL),
  tableGrob(format(z_scores_vs_without_vaccination, decimal.mark = ".", big.mark = ",", nsmall = 1, scientific = FALSE), rows = NULL),
  tableGrob(format(z_scores_vs_full_2nd_dose, decimal.mark = ".", big.mark = ",", nsmall = 1, scientific = FALSE), rows = NULL),
  ggqrcode("https://data.gov.il/dataset/covid-19"),
  ggqrcode("https://github.com/stephenc/2021-israeli-analysis"),
  ncol = 2
)
dev.off()
