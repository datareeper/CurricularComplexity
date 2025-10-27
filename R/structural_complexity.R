#' Calculates structural complexity of a plan of study
#'
#' This function takes in a plan of study, then finds the plan of study's structural complexity.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param term_weighted logical - TRUE if crucialities should be term-weighted
#' @param include_coreqs logical - TRUE if coreqs should be included when calculating blocking and delay factor
#' @param quarters logical - TRUE if the plan of study uses quarters instead of semesters
#' @return list of (1) a dataframe of course crucialities, delay factors, and blocking factors; (2) a numeric value
#' of structural complexity
#' @export

structural_complexity <- function(plan_of_study, term_weighted = FALSE, include_coreqs = TRUE, quarters = FALSE)
{
  if (include_coreqs == FALSE)
  {
    plan_of_study <- delete_edges(plan_of_study, which(E(plan_of_study)$reqtype == "Co"))
  }
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

  if(term_weighted == TRUE)
  {
    terms <- V(plan_of_study)$term
    structural_complexity_scores$Blocking <- structural_complexity_scores$Blocking*terms
    structural_complexity_scores$Delay <- structural_complexity_scores$Delay*terms
    structural_complexity_scores$Cruciality <- structural_complexity_scores$Cruciality*terms
  }
  
  if(quarters == TRUE)
  {
    structural_complexity_scores$Blocking <- round(structural_complexity_scores$Blocking/1.5,2)
    structural_complexity_scores$Delay <- round(structural_complexity_scores$Delay/1.5,2)
    structural_complexity_scores$Cruciality <- round(structural_complexity_scores$Cruciality/1.5,2)
  }

  #The overall structural complexity is the sum of the individual crucialities
  overall_complexity <- sum(structural_complexity_scores$Cruciality)
  #We'll output the summary score and details in a list.
  output <- list(structural_complexity_scores,overall_complexity)
  names(output) <- c("Course Crucialities","Overall Structural Complexity")
  return(output)
}
