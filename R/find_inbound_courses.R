#' Find all possible prerequisites to a course
#'
#' This function takes in a plan of study and a course, then finds all the courses it is related to
#' through its prerequisites
#' @param plan_of_study An igraph object created using the create_plan_of_study function
#' @param course The course to find all relevant prerequisites of
#' @return An atomic vector of vertex ids for the course's prerequisites
#' @export

find_inbound_courses <- function(plan_of_study, course)
{
  #First get a vector of the courses immediately before the course of interest.
  leading_courses <- unlist(adjacent_vertices(plan_of_study, course, mode = c("in")))
  #We'll be using a while loop, so this will initialize the list of courses we'll
  #use to track the prerequisites until we run out of connections.
  previous_courses <- leading_courses
  difference <- 1 #We'll be checking if the list gets any longer after iterating
  while (difference > 0)
  {
    running_list <- NULL  #This running list will track the courses we find looking back one term.
    for (course in previous_courses)
    {
      #Get the next set of courses looking back one term.
      leading_courses <- unlist(adjacent_vertices(plan_of_study,course, mode = c("in")))
      if (length(leading_courses) > 0) #Only add something to the list if we find courses.
      {
        running_list <- c(leading_courses,running_list) #Concatenate what we found with the master list
      }
    }
    previous_run <- previous_courses #Set up the comparison by using the list of courses from the loop.
    #Duplicates are possible because of coreqs, so we'll only keep the unique courses we find.
    previous_courses <- unique(c(running_list, previous_courses))
    #This next statement will check if our master list got any bigger on the last iteration.
    difference <- abs(length(previous_run) - length(previous_courses))
  }
  return(previous_courses)
}
