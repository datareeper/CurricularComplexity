#' Create a plan of study igraph object
#'
#' This function takes in a set of courses, their terms, prerequisites, and corequisites.
#' Optional arguments include the number of credits, pass rates, lost credits from transferring,
#' and the frequency of course offerings. The function creates an igraph structure of edges and nodes with the
#' given qualities.
#'
#' It is recommended that the user imports the data from a csv file to
#' ensure the indices for each atomic vector correspond to the attributes of one course.
#'
#' @param Course atomic vector - strings for each course
#' @param Term a numeric atomic vector - the term  each course is offered
#' @param Prereq atomic vector - strings of the courses' prereqs, separated by commas
#' @param Coreq atomic vector - strings of the courses' coreqs, separated by commas
#' @param Credits numeric atomic vector - number of credits each course is worth (optional)
#' @param LostCredits numeric atomic vector - (for transfer students) identifies if credit for the course is not applied toward a student's degree, 1. If it is, 0. (optional)
#' @param PassRate numeric atomic vector - pass rates by class (optional)
#' @param Timing numeric atomic vector - number of times the course is offered in 2 years (optional)
#' @param Institution atomic vector - strings of course affiliations (CC or FY)
#' @return An igraph object of the prerequisite structure
#' @export

create_plan_of_study <- function(Course,
                                 Term,
                                 Prereq,
                                 Coreq,
                                 Credits = NULL,
                                 LostCredits = NULL,
                                 PassRate = NULL,
                                 Timing = NULL,
                                 Institution = NULL
                                 )
{

   #These statements handle optional arguments if they're unused.
  if (is.null(PassRate))
  {
    PassRate <- rep(NA, length(Course))
  }
  if (is.null(Credits))
  {
    Credits <- rep(NA, length(Course))
  }
  if (is.null(LostCredits))
  {
    LostCredits <- rep(0, length(Course))
  }
  if (is.null(Timing))
  {
    Timing <- rep("All", length(Course))
  }
  if (is.null(Institution))
  {
    Institution <- rep("FY", length(Course))
  }

  #Avoiding "data too long" error by replacing white space cells with NA
  Prereq[Prereq == ""] <- NA
  Coreq[Coreq == ""] <- NA
  LostCredits[LostCredits == ""] <- NA
  PassRate[PassRate == ""] <- NA
  Timing[Timing == ""] <- "All"
  Institution[Institution == ""] <- "FY"

  ###End of data prep stage###

  #The actual function starts here.
  courses <- as.data.frame(cbind(Course, Term, Credits, PassRate, LostCredits,Timing,Institution), stringsAsFactors = FALSE)  #create vertex matrix
  courses$Term <- as.numeric(courses$Term)
  courses$LostCredits <- as.numeric(courses$LostCredits)
  courses$PassRate <- as.numeric(courses$PassRate)
  names(courses) <- c("name", "term", "credits", "passrate", "lostcredits","timing","institution")
  courses$name <- trimws(courses$name) #trims any whitespace...wasted too much time debugging to find out this was an issue.
  courses$name <- make.unique(courses$name, sep = " ") #if there are duplicates like "gen ed course," this function will make each vertex unique

  reqs <- NULL  #initialize the requisties
  prereqs_subset <- Prereq[is.na(Prereq) == FALSE] #take all the prereqs and put them into a data frame
  prereq_index <- which(is.na(Prereq) == FALSE)
  if (length(prereqs_subset) > 0)
  {
  for (courseindex in 1:length(prereqs_subset))
  {
    course_to_fetch <- prereq_index[courseindex] #what is the course for this prereq?
    course_prereqs <- unlist(strsplit(prereqs_subset[courseindex], split = ",")) #split the prereqs into a vector
    course_prereqs <- trimws(course_prereqs) #trims any whitespace...
    course <- matrix(Course[course_to_fetch], nrow = length(course_prereqs)) #initialize the matrix to store these edges
    req_type <- matrix("Pre", nrow = length(course_prereqs)) #Save the type of requistie
    edges_for_course <- cbind(course_prereqs,course, req_type) #Record the prereqs
    reqs <- rbind(reqs,edges_for_course) #Combine them with the ongoing list
    names(reqs) <- c("from","to")

  }
  }
  coreqs_subset <- Coreq[is.na(Coreq) == FALSE]  #Same process for coreqs
  coreq_index <- which(is.na(Coreq) == FALSE)
  if(length(coreqs_subset) > 0)
  {
  for (courseindex in 1:length(coreqs_subset))
  {
    course_to_fetch <- coreq_index[courseindex] #what is the course for this coreq?
    course_coreqs <- unlist(strsplit(coreqs_subset[courseindex], split = ","))
    course_coreqs <- trimws(course_coreqs) #trims any whitespace...
    course <- matrix(Course[course_to_fetch], nrow = length(course_coreqs))
    req_type <- matrix("Co", nrow = length(course_coreqs))
    edges_for_course <- cbind(course_coreqs, course, req_type)
    reqs <- rbind(reqs,edges_for_course)
  }
  }
  if (is.null(reqs) == FALSE)
  {
  reqs <- as.data.frame(reqs,stringsAsFactors = FALSE)
  names(reqs) <- c("from","to","reqtype")

  #Remove degenerate prereqs that don't appear in course list
  list_of_reqs <- as.character(unique(unlist(reqs[,1:2])))
  for (index in list_of_reqs)
  {
   if (is.element(index,courses$name) == FALSE)
   {
     req_to_remove <- which(reqs == index, arr.ind = TRUE)[,1]
     reqs <- reqs[-req_to_remove,]
   }
  }
  }

  #Create the plan of study object...
  plan_of_study <- graph_from_data_frame(d = reqs, vertices = courses, directed = TRUE) #Create the graph from the requisites and courses, saving the attributes
  return(plan_of_study)
}

