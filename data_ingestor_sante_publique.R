library(readr)
library(plyr)
library(dplyr)
library(ggplot2)
library(viridisLite)

######################
dd = read_csv("https://raw.githubusercontent.com/opencovid19-fr/data/master/dist/chiffres-cles.csv")

dd_fr = filter(dd, maille_code=="FRA", maille_nom=="France", source_type=="sante-publique-france")

str(dd_fr)

p <- ggplot(dd_fr, aes(x=date, y=cas_confirmes)) +
  geom_line( color="steelblue") + 
  geom_point() +
  xlab("") +
  theme(axis.text.x=element_text(angle=60, hjust=1))
p
