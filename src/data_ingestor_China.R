library(tidyr)
library(lubridate)
library(readr)
library(plyr)
library(dplyr)
library(reshape2)

library(ggplot2)
library(viridisLite)
library(gridExtra)
library(Cairo)

# https://timchurches.github.io/blog/posts/2020-02-18-analysing-covid-19-2019-ncov-outbreak-data-with-r-part-1/#estimating-changes-in-the-effective-reproduction-number
destfile = "./data/provinces_confirmed_jh.rda"
if (!file.exists(destfile)) {
  provinces_confirmed_jh <- read_csv("https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv") %>% 
    rename(province = "Province/State", country_region = "Country/Region") %>% 
    pivot_longer(-c(province, country_region, Lat, Long), 
                 names_to = "Date", values_to = "cumulative_cases") %>% 
    mutate(Date = as.Date(mdy_hm(paste(Date, "23:59", tz = "UTC")), 
            tz = "Asia/Shanghai")) %>% filter(country_region == 
            "Mainland China") %>% group_by(province) %>% 
            arrange(province, Date) %>% group_by(province) %>% 
            mutate(incident_cases = c(0, diff(cumulative_cases))) %>% ungroup() %>% 
            select(-c(country_region, Lat, Long, cumulative_cases)) %>% 
            pivot_wider(Date, names_from = province, values_from = incident_cases) %>% 
          mutate(source = "Johns Hopkins University")
  save(provinces_confirmed_jh, file = destfile)
} else {
  load(destfile)
}



dd = filter(provinces_confirmed_jh, 
            province %in% c("Hubei", "Beijing", "Guangdong", "Henan", 
                       "Zhejiang", "Hunan", "Anhui", "Jiangxi", "Jiangsu", "Chongqing", 
                       "Shandong"))

# CHINA
dd_cn = filter(dd, country=="CHN")
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
saveRDS(dd_m, "data/uptodate4countries.Rds", compress=T)

dm <- reshape2::melt(dd_m, id=1)
p_growth <- ggplot(dm, aes(x=date, y=value, col=variable)) +
  geom_line(size=.5) + geom_point(size=2) +
  labs(x="Date, 2020", y="Confirmed cases") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Cov19: daily cumulative incidence") +
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
Cairo(width = 800, height = 550, 
      file="figures/total_growth.png", 
      type="png", pointsize=14, 
      bg = "transparent", canvas = "white", units = "px", dpi = 90)
print(p_growth)
dev.off()

# CASES
dd_diff <- mutate_if(dd_m, is.numeric, funs(. - lag(.)))
dd_diff <- mutate_if(dd_diff, is.numeric, ~replace(., is.na(.), 0))
saveRDS(dd_diff, "data/daily_incidence.Rds", compress=T)

dm <- reshape2::melt(dd_diff, id=1)
p_growth <- ggplot(dm, aes(x=date, y=value, fill=variable)) +
  geom_bar(stat = "identity") +
  labs(x="Date, 2020", y="Confirmed cases") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("Cov19: daily incremental incidence") +
  scale_fill_viridis_d(name="Countries") + theme_dark() +
  theme(panel.background=element_rect(fill = "lightgrey", colour = "grey", size = 0.5, linetype = "solid"),
        panel.grid.major=element_line(size = 0.5, linetype = 'solid',colour = "white"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid',colour = "white"),
        legend.background = element_rect(fill="lightgrey", size=0.5, linetype="solid", colour ="grey"),
        legend.key = element_rect(fill="grey75", size=0.5, linetype="solid", colour ="grey60"),
        legend.key.width = unit(20, unit = "pt")
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
