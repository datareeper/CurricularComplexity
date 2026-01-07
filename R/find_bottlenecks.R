#' Finds the bottlenecks in the plan of study based on prerequisite relationships
#'
#' This function takes in a plan of study and three parameters. In this case, we
#' choose min_prereq,min_postreq, and min_connections. The value of min_prereq is the minimum number of prerequisites defining
#' a bottleneck (in the user's perspective), whereas min_postreq is the minimum number of courses
#' the given course is a prerequisite for. Finally, min_connections is the minimum total of the number of prerequisites
#' and the number of courses the given course is a prerequisite for. A course is a bottleneck if it meets
#' at least one of the parameters
#'
#' Suggested values for typical usage is find_bottleneck(x,3,3,5), which are #' provided by default.
#' Note that min_connections >= min_prereq + min_postreq - 2. If this is violated, a warning is
#' provided and corrected to the suggested minimum value of min_prereq + min_postreq - 2.
#'
#' The output is an atomic vector of possible bottlenecks based on the user-defined parameters.
#'
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param min_prereq numeric - minimum number of prerequisites defining a bottleneck
#' @param min_postreq numeric - minimum number of courses the given course is a prerequisite for
#' @param min_connections numeric - minimum total of the number of prerequisites
#' @param include_coreqs boolean - default is TRUE, treats corequisites as prerequisites
#' and the number of courses the given course is a prerequisite for
#' @return atomic vector - list of courses meeting at least one condition of the three parameters
#' @export

find_bottlenecks <- function(plan_of_study, min_prereq = 3, min_postreq = 3, min_connections = 5,include_coreqs = TRUE)
{
  #First we'll initialize a vector of the bottlenecks and get the IDs of the courses to process.
  bottleneck_list <- NULL
  courses_to_process <- V(plan_of_study)
  #If we want to exclude the coreqs, we'll find each of the edges with reqtype of "Co" and delete
  #them from the network before calculating the various in-, out-, and total degrees of each node.
  if (include_coreqs == FALSE)
  {
    coreqs_to_delete <- which(E(plan_of_study)$reqtype == "Co")
    plan_of_study <- delete.edges(plan_of_study, coreqs_to_delete)
  }
  #We'll check if the last parameter is an appropriate value
  minimum_value_for_min_connections <- min_prereq + min_postreq - 2
  #If not, we'll throw a warning and adjust to the minimum sensible value.
  if (min_connections <= minimum_value_for_min_connections)
  {
    min_connections <- minimum_value_for_min_connections
    warning(paste("Your value for min_connections was too low. It has been adjusted to ", min_connections,".", sep = ""))
  }
  #We'll iterate through each course and calculate the in-, out-, and total degrees of each vertex.
  for (course in courses_to_process)
  {
    num_prereqs <- degree(plan_of_study,
                                v = courses_to_process[course],
                                mode = "in"
                                )
    num_postreqs <- degree(plan_of_study,
                                v = courses_to_process[course],
                                mode = "out"
    )
    num_connections <- degree(plan_of_study,
                           v = courses_to_process[course],
                           mode = "total"
    )
    #Getting rid of the named number attribute that is an artifact of the "degree" function.
    num_prereqs <- as.numeric(num_prereqs)
    num_postreqs <- as.numeric(num_postreqs)
    num_connections <- as.numeric(num_connections)
    #We'll check if any of the conditions are violated.
    if(num_prereqs >= min_prereq | num_postreqs >= min_postreq | num_connections >= min_connections)
    {
      #If so, we add the course ID to the list.
      bottleneck_to_add <- course
      bottleneck_list <- c(bottleneck_list,bottleneck_to_add)
    }
  }
  #Finally, we'll get the names of each course using the V function from igraph to get the vertex
  #list. The result is what we'll return.
  bottleneck_list <- V(plan_of_study)[bottleneck_list]
  return(bottleneck_list)
}
