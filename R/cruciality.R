#' Calculates the cruciality of a course
#'
#' This function takes in a plan of study and a course, then finds that course's cruciality.
#' The value is the sum of the blocking and delay factors of the course
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param course Numeric (vertex id) or String - The course to calculate the cruciality of
#' @param include_coreqs logical - Indicates whether corequisites should be included in the calculation
#' @return Numeric - the course's cruciality
#' @export


cruciality <- function(plan_of_study, course, include_coreqs = TRUE)
{
  cruciality_value <- blocking_factor(plan_of_study,course,include_coreqs) + delay_factor(plan_of_study,course,include_coreqs)
  return(cruciality_value)
}

