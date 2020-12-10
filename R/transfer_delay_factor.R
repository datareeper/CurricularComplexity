#' Calculates the transfer delay factor of a course
#'
#' This function takes in the subcomplexity graph from the transfer excess courses function, then finds the transfer delay
#' factor. The output is the sum of the longest paths of prerequisties through courses related to those beyond the
#' expected time to degree.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param expected_time_to_degree Numeric - The term where students are expected to finish (often 8)
#' @return Numeric - the transfer delay factor
#' @export


transfer_delay_factor <- function(plan_of_study, expected_time_to_degree)
{
  #First form the subcomplexity graph of the courses beyond the expected time to degree
  subgraph <- transfer_excess_courses(plan_of_study, expected_time_to_degree)

  #If there are no courses beyond the time to degree, then the delay factor is zero
  if (is.null(subgraph))
  {
    return(0)
  }

  #Find the structural complexity of the new plan of study graph
  complexity_calculations <- structural_complexity(subgraph)

  #Fetch the delay factors and sum them
  delay_factors <- complexity_calculations$`Course Crucialities`$Delay
  delay_factor_transfer <- sum(delay_factors)

  return(delay_factor_transfer)
}
