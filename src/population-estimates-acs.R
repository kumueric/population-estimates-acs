
# DATA --------------------------------------------------------------------

options(scipen=999, digits=4)

pacman::p_load(plyr, dplyr, tidyr, stringr, lubridate)

pacman::p_load(acsr)
api.key.install(key="paste your API key here")

# Create table and variable inputs
acs_tbl <- "B01001_"
acs_seq <- list(c(3,3), c(4,4), c(5,5), c(6,7), c(8,10), c(11,11), c(12,12), c(13,13), c(14,14), 
                c(15,15), c(16,16), c(17,17), c(18,19), c(20,21), c(22,22), c(23,23), c(24,24), c(25,25),
                
                c(27,27), c(28,28), c(29,29), c(30,31), c(32,34), c(35,35), c(36,36), c(37,37), 
                c(38,38), c(39,39), c(40,40), c(41,41), c(42,43), c(44,45), c(46,46), c(47,47), c(48,48), c(49,49))
acs_varname <- c("Male/00-04", "Male/05-09", "Male/10-14", "Male/15-19", "Male/20-24", "Male/25-29", 
                 "Male/30-34", "Male/35-39", "Male/40-44", "Male/45-49", "Male/50-54", "Male/55-59", 
                 "Male/60-64", "Male/65-69", "Male/70-74", "Male/75-79", "Male/80-84", "Male/85 and Over",
                 "Female/00-04", "Female/05-09", "Female/10-14", "Female/15-19", "Female/20-24", "Female/25-29",
                 "Female/30-34", "Female/35-39", "Female/40-44", "Female/45-49", "Female/50-54", "Female/55-59",
                 "Female/60-64", "Female/65-69", "Female/70-74", "Female/75-79", "Female/80-84", "Female/85 and Over")

acs_formula <- list()
n <- 0

# Run loop to create formula
for(i in acs_seq) {
  n <- n+1
  y <- str_c(acs_tbl, str_pad(seq(i[1], i[2], by=1), width=3, pad="0"))
  y <- str_c(y, collapse="+")
  acs_formula[[n]]<- y
}
acs_formula <- sapply(acs_formula, rbind)

# Make API call
age_sex <- sumacs(formula = acs_formula,
                    varname = acs_varname,
                    state   = "*",
                    county  = "*",
                    level   = "zip.code",
                    span    = 5,
                    endyear = "2014",
                    method  = rep("aggregation", length(acs_varname)))

save(age_sex, file="age.Rda")
load(file="age.Rda")

# EDA/IDA -----------------------------------------------------------------

# Create reference table for Hawaii zip code areas
data(zip.regions, package="choroplethrZip")

zip.regions <- zip.regions %>%
  select(region, state.name, county.name) %>%
  unique

# Create population table
age_sex_pp <- age_sex %>%
  left_join(zip.regions, by=c("zip"="region")) %>%
  filter(state.name=="hawaii") %>%
  select(county.name, contains("_est")) %>%
  gather(group, population, -county.name) %>%
  group_by(county.name, group) %>%
  summarise(
    population = sum(population)
  ) %>%
  separate(group, c("sex", "age.group"), "/") %>%
  ungroup

# Create population pyramid
pacman::p_load(ggplot2, grid)

chart_labels <- age_sex_pp %>%
  filter(county.name!="kalawao") %>%
  ggplot(aes(x=1, y=age.group)) + 
  geom_text(aes(label=age.group)) +
  labs(y=NULL, x=NULL) +
  scale_x_continuous(expand=c(0,0), limits=c(0.995, 1.005)) +
  theme_bw() +
  theme(axis.title=element_blank(),
        panel.grid=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks.y=element_blank(),
        panel.background=element_blank(),
        axis.text.x=element_text(color=NA),
        axis.ticks.x=element_line(color=NA),
        plot.margin=unit(c(1,-1,1,-1), "mm"),
        legend.position="none")

chart_female <- age_sex_pp %>%
  filter(county.name!="kalawao", sex=="Female") %>%
  ggplot(aes(x=age.group, y=population, fill=county.name)) +
  geom_bar(stat="identity") + 
  scale_y_reverse(limits=c(60000, 0), labels=scales::comma) +
  ggtitle("Females") +
  theme_bw() +
  theme(axis.title.x=element_blank(), 
        axis.title.y=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(), 
        plot.margin=unit(c(1,-1,1,0), "mm"),
        legend.position="none") +
  coord_flip()

chart_male <- age_sex_pp %>%
  filter(county.name!="kalawao", sex=="Male") %>%
  ggplot(aes(x=age.group, y=population, fill=county.name)) +
  geom_bar(stat="identity") + 
  scale_y_continuous(limits=c(0, 60000), labels=scales::comma) +
  ggtitle("Males") +
  theme_bw() +
  theme(axis.title.x=element_blank(), 
        axis.title.y=element_blank(), 
        axis.text.y=element_blank(), 
        axis.ticks.y=element_blank(), 
        plot.margin=unit(c(1,-1,1,0), "mm"),
        legend.position="right") +
  coord_flip()

pacman::p_load(gridExtra)
chart_female_ggt <- ggplot_gtable(ggplot_build(chart_female))
chart_male_ggt   <- ggplot_gtable(ggplot_build(chart_male))
chart_labels_ggt <- ggplot_gtable(ggplot_build(chart_labels))

chart_final <- marrangeGrob(list(chart_female_ggt, chart_labels_ggt, chart_male_ggt), ncol=3, nrow=1, widths=c(4/9,1/9,4/9))

ggsave("chart_final.pdf", chart_final, width=45, height=15, units="in")
