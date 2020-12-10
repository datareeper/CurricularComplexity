#' Calculates the blocking factor of a course
#'
#' This function takes in a plan of study and a course, then finds that course's blocking factor.
#' The value is the number of courses 'blocked' by failing the given course.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param course Numeric (vertex id) or String - The course to calculate the blocking factor of
#' @return Numeric - the blocking factor
#' @export


blocking_factor <- function(plan_of_study, course)
{
  #We can simply call the find_outbound_courses function and find the number of
  #courses after the course of interest. This gives us the desired result.
  blocked_courses <- find_outbound_courses(plan_of_study, course)
  number_blocked <- length(blocked_courses)
  return(number_blocked)
}
