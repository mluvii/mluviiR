# To obtain client_token, see clientToken.R

library(jsonlite)
library(lubridate)
library(dplyr)
library(ggplot2)

# unreleased bugfix in lubridate: https://github.com/tidyverse/lubridate/pull/696
setMethod("Compare", signature(e1 = "Duration", e2 = "numeric"),
          function(e1, e2) {
            callGeneric(e1@.Data, e2)
          })

# Fetch last month's sessions

today <- Sys.Date()
rawdata <- content(GET('https://app.mluvii.com/api/v1/Sessions', client_token,
                       query = list(
                         created.min = floor_date(today, "month") - months(1),
                         created.max = floor_date(today, "month"),
                         limit = "5000")),
                   as="text")

data <- fromJSON(rawdata, flatten = TRUE)

# Median waiting time per day, hour and widget

waited_widget_dayhour <- data %>%
  select(widget, enteredQueue, waited) %>%
  mutate(entered = round_date(ymd_hms(enteredQueue), unit="hour")) %>%
  mutate(waited = duration(waited)) %>%
  group_by(widget, entered) %>%
  summarise(median_waited = median(waited, na.rm = TRUE))

ggplot(waited_widget_dayhour, aes(entered, y = median_waited, group = widget, colour = widget)) +
  geom_point() + geom_line() +
  scale_y_continuous(labels = function (x) {
    gsub(" \\(", "\n(", duration(x))
  })

# Waiting time per day of week, hour of day and widget

waited_widget_dowhour <- data %>%
  select(widget, enteredQueue, waited) %>%
  mutate(
    weekday = factor(weekdays(ymd_hms(enteredQueue)), levels = weekdays(as.Date('2019-01-07')+0:6)),
    hour = factor(hour(ymd_hms(enteredQueue))),
    waited = duration(waited))

ggplot(waited_widget_dowhour, aes(x = hour, y = waited, fill = widget)) +
  geom_boxplot(outlier.shape = NA) +
  facet_grid(vars(widget), vars(weekday)) +
  coord_cartesian(ylim = boxplot.stats(waited_widget_dowhour$waited)$stats[c(1, 5)]*1.05) +
  scale_y_continuous(labels = function (x) {
    gsub(" \\(", "\n(", duration(x))
  }) +
  scale_x_discrete(labels = function (x) {
    sprintf("%sh", x)
  })

# Client browsers

browsers <- data %>%
  select(guest.browser) %>%
  group_by(guest.browser) %>%
  summarise(count = n()) %>%
  ungroup() %>%
  arrange(desc(count)) %>%
  mutate(freq = count / sum(count), browser = factor(guest.browser, levels = rev(guest.browser)))

ggplot(browsers, aes(x = "", y = freq, fill = browser)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = paste0(browser, "\n", scales::percent(round(freq, 3)))),
            position = position_stack(vjust = 0.5)) +
  coord_polar("y") +
  theme_void() +
  guides(fill = guide_legend(reverse = TRUE))
