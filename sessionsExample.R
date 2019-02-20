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
data <- fromJSON(content(GET('https://app.mluvii.com/api/v1/Sessions', client_token,
                             query = list(
                               created.min = floor_date(today, "month") - months(1),
                               created.max = floor_date(today, "month"),
                               limit = "5000")),
                         as="text"))

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
