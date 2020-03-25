library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(viridisLite)

######################
dd = read_csv("https://raw.githubusercontent.com/opencovid19-fr/data/master/dist/chiffres-cles.csv")
dd_fr = filter(dd, maille_code=="FRA", maille_nom=="France", source_type=="sante-publique-france")
p_growth <- ggplot(dd_fr, aes(x=date, y=cas_confirmes)) +
  geom_line() + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1)) +
  ggtitle("fRANCE: Cov19 cases growth")
p_growth

# https://timchurches.github.io/blog/posts/2020-02-18-analysing-covid-19-2019-ncov-outbreak-data-with-r-part-1/#estimating-changes-in-the-effective-reproduction-number

library(earlyR)
?get_R
