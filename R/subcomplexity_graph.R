#' Creates a subcomplexity graph for a course
#'
#' This function takes in a plan of study and course, then constructs the subcomplexity graph for the course.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param course Numeric (vertex id) or String - The course to find the subcomplexity graph of
#' @return igraph object representing the course's subcomplexity graph.
#' @export


subcomplexity_graph <- function(plan_of_study, course)
{
  #To get the subcomplexity graph for a course, we need to get all the courses in its
  #prerequiste chain. We'll use the find_X_courses functions to get those vertices
  blocked_courses <- find_outbound_courses(plan_of_study, course)
  previous_courses <- find_inbound_courses(plan_of_study, course)
  #Next, we'll put all those vertices in one set. We'll add in the course of interest
  #by pulling its index and appending it to the set.
  relevant_courses <- c(blocked_courses,previous_courses,as.numeric(V(plan_of_study)[course]))
  #This igraph function will make a subgraph based on the vertices we specified.
  reduced_graph <- induced_subgraph(plan_of_study,relevant_courses)
  return(reduced_graph)
}
