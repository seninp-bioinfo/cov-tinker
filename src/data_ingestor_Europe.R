library(readr)
library(plyr)
library(dplyr)
library(reshape2)

library(ggplot2)
library(scales)
library(RColorBrewer)
library(viridisLite)
library(gridExtra)
library(Cairo)

# https://coronadatascraper.com/#sources
# https://github.com/lazd/coronadatascraper
# https://www.iban.com/country-codes

dd = read_csv("https://coronadatascraper.com/timeseries-tidy.csv")
grepl("FRA", unique(dd$country))

# FRANCE
dd_fr = filter(dd, country=="FRA")
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

# RUSSIA
dd_ru = filter(dd, country=="RUS")
dd_ru = filter(dd_ru, population==max(dd_ru$population, na.rm=T))
dd_ru_cases = as.data.frame(select(filter(dd_ru, type=="cases"), date, value))
p_growth <- ggplot(dd_ru_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Russia: Cov19 cases growth")
p_growth

# USA
dd_us = filter(dd, country=="USA")
dd_us = filter(dd_us, population==max(dd_us$population, na.rm=T))
dd_us_cases = as.data.frame(select(filter(dd_us, type=="cases"), date, value))
p_growth <- ggplot(dd_us_cases, aes(x=date, y=value)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("USA: Cov19 cases growth")
p_growth

# MERGE
dd_m <- data.frame(date=seq(as.Date("01/01/2020", "%d/%m/%y"), Sys.Date()-1, by='day')) ### -1 here
dd_m <- Reduce(function(...) merge(..., by='date', all=TRUE),
             list(dd_m, dd_fr_cases, dd_it_cases, dd_sp_cases, dd_gr_cases, dd_ru_cases, dd_us_cases))
names(dd_m) <- c("date", "France", "Italy", "Germany", "Spain", "Russia", "USA")
dd_m <- filter(dd_m, date>as.Date("15/02/2020", "%d/%m/%y"))
saveRDS(dd_m, "data/Europe_cases.Rds", compress=T)

dm <- reshape2::melt(dd_m, id=1)
colourCount = length(unique(dm$variable))
getPalette = colorRampPalette(brewer.pal(8, "Dark2"))
labelz = unique(dm$variable)
shapez = seq(15,(15+length(unique(dm$variable))))

p_growth <- ggplot(dm, aes(x=date, y=value, colour=variable, shape = variable)) +
  geom_line(size=.5) + geom_point(size=2) +
  labs(x="Date, 2020", y="Confirmed cases") +
  scale_x_date(breaks = "day", labels=date_format("%d-%m")) +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Cov19: daily cumulative incidence") +
  scale_colour_manual(name = "Countries",
                      labels = labelz,
                      values = getPalette(colourCount)) +   
  scale_shape_manual(name = "Countries",
                     labels = labelz,
                     values = shapez) +  
  theme_dark() +
  theme(panel.background=element_rect(fill = "lightgrey", colour = "grey", size = 0.5, linetype = "solid"),
    panel.grid.major=element_line(size = 0.5, linetype = 'solid',colour = "white"), 
    panel.grid.minor = element_blank(),
    legend.background = element_rect(fill="lightgrey", size=0.5, linetype="solid", colour ="lightgrey"),
    legend.key = element_rect(fill="grey75", size=0.5, linetype="solid", colour ="grey60"),
    legend.key.width = unit(20, unit = "pt"),
    axis.text.x = element_text(angle = 55, hjust = 1)
  )
p_growth

# ggsave(p_growth, filename = "figures/total_growth.png", width = 8, height = 6, dpi = 400, type = "cairo")
Cairo(width = 800, height = 550, 
      file="figures/total_growth.png", 
      type="png", pointsize=14, 
      bg = "transparent", canvas = "white", units = "px", dpi = 90)
print(p_growth)
dev.off()

# CASES
dd_diff <- mutate_if(dd_m, is.numeric, funs(. - lag(.)))
dd_diff <- mutate_if(dd_diff, is.numeric, ~replace(., is.na(.), 0))
saveRDS(dd_diff, "data/Europe_daily_incidence.Rds", compress=T)

dm <- reshape2::melt(dd_diff, id=1)
colourCount = length(unique(dm$variable))
getPalette = colorRampPalette(brewer.pal(8, "Dark2"))
labelz = unique(dm$variable)
shapez = seq(15,(15+length(unique(dm$variable))))

p_growth <- ggplot(dm, aes(x=date, y=value, fill=variable)) +
  geom_bar(stat = "identity") +
  labs(x="Date, 2020", y="Confirmed cases") +
  scale_x_date(breaks = "day", labels=date_format("%d-%m")) +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Cov19: daily incremental incidence") +
  scale_colour_manual(name = "Countries",
                      labels = labelz,
                      values = getPalette(colourCount)) +   
  theme_dark() +
  theme(panel.background=element_rect(fill = "lightgrey", colour = "grey", size = 0.5, linetype = "solid"),
        panel.grid.major=element_line(size = 0.5, linetype = 'solid',colour = "white"), 
        panel.grid.minor = element_blank(),
        legend.background = element_rect(fill="lightgrey", size=0.5, linetype="solid", colour ="grey"),
        legend.key = element_rect(fill="grey75", size=0.5, linetype="solid", colour ="grey60"),
        legend.key.width = unit(20, unit = "pt"),
        axis.text.x = element_text(angle = 55, hjust = 1)
  ) + 
  facet_wrap(~variable,scales = "fixed",strip.position="right",ncol=1)
p_growth

# ggsave(p_growth, filename = "figures/total_growth.png", width = 8, height = 6, dpi = 400, type = "cairo")
Cairo(width = 800, height = 550, 
      file="figures/new_daily.png", 
      type="png", pointsize=10, 
      bg = "transparent", canvas = "white", units = "px", dpi = 90)
print(p_growth)
dev.off()
