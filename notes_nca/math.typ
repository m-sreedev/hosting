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
  title: [Calculations],
  authors: "Sreedev M ",
  abstract: [

  ],
  date: none,
  bibliography: none,
  figure-index: (enabled: true),
  table-index: (enabled: true),
  listing-index: (enabled: true)
)

= Delta Estimation
This is supposed to be a back of the envelope calculation to determine how the error between a Continuous CA with Moore Neighbourhood (hereby named Vanilla) and a Continuous CA with a distant neighbour (hereby referred to as Small World) will grow, after each step of the evolution.

Assume a grid of $N times N$ cells, and the state of a cell represented as $X_(i j)^t $. For a vanilla, the state at time $t+1$ can be calculated as

$ attach(X, bl: L, br: i j ) ^(t+1) = f_L (X_({i-1,i,i+1} {j-1,j,j+1})^ (t)) $

For a small world model, if we assume that every cell gets a partner outside its Moore neighbourhood, the evolution equation is of the form

$ attach(X, bl: N L, br: i j ) ^(t+1) = f_L (X_({i-1,i,i+1} {j-1,j,j+1})^ (t), X_(i + k, j + l) ^ (t)) $

where  $X_(i + k, j + l) ^ (t)$ is the long distance neighbour and $X_({i-1,i,i+1} {j-1,j,j+1})$ represents the Moore neighbourhood . Usually,  $X_(i + k, j + l) ^ (t)$ is independent of $X_({i-1,i,i+1} {j-1,j,j+1})$.

But, we make the assumption that a good enough $f_L$ can approximate $X_(i + k, j + l) ^ (t)$ with some error $epsilon$.

$ X_(i + k, j + l) ^ (t) = f_A (X_({i-1,i,i+1} {j-1,j,j+1})^ (t)) + epsilon$

which means that 

$ attach(X, bl: N L, br: i j ) ^(t+1) = f_(A L) (X_({i-1,i,i+1} {j-1,j,j+1})^ (t)) + epsilon  \

= attach(hat(X), bl: L, br: i j ) ^(t+1) + epsilon $

At time = $t+1$, the delta between the approximation and the small world cell state is

$ abs(attach(X, bl: N L, br: i j ) ^(t+1) - attach(hat(X), bl: L, br: i j ) ^(t+1)) = epsilon $

At time = $t+2$,

$  Delta(t+1) = attach(hat(X), bl: L, br: i j ) ^(t+2) = f_(A L) (hat(X)_({i-1,i,i+1} {j-1,j,j+1})^ (t+1)) + epsilon $

$hat(X)_({i-1,i,i+1} {j-1,j,j+1})^ (t+1)$ is composed of 9 terms, and each term has an $epsilon$ term associated with it. Therefore, 

$ Delta (t+2) = sum_("Moore") abs((partial f)/ (partial X_ (i j )))  abs(hat(X)_(i j) ^ (t+1) -X_(i j) ^ (t+1) )  $

If we consider the leading $abs((partial f)/ (partial X_ (i j )))$ to be $alpha$, the equation reduces to 

$ Delta (t+2) <= 9 alpha epsilon  $

Similarly, for $t+3$, 

$ Delta (t+3) <= 9 alpha Delta (t+2) \
<= 81 alpha^2 epsilon   $

More generally, 

$ Delta (t+k) <= (9 alpha)^(k-1) epsilon $

This means if $alpha < 1$, after a certain enough $k$, both vanilla and small world can converge to the same grid.
So if a task can only be acheived with a non-local connection, its should be $alpha > 1$.  (?)