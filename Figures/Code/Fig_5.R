##########################################
### Mixed Logistic Regression Analysis ### FIG 5
##########################################

require(tidyverse)
require(jtools)
require(broom.mixed)

### load mixed logistic regression model 
root <- rprojroot::is_rstudio_project
basename(getwd())               
filepath <- root$find_file("Data/Regression_Results/MixedLogisticRegressionAnalysis.RData")
load(file= filepath)

plot_summs(a_log, coefs = c('AQ' = 'confidence_key.norm:AQ_test.norm',
                            'Gender[m]' = 'confidence_key.norm:gender',
                            'Age' = 'confidence_key.norm:age.norm',
                            'AQ:Gender[m]' = 'confidence_key.norm:AQ_test.norm:gender',
                            'AQ:Age' = 'confidence_key.norm:AQ_test.norm:age.norm'),
           plot.distributions = FALSE, colors = "black")+
  ylab("") +
  xlab("Regression coefficient") +
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

ggsave("Figures/Figures/5.png", 
       width = 10, height = 6)
