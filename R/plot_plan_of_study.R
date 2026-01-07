#' Plots the plan of study with courses ordered by term
#'
#' This function takes in a plan of study and plots it in the 'plot' window.
#' The courses are ordered horizontally by term and vertically by the outdegree
#' (i.e., number of prereqs) of the vertices in that column/term. The shading of
#' the nodes corresponds to the cruciality of the course. A darker blue indicates
#' higher cruciality while white indicates lower cruciality.
#'
#' Note that there can be some overlap where a course is covering a path for a prereq,
#' which may make is seem like a course is a prereq for some other course when it is
#' in fact the course in a previous semester.
#' @param plan_of_study igraph object - An igraph object created using the create_plan_of_study function
#' @return Plots the plan of study in the 'plot' window
#' @export


plot_plan_of_study <- function(plan_of_study)
{
  #First, we'll make sure there isn't a cycle in the data that would cause an infinite loop.
  test_results <- suppressMessages(admissibility_test(plan_of_study))
  if(!is.null(test_results$DAGErrors))
  {
    warning("Your data fails the Directed Acyclic Graph admissibility test. Crucialities cannot be added to the plot. Please use *admissibility_test* to diagnose and fix the error.")
  }
  #Next, we'll calculate the course crucialities to add that detail to the plot
  if(is.null(test_results$DAGErrors))
  {
    complexity_scores <- structural_complexity(plan_of_study)
    complexity_scores <- complexity_scores$`Course Crucialities`
    crucialities <- complexity_scores$Cruciality
    #We'll append these crucialities as an attribute of the vertices.
    plan_of_study <- set_vertex_attr(plan_of_study,"cruciality",index = V(plan_of_study),crucialities)
    #Use the ramp palette to get a range of colors, we only need colors up to the highest cruciality
    colors_palette <- colorRampPalette(c("white", "dark blue"))(n=max(crucialities))
    #This will give us the right colors by evaluating the palette at the associated cruciality.
    colors_for_vertices <- colors_palette[crucialities]
    #Then we'll append the "color" attribute with those values we found.
    plan_of_study <- set_vertex_attr(plan_of_study, "color", index = V(plan_of_study), colors_for_vertices)
  }

  #To get the horizontal position, we'll use the course terms.
  terms <- as.numeric(V(plan_of_study)$term)
  horizontal_position <- terms - rep(1,length(terms)) #Shift by one to center the graph.
  vertical_position <- numeric(length(terms))

  #To get the vertical position, we'll order the courses by their outdegree.
  degrees <- degree(plan_of_study, v = V(plan_of_study), mode = "out")
  ordering <- as.data.frame(cbind(degrees,terms))
  rownames(ordering) <- 1:nrow(ordering)
  names(ordering) <- c("degree","terms")
  ordered_data <- NULL
  #This loop will organize the courses by outdegree within the context
  #of the term they are taken.
  for (index in 1:max(terms))
  {
    next_term <- ordering[ordering$terms == index,]
    next_term <- next_term[order(next_term$degree, decreasing = FALSE),]
    ordered_data <- rbind(ordered_data,next_term)
  }
  #Recover the permutation to reorder the courses by number of requisties
  #This is because "permute" wants the index the vertex should be mapped to.
  new_order <- as.numeric(rownames(ordered_data))
  id <- 1:length(new_order)
  permutation <- as.data.frame(cbind(new_order,id))
  permutation <- permutation[order(new_order,decreasing = FALSE),]
  permutation <- permutation$id
  plan_of_study <- permute(plan_of_study,permutation)

  #We'll use these counters to space out the vertices as needed.
  position <- 0

  #This loop will assign each vertex to a vertical position.
  for (index in 2:length(terms))
  {
    if((terms[index]-terms[index-1])==0)
    {
      position <- position + 2.5 #Spacing accounted for here
    }
    else
    {
      position <- 0  #Reset if we hit the next term.
    }
    vertical_position[index] <- position
  }

  #This matrix will hold the coordinates we just assigned.
  coordinates <- as.matrix(cbind(horizontal_position,vertical_position))

  #To differentiate the coreqs and prereqs, we'll make their line types and colors different
  plan_of_study <- set_edge_attr(plan_of_study, "lty", index = which(E(plan_of_study)$reqtype == "Co"), 2)
  plan_of_study <- set_edge_attr(plan_of_study, "lty", index = which(E(plan_of_study)$reqtype == "Pre"), 1)
  plan_of_study <- set_edge_attr(plan_of_study, "color", index = which(E(plan_of_study)$reqtype == "Pre"), "black")
  plan_of_study <- set_edge_attr(plan_of_study, "color", index = which(E(plan_of_study)$reqtype == "Co"), "gray 72")

  #The coreqs point directly to the course in the same term, which makes them hard to point
  #out sometimes. We'll curve the coreqs to make them easier to see.
  curved_coreqs <- c(numeric(length(E(plan_of_study))))
  curved_coreqs[which(E(plan_of_study)$reqtype == "Co")] <- 0.1

  #Rescale as needed
  xmax <- 8
  ymax <- 16
  if (max(terms) > 8)
  {
    xmax <- max(terms)
  }

  #Truncate strings that are a little too long for display purposes...
  #I'm probably missing an easier way to do this, but it works.
  list_of_courses <- names(V(plan_of_study))
  for (string in list_of_courses)
  {
    if (nchar(string) > 10)
    {
      index <- which(V(plan_of_study)$name == string)
      V(plan_of_study)$name[index] <- paste(substr(string, 1, 8),"...")
    }
  }


  #This is actual plotting function after the setup in the previous lines.

  plot.igraph(plan_of_study,layout=coordinates, vertex.shape = "circle", vertex.size = 15,
              vertex.label.cex = 0.85,
              vertex.label.color = "dark blue",
              edge.arrow.size = 0.45,
              edge.size = 0.5,
              edge.curved = curved_coreqs,
              vertex.label.dist = 10,
              vertex.label.degree = pi/2,
              rescale=FALSE,
              xlim=c(0,xmax),ylim=c(0,ymax),
              asp=0,
  )
  for (index in 1:max(terms))
  {
    text(index-1,-2,paste("Term",index), col = "gray 31")
  }
}
