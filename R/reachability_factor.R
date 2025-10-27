#' Calculates the reachability factor of a course
#'
#' This function takes in a plan of study and a course, then finds that course's reachability factor.
#' The value is the number of courses needed to be passed before enrolling in the given course.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param course Numeric (vertex id) or String - The course to calculate the blocking factor of
#' @param include_coreqs logical - Indicates whether corequisites should be included in the calculation
#' @return Numeric - the reachability factor
#' @export


reachability_factor <- function(plan_of_study, course, include_coreqs = TRUE)
{
  if (include_coreqs == FALSE)
  {
    plan_of_study <- delete_edges(plan_of_study, which(E(plan_of_study)$reqtype == "Co"))
  }
  #We can simply call the find_outbound_courses function and find the number of
  #courses after the course of interest. This gives us the desired result.
  leading_courses <- find_inbound_courses(plan_of_study, course)
  number_leading <- length(leading_courses)
  return(number_leading)
}

