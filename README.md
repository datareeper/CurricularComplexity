# The CurricularComplexity Package


This notebook documents how to use the Curricular Complexity package to analyze different plans of study across disciplines. Using the ideas put forth by Heileman et al. (2018) to conceptualize "Curricular Analytics," 
related efforts to systematically evaluate the accessibility or complexity of different programs in the literature, and our own work through a National Science Foundation-funded project, "Studying Undergraduate Curricular Complexity for Undergraduate Student Success," we present a comprehensive set of functions to look at curricula from several angles. 

# 0. Installing and uninstalling the package 

# 0.1 Installing dependencies 
The package has been designed to limit the number of dependencies needed from other packages. The igraph package is the only dependency. If you do not have it, 
run the following line to install it:

```{r}
install.packages("igraph")
```
# 0.2 Installing the package
The package is available on CRAN, so you can directly install the package like so:

```{r}
install.packages("CurricularComplexity")
```

If you need to *uninstall* the package, you can use the following chunk.

```{r}
remove.packages("CurricularComplexity")
```

If you want to review the documentation for the package, you can use the *help* function.

```{r}
help(package = "CurricularComplexity")
```

# 1. Data Requirements
To get started, we need to discuss what kind of data is needed to run the basic
analyses in the package. The main premise of Curricular Analytics, and similar
complementary methods, is to treat a program or curriculum as a graph (or network). 
In this model, we treat each course as a vertex (or node) in the network. 
The edges, or connections among the vertices, are the prerequisites 
and corequisites defining the sequence in which courses must be completed. For
example, the data would be entered like so.

```{r}
courses <-       c("A","B","C","D","E","F","G","H","I")
prerequisites <- c(" "," "," ","A","C"," ","D","F","D")
corequisites <-  c(" ","A"," "," "," "," "," "," ","H")
```

Note that the entry for "A," or the first index of the vector, is intended to
be associated with the corresponding first index of the two other vectors: 
prerequisites and corequisites. Typically, this would be entered in a spreadsheet
where each row corresponds to a course and its relevant information. 

Believe it or not, these data are sufficient to perform the standard analyses in 
Curricular Analytics. However, it is useful to include some additional information
to the network to make it correspond to actual curricula. Specifically, we 
want to specify the term in which each of these courses are taken. So, we can
introduce a vector that gives each course a term.

```{r}
terms <- c(1,1,1,2,2,2,3,3,3)
```

To run the analyses in the package, we need to create an object that
works with the functionality of the igraph package - which enables much of
the analysis. Now, we'll load our package to get access to the functions we need.

```{r message=FALSE, warning=FALSE}
library(CurricularComplexity)
```

The function that will create what we call the *plan of study object* is called
*create_plan_of_study*. It will take four inputs at minimum, the courses, the 
prerequisites, the corequisites, and the terms. There are several optional 
arguments we will attend to later.

```{r}
example_plan_of_study <- create_plan_of_study(Course = courses,
                                              Prereq = prerequisites,
                                              Coreq = corequisites,
                                              Term = terms)
```

To plot this plan of study, we use the *plot_plan_of_study* function. The 
only input is the object we just created.

```{r}
plot_plan_of_study(example_plan_of_study)
```

When we model curricula as networks in this way, we should always get what is 
called a "directed acyclic graph." 

*Directed*: Meaning that the order in which you move from vertex to vertex matters
*Acyclic*: Meaning that you CANNOT revisit a vertex; there are no "cycles" or loops

These properties naturally emerge from our understanding of how academic 
programs work. Prerequisites define the order in which courses can be completed,
which suggests that movement from one vertex to another has a direction.
Moreover, because the program defines the sequencing of courses, students are
not expected to go back and retake courses (though this does happen, we are
not handling student data, only the program information). Therefore, there 
should be no loops - satisfying the acyclic criterion.

There are occasional exceptions that have appeared during our analyses of
engineering programs in the US, particularly how laboratory courses are connected
to their lecture counterparts. In these cases, the program author will sometimes 
list the lecture course as a corequisite for the laboratory course AND the
laboratory course as a corequisite for the lecture course. This issue is referred
to as courses being *mutually coreqed*. This configuration creates a cycle and 
thereby violatesthe acyclic criterion. This situation may not seem like a 
pertinent issue, but the presence of a cycle renders some functions usuable. 

Whenever you have courses that are mutually coreqed you *must* select one 
direction to define the corequisite relationship. In the case of laboratory 
courses, we recommend that the corequisite relationship be defined in the
row of the laboratory course. If you are running several programs, be consistent
in the chosen direction.

To check whether your data is ready for analysis, you can use the following 
function called *admissibility test*. This function checks for cases where
there are illogical arrangements of courses (e.g., a course and its prereq
occurring in the same semester) and cycles present. The only input is the
plan of study object we created. If there are issues, the function will
point you to which courses are causing the problem(s).

```{r}
admissibility_test(example_plan_of_study)
```
What if there are issues? Let's mess up the plan of study data. We'll introduce three common errors. First, we'll make A and B corequisites with one another - which introduces a cycle, a problematic feature of these graphs we'll discuss later when we're calculating different quantities. We'll make E a prerequisite for F and have I and H be corequisites, both of which are illogical combinations. The admissibility test will flash us messages of any relevant errors and give a vector of the problematic courses. 

```{r}
courses <-       c("A","B","C","D","E","F","G","H","I")
prerequisites <- c(" "," "," ","A","C","E","D","F","D") 
corequisites <-  c("B","A"," "," "," ","I"," "," ","H") 
#E is a prereq for F in same semester
#A and B are mutually coreqed, F has coreq I in diff semesters

error_plan_of_study <- create_plan_of_study(Course = courses,
                                              Prereq = prerequisites,
                                              Coreq = corequisites,
                                              Term = terms)

admissibility_test(error_plan_of_study)
```

Note that the plotting functionality depends on the graph being a DAG, so if that test is failed, you will be given a warning message to fix it. However, the plan of study will still be plotted. 

```{r}
plot_plan_of_study(error_plan_of_study)
```

## 1.1 Representing more complex prerequisite relationships
In the original conceptualization of Curricular Analytics, data entry can only handle AND type relationships with pre and corequisites. For those that want to incorporate more detailed prerequisite relationships, we offer the following notation to make data entry more straightforward. Moreover, future metrics could take advantage of this additional information.

*AND-type relationships*

For AND type relationships, meaning the student must pass both A, B, *and* C. We use commas to separate them: A, B, C.

*OR-type relationships*

For OR type relationships, meaning the student must pass both A, B, *or* C. We use plus signs to separate them: A + B + C.

*Subset of courses*

When students are provided a list of courses from which they are required to pass some subset of them, we can use the *FROM* keyword in the following fashion. So, for example, if the list of courses is A, B, C, D, E and students must complete two of them, then we would write: FROM(A,B,C,D,E)[2]. In general, for X courses that must be completed, the notation is FROM(A,B,C,D,...,Z)[X].

*Minimum grade*

If a course must be completed with a minimum grade before enrolling in a later course, we use the keyword *MINGRADE*. For example, if A must be completed with at least a C-, then we would write: MINGRADE(A)[C-]. In general, if A must be completed with grade X, we notation is MINGRADE(A)[X].

*Combining different types of requirements*

Sometimes you might need to combine the various requirements discussed so far. For example, AND and OR requirements could be mixed: the student must pass both A *and* either B *or* C. In this case, we will group them using parentheses: A, (B + C). Use parentheses to group any ORs, otherwise commas can be used to combine requirements. Here are a few possible arrangements:

(A,B) + C: Either A *and* B *or* C


A, (MINGRADE(B)[C-] + MINGRADE(C)[C-]): A *and* B with at least a C- *or* C with at least a C-


(A + B + MINGRADE(C)[D]) + MINGRADE(E)[C-]: Either A *or* B *or* C with at least a D *OR* E with at least a C-.


*"Junior" standing, admission to major, and similar requirements*

Some authors might elect to include specific curricular blockades into their analyses, such as requirements to be a specific level (e.g., junior standing) or gain admission to a specific major. These can be representing by adding a new course that only serves as a medium to embed the requirements in the plan of study.

For example, suppose courses G and I in our example plan of study require the student to be a senior. We can add the course *SenStand* to the list of courses and prerequisites. Note that when we add *SenStand*, we need to add its prerequisites, corequisites, and term. 

When adding these kinds of requirements into the plan of study, it's most convenient to add them in the term prior to wherever they are called as prerequisites. For example, if the course requiring "senior standing" is in term 7, it is best to put it in term 6. 

```{r}
courses <-       c("A","B","C","D","E","F","SenStand","G","H",         "I")
prerequisites <- c(" "," "," ","A","C"," "," ",       "D","F,SenStand","D,SenStand")
corequisites <-  c(" ","A"," "," "," "," "," ",       " "," ",         "H")
terms <-         c(1,   1,  1,  2,  2,  2,  2,         3,  3,           3)
example_plan_of_study_sen_standing <- create_plan_of_study(Course = courses,
                                                           Prereq = prerequisites,
                                                           Coreq = corequisites,
                                                           Term = terms)
plot_plan_of_study(example_plan_of_study_sen_standing)
```


*Other requirements*

If there are requirements beyond what is described here, such as passing a placement exam or having a specific ACT/SAT score, these can be put in a notes column on your spreadsheet.

## 1.2 Converting the notation to all ANDs
In order to plot the networks properly, we need to go back to all AND relationships for the sake of aligning with the expected inputs for the igraph functions. To do so, we can use the *simplify_requisites* function. Example usage is below:

```{r}
example_requisites <- c("(A+B),(C+D)",
                        "MINGRADE(A)[C-]+(MINGRADE(B)[D],MINGRADE(C)[D])",
                        "FROM(A,B,C)[2]"
                        )
simplify_requisites(example_requisites)
```

When the networks are plotted using the *create_plan_of_study* function, only courses listed in the plan of study will be used in the construction of the network. In general, this will work without issue. However, be cautious of cases such as when course C requires either A or B, but A and B both appear in the plan of study. In this case, the cruciality of C will be overestimated. 

## 1.3 Representing electives
There are several ways to represent electives in the plan of study. Here we will review a selection of methods that we are aware of. 

## 1.3.1 Electives as generic, standalone courses

The standard advice for dealing with electives when extracting data is to represent them as standalone courses with no connections. Note that when you add courses with the same name, the *create_plan_of_study* function will automatically rename them. For example, we can add to courses called *Elec* to the last term like so:

```{r}
courses <-       c("A","B","C","D","E","F","G","H","I","Elec","Elec")
prerequisites <- c(" "," "," ","A","C"," ","D","F","D"," ",   " ")
corequisites <-  c(" ","A"," "," "," "," ",","," ","H"," ",   " ")
terms <-         c(1,   1,  1,  2,  2,  2,  3,  3,  3,  3 ,    3)
example_plan_of_study_elec <- create_plan_of_study(Course = courses,
                                                   Prereq = prerequisites,
                                                   Coreq = corequisites,
                                                   Term = terms)
plot_plan_of_study(example_plan_of_study_elec)
```

## 1.3.2 Electives as generic, but connected courses
There are, of course, other ways to include electives in the plan of study that can more faithfully represent the curricular complexity students face. For instance, if there are specific courses that are common prerequisites for the electives, then we can incorporate those directly as we would for any other course. Consider that E and F are prerequisites for one of the electives and C is a prerequisite for the other elective. In this case, we need to differentiate the electives from one another by labeling them as *Elec 1* and *Elec 2*. We would represent this like so:

```{r}
courses <-       c("A","B","C","D","E","F","G","H","I","Elec 1","Elec 2")
prerequisites <- c(" "," "," ","A","C"," ","D","F","D","E,F", "C")
corequisites <-  c(" ","A"," "," "," "," ",","," ","H"," ",   " ")
terms <-         c(1,   1,  1,  2,  2,  2,  3,  3,  3,  3 ,    3)
example_plan_of_study_elec <- create_plan_of_study(Course = courses,
                                                   Prereq = prerequisites,
                                                   Coreq = corequisites,
                                                   Term = terms)
plot_plan_of_study(example_plan_of_study_elec)
```

## 1.3.3 Customizing pathways with frequently taken electives
Instead of making the electives generic courses, you can customize the plan of study by incorporating the actual courses student frequently take (such as by reviewing student course-taking data or speaking with advisors). This is most easily accomplished by developing a *base* plan of study, like what is described in the previous examples of handling electives, then specific pathways can be constructed by replacing the elective placeholders with the common elective courses. From there, you can calculate the average of the different pathways for an overall score, if desired.

# 2. Conducting simple curricular analytics
Once you have your plan of study object, you can immediately start performing
calculations. The measures in Curricular Analytics and related literature can be
put into two categories, the *course level* and the *curriculum level*. Course
level measures can be used as a finer-grained analysis that looks "locally" at
a course or set of courses. On the other hand, curriculum level measures are
broader summaries that can be used to compare different programs to one another.

We will start with the course level measurements. Heileman et al. (2018) present 
two key metrics that define what is called the *cruciality* of a course.

*Cruciality*: A measure of how important a course is in the curriculum. Higher
values suggest the course is likely a bottleneck to student progress.

These two metrics are the *blocking factor* and the *delay factor*.

## 2.1 Blocking Factor
One intrinsic measurement that we can take to understand the cruciality of 
a course is to see how many courses it is a direct or indirect prerequisite 
for. This is the premise of the *blocking factor*.

*Blocking factor*: The number of courses inaccessible to a student if the 
given course is failed.

In the package, we can use the *blocking_factor* function to calculate this
quantity for any course. For example, we can calculate the blocking factor 
of course A. 

```{r}
blocking_factor(example_plan_of_study,"A")
```

In this case, the blocking factor is 4. Note that the blocking factor is 
including any corequisites that point from the course to a different course. 
If you would not like to include the corequisites, you can add the optional
argument *include_coreqs* and set it to FALSE.

```{r}
blocking_factor(example_plan_of_study,"A", include_coreqs = FALSE)
```

## 2.2 Delay Factor
The other measurement that can help us characterize a course's cruciality is 
examines how embedded the course is in the prerequisite structure. So, if 
a course belongs to a long prerequisite chain, we would believe this course
is more important than one that is connected to fewer, or maybe no, other courses.

*Delay Factor*: The length of the longest prerequisite chain to which the course
belongs. 

We use the *delay_factor* function in the same fashion as the *blocking factor*
function. Let's try course A.

```{r}
delay_factor(example_plan_of_study,"A")
```

In this case, course A belongs to two prerequisite chains of length 3, which 
are also the longest. Therefore, the delay factor is 3. Just like the blocking
factor, corequisites are included in the calculation. If you would like to 
omit them from the calculation, you would handle it the same way as the 
blocking factor.

```{r}
delay_factor(example_plan_of_study,"A",include_coreqs = FALSE)
```

## 2.3 Cruciality
Given the blocking and delay factors, we can calculate the cruciality of a 
course by adding its blocking factor and delay factor together. 

```{r}
blocking_factor(example_plan_of_study,"A")+delay_factor(example_plan_of_study,"A")
```

Alternatively, we can use the *cruciality* function, which performs the 
addition by itself.

```{r}
cruciality(example_plan_of_study,"A")
cruciality(example_plan_of_study,"A") == blocking_factor(example_plan_of_study,"A")+delay_factor(example_plan_of_study,"A")
```

Just like the blocking and delay factors, we can omit the corequisite relationships by changing the *include_coreqs* input to *FALSE*.

```{r}
cruciality(example_plan_of_study,"A", include_coreqs = FALSE)
```

## 2.4 Structural Complexity
If you would like to calculate a global measure of the plan of study's complexity, you can use the *structural complexity* function. The structural complexity is simply the sum of each individual course's cruciality. The only input you need to provide is the plan of study you'd like to calculate the complexity of. The output of the function is a table displaying the blocking and delay factors for each course, including the crucialities. 

```{r}
example_structural_complexity <- structural_complexity(example_plan_of_study)
#The individual outputs can be selected like so...
example_structural_complexity$`Course Crucialities`
```

The overall structural complexity can be fetched using the following command

```{r}
example_structural_complexity$`Overall Structural Complexity`
```

Sometimes researchers might be interested in exploring the impact of where courses are placed in a program. This idea was introduced in DeRocchis et al. (2021), where we add weights to the individual crucialities based on the term the courses appear within. This functionality can be accessed by using the *term_weighted* input, which is *FALSE* by default. 

```{r}
example_structural_complexity <- structural_complexity(example_plan_of_study, term_weighted = TRUE)
#The individual outputs can be selected like so...
example_structural_complexity$`Course Crucialities`
```

While we could calculate the overall structural complexity with weighted terms, the information we gain is minimal. The unweighted and weighted versions of structual complexity are almost perfectly linearly correlated. Therefore, it is advised to explore the weighted crucialities instead and ignore the aggregate score.

## 2.4.1 Structural complexity and the quarter system
The structural complexity values increase as the number of terms increases, making comparisons between plans harder when the number of terms are significantly different. This is most pronounced when comparing programs on the semester system and those on the quarter system. Because quarter systems have three additional terms, the structural complexities for these plans of study tend to be artificially higher. One way to adjust the structural complexities is to use the adjustment made for credit hours to convert between quarters and semesters, which involves dividing the number of credits by 1.5. In the same vein, we'll divide the structural complexity by 1.5.

$\alpha_{\text{semesters}} = \frac{\alpha_{\text{quarters}}}{1.5}$

We can use the argument, *quarters*, in the structural complexity function that is *FALSE* by default by changing it to *TRUE*.

```{r}
example_structural_complexity <- structural_complexity(example_plan_of_study, quarters = TRUE)
example_structural_complexity$`Course Crucialities`
example_structural_complexity$`Overall Structural Complexity`
```

# 3. Digging deeper into a plan of study
More often than not, we want to explore the plan of study more thoroughly than the general Curricular Analytics metrics. For example, there may be cases where we want to take a slice of the program to see how specific curricular design patterns look, such as the Calculus sequence or introductory mechanics sequence (i.e., Statics, Dynamics, and Strength of Materials). We have included this functionality into the package.

## 3.1 Extracting course sequences
Suppose we wanted all of the courses related to a specific course in the program, let's focus on A. We can extract the network of courses that have some direct or indirect relationship with A using the *subcomplexity_graph* function. 

```{r}
courses_related_to_A <- subcomplexity_graph(example_plan_of_study, "A")
plot_plan_of_study(courses_related_to_A)
```

From here, we can use any functions that take in the plan of study networks as an input and calculate whatever we'd please. For instance, we can run the *structural complexity* function on this subset of courses. 

```{r}
example_structural_complexity_for_subgraph <- structural_complexity(courses_related_to_A)
#The individual outputs can be selected like so...
example_structural_complexity_for_subgraph$`Course Crucialities`
```

## 3.2 Unbundling layers of requirements
If you are not necessarily interested in specific courses and would like to explore how different design patterns are embedded within a program, we can use a technique called *core collapse*, which has an aptly named function that performs this operation

The *core collapse* procedure builds on the idea of *k-cores* in graph theory. A *k-core* refers to a graph that contains vertices with degrees of at least k - usually discussed as a subgraph of a larger network. In other words, a k-core in this context would refer to the set of courses with at least k pre- or corequisites attached to them.   

The idea of the *core collapse* procedure involves gradually removing courses with more and more connections until every course is eliminated using the network's k-cores. We start with the 1-core, where each course is connected to at least one other course through a prerequisite relationship. At each iteration, the proportion of courses removed relative to the original total number of vertices is recorded, forming a sequence. So, in the next step, we remove the courses that don't belong to the 1-core and find those that belong to the 2-core. We perform the same operation, remove the courses that don't belong to the 2-core, record the proportion of courses that were removed, and continue until no courses are left. A sequence that decreases quickly to zero typically indicates that the network is generally uniform in terms of the number of courses with different numbers of prerequisites. A sequence with more erratic values that does not settle to zero smoothly would imply more dense sets of prerequisites.

To call the function, we just need to input the plan of study we want to decompose.

```{r}
example_core_collapse <- core_collapse(example_plan_of_study)
```

Then, we can fetch the sequence and the associated network at each step of the process. For more complex programs, each slice (i.e., each k-core) will show another layer of requirements than could make it simpler to see how courses are related to one another. 

The first output we can examine is the *core collapse sequence*

```{r}
example_core_collapse$sequence
```

The k-cores that are formed at each step can be pulled out and plotted individually just like the subcomplexity graphs. This procedure treats the plan of study like an onion, where we can progressively remove layers until we reach the middle.

```{r}
kcores <- example_core_collapse$kcores
plot_plan_of_study(kcores[[1]])
plot_plan_of_study(kcores[[2]])
plot_plan_of_study(kcores[[3]])
```

## 3.3 Other course-level metrics 
Other metrics have been proposed in the literature that provide different perspectives on the impact of specific course on student progress. This section will overview a selection of them that are available in the package

### 3.3.1 Deferment factor
The *deferment factor* is one of the few metrics available that uses the term information for the course. If you look back at the calculations for the typical metrics included in Curricular Analytics, the *blocking factor* and the *delay factor*, neither depend on how courses are organized term-wise. This factor fetches the number of terms a student would need to fail a course before extending their time to degree, $k$. 

$D(c_i) = \frac{1}{k + 1}$

In fact, this factor can be calculated using the delay factor, *when ignoring corequisite relationships* (denoted by $d'(c_i)$) like so:

$D(c_i) = \frac{1}{t_e-t(c_i)-d'(c_i)+2}$

If a course cannot be failed without extending the student's time to degree, then the deferment factor will be 1. Smaller values of the deferment factor suggest more flexible courses. For example, course A is embedded in a three-course long prerequisite chain, which leads to a deferment factor of 1. 

The inputs of the *deferment_factor* function include the plan of study, the course to calculate the deferment factor of, and the expected completion term.

```{r}
deferment_factor(example_plan_of_study,"A",3)
```

On the other hand, course B is a corequisite for A, which (in general) is a less strict relationship. Therefore, we can treat it independent of A. Since it isn't connected to other courses, its deferment factor is the minimum possible. 

$min(D(c_i)) = \frac{1}{t_e}$

In this case, the minimum is $1/3$.

```{r}
deferment_factor(example_plan_of_study,"B",3)
```

### 3.3.2 Bottleneck courses
In highly sequenced curricular, like those found in STEM, there is often a concept of a *gateway*, *weed-out*, *gatekeeper*, or *bottleneck course*. These courses tend to be difficult, foundational courses that present the most significant barriers to student progress. In Curricular Analytics, a course with a high cruciality tends to identify such *bottleneck course*. However, what if you wanted to define what a bottleneck course means to you? This is accomplished using the *find_bottlenecks* function.

The *find_bottlenecks* function has five inputs, one of which is optional. Given an inputed plan of study, the user specifies the minimum number of prerequisites, the minimum number of courses the course serves as a prerequisite for (i.e., *"postreqs"*), and the minimum number of total connections. You can also specify whether you'd like to include corequisites in the calculation; it is *TRUE* by default. Suggested values from the original paper (Wigdahl et al., 2013) would suggest typical usage is  find_bottleneck(),3,3,5), which are provided by default. 

```{r}
find_bottlenecks(example_plan_of_study,min_prereq = 3, min_postreq = 3, min_connections = 5,include_coreqs = TRUE)
```

Note the function also works without specifying the other arguments

```{r}
find_bottlenecks(example_plan_of_study)
```

Since the network is a small, we don't have any bottlenecks as traditionally defined, so we can adjust our parameters however we'd like, for example...

```{r}
find_bottlenecks(example_plan_of_study,min_prereq = 2, min_postreq = 2, min_connections = 3,include_coreqs = TRUE)
```

In this case, A, D, and I are sorted out as bottlenecks. 

Note that min_connections >= min_prereq + min_postreq - 2. If this is violated, a warning is provided and corrected to the suggested minimum value of min_prereq + min_postreq - 2. 

```{r}
find_bottlenecks(example_plan_of_study,min_prereq = 2, min_postreq = 2, min_connections = 1,include_coreqs = TRUE)
```

# 3.3.3 Reachability Factor
If you are interested in calculating the number of courses that a student needs to pass in order to enroll in a later course, you are looking for a metric that is the opposite of the blocking factor called the *reachability factor*.  The *reachability_factor* function takes the same inputs as the blocking factor, the plan of study and the course you want to find the reachability factor for. 

```{r}
reachability_factor(example_plan_of_study,"G")
```

Like the delay and blocking factor, there is an optional argument to include the corequisites. If you'd like to exclude them, you will set the *include_coreqs* argument to be *FALSE*.

```{r}
reachability_factor(example_plan_of_study,"G", include_coreqs = FALSE)
```

#3.4 Other curriculum level metrics
Unlike course-level metrics, there are much fewer structural metrics at the curriculum level. This section provides a few examples of the metrics available in the package. 

## 3.4.1 Curriculum rigidity
A simpler metric to quantify how complex a curriculum is would be to use what's called the *curriculum rigidity*. This metric borrows the *beta index* from graph theory, which is calculated as the number of edges (i.e., pre and corequisites) divided by the number of vertices (i.e., courses). A value larger than 1 denotes a more complex network; whereas, a value below 1 would indicate a sparser network. 

The function to run this analysis is *curriculum_rigidity*, with only the plan of study as the input.

```{r}
curriculum_rigidity(example_plan_of_study)
```

# 4. Transfer-Sensitive Metrics
If you are interested in exploring what curricular complexity looks like for transfer students, metrics that quantify issues felt particularly by the transfer student population are available. These include the *transfer delay factor*, *complexity explained*, *inflexibility factor*, and *credit loss*.The first factor that doesn't require any additional information beyond what is needed for the metrics discussed before is the *transfer delay factor* and *complexity explained*

# 4.1 Transfer Delay Factor
When designing a transfer pathway, there might be cases where it is simply not feasible to design the program of study that enables the student to complete their requirements in the expected time to degree - usually eight semesters. The original metrics do not punish courses that extend students' time to degree. Therefore, the transfer delay factor focuses on the courses that are extending the student's time to degree by summing the delay factors of the courses in the terms beyond the user-specified intended finishing term.

For example, assume we expect to finish the example plan of study in two terms instead of three. This means there are three courses beyond the expected time to degree. We can calculate the associated *transfer delay factor* associated with these courses like so:

```{r}
transfer_delay_factor(example_plan_of_study,2)
```

If you are interested in the network of courses associated with the transfer delay factor, you can use the *transfer_excess_courses* function. It has the same inputs as the *transfer_delay_factor* function. 

```{r}
courses_extending_time <- transfer_excess_courses(example_plan_of_study,2)
plot_plan_of_study(courses_extending_time)
```

We can calculate the average sequencing causing the delays using the *average_sequencing* function as well. This function has two uses. With a single input, the plan of study object, the average length of the prerequisite chains in the curriculum will be reported. When we add the expected time to degree as the second argument, then we get the average length of the prerequisite chains for the courses extending the time to degree.

```{r}
#Only supplying the plan of study object will return the average length of the prerequisite chains for the entire plan of study.
average_sequencing(example_plan_of_study)
#Adding the expected time to degree will only calculated the average for the courses extending the time to degree.
average_sequencing(example_plan_of_study, expected_time_to_degree = 2)
```

# 4.2 Explained Complexity
Another way to look at this situation is to consider what proportion of the overall structural complexity is attributable to the courses extending the students' time to degree. We can calculate this using the *explained_complexity* function. The inputs are the exact same as the *transfer_delay_factor* function. As an output, the *explained_complexity* function will give the structural complexity and the *transfer subcomplexity*, which is the structural complexity of the subgraph formed by the courses that are connected to the courses extending the time to degree. The ratio of the transfer subcomplexity to the overall structural complexity is the *explained complexity*.

```{r}
explained_complexity(example_plan_of_study,2)
```

# 4.3 Inflexibility Factor
The original conceptualization of Curricular Analytics assumes that courses are available at all times, which isn't necessary realistic for many programs. This issue is particular salient for transfer students, where students can enter at different times and the availability of course can also impact their progression. 

The timing of courses that is currently supported uses semesters. The possible designations are "Fall", "Spring","Alt Fall", and "Alt Spring". These are included in the plan of study object by adding the timing information in the following format. Note that the timing needs to be specified when creating the plan of study object.

```{r}
courses <-       c("A","B","C","D","E","F","G","H","I")
prerequisites <- c(" "," "," ","A","C"," ","D","F","D")
corequisites <-  c(" ","A"," "," "," "," "," "," ","H")
terms <- c(1,1,1,2,2,2,3,3,3)

#Now we'll incorporate the timing here:
timing <- c("Fall",NA,NA,"Alt Spring",NA,NA,"Alt Fall",NA,"Spring")

example_plan_of_study <- create_plan_of_study(Course = courses,
                                              Prereq = prerequisites,
                                              Coreq = corequisites,
                                              Term = terms,
                                              Timing = timing)
```

Once we have incorporated the timing, we can calculate the *inflexibility factor*. The inflexibility factor is calculated for courses that have limited offerings. The function works by taking the course that is offered in specific terms and moves it to the next available term it can be taken. We then determine how many terms the student's time to degree is extended. After which, we sum the original term the course was offered, the number of terms it shifted, and the number of additional terms added to the student's time to degree. This value is a weight that multiply with the course's delay factor. 

```{r}
inflexibility_factor(example_plan_of_study,2)
```

The function, *inflexibility_factor* will output two things: (1) a table of the individual inflexibility factors and (2) a total inflexibility factor summing them. 

# 5. Using the NSF SUCCESS Data (coming soon)
To explore the majority of these metrics, except for those which are transfer-specific, you can use data from the National Science Foundation-funded project, *Studying Undergraduate Curricular Complexity for Undergraduate Student Success (SUCCESS)*. The project examined engineering curricula from 13 of the 21 MIDFIELD universities, chosen to enable linkage with student course-taking data from the 2010s onward. In Fall 2022, five undergraduate assistants and a PhD student collected plan of study information for five engineering disciplines over a 10-year period, using institutional websites and the Wayback Machine when needed. Data recorded in a CSV file included course details (e.g., name, code, term, prerequisites, corequisites, credits, and notes), with complex cases resolved via a Microsoft Teams channel. Although 650 plans were expected (5 disciplines × 10 years × 13 institutions), 494 were collected due to incomplete program offerings: mechanical and electrical engineering were present at all institutions, while chemical, civil, and industrial engineering were less consistently offered.

You can load the data using the following chunk.

```{r message=FALSE, warning=FALSE}
#Make sure your working directory is correct, it needs to be wherever the NSF_SUCCESS_CurricularAnalyticsData_2025_0722 data is on your computer
load("NSF_SUCCESS_CurricularAnalyticsData_2025_0722.Rdata")
data <- NSF_SUCCESS_CurricularAnalyticsData_2025_0722
```

You can explore the contents of the data using the following table, *plan_of_study_information*.

```{r}
plan_of_study_names_all <- names(data)

info_list <- strsplit(plan_of_study_names_all,"_")
plan_of_study_information <- NULL
for (index in 1:length(info_list))
{
  plan_of_study_information <- rbind(plan_of_study_information,info_list[[index]][1:3])
}
plan_of_study_information <- as.data.frame(plan_of_study_information)
names(plan_of_study_information) <- c("Institution",
                                       "CatalogYear",
                                       "Discipline"
                                       )
#Removing the "Engineering" from discipline, considering it is redundant in this context.
plan_of_study_information$Discipline <- gsub("Engineering", "", plan_of_study_information$Discipline)
head(plan_of_study_information)
```

Most of the plans of study are within the 2012-2022 catalog year range.

```{r}
table(plan_of_study_information$CatalogYear)
```

In terms of discipline, civil, electrical, mechanical are the most represented disciplines.

```{r}
table(plan_of_study_information$Discipline)
```

# 5.1 Structural complexities for the NSF SUCCESS Data
One of the first steps we might take in analyzing the data is examining the structural complexities of each plan of study. This chunk will calculate them for us. Be patient - some networks require a bit more time to compute than others.

```{r message=FALSE, include=FALSE}
structural_complexities <- NULL
for(x in 1:length(data))
{
  print(plan_of_study_names_all[[x]])
  next_result <- structural_complexity(data[[x]])
  next_result <- next_result$`Overall Structural Complexity`
  structural_complexities <- c(structural_complexities, next_result)
}
```

Let's add the structural complexities to the table we formed in the previous section.

```{r}
plan_of_study_information <- cbind(plan_of_study_information,structural_complexities)
names(plan_of_study_information)[4] <- "Structural Complexity"
head(plan_of_study_information)
```

We can calculate some standard descriptive statistics for the structural complexity next.

```{r}
mean(plan_of_study_information$`Structural Complexity`)
sd(plan_of_study_information$`Structural Complexity`)
```

Now, we can explore the data across different strata, such as discipline and institution. We can accomplish this using boxplots and histograms.

```{r}
hist(plan_of_study_information$`Structural Complexity`, 
     main = "Histogram of all structural complexities", 
     xlab = "Structural Complexity")
boxplot(`Structural Complexity` ~ Discipline,
        data = plan_of_study_information,
        ylab = "Structural Complexity",
        main = "Structural Complexity by Discipline"
        )
boxplot(`Structural Complexity` ~ Institution,
        data = plan_of_study_information,
        ylab = "Structural Complexity",
        main = "Structural Complexity by Institution"
        )
boxplot(`Structural Complexity` ~ CatalogYear,
        data = plan_of_study_information,
        ylab = "Structural Complexity",
        main = "Structural Complexity by Catalog Year"
        )
boxplot(`Structural Complexity` ~ Discipline * Institution,
        data = plan_of_study_information,
        ylab = "Structural Complexity",
        main = "Structural Complexity by Discipline and Institution"
        )
```

We can examine the dataset with other metrics, such as curricular rigidity.

```{r}
curricular_rigidities <- NULL
for(x in 1:length(data))
{
  next_result <- curriculum_rigidity(data[[x]])
  curricular_rigidities <- c(curricular_rigidities, next_result)
}
curricular_rigidities <- round(curricular_rigidities,2)
plan_of_study_information <- cbind(plan_of_study_information,curricular_rigidities)
names(plan_of_study_information)[5] <- "Curricular Rigidity"
```

Let's plot the structural complexity and curricular rigidity. What we'll find is that there seems to be a strong positive relationship between the two quantities. 

```{r}
plot(plan_of_study_information$`Structural Complexity`,
     plan_of_study_information$`Curricular Rigidity`,
     xlab = "Structural Complexity",
     ylab = "Curricular Rigidity"
     )
#Add line where transition occurs between more and less rigid.
abline(h = 1, col = "red")
```

Correlating these two metrics yields a strong correlation of 0.82. This shouldn't be entirely surprising, considering both are derived from the prerequisite and corequisite relationships in the program. 

```{r}
cor(plan_of_study_information$`Structural Complexity`,plan_of_study_information$`Curricular Rigidity`)
```

However, the metrics making up the structural complexity values can provide much more substantive information. Note, in particular, that for the same structural complexity, a program could be labeled as more rigid or less rigid using the rigidity baseline value of 1 - as given by the red line. One metric does not rule them all. Each metric has its own strengths and weaknesses, providing different kinds of insights. 

From here, just about any of the functions described in this R Notebook can be used with the dataset. Enjoy your exploration!
