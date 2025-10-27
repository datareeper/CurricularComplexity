#' Calculates inflexibility factor of a plan of study
#'
#'Calculates the inflexibility factor for courses that have specific offering times extending chains beyond the
#'expected time to degree.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @param time_to_degree numeric - expected time to degree, often 8
#' @return list of (1) a dataframe of inflexibility factors and (2) a total inflexibility factor
#' @export

inflexibility_factor <- function(plan_of_study, time_to_degree)
{
  #First, we'll figure out which courses we need to check for limited offerings
  num_of_courses <- length(V(plan_of_study))
  courses_to_check <- which(V(plan_of_study)$timing != "All")
  #We'll initialize the list of inflexibility factor.
  inflexibility_factors <- rep(0,num_of_courses)
  #Next, we'll iterate through the list, checking each course one-by-one
  for (course in courses_to_check)
  {
    #We'll first fetch all of the courses that are connected to the given course through
    #a prerequisite or corequisite relationship. Then, we'll get the terms they reside in.
    outbound_courses <- find_outbound_courses(plan_of_study, course)
    terms_to_check <- V(plan_of_study)$term[c(course,outbound_courses)]

    #The next step will be to determine the term adjustment. If the timing is Fall or Spring, then the
    #adjustment is 2 terms, otherwise it is assumed the timing is alternating Fall or Spring, meaning
    #the adjustment is 4 terms.
    if(V(plan_of_study)$timing[course] == "Fall" |
       V(plan_of_study)$timing[course] == "Spring")
    {
      term_adjustment <- 2
    }
    else if (V(plan_of_study)$timing[course] == "Alt Fall" |
             V(plan_of_study)$timing[course] == "Alt Spring")
    {
      term_adjustment <- 4
    }

    #We'll add the resulting term adjustment to the terms of the outbound
    #courses, then check which ones ended up going beyond the expected
    #time to degree.
    terms_to_check <- terms_to_check + term_adjustment
    courses_beyond_ttd <- which(terms_to_check > time_to_degree)
    terms_to_check <- terms_to_check[courses_beyond_ttd]

    #To determine the weighting, we need the course term, the term adjustment
    #and if the adjustment caused courses to extend beyond the specified time
    #to degree.
    course_term <- V(plan_of_study)$term[course]
    if(length(terms_to_check) > 0)
    {
      #The weighting is the sum of the number of terms beyond the time to degree
      #the course term, and the term adjustment.
      weighting <- (max(terms_to_check)-time_to_degree) + course_term + term_adjustment
    }
    else
    {
      #If none of the courses extended beyond the expected time to degree, we'll just
      #use the course term and term adjustment.
      weighting <- course_term + term_adjustment
    }

    #We multiply the resulting weight with the delay factor.
    course_delay_factor <- delay_factor(plan_of_study,course)
    inflexibility_factors[course] <- weighting*course_delay_factor

  }

  #In the end, we'll add all of the inflexibility factors together.
  total_inflexibility_factor <- sum(inflexibility_factors)

  #And to make the output nice, we'll get the course names and bind them
  #with the vector of inflexibility factors.
  course_names <- V(plan_of_study)$name
  output_table <- cbind(course_names,inflexibility_factors)
  output_table <- as.data.frame(output_table)
  output_table$course_names <- as.character(output_table$course_names)
  output_table$inflexibility_factors <- as.numeric(as.character(output_table$inflexibility_factors))
  output <- list(output_table,total_inflexibility_factor)
  names(output) <- c("Inflexibility Factors","Total")

  return(output)
}
