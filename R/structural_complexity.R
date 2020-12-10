#' Calculates structural complexity of a plan of study
#'
#' This function takes in a plan of study, then finds the plan of study's structural complexity.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return list of (1) a dataframe of course crucialities, delay factors, and blocking factors; (2) a numeric value
#' of structural complexity
#' @export

structural_complexity <- function(plan_of_study)
{
  #Set up the matrix to track all the structural complexity elements.
  structural_complexity_scores <- as.data.frame(matrix(NA,nrow = length(V(plan_of_study)), ncol = 4))
  names(structural_complexity_scores) <- c("Course","Blocking","Delay", "Cruciality")
  structural_complexity_scores$Course <- V(plan_of_study)$name
  #Iterate through all the courses and calculating the indices we need.
  for (index in 1:length(V(plan_of_study)))
  {
    structural_complexity_scores$Blocking[index] <- blocking_factor(plan_of_study, index)
    structural_complexity_scores$Delay[index] <- delay_factor(plan_of_study, index)
    structural_complexity_scores$Cruciality[index] <- structural_complexity_scores$Blocking[index] + structural_complexity_scores$Delay[index]
  }
  #The overall structural complexity is the sum of the individual crucialities
  overall_complexity <- sum(structural_complexity_scores$Cruciality)
  #We'll output the summary score and details in a list.
  output <- list(structural_complexity_scores,overall_complexity)
  names(output) <- c("Course Crucialities","Overall Structural Complexity")
  return(output)
}
