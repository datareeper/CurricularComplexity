#' Calculates the curriculum rigidity
#'
#' This function takes in a plan of study and then finds the curriculum's rigidity.
#' The rigidity is the beta index of the graph, which is the number of prerequisites
#' divided by the number of courses
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return Numeric - the curriculum rigidity
#' @export

curriculum_rigidity <- function(plan_of_study)
{
  E <- length(E(plan_of_study))
  V <- length(V(plan_of_study))
  rigidity <- E/V
  return(rigidity)
}

