library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(viridisLite)

# https://coronadatascraper.com/#sources
# https://github.com/lazd/coronadatascraper

dd = read_csv("https://coronadatascraper.com/timeseries-tidy.csv")

dd_fr = filter(dd, country=="FRA", population=67106161, grepl("opencovid19-fr", url))
unique(dd_fr$type)
dd_cases = plyr::ddply(dd_fr, .(date), summarize, max_cases = max(value, na.rm=T))


dd_cases = as.data.frame(select(filter(dd_fr, type=="cases"), date, value, type, url))
unique(dd_cases$url)

p <- ggplot(dd_cases, aes(x=date, y=max_cases)) +
  geom_line( color="steelblue") + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1))
p
