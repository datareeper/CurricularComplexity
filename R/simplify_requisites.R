#' Convert requisites to original notation
#'
#' This function takes in either the pre or corequisites of a plan of study as a vector, then
#' removes any additional information like OR relationships and minimum grades such that the
#' network can be analyzed using the traditional functions.
#' @param requisites vector object - A vector describing the pre and corequisites (as strings)
#' @return vector object -  A simplified vector describing the pre and corequisites (as strings)
#' @export

simplify_requisites <- function(requisites) {
  #Replace all ORs (+) with ANDs (,)
  requisites <- gsub("\\+", ",",requisites)
  #Remove the parentheses
  requisites <- gsub("[()]", "", requisites)
  #Begins removing the notation for MINGRADE and FROM.
  requisites <- gsub("FROM|MINGRADE", "", requisites)
  #Remove notation for MINGRADE and FROM.
  requisites <- gsub("\\[.*?\\]", "", requisites)
  #Return the courses with the original notation.
  return(requisites)
}
