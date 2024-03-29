#######################################################
### Linear Regression Analysis AQ Subscales M_ratio ### 
#######################################################

### linear regression model 

root <- rprojroot::is_rstudio_project
basename(getwd())               

####### data frame with filters already applied
filepath <- root$find_file("Data/df_total.Rda")
load(file= filepath)

# Filter by reaction times
df_total <- df_total[df_total$TimeDiscTrial <= 20000,]
df_total <- df_total[df_total$TimeConfTrial <=20000,]

# burning the first 20 trials of each subject
df_total <- df_total[df_total$trial > 20,]

### AUROC2
# get metacognitive sensivity

# load the type 2 ROC analysis function
source(root$find_file("Analysis/AuxiliaryFunctions/auroc2.R"))

Nsuj <- length(unique(df_total$Participant))
# saving metacog = mc for each RT discarded
mc <- rep(NA, Nsuj)
ExistingSubjects <- unique(df_total$Participant)

for (i in 1:Nsuj){
  mc[i] <- type2roc(correct = df_total$discrimination_is_correct[df_total$Participant==ExistingSubjects[i]],
                    conf = df_total$confidence_key[df_total$Participant==ExistingSubjects[i]], 
                    Nratings = 4)}

## adding column mc to df_total

All_participants_mc <- c()
for (i in 1:length(ExistingSubjects)) {
  participant_df_exp <- df_total[df_total$Participant == ExistingSubjects[i],]
  trials <- nrow(participant_df_exp)
  participant_mc <-rep(mc[i],trials)
  All_participants_mc <- c(All_participants_mc,participant_mc)
}

df_total$mc <- All_participants_mc

### subset the df_total
source(root$find_file("Analysis/AuxiliaryFunctions/DataFrame_subset.R"))
d <- DataFrame_subset(df_total)

### preprocessing
d$age.std <- (d$age - mean(d$age))/ sd(d$age)
d[d == "non gender"] <- "4"
d[d == "Non Binary"] <- "3"
d[d == "Prefer not to say"] <- "2"
d[d == "Male"] <- "1"
d[d == "Female"] <- "0"
d$gender <- as.integer(d$gender)
d$AQ_social.std <- (d$AQ_social - mean(d$AQ_social))/ sd(d$AQ_social)
d$AQ_AttentionSwitch.std <- (d$AQ_AttentionSwitch - mean(d$AQ_AttentionSwitch))/ sd(d$AQ_AttentionSwitch)
d$AQ_AttentionDetail.std <- (d$AQ_AttentionDetail - mean(d$AQ_AttentionDetail))/ sd(d$AQ_AttentionDetail)
d$AQ_communication.std <- (d$AQ_communication - mean(d$AQ_communication))/ sd(d$AQ_communication)
d$AQ_imagination.std <- (d$AQ_imagination - mean(d$AQ_imagination))/ sd(d$AQ_imagination)

# adding the meta_d column
M_ratio <- read.table("./Analysis/Meta_d_analysis/M_ratio.txt")

d$M_ratio <- M_ratio$V1

# model
a=lm(M_ratio ~ AQ_social.std+
       AQ_AttentionSwitch.std+
       AQ_AttentionDetail.std+
       AQ_communication.std+
       AQ_imagination.std+
       gender +
       age.std,
     data = d) 
summary(a)

save(a, file = "Data/Regression_Results/Non_Exclusion_Criteria/M_ratio_AQ_subscales_linear_model.RData")

# power analysis
library(pwr)

power <- pwr.f2.test(u = 7, # number of iv
                     v = a$df.residual, # degree of freedom
                     f2 = 0.01702/(1-0.01702), # effect size
                     sig.level = 0.05) # alpha

print(paste("power model 1:", power$power))

# Adjust p-values for multiple comparisons with fdr method
library(broom)
library(tidyverse)

regression.results = summary(a)$coefficients
p_values <-unname(regression.results[,4])
p.adjust(p_values, method = "fdr")
