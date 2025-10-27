#' Calculates the explained complexity of courses extending time to degree
#'
#' This function takes in the subcomplexity graph from the transfer excess courses function, then finds the transfer delay
#' factor. The output is the proportion of complexity explained by courses extending time to degree.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param expected_time_to_degree Numeric - The term where students are expected to finish (often 8)
#' @param term_weighted logical - TRUE if crucialities should be term-weighted
#' @return Numeric - the explained complexity
#' @export


explained_complexity <- function(plan_of_study, expected_time_to_degree, term_weighted = FALSE)
{
  #First form the subcomplexity graph of the courses beyond the expected time to degree
  subgraph <- transfer_excess_courses(plan_of_study, expected_time_to_degree)

  #If there are no courses beyond the time to degree, then the delay factor is zero
  if (is.null(subgraph))
  {
    return(0)
  }

  #Next, we'll find the structural complexity of the transfer related courses
  #and we'll find the overall complexity.
  subcomplexity_transfer_output <- structural_complexity(subgraph, term_weighted)
  subcomplexity_full_output <- structural_complexity(plan_of_study, term_weighted)
  transfer <- subcomplexity_transfer_output$`Overall Structural Complexity`
  full <- subcomplexity_full_output$`Overall Structural Complexity`

  #To find the explained complexity, we find the ratio of the transfer subcomplexity
  #over the full complexity.
  result <- 100*transfer/full

  #We'll round the result to one decimal place
  result <- round(result, digits = 1)
  output <- list(full,transfer,result)
  names(output) <- c("Structural Complexity","Transfer Subcomplexity","Explained Complexity")

  return(output)
}
