#' Calculates the average sequencing in a program
#'
#' This function calculates the average sequencing in the program using the
#' delay factors of the courses. The second argument, expected_time_to_degree
#' is optional. If it is not NULL, the average sequencing will be for courses
#' extending the student's time to degree. 
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param expected_time_to_degree Numeric - The term where students are expected to finish (often 8)
#' @return Numeric - the average sequencing in the program
#' @export


average_sequencing <- function(plan_of_study, expected_time_to_degree = NULL)
{
  if(!is.null(expected_time_to_degree))
  {
    #First form the subcomplexity graph of the courses beyond the expected time to degree
    plan_of_study <- transfer_excess_courses(plan_of_study, expected_time_to_degree)
    relevant_courses <- which(V(plan_of_study)$term > expected_time_to_degree)
  }
  else
  {
    relevant_courses <- V(plan_of_study)
  }
  #Find the delay factors of the courses beyond the expected time-to-degree
  delay_factors <- lapply(relevant_courses,
                          function(x){
                            delay_factor(plan_of_study,x,include_coreqs = FALSE)
                          })
  delay_factors <- unlist(delay_factors) #need to unlist them from lapply
  average <- mean(delay_factors)
  return(average)
}
