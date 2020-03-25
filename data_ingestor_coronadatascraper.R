library(readr)
library(plyr)
library(dplyr)
library(reshape2)

library(ggplot2)
library(viridisLite)
library(gridExtra)
library(Cairo)

# https://coronadatascraper.com/#sources
# https://github.com/lazd/coronadatascraper
dd = read_csv("https://coronadatascraper.com/timeseries-tidy.csv")

# FRANCE
dd_fr = filter(dd, country=="FRA", grepl("opencovid19-fr", url))
dd_fr = filter(dd_fr, population==max(dd_fr$population, na.rm=T))
dd_fr_cases = as.data.frame(select(filter(dd_fr, type=="cases"), date, value))
p_growth <- ggplot(dd_fr_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("FRANCE: Cov19 cases growth")
p_growth

# ITALY
dd_it = filter(dd, country=="ITA")
dd_it = filter(dd_it, population==max(dd_it$population, na.rm=T))
dd_it_cases = as.data.frame(select(filter(dd_it, type=="cases"), date, value))
p_growth <- ggplot(dd_it_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("GERMANY: Cov19 cases growth")
p_growth

# SPAIN
dd_sp = filter(dd, country=="ESP")
dd_sp = filter(dd_sp, population==max(dd_sp$population, na.rm=T))
dd_sp_cases = as.data.frame(select(filter(dd_sp, type=="cases"), date, value))
p_growth <- ggplot(dd_sp_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("SPAIN: Cov19 cases growth")
p_growth

# GERMANY
dd_gr = filter(dd, country=="DEU")
dd_gr = filter(dd_gr, population==max(dd_gr$population, na.rm=T))
dd_gr_cases = as.data.frame(select(filter(dd_gr, type=="cases"), date, value))
p_growth <- ggplot(dd_gr_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("GERMANY: Cov19 cases growth")
p_growth

# MERGE
dd_m <- data.frame(date=seq(as.Date("01/01/2020", "%d/%m/%y"), Sys.Date()-1, by='day'))
dd_m <- Reduce(function(...) merge(..., by='date', all=TRUE),
             list(dd_m, dd_fr_cases, dd_it_cases, dd_sp_cases, dd_gr_cases))
names(dd_m) <- c("date", "France", "Italy", "Germany", "Spain")
dd_m <- filter(dd_m, date>as.Date("15/02/2020", "%d/%m/%y"))

dm <- reshape2::melt(dd_m, id=1)
p_growth <- ggplot(dm, aes(x=date, y=value, col=variable)) +
  geom_line(size=.5) + geom_point(size=2) +
  labs(x="Date, 2020", y="Confirmed cases") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Cov19 cases growth") +
  scale_colour_viridis_d(name="Countries") + theme_dark() +
  theme(panel.background=element_rect(fill = "lightgrey", colour = "grey", size = 0.5, linetype = "solid"),
    panel.grid.major=element_line(size = 0.5, linetype = 'solid',colour = "white"), 
    panel.grid.minor = element_line(size = 0.25, linetype = 'solid',colour = "white"),
    legend.background = element_rect(fill="lightgrey", size=0.5, linetype="solid", colour ="grey"),
    legend.key = element_rect(fill="grey75", size=0.5, linetype="solid", colour ="grey60"),
    legend.key.width = unit(20, unit = "pt")
  )
p_growth

# ggsave(p_growth, filename = "figures/total_growth.png", width = 8, height = 6, dpi = 400, type = "cairo")
Cairo(width = 600, height = 450, 
      file="figures/total_growth.png", 
      type="png", pointsize=14, 
      bg = "transparent", canvas = "white", units = "px", dpi = 90)
print(p_growth)
dev.off()
