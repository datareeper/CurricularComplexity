#' Calculates the student mobility turbulence for a program
#'
#' This metric captures the volatility in student progression by analyzing
#' the withdraws and major changes, which can indicate structural barriers
#' or inefficiencies in the curriculum. This is most useful to apply to a combination
#' of programs or a unit, like a department or college. There are two coefficients,
#' withdrawn and changed major that can be used to prioritize either of the two causes
#' for turbulence. They are set to 1 and 0.5 by default, respectively.
#' @param number_withrawn numeric - the total number of students who dropped out of a program in a given unit
#' @param number_changed_major numeric - the total number of students who changed majors in a given unit
#' @param total_number_of_students numeric - the total number of students in a given unit starting at a specific time
#' @param withdrawn_coefficient numeric - a coefficient weighting the number of students who dropped out
#' @param changed_major_coefficient numeric - a coefficient weighting the number of students who changed majors out
#' @return numeric -  The student mobility turbulence
#' @export

student_mobility_turbulence <- function(number_withrawn,
                                        number_changed_major,
                                        total_number_of_students,
                                        withdrawn_coefficient = 1,
                                        changed_major_coefficient = 0.5
                                        )
{
  withdrawn <- withdrawn_coefficient * number_withrawn
  changed_major <- changed_major_coefficient * number_changed_major
  numerator <- withdrawn + changed_major
  student_mobility_turbulence_value <- numerator/total_number_of_students
  return(student_mobility_turbulence_value)
}
