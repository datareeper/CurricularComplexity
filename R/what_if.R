#' Calculate hypotheticals of adding/deleting user-defined courses/prereqs/coreqs
#'
#' This function takes in a plan of study, then adjusts the plan of study subject to the following user-defined
#' hypotheticals.
#' @param plan_of_study An igraph object created using the create_plan_of_study function
#' @param courses_to_delete An atomic vector listing the courses to delete (e.g., c("ENGR 101","ENGR 102"))
#' @param reqs_to_delete An atomic vector listing the pre/co requisties to delete (e.g.,
#' c("ENGR 101|ENGR 102","ENGL 101|ENGL 102")
#' @param prereqs_to_add An atomic vector listing the prerequisties to add
#' (e.g., c("ENGR 101","ENGR 102","ENGL 101","ENGL 102") where ENGR 101 is a prereq to ENGR 102)
#' @param coreqs_to_add An atomic vector listing the corequisties to add
#' (e.g., c("ENGR 101","ENGR 102","ENGL 101","ENGL 102") where ENGR 101 is a coreq with ENGR 102)
#' @param courses_to_add An atomic vector listing the courses to add (e.g., c("ENGR 101","ENGR 102"))
#' @return A list containing the change in structural complexity, the new hypothetical structural complexity,
#' the list of hypothetical crucialities, and the new plan of study igraph object.
#' @export


what_if <- function(plan_of_study,courses_to_delete = NULL,
                    reqs_to_delete = NULL,
                    courses_to_add = NULL,
                    prereqs_to_add = NULL,
                    coreqs_to_add = NULL)
{
  #We first calculate the baseline complexity.
  original <- structural_complexity(plan_of_study)
  original_complexity <- original$`Overall Structural Complexity`
  #Then we add/delete vertices/edges as specified in the function call.
  plan_of_study <- delete_vertices(plan_of_study,courses_to_delete)
  course_names <- vertex_attr(plan_of_study,"name")
  plan_of_study <- delete_edges(plan_of_study,reqs_to_delete)
  plan_of_study <- add_vertices(plan_of_study,courses_to_add)
  plan_of_study <- add_edges(plan_of_study,prereqs_to_add, reqtype = "Pre")
  plan_of_study <- add_edges(plan_of_study,coreqs_to_add, reqtype = "Co")
  #Next we calculate the structural complexity of this hypothetical plan of study.
  hypothetical_structural_complexity <- structural_complexity(plan_of_study)
  new_complexity <- hypothetical_structural_complexity$`Overall Structural Complexity`
  #Find the difference between the new and old plan of study.
  delta <- new_complexity - original_complexity
  #We'll output the details of the "what if" and the delta. We'll also output the associated graph.
  hypothetical_structural_complexity_detailed <- hypothetical_structural_complexity$`Course Crucialities`
  hypothetical_structural_complexity_value <- hypothetical_structural_complexity$`Overall Structural Complexity`
  output <- list(delta, hypothetical_structural_complexity_value,hypothetical_structural_complexity_detailed,plan_of_study)
  names(output) <- c("Change in Structural Complexity", "Hypothetical Structural Complexity","Hypothetical Crucialities","Hypothetical Plan of Study")
  return(output)
}
