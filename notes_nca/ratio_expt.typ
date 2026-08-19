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


#set text(lang: "en", font: "PT Serif", size: 11pt, hyphenate: false)

#show: ilm.with(
  title: [Cell Differentiation Task],
  authors: "Sreedev M ",
  abstract: [

  ],
  bibliography: bibliography("refs.bib"),
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

= Idea
The idea was to devise a toy problem of the sort where each individual cell does not have a pre-defined target. The property trained for should be measured at the grid level, which would subsequently mean that  loss would also be applied at grid level. 

Such a problem can bring out the difference between a Moore-neighbourhood based NCA and a NCA with non-local connections better than problems with cell level targets#note[Since if a cell has a predefined target, it can reach there without little consideration given towards the state of the grid.] Using such a problem, we can test different versions of the non-local NCA and treat the advantage over vanilla NCA as a "Hello World" check.

The problem is defined as follows:
1. Each grid starts out with each cell in a parent state.
2. A parent state can mutate into a daughter state A, or daughter state B, or stay as it is.
3. The goal is to learn a set of update rules, so that the NCA settles into a configuration, where the ratio of daughter A to daughter B is a predefined target, and the number of cells in the parent state is as minimum as possible.

It is entirely possible for the vanilla NCA to solve this task.
The advantage discussed earlier would be in the form of convergence time, since immediate neighbour-neighbour difussion would take a longer time than non-local version#note[where information can travel faster; if it is a small-world map , information can travel within $log(N)$ steps where $N$ is the grid size.]

= Design
The vanilla NCA#note[with Moore neighbours] architecture is pretty much the same as that of the one discussed in #cite(<mordvintsev2020growing>, form: "prose"). Main differences are as follows:
- We will have no hidden channels for the first few experiments. We will observe the role hidden channels play by varying them after initial experiments are performed. Similarly, the firing rate of cells is kept at 1, and will be varied later.
- The Sample Pool structure is kept as is from @mordvintsev2020growing. The worst performing grid is replaced with a grid at initial state after every epoch

Some task specific design choices:
1. The main channel is responsible for the *fate* of the cell. #linebreak() $
"fate"(f) = cases(
  "parent , "    & -0.95 <= f <= 0.95,
  "daughter A , "  &  -1 <=  f < -0.95,
  "daughter B, "  & 0.95 < f <= 1,
)
$ The update output from the network is capped at  $mod(0.05)$ and the cell fate is capped at $mod(1)$. 

2. *Loss functions* <loss_funcs>
 1. *Commitment Loss*: a double welled potential with two minima, one at -1 and the other at 1,  and a maximum at 0. This forces the cells to move away from the parent state towards the two daughter states. #linebreak() $ cal(L)_"commitment" = (1 - "fate"^2)^2 $
 2. *Ratio Loss*: quantifies the ratio of the grid from the target ratio. This is done with the help of a helper function called strength.#note[strength quantifies the commitment towards a daughter] #linebreak()$
 "strength(A)" = sum_"grid" "ReLU(fate)" \ "strength(B)" = sum_"grid" "ReLU(-fate)"
 $Then ratio of B is defined as #linebreak()$
 "ratio"_"B" = "strength(B)"/ ("strength (A) + strength (B)")
 $ The ratio loss is then #linebreak()$
 cal(L)_"ratio"#note[The ratio loss is computed across the batch used during training epoch.] = E_"batch" [ ("ratio"_"B" - "target ratio")^2 ]
 $
 3. *Variance Loss* : If the batch size gets large enough, the network can push  each individual grid within the batch towards all daughter cell A or all daughter cell B and try to acheive the the ratio at the batch level instead of the grid level. In order to mitigate this we try to minimize the variance between grids.#linebreak()$
 cal(L)_"variance" = E_"batch" [("ratio"_"B" - E_"batch" ["ratio"_"B"])^2]
 $

 The total loss is
 $ cal(L)  = cal(W)_"commitment"*cal(L)_"commitment" + cal(W)_"ratio" * cal(L)_"ratio" \ + cal(W)_"variance" * cal(L)_"variance" $
 where $cal(W)$s are the weights to the terms.

 == Vanilla NCA
The pipeline is given below:
1. An identity filter, Sobel X filter, and Sobel Y filter are convolved over the grid (C #sym.arrow.r 3C#note[C is the number of channels])
2. A CNN with 3 Layers act on this grid with 3C channels:
  #table(columns: 3,
  [Layer 1 ], [2D Convolution , 32 Channels, ReLU, Width 1], [3C #sym.arrow.r 32],
  [Layer 2 ], [2D Convolution , 32 Channels , ReLU, Width 1], [32 #sym.arrow.r 32],
  [Layer 3 ], [2D Convolution , C Channels , No Activation, Width 1], [32 #sym.arrow.r C]
  )
3. The output of Layer 3 is the update given to the current grid.
4. The grid is evolved for some steps and the loss is computed. The gradients are updated via BPTT.
5. The worst performing grid#note[who has the highest variance in the batch] is removed and replaced with a grid in the initial state
6. Steps 1 to 5 are repeated for some number of times.

== Non Local NCA

Non locality is established by randomly selecting a fixed percentage of cells in the grid to have one long range partner. The partner is also randomly chosen, and their distance must be greater than some fixed Manhattan Distance#note[here it is 10].
A wiring bank is made by repeating the long range wiring process for $N_"wirings"$ times.#note[since it is random, each wiring process generates a different graph]. When a batch is selected from the pool during train, each sample within the batch is chosen to be a unique wiring from the wiring bank#note[this wirings associated with a batch change in each epoch].

This ensures that the network learns rules which generalize to all kinds of wirings.#note[which is a function of fraction of cells with wiring and the Manhattan Distance]

=== v1 #text(fill:red)[(Discarded)]
1. An identity filter, Sobel X filter, and Sobel Y filter are convolved over the grid (C #sym.arrow.r 3C#note[C is the number of channels])
2. A CNN (termed Local CNN) with 3 Layers act on this grid with 3C channels:
  #table(columns: 3,
  [Layer 1 ], [2D Convolution , 32 Channels, ReLU, Width 1], [3C #sym.arrow.r 32],
  [Layer 2 ], [2D Convolution , 32 Channels , ReLU, Width 1], [32 #sym.arrow.r 32],
  [Layer 3 ], [2D Convolution , C Channels , No Activation, Width 1], [32 #sym.arrow.r C]
  )
3.  For each wiring, the parings are determined. The channel values of the partners are collected and concatenated#note[If the cell deoesnt have a partner, zero vectors are concatenated, so the lenght of the vector of NC]. A CNN (termed Non Local CNN) with 3 Layers act on this grid with 3C channels:
  #table(columns: 3,
  [Layer 1 ], [2D Convolution , 32 Channels, ReLU, Width 1], [1 #sym.arrow.r 32],
  [Layer 2 ], [2D Convolution , 32 Channels , ReLU, Width 1], [32 #sym.arrow.r 32],
  [Layer 3 ], [2D Convolution , C Channels , No Activation, Width 1], [32 #sym.arrow.r C]
  )

4. The Local CNN and the Non Local CNN outputs their own separate update grid. These are then independently added to the current grid and evolved.
5. The rest of the training procedure proceeds similar to the vanilla NCA.

_This version of the Non Local NCA is discarded now and the reasons are discussed later._


=== v2
1. An identity filter, Sobel X filter, and Sobel Y filter are convolved over the grid (C #sym.arrow.r 3C)
2. For each wiring, the parings are determined. Three additional channels are created which will contain the partnter's identity, Sobel X and Sobel Y values respectively. If a cell doesn't have a partner the values are kept at 0.#note[throughout the process] (3C #sym.arrow.r 6C)
3. A CNN with 3 Layers act on this grid with 3C channels:
  #table(columns: 3,
  [Layer 1 ], [2D Convolution , 32 Channels, ReLU, Width 1], [6C #sym.arrow.r 32],
  [Layer 2 ], [2D Convolution , 32 Channels , ReLU, Width 1], [32 #sym.arrow.r 32],
  [Layer 3 ], [2D Convolution , C Channels , No Activation, Width 1], [32 #sym.arrow.r C]
  )
4. The output of Layer 3 is the update given to the current grid.
5. The rest of the training procedure proceeds similar to the vanilla NCA.

== Initialization
Each cell in the grid is initialized with a small random noise at 0. The weights of the network are also randomly chosen. The probability of a cell getting a long range partner is determined by a hyperparameter. A small fraction#note[another hyperparameter] of cells are then converted to daughter A/ daughter B cells with random chance so that there is variability and symmetry-breaking in the intial state.

= Experiments
== Convergence Time Comparison
+ $N_R$ number of ratios are randomly chosen between the range 0.35 and 0.75.#note[0 to 1 was not chosen because it was getting harder to train]. Each $N_R$ is associated with $N_s$ number of seeds. The seeds are same across ratios.
+ The seed determines the model weights, the initial grid etc. so that both the vanilla NCA and Non Local NCA having almost everything same except the wiring toplogy.
+ A vanilla NCA model and a Non Local NCA Moodel is trained for every seed associated with every ratio#note[for 1000 epochs].

+ $N_"eval"$ number of fresh initial grids are then made and it is evolved with the learned rules till it reaches within $"tol"$ #note[tol is set here as within 0.05 band of target ratio and less than 5% parent cells]. The maximum number of steps it can take is set as $"MAX_STEPS"$ and the models that fail to converge before this are discarded.#note[Work has to be done to bring this to a minimum.]
+ he number of steps taken for convergence#note[satisfying the $"tol"$ condition] is noted down for both vanilla NCA and Non Local NCA. An average is taken is across the evaluation grids and this number can be denoted as $t_(s_i)^(r_j)$
+ $ 1/(N_s + N_r) sum_s_i sum_r_j t_(s_i)^(r_j) $ is the mean convergence time. This is shown as the point in the plot.
+ $ (sigma_({s_i} U {r_j}))/sqrt(N_s*N_r) $ is the mixed standard deviation of the readings and this is plotted as the error-bar
+ $ (sigma_({s_i}))$ is the standard deviation of the readings across seed axis  and this is plotted as a band.
+ Steps 4 to 8 are repeated again for grids of different sizes in $N_"test"$

=== Results
#figure(
  image("../ratio_expt/results/train_40_test_till_100.png"),
  caption: [Convergence Time vs Grid Size for vanilla NCA and Non Local NCA#note[denoted as small-world] with $p = 0.3$. The mean convergence time are the points, $sigma/sqrt(N)$ of the whole dataset is the error-bar, and $sigma$ across seeds is the band.#note[Parameters for @train_40_test_till_100 #table(
    columns: 2,
    [$N_r$], [10],
    [$N_s$], [10],
    [$N_"eval"$], [10]
    )
  ]]
)<train_40_test_till_100>

=== Analysis
- From @train_40_test_till_100 it is evident that Non Local NCA has a clear advantage in convergence time. Plus the convergence time across seeds are stable for Non Local NCA #note[notice the small band for non local NCA compared to a very wide band for vanilla] compared to vanilla NCA which are all over the place. Does this mean that the Non-Local NCA converged to a more general rule across seeds, wirings and initializations that is not affected by perturbation?
- Since the channels 2-5 are always set to 0 for the vanilla NCA, a reason for the slower performance of vanilla NCA might be due to effectively working with a lower parameter count. There is a need to perform the experiment with the effective parameters of vanilla NCA either matching or exceeding that if its non local counterpart to strengthen the claim for non local connections.