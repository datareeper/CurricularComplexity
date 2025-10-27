#' Calculates the delay factor of a course
#'
#' This function takes in a plan of study and a course, then finds that course's delay factor.
#' The output is the longest path of prerequisites through the given course.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param course Numeric (vertex id) or String - The course to calculate the delay factor of
#' @param include_coreqs Logical - Calculates the delay factor using corequisites, default value is TRUE
#' @return Numeric - the delay factor
#' @export


delay_factor <- function(plan_of_study, course, include_coreqs = TRUE)
{
  #First we use the subcomplexity function to sample the right courses
  necessary_courses <- subcomplexity_graph(plan_of_study, course)
  if (include_coreqs == FALSE)
  {
    necessary_courses <- delete_edges(necessary_courses, which(E(necessary_courses)$reqtype == "Co"))
  }
  #Next we call the course by name because the vertex indices were not preserved
  if (is.numeric(course)==TRUE) #Only need to covert if we're running through the loop
  {
    course <- as.character(V(plan_of_study)$name[course])
  }
  #We then use the find_X_courses functions to get a list of the courses before and after
  #the course of interest.
  blocked_courses <- find_outbound_courses(necessary_courses, course)
  previous_courses <- find_inbound_courses(necessary_courses, course)
  #Next, we need to find the longest path (prerequisite chain) through the course.
  #All simple paths gives us a list of all the paths that lead to a vertex.
  #In this case we want all paths before the course that lead to it using out degree
  #and we'll get all the courses after using the in degree instead.
  outbound <- all_simple_paths(necessary_courses, course, to = blocked_courses, mode = c("out"))
  inbound <- all_simple_paths(necessary_courses, course, to = previous_courses, mode = c("in"))

  #Next, we'll brute force the solution by checking the lengths finding the maximum paths
  #before and after the course. We'll then add their lengths.
  outbound.max <- 0   #starting with the outbound classes...
  if (length(outbound) > 0)
  {
    for (index in 1:length(outbound))
    {
      path_length <- length(outbound[[index]]) #the simple paths function uses lists, hence the [[]]
      if (path_length > outbound.max)
      {
        outbound.max <- path_length
      }
    }
  }

  inbound.max <- 0 #next we'll do the inbound courses, same process.
  if (length(inbound) > 0)
  {
    for (index in 1:length(inbound))
    {
      path_length <- length(inbound[[index]])
      if (path_length > inbound.max)
      {
        inbound.max <- path_length
      }
    }
  }

  #Next, there are some edge cases to take care of...
  #This is the typical case, there are courses before and after the course of interest.
  #Because we looked at paths before and after the course, it
  #was counted twice. Just subtract 1 from the total.
  if (outbound.max != 0 && inbound.max != 0)
  {
    longest_prereq_chain <- inbound.max + outbound.max - 1   #adjust for double count
  }
  #It's possible a course could be isolated. In that case, we take
  #the delay factor to be 1.
  else if (outbound.max == 0 && inbound.max == 0)
  {
    longest_prereq_chain <- 1
  }
  #Finally, this case accounts for a situation where either
  #the course has no prerequisites or it is the final course
  #in a chain. There's no double counting here, so we can
  #just add the path lengths.
  else
  {
    longest_prereq_chain <- inbound.max + outbound.max
  }
  return(longest_prereq_chain)
}
