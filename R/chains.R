#' Calculates the delay factor of a course
#'
#' This function takes in a plan of study and a course, then finds that course's delay factor.
#' The output is the longest path of prerequisties through the given course.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return Numeric - the delay factor
#' @export

chains <- function(plan_of_study, course, include_coreqs = TRUE)
{
  all_simple_paths
}