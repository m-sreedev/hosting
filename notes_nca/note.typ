#import "@preview/ilm:2.1.1": *


#import "@preview/marginalia:0.3.1" as marginalia: note, notefigure, wideblock
#let note = note.with(text-style: (font: "PT Serif"))

#show: marginalia.setup.with(
  inner: ( far: 5mm, width: 15mm, sep: 5mm ),
  outer: ( far: 10mm, width: 35mm, sep: 15mm ),
  top: 2.5cm,
  bottom: 2.5cm,
  book: false,
  clearance: 12pt,
)

#show link: set text(fill: blue)


#set text(lang: "en", font: "PT Serif", size: 11pt)

#show: ilm.with(
  title: [Non-Locality in NCA],
  authors: "Sreedev M ",
  abstract: [

  ],
  date: none,
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

= Motivation

== Modelling Life as Interactions
How do biological systems, composed of numerous individual units, acheive many incredible feats such as coordination and stable complex pattern formation? In a 1952 paper titled The Chemical Basis of Morphogenesis, Alan Turing presents a mathematical model where the interaction between two diffusing substances giving rise to intricate patterns #cite(<turing_rd>). The diffusing substances, called "morphogens", are modelled with the help linear differential equations. Differential equations are local, meaning the evolution of the system at a point is determined only by it's neighbours, both in space and time. This choice is based on the assumption that the basic process in  biological computation is a cell reacting to it's local environment. Turing's reaction diffusion model successfully modelled various complex patterns seen in nature, and it even got adopted to many other fields like phyiscs, economics, sociology etc. The "local computations leading to global emergent complex behaviour" theory became an integral part of biological modelling henceforth.

Cellular Automata (CA) are models of computations introduced by John Von Neumann, where computation occurs via the interaction between "cells" in a grid. The cells can exist in a finite number of states. The next state of a cell is determined by it's current state, and the state of it's immediate neighbours. CAs are very powerful, they are even shown to be Turing Complete. #cite(<ca_in_bio>, form: "author"), employed CAs to model various developmental, populational biology patterns and a neuronal model. CA have been used in various biological settings, since it's implicit local and simple update rules grants control to model things at a cellular level and let interactions among cells take care of the resultant complex emergent behaviour.

Neural Cellular Automata @mordvintsev2020growing, is a modification on CA architecture. Instead of hand-coding the rules, a MLP is used which learns the local update rules of the CA, given a  final state of the CA as target. NCA have been trained to model growth from a single cell, generate stable and self-stabilising patterns, and regenerate from a damaged state. Even more, they can self classify images, solve mazes and so on. One can think of NCA as machines that solve a task, with only means of localized computations. Efforts are underway now for establishing NCA as Universal Computing architectures.

== Are neighbours enough?
Any information can spread within a grid, via cell to cell communication, *given enough time*. But there are many systems in nature, where we can find instances of non-local communication. Brain, nature's most powerful and efficient computer is a good example. There are evidences of non-local communications between different segments of the brain. In a much simpler system like the zebrafish skin, which has a characterisitic gold and black pattern, there are long range connections called "airnemes" that help with the pattern stability. If only cell-to-cell communications are sufficient for information propagation, why did nature evolve such systems is a natural question to pose and the answer may also come as obvious. One is that diffusion is slow, and a  system might have to function in conditions where information transfer via diffusion is too slow, which led to the formation of long-range jumps. Other one is that of efficiency, where the argument is that instead of wiring every cell with it's neigbhour, it might be more efficent to skip some of those wirings and add long range jumps. Another reason might be for the need to position a cell unit. In CAs, cells are symmetric; which implies they have no mechanism to gauge their position within the grid. But organisms have positional and body axis information, which might be an artefact emerging from long-range connections.

== Can NCA compute everything? <can_it_do_uni_comp>

There are existing literature, that discuss solving various tasks with NCA, that attribute the limitations of NCA to it's local update rule feature#note[#cite(<nca_arcagi>, form: "prose") is an example.]
Nature, having evolved non-local connections to facilitate such tasks implies that certain computations are either not feasible #note[ meaning it might take a huge amount of time for the NCA to compute] or not possible with NCA. While there are NCA with flexible topology called Graph-NCA#note[or GNCA for short], there have been little to no studies comparing vanilla NCA#note[with Moore neighbours; the immediate square neighbourhood of 8] to GNCA#note[#cite(<BraiNCA>, form: "prose") claims such studies have not been performed as per their knowledge.]. Especially, there have been very no studies gauging what the limitations of NCA are and what additional capabilities non-local connections impart to them.  To gauge the computational bounds or limiltations of NCA, one can cook up toy problems of scenarios where nature has evolved non-local connections and assess the performance of NCA on them. The intuition is that vanilla  NCA will perform subtantially poorly than a NCA with long range connections. #note[The nature and structure of those connections can be taken up depending upon the nature of the problem.]


#pagebreak()
== Why bother?
One straightforward reason is to assess what NCA can compute and cannot/struggle to  compute. This can also serve as a comparison of vanilla NCA to GNCA approaches, and a study of the capabilities non-locality imparts to the architecture exclusively. Another more ambitious aspiration, is that if the experiments turns out to be fruitful, a non-local NCA can serve as a tool to examine the reasons for emergence of non-local systems in nature and life. Testing new hypotheses that try to explain why non-local structures emerged, either functionally or evolutionarilly can be tested with a toy problem here. We can vary the topology and connection architecture to see if feasible alternative pathways are allowed in nature.


= Experiments
== Estimating Global Properties
Usually, NCA are trained on tasks such that each cell has a predefined target to reach#note[something like generating an image, where each cell has to reach it's target pixel]. What the network learns is to how to guide each cell, only using it's current value the value of its current neighbors, to that target state. NCA shows remarkable performance in such tasks.

The goal of the experiments in this section is not to have a specified target for each cell#note[this is not exactly true, but I'll clarify this later.]. The loss is predominantly applicable for the whole grid, and the values taken by each individual cell is of less importance than the global properties of the grid that emerge from those values. The intuitoin here is to test how NCA fares in situations where each cell has to perform by taking into account how the global property of the grid might change due to it's actions.

=== Cell Differentiation Task
This task is designed with the goal of desigining a non-local version of NCA and establishing that it is performing better#note[better how will be defined later] when compared to vanilla NCA#note[vanilla NCA only has Moore neighbourhood]. The task designed is simple enough to implement but is one that respects the idea of a global property task described in the previous section.
If our version of the non-local NCA fares better than vanilla NCA, it is a green light ahead for experiments further down the line.
The task  is described as given below:
1. Each grid starts out with each cell in a parent state.
2. A parent state can mutate into a daughter state A, or daughter state B, or stay as it is.
3. The goal is to learn a set of update rules, so that the NCA settles into a configuration, where the ratio of daughter A to daughter B is a predefined target, and the number of cells in the parent state is as minimum as possible.

A detailed note on this experiment is maintained #link("https:github.com")[here].

The ideal outcome here would be the non-local NCA demonstrating a notable reduction in convergence time over vanilla NCA. A decrease in convergence time conveys that cells in non-local grid could come to a conclusion about the global picture of the number of daughter A cells and daughter B cells quicker than the cells in the vanilla grid and therby is an indicator that it is a better model for tasks that estimate global properties.

=== Density Classification for NCA
This tasked was motivated by the question discussed in @can_it_do_uni_comp. Turns out that people were interested in desigining tasks that CA cannot solve from a very long time, one such task being the Density Classification Task, as discussed for the first time in #cite(<no_sol_discrete_ca>, form:"prose"). This was for a  binary state discrete cellular automata. The density classification task was then extended to continuous CA, and it was shown to be solvable _under certain conditions_ @Wolnik_2017. As for now, no general solutions exist#note[I'm also not sure about the truth value  of this statement.] and it can be stated with some confidence that the density classification problem is a hard problem for a CA.

The density classification task, modified for NCA is described below:
1. Each cell starts with a random value between 0 and 1 as it's starting state. A predetermined number (also between 0 and 1) named threshold is also given as input.
2. If the density of the grid#note[the mean of all values in the grid] is less than the threshold, all cells must settle towards values less than the threshold.
3. If the inverse is true, all cells must settle to values which are greater than the threshold.

A detailed note on this experiment is maintained #link("https:github.com")[here].

What we're expecting here is an incredibly poor performance from vanilla NCA when compared to the non-local NCA. This would serve as solid evidence for purely local rules struggling to estimate the global picture#note[some concerns regarding this statement is discuessed in ].

#pagebreak()

= Thoughts and Concerns
== Does better performance mean more accurate representation?
Assume that everything went according to plan, and non-local NCA is showing better performance, how do i isolate that topology is the deciding factor that fuelled this performance boost? It could also be the case that gradient descent in vanilla NCA was not optimal/powerful enough to find the correct local rules that does the task with comparable speeds to non-local NCA.

Additional experiments would have to be devised to rule out this possibility.