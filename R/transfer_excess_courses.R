#' Finds the subcomplexity graph of courses beyond expected time to degree
#'
#' This function takes in a plan of study and the expected time to degree, then outputs a subcomplexity
#' graph that contains all of the courses beyond the time to degree and their prerequisites.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param expected_time_to_degree Numeric - The term where students are expected to finish (often 8)
#' @param include_coreqs Logical - Calculates the delay factor using corequisties, default value is TRUE
#' @return Numeric - the delay factor
#' @export


transfer_excess_courses <- function(plan_of_study, expected_time_to_degree, include_coreqs = TRUE)
{
  #Find the courses that extend beyond the expected time to degree.
  excess_courses <- which(vertex.attributes(plan_of_study)$term > expected_time_to_degree)

  #Check if there are courses beyond the expected time to degree, if not just return NULL.
  if (length(excess_courses) == 0)
  {
    return(NULL)
  }

  #Initialize list of graphs and matrices to store the relevant courses and requisites
  subcomplexity_graphs_of_relevant_courses <- list()
  courses_in_graph <- NULL
  reqs_in_graph <- NULL

  #We'll search through all the courses identified and make the vertex/edge matrices
  for (index in 1:length(excess_courses))
  {
    #Use the subcomplexity function to find the courses associated with the excess course
    subcomplexity_graphs_of_relevant_courses[[index]] <- subcomplexity_graph(plan_of_study, excess_courses[index])

    #Fetch all the course qualities and put them in a matrix
    course_running_list <- cbind(vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$name,
                                 vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$term,
                                 vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$credits,
                                 vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$passrate,
                                 vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$lostcredits,
                                 vertex.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$timing
    )

    #Fetch all the requisite qualities and put them in a matrix
    reqs_running_list <- cbind(as_edgelist(subcomplexity_graphs_of_relevant_courses[[index]]),
                               edge.attributes(subcomplexity_graphs_of_relevant_courses[[index]])$reqtype)

    #Add what we found to the list of courses and requisites
    courses_in_graph <- rbind(courses_in_graph, course_running_list)
    reqs_in_graph <- rbind(reqs_in_graph, reqs_running_list)
  }

  #Now that we're done, there are certainly duplicates. Only keep unique entries.
  courses_in_graph <- unique(courses_in_graph)
  reqs_in_graph <- unique(reqs_in_graph)

  #Convert to dataframes for the igraph function and tidy them up
  courses_in_graph <- as.data.frame(courses_in_graph, stringsAsFactors = FALSE)
  reqs_in_graph <- as.data.frame(reqs_in_graph, stringsAsFactors = FALSE)
  names(courses_in_graph) <- c("name", "term", "credits", "passrate", "lostcredits", "timing")
  names(reqs_in_graph) <- c("from","to","reqtype")
  courses_in_graph$term <- as.numeric(courses_in_graph$term)
  courses_in_graph$passrate <- as.numeric(courses_in_graph$passrate)

  #For the plotting, some of the terms might be out of order and could cause overlap
  #Let's reorder them...note the order of the reqs don't matter.
  new_order <- order(courses_in_graph$term)
  courses_in_graph <- courses_in_graph[new_order,]

  #This graph will be the union of all the subcomplexity graphs for courses beyond the
  #Expected time to degree
  excess_courses_subcomplexity_graph <- graph_from_data_frame(d = reqs_in_graph,
                                                              vertices = courses_in_graph,
                                                              directed = TRUE)
  return(excess_courses_subcomplexity_graph)
}
