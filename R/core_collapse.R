#' Calculates the core collapse sequence for a plan of study
#'
#' This function takes in a plan of study network and constructs the "core collapse sequence."
#' The core collapse sequence progressively removes courses from the plan of study with increasing
#' prereq counts and calculates the proportion of courses deleted at each step. The process stops
#' when all of the vertices have been removed. A sequence that decreases quickly to zero typically
#' indicates that the network is generally uniform with its prereqs. A sequence with more erratic
#' values that does not settle to zero smoothly would imply more dense sets of prereqs.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return List of two items: (1) sequence - the core collapse sequence, (2) the associated network for each entry
#' @export

core_collapse <- function(plan_of_study)
{
  graph_size <- vcount(plan_of_study) #find the number of vertices to use later
  core_collapse_sequence <- matrix(1,graph_size) #set up the sequence to track the k-cores
  coreness_index <- 0 #begin index
  kcore <- list()
  while (vcount(plan_of_study) > 0) #this will stop when there are no more vertices to remove
  {
    kcore[[coreness_index+1]] <- plan_of_study #save the network for reference later
    remainder <- length(as.matrix(V(plan_of_study)[degree(plan_of_study) < coreness_index+1])) #how many vertices are not members of the k+1-core?
    plan_of_study <- delete_vertices(plan_of_study,
                                     V(plan_of_study)[degree(plan_of_study) < coreness_index+1]) #remove those vertices
    core_collapse_sequence[coreness_index+1] <- remainder/graph_size #what proportion were just removed relative to the graph size?
    coreness_index <- coreness_index + 1 #next k-core
  }
  extra <- which(core_collapse_sequence == 1) #there will be some extra entries in the matrix, find those indices
  core_collapse_sequence <- core_collapse_sequence[-extra] #get rid of them
  output <- list(core_collapse_sequence,kcore) #form the output by combining the sequence and networks
  names(output) <- c("sequence","kcores")
  return(output)
}

