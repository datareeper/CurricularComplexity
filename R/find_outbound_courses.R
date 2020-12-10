#' Find all possible courses that depend on a particular course
#'
#' This function takes in a plan of study and a course, then finds all the courses it is related to
#' through its prerequisties (after the course).
#' @param plan_of_study An igraph object created using the create_plan_of_study function
#' @param course The course to find all relevant courses that directly or indirectly have it as a prereq
#' @return An atomic vector of vertex ids for the course's following courses
#' @export


find_outbound_courses <- function(plan_of_study, course)
{
  #The first statement looks ahead to see what courses are immediately after
  #the one we're interested in.
  next_courses <- unlist(adjacent_vertices(plan_of_study, course, mode = c("out")))
  #We'll be using a while loop, so this will initialize the list of courses we'll
  #use to track the following courses that are blocked until we run out of connections.
  blocked_courses <- next_courses
  while (length(next_courses) > 0)  #We'll keep going until there are no more courses found.
  {
    running_list <- NULL #This running list will track the courses we find looking forward one term.
    for (course in next_courses)  #This for loop will iterate through each set of courses we find.
    {
      #Get the next set of courses looking forward one term.
      following_courses <- unlist(adjacent_vertices(plan_of_study,course, mode = c("out")))
      if (length(following_courses) > 0)  #Only add something to the list if we find courses.
      {
        running_list <- c(following_courses,running_list) #add the courses to our master list
        next_courses <- following_courses #we'll check these courses next
      }
    }
    blocked_courses <- unique(c(running_list, blocked_courses)) #only keep the unique courses
    next_courses <- running_list #see if we have any new courses to check.
  }
  return(blocked_courses)
}
