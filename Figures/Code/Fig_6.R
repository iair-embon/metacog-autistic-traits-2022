###########################
### Regression Analysis ### FIG 6
###########################

require(tidyverse)
require(jtools)
require(broom.mixed)

### load linear regression model 
root <- rprojroot::is_rstudio_project
basename(getwd())               
filepath <- root$find_file("Data/Regression_Results/AQ_subscales_linear_model.RData")
load(file= filepath)

plot_summs(a, coefs = c('Social Skill' = 'AQ_social.norm',
                        'Attention Switching'='AQ_AttentionSwitch.norm',
                        'Attention to Detail' = 'AQ_AttentionDetail.norm',
                        'Communication'='AQ_communication.norm',
                        'Imagination'='AQ_imagination.norm',
                        'Gender'='gender',
                        'Age' = 'age.norm') ,
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

ggsave("Figures/Figures/6.png", 
       width = 10, height = 6)
