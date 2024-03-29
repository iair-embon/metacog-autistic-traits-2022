########################
### Regression model ### FIG 4
########################

require(tidyverse)
require(jtools)
require(broom.mixed)

### load linear regression model 
root <- rprojroot::is_rstudio_project
basename(getwd())               
filepath <- root$find_file("Data/Regression_Results/AUROC2_AQ_linear_model.RData")
load(file= filepath)

### FIG 4a
plot_summs(a, coefs = c('AQ' = 'AQ_test.norm',
                        'Gender[m]'='gender',
                        'Age' = 'age.norm',
                        'AQ:Gender[m]'='AQ_test.norm:gender',
                        'AQ:Age'='AQ_test.norm:age.norm'),
           colors = "black")+
  ylab("") +
  xlab("Regression coefficient") +
  scale_x_continuous(breaks=seq(-0.03,0.03,0.02))+
  theme_bw() +
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        plot.margin = margin(1, 1,1, 1, "cm"),
        panel.background = element_blank(),
        axis.text.x = element_text(size = 30),
        axis.text.y = element_text(size = 30), 
        axis.title.y = element_text(size = 30),
        axis.title.x = element_text(size = 30))

ggsave("Figures/Figures/4a.png", 
       width = 10, height = 6)

####### data frame with filters already applied
filepath <- root$find_file("Data/df_total_filtered.Rda")
load(file= filepath)

source(root$find_file("Analysis/AuxiliaryFunctions/DataFrame_subset.R"))
d <- DataFrame_subset(df_total)

# convert the normalized AQ scores to the original scores
intercept <- coefficients(a)[[1]]
slope <- coefficients(a)[[2]]

converted_intercept <- intercept-slope*mean(d$AQ_test)/sd(d$AQ_test)
converted_slope <- slope/sd(d$AQ_test)


## regression line and scatter plot
ggplot(d, aes(x=AQ_test, y=mc)) + 
  geom_point()+
  geom_abline(intercept = converted_intercept, 
              slope = converted_slope)+
  ylab("AUROC2") +
  xlab("AQ") +
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        plot.margin = margin(1, 1,1, 1, "cm"),
        panel.background = element_blank(),
        axis.title.x=element_text(size = 30),
        axis.text.x=element_text(size = 30),
        axis.text.y = element_text(size = 30),
        axis.title.y = element_text(size = 30))

ggsave("Figures/Figures/4b.png", 
       width = 10, height = 6)