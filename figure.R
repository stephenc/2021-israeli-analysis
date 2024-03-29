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

args <- commandArgs(trailingOnly = TRUE)

dev.on <- function(file) {
  if (sum(args == "--eps")) {
  setEPS()
    postscript(paste(file, ".eps", sep=""))
  } else {
    png(paste(file, ".png", sep=""), width = 1536, height = 1152)
  }
}

# Read in the data
data <- read.csv('data.csv') %>%
  mutate(
    age_group = factor(age_group),
    first_week_day = as.Date(first_week_day),
    last_week_day = as.Date(last_week_day)
  )

g1 <- ggplot(data, aes(x = last_week_day, y = weekly_cases, colour = age_group)) +
  geom_line() +
  labs(y = "Positive cases / week", x = "Week ending", colour = "Age group") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
g2 <- ggplot(data, aes(x = last_week_day, y = weekly_tests_num, colour = age_group)) +
  geom_line() +
  labs(y = "Tests / week", x = "Week ending", colour = "Age group") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
g3 <- ggplot(data, aes(x = last_week_day, y = weekly_cases / weekly_tests_num, colour = age_group)) +
  geom_line() +
  labs(y = "Positivity rate", x = "Week ending", colour = "Age group") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
g4 <- ggplot(data, aes(x = last_week_day, y = weekly_deceased, colour = age_group)) +
  geom_line() +
  labs(y = "Deaths / week", x = "Week ending", colour = "Age group") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.on(sub(".R", "", script.name))
plot(gridExtra::grid.arrange(g1, g2, g3, g4, ncol = 2))
dev.off()

g5 <- ggplot(data %>% filter(age_group == "50-59") 
  %>% pivot_longer(
    cols=c(
      "deaths_for_not_vaccinated",
      "deaths_after_1st_dose",
      "deaths_after_2nd_dose",
      "deaths_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Deaths"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "deaths_for_not_vaccinated" = "Unvaccinated",
    "deaths_after_1st_dose" = "1st Dose",
    "deaths_after_2nd_dose" = "2nd Dose",
    "deaths_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_deceased)) +
  geom_col(aes(y = Deaths, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Deaths / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 50-59") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g6 <- ggplot(data %>% filter(age_group == "60-69") 
  %>% pivot_longer(
    cols=c(
      "deaths_for_not_vaccinated",
      "deaths_after_1st_dose",
      "deaths_after_2nd_dose",
      "deaths_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Deaths"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "deaths_for_not_vaccinated" = "Unvaccinated",
    "deaths_after_1st_dose" = "1st Dose",
    "deaths_after_2nd_dose" = "2nd Dose",
    "deaths_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_deceased)) +
  geom_col(aes(y = Deaths, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Deaths / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 60-69") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g7 <- ggplot(data %>% filter(age_group == "70-79") 
  %>% pivot_longer(
    cols=c(
      "deaths_for_not_vaccinated",
      "deaths_after_1st_dose",
      "deaths_after_2nd_dose",
      "deaths_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Deaths"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "deaths_for_not_vaccinated" = "Unvaccinated",
    "deaths_after_1st_dose" = "1st Dose",
    "deaths_after_2nd_dose" = "2nd Dose",
    "deaths_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_deceased)) +
  geom_col(aes(y = Deaths, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Deaths / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 70-79") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g8 <- ggplot(data %>% filter(age_group == "80+") 
  %>% pivot_longer(
    cols=c(
      "deaths_for_not_vaccinated",
      "deaths_after_1st_dose",
      "deaths_after_2nd_dose",
      "deaths_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Deaths"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "deaths_for_not_vaccinated" = "Unvaccinated",
    "deaths_after_1st_dose" = "1st Dose",
    "deaths_after_2nd_dose" = "2nd Dose",
    "deaths_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_deceased)) +
  geom_col(aes(y = Deaths, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Deaths / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 80+") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.on(sub(".R", "2", script.name))
plot(gridExtra::grid.arrange(
  g5, g6, g7, g8, ncol = 2))
dev.off()


g5 <- ggplot(data %>% filter(age_group == "50-59") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 50-59") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g6 <- ggplot(data %>% filter(age_group == "60-69") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 60-69") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g7 <- ggplot(data %>% filter(age_group == "70-79") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 70-79") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g8 <- ggplot(data %>% filter(age_group == "80+") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 80+") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.on(sub(".R", "3", script.name))
plot(gridExtra::grid.arrange(
  g5, g6, g7, g8, ncol = 2))
dev.off()

g5 <- ggplot(data %>% filter(age_group == "0-19") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 0-19") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g6 <- ggplot(data %>% filter(age_group == "20-29") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 20-29") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g7 <- ggplot(data %>% filter(age_group == "30-39") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 30-39") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

g8 <- ggplot(data %>% filter(age_group == "40-49") 
  %>% pivot_longer(
    cols=c(
      "hospitalization_for_not_vaccinated",
      "hospitalization_after_1st_dose",
      "hospitalization_after_2nd_dose",
      "hospitalization_after_3rd_dose"
      ), 
    names_to="Vaccination_status", 
    values_to="Hospitalizations"
    )
  %>% mutate(Vaccination_status=recode(
    Vaccination_status,
    "hospitalization_for_not_vaccinated" = "Unvaccinated",
    "hospitalization_after_1st_dose" = "1st Dose",
    "hospitalization_after_2nd_dose" = "2nd Dose",
    "hospitalization_after_3rd_dose" = "3rd Dose"
    )), aes(x = last_week_day, y = weekly_cases)) +
  geom_col(aes(y = Hospitalizations, fill = Vaccination_status)) +
  geom_line() +
  labs(y = "Hospitalization / week", x = "Week ending", fill = "Vaccination status") +
  ggtitle("Ages 40-49") +
  scale_x_date(date_labels = "%b %Y") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

dev.on(sub(".R", "3b", script.name))
plot(gridExtra::grid.arrange(
  g5, g6, g7, g8, ncol = 2))
dev.off()

dev.on(sub(".R", "4", script.name))
plot(ggplot(data %>%
              drop_na() %>%
              filter(age_group == "20-29"), aes(x = last_week_day)) +
       geom_line(aes(y = total_unvaccinated / total_population, colour = "Unvaccinated")) +
       geom_line(aes(y = total_vaccinated_first_dose / total_population, colour = "1st dose")) +
       geom_line(aes(y = total_vaccinated_second_dose / total_population, colour = "2nd dose")) +
       geom_line(aes(y = total_vaccinated_third_dose / total_population, colour = "3rd dose")) +
       geom_line(aes(y = total_two_dose_fully_vaccinated / total_population, colour = "Fully vaccinated")) +
       labs(y = "% vaccinated", x = "Week ending", colour = "Vaccination status") +
       scale_x_date(date_labels = "%b %Y") +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()

dev.on(sub(".R", "5a", script.name))
plot(ggplot(data %>% drop_na(), aes(x = last_week_day, y = (hospitalization_after_2nd_dose / total_two_dose_fully_vaccinated * 100000), colour = age_group)) +
       geom_line() +
       labs(y = "Hospitalizations per 100k per week", x = "Week ending", colour = "Age group") +
       ggtitle("Hospitalization rate of fully vaccinated (at least 2 weeks since 2nd dose)") +
       scale_x_date(date_labels = "%b %Y") +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()

dev.on(sub(".R", "5b", script.name))
plot(ggplot(data %>% drop_na(), aes(x = last_week_day, y = (hospitalization_for_not_vaccinated / total_unvaccinated * 100000), colour = age_group)) +
       geom_line() +
       labs(y = "Hospitalizations per 100k per week", x = "Week ending", colour = "Age group") +
       ggtitle("Hospitalization rate of unvaccinated") +
       scale_x_date(date_labels = "%b %Y") +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()

dev.on(sub(".R", "5c", script.name))
plot(ggplot(data %>% drop_na(), aes(x = last_week_day, y = (hospitalization_after_2nd_dose / total_two_dose_fully_vaccinated) / (hospitalization_for_not_vaccinated / total_unvaccinated), colour = age_group)) +
       geom_line() +
       labs(y = "Relative Risk of Hospitalizations", x = "Week ending", colour = "Age group") +
       ggtitle("Relative Risk") +
       scale_x_date(date_labels = "%b %Y") +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()

ve_data <- data %>% mutate(ve = ((hospitalization_for_not_vaccinated / total_unvaccinated) - (hospitalization_after_2nd_dose / total_two_dose_fully_vaccinated)) / (hospitalization_for_not_vaccinated / total_unvaccinated))
dev.on(sub(".R", "5", script.name))
plot(ggplot(ve_data %>%
              drop_na() %>%
              filter(ve >= -1) %>%
              filter(ve <= 1), aes(x = last_week_day, y = ve, colour = age_group)) +
       geom_point() +
       geom_smooth(se = FALSE) +
       labs(y = "Vaccine efficiency for Hospitalization", x = "Week ending", colour = "Vaccination status") +
       scale_x_date(date_labels = "%b %Y") +
       scale_y_continuous(labels = scales::percent, limits = c(-1, 1)) +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()


ve_data <- data %>% mutate(ve = ((deaths_for_not_vaccinated / total_unvaccinated) - (deaths_after_2nd_dose / total_two_dose_fully_vaccinated)) / (deaths_for_not_vaccinated / total_unvaccinated))
dev.on(sub(".R", "6", script.name))
plot(ggplot(ve_data %>%
              drop_na() %>%
              filter(ve >= -1) %>%
              filter(ve <= 1), aes(x = last_week_day, y = ve, colour = age_group)) +
       geom_point() +
       geom_smooth(se = FALSE) +
       labs(y = "Vaccine efficiency for Deaths", x = "Week ending", colour = "Vaccination status") +
       scale_x_date(date_labels = "%b %Y") +
       scale_y_continuous(labels = scales::percent, limits = c(-1, 1)) +
       theme_bw() +
       theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
dev.off()

