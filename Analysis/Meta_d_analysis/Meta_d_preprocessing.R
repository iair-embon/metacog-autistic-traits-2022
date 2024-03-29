##### This script creates the data frame to preprocess the data and run the meta d' 
##### from matlab

library(dplyr)

# load dataframe
root <- rprojroot::is_rstudio_project
basename(getwd())
load("./Data/df_total.Rda")

# stimuli presented column
df_total$left_right_stimuli <- ifelse(df_total$dots_num_left > df_total$dots_num_right,
                             "left","right")

# response key column 
left_right_response_key <- rep(NaN, nrow(df_total))
for (i in 1:nrow(df_total)) {

  if(df_total$dots_num_left[i] > df_total$dots_num_right[i] &
     df_total$discrimination_is_correct[i] == TRUE)
  {left_right_response_key[i] <- "left"} 
  
  if(df_total$dots_num_left[i] > df_total$dots_num_right[i] &
     df_total$discrimination_is_correct[i] == FALSE)
  {left_right_response_key[i] <- "right"}
  
  if(df_total$dots_num_left[i] < df_total$dots_num_right[i] &
     df_total$discrimination_is_correct[i] == TRUE)
  {left_right_response_key[i] <- "right"}
  
  if(df_total$dots_num_left[i] < df_total$dots_num_right[i] &
     df_total$discrimination_is_correct[i] == FALSE)
  {left_right_response_key[i] <- "left"}
}

df_total$left_right_response_key <-left_right_response_key

# summarise in the column needed
df_summarise <- df_total %>%
  group_by(Participant, left_right_stimuli, left_right_response_key, confidence_key) %>%
  summarise(confidence_n = n()) %>%
  ungroup()

# create a df where all preprocessed data will be saved
df_total_preprocessed <- data.frame(Participant = numeric(),
                                    left_right_stimuli = character(),
                                    left_right_response_key = character(),
                                    confidence_key = numeric(),
                                    confidence_n = numeric())

conf_ratings <- c(1,2,3,4)

# a function that will add the 0 responses to the missing confidence rating
add_zero_rating <- function(df_summarise_per_subj, stimuli, response){
  
  direction_df <- df_summarise_per_subj %>%
    filter(left_right_stimuli == stimuli & left_right_response_key == response)
  
  if(nrow(direction_df) < 4){
    diff_ratings <-  setdiff(conf_ratings, direction_df$confidence_key)
    

      df <- data.frame(Participant = rep(unique(df_summarise$Participant)[i], length(diff_ratings)),
                       left_right_stimuli = rep(stimuli,length(diff_ratings)),
                       left_right_response_key = rep(response,length(diff_ratings)),
                       confidence_key = diff_ratings, 
                       confidence_n = rep(0,length(diff_ratings)))
        df_total_temporary <- rbind(direction_df, df)
   
  }else{
    df_total_temporary <- direction_df}

  return(df_total_temporary)    
}

# applie the function per subject, stimuli and response
for (i in 1:length(unique(df_summarise$Participant))) {
  
  df_summarise_per_subj <- df_summarise %>%
    filter(Participant == unique(df_summarise$Participant)[i]) 
  
  if(nrow(df_summarise_per_subj)<16){
    
    # left left 
    df_total_temporary <- add_zero_rating(df_summarise_per_subj = df_summarise_per_subj, 
                                             stimuli = "left",
                                             response = "left")
    
    # order by confidence_key in descending order
    df_total_temporary <- df_total_temporary[order(-df_total_temporary$confidence_key), ]
    df_total_preprocessed <- rbind(df_total_preprocessed, df_total_temporary)
    
    # left right 
    df_total_temporary <- add_zero_rating(df_summarise_per_subj = df_summarise_per_subj, 
                                             stimuli = "left",
                                             response = "right")
    
    # order by confidence_key in ascending order
    df_total_temporary <- df_total_temporary[order(df_total_temporary$confidence_key), ]
    df_total_preprocessed <- rbind(df_total_preprocessed, df_total_temporary)
    
    # right left 
    df_total_temporary <- add_zero_rating(df_summarise_per_subj = df_summarise_per_subj, 
                                             stimuli = "right",
                                             response = "left")
    
    # order by confidence_key in descending order
    df_total_temporary <- df_total_temporary[order(-df_total_temporary$confidence_key), ]
    df_total_preprocessed <- rbind(df_total_preprocessed, df_total_temporary)
    
    # right right 
    df_total_temporary <- add_zero_rating(df_summarise_per_subj = df_summarise_per_subj, 
                                             stimuli = "right",
                                             response = "right")
    
    # order by confidence_key in ascending order
    df_total_temporary <- df_total_temporary[order(df_total_temporary$confidence_key), ]
    df_total_preprocessed <- rbind(df_total_preprocessed, df_total_temporary)
    
  } else {
    df_total_preprocessed <- rbind(df_total_preprocessed, df_summarise_per_subj)
  }
  
}

## In order to deal with 0 responses for some confidence ratings, we follow the 
## recomendation of Maniscalco and Lau function, and add a small adjustment factor
##  adj_f = 1/(length(nR_S1). In our case it would be 0.125

df_total_preprocessed$confidence_n <- df_total_preprocessed$confidence_n + 0.125  

## create a txt file that contain the column df_total_preprocessed$confidence_n 
## For df_total: /confidence_n.txt ; For df_total_filtered: /confidence_n_filtered.txt
write.table(df_total_preprocessed$confidence_n ,"Analysis/Meta_d_analysis/confidence_n.txt",sep="\t",row.names=FALSE)
