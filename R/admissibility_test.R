#' Automatically check for data entry issues
#'
#' This function takes in a plan of study and a course, then checks for potential data entry issues.
#' It will detect issues in formatting with the csv (such as notes creating empty rows), if there
#' are cycles in the network, and if pre- and corequisites are appropriately defined.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return Printed warnings for potential data entry issues
#' @export

admissibility_test <- function(plan_of_study)
{
  errors <- 0

  #Check for formatting issues
  if(any(V(plan_of_study)$name == "") | any(is.na(V(plan_of_study)$name)))
  {
    errors <- errors + 1
    writeLines("WARNING (Formatting Error): Your plan of study did not pass an admissibility test. \n Your csv appears to have data in a row where no course is defined. \n Check the bottom rows of the csv and delete/move their contents if they are notes. \n Highlight the bottom rows and select 'Clear All' in Excel.")
  }

  #Check if plan of study is a directed acyclic graph
  dag_test <- is.dag(plan_of_study)
  if(dag_test == FALSE)
  {
    errors <- errors + 1
    writeLines("WARNING (Not Directed Acyclic Graph): Your plan of study did not pass an admissibility test. \n One or more of your prerequisites/corequisites form a cycle. \n Check the following courses to see if they are mutually coreqed. \n If so, check the original plan of study for the correct direction.\n")

    #Get the relevant courses...
    edgelist <- as_edgelist(plan_of_study)

    cycles <- NULL
    c_index <- 1
    for (index in 1:nrow(edgelist))
    {
      possible_cycle <- c(edgelist[index,2],edgelist[index,1])
      id <- which(edgelist[,1] == possible_cycle[1] & edgelist[,2] == possible_cycle[2])
      if(length(id)>0)
      {
        cycles[[c_index]] <- c(edgelist[id,1],edgelist[id,2])
        c_index <- c_index+1
      }
    }
    print(paste((unique(unlist(cycles)))))
  }

  test<-as.data.frame(cbind(as_edgelist(plan_of_study),E(plan_of_study)$reqtype), stringsAsFactors = FALSE)
  name_term_dictionary <- as.data.frame(cbind(V(plan_of_study)$name,
                                              V(plan_of_study)$term),
                                        stringsAsFactors = FALSE)
  test_numbered <- test
  for(x in name_term_dictionary$V1)
  {
    from_index <- which(test$V1 == x)
    to_index <- which(test$V2 == x)
    test_numbered$V1[from_index] <- name_term_dictionary$V2[which(name_term_dictionary$V1 == x)]
    test_numbered$V2[to_index] <- name_term_dictionary$V2[which(name_term_dictionary$V1 == x)]
  }

  prereqs <- which(test_numbered$V3 == "Pre")
  uncoreqs <- test[-prereqs,]
  unprereqs <- test[prereqs,]

  coreqs <- test_numbered[-prereqs,]
  prereqs <- test_numbered[prereqs,]

  same_term_test <- NULL
  different_term_test <- NULL

  for(x in 1:nrow(prereqs))
  {
    same_term_test[x] <- prereqs$V1[x] == prereqs$V2[x]
  }
  prereqstocheck <- unprereqs[which(same_term_test == TRUE),]
  for(x in 1:nrow(coreqs))
  {
    different_term_test[x] <- coreqs$V1[x] != coreqs$V2[x]
  }
  coreqstocheck <- uncoreqs[which(different_term_test == TRUE),]

  if(nrow(prereqstocheck)>0)
  {
    errors <- errors + 1
    writeLines("WARNING (Illogical Prereqs): Your plan of study did not pass an admissibility test. The following courses are prereqs in the same semester.\n")
    print(prereqstocheck[,c(1,2)])
  }
  if(nrow(prereqstocheck)>0)
  {
    errors <- errors + 1
    writeLines("WARNING (Illogical Coreqs): Your plan of study did not pass an admissibility test. The following courses are occur in different semesters. \n")
    print(coreqstocheck[,c(1,2)])
  }

  if(errors==0)
  {
    writeLines("No structural or formatting errors detected. \n")
  }
  return("")
}
