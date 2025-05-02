# Fractal Dimension by Box Counting
This repository contains a `MATLAB` implementation of the *box counting* method for approximating the *fractal dimension* of an image.

## Usage
 For obtaining the fractal dimension of an image and the corresponding plot, run (from the command window):
 ```
>> getfractaldim(imgfile, boxwidth_start, boxwidth_end, boxwidth_incr)
 ```
 where `imgfile` is the image filename, `boxwidth_start`, `boxwidth_end` and `boxwidth_incr` are the start, end and increment values of the box side lengths (in px) for multiple iterations.

 For obtaining the grid lines overlaid on the image, for a specific boxwidth, run:
 ```
 >> drawgrid(imgfile, boxwidth)
 ```
 where `imgfile` is the image filename (must be a character array), and `boxwidth` is the side length of one grid box (in px).
## Theory
### 1. Fractal Dimension

- *What is fractal dimension?*

A <i>fractal dimension</i> is a ratio providing a statistical index of complexity comparing how detail in a pattern changes with the scale at which it is measured. In general, fractal dimensions help to show how scaling changes a model or modeled object.

- *What does it measure?*

Fractal dimension is a measure of how *complex* a figure is, which is sometimes intuitively explained as how *rough* it is, when zooming in on the figure extensively. In another sense, it captures a notion of <i>how many points</i> lie in a given set. Even though a plane and a line have uncountable points each, a plane is <i>larger</i> than a line, whereas something like the *Vicsek fractal* that we will see subsequently, lies somewhere in between. Fractal dimension captures this notion nicely. The mathematical formulation of the fractal dimension specifies this idea clearly.

Mathematically,
$$
D = \frac{\ln{N}}{\ln{S}}
$$
where $D$ is the fractal dimension, $N$ is the number of the auto-similar parts in which an object can be subdivided and $S$ is the scaling, that is, the factor needed to observe $N$ auto-similar parts.

As an example, for the <i>Vicsek Fractal</i>, $N = 5$ and $S = 3$. So, $D_{Vicsek} = \frac{\ln{5}}{\ln{3}} \approx 1.4649$.

<p align="center" width="100%">
<img src="img/vicsek-fractal.png" height=300px>
</p>
<p align="center" width="100%">
<em>Fig 1. Vicsek Fractal.</em>
</p>

### 2. Box Counting Method

The <i>box counting</i> method is a technique for approximating the fractal dimension of an object. In essence, it can be viewed as zooming in or out of the image, to observe how detail changes with scale. However, in this technique, rather than changing the magnification of the image itself, we alter the size of the element used to inspect the image, by varying the <i>box width</i>. 

Fractal dimension can be approximated by the box counting method using the relation given below :

$$
D = \frac{\ln{N_{boxes}}}{\ln{1/r}}
$$
where $D$ is the fractal dimension, $N_{boxes}$ is the number of boxes containing some portion of the object, and $r$ is the side length of a box.

On plotting a graph between $\ln{N_{boxes}}$ on the y-axis, and $\ln{1/r}$ on the x-axis, we can hence estimate the fractal dimension $D$ as the <i>slope</i> of the graph.

We demonstrate the box counting method using a sample image of the Vicsek fractal, the fractal dimension of which as shown previously is **1.4649**.

First, we attempt to do this by **hand-counting** the number of boxes containing a portion of the image, for varying box widths. 

|<img src="plots/vf-grid-60.png" height=200px><font size=2px><br>Box width = 60px<br>Box count = 36</font>|<img src="plots/vf-grid-100.png" height=200px><font size=2px><br>Box width = 100px<br>Box count = 21</font>|<img src="plots/vf-grid-140.png" height=200px><font size=2px><br>**Box width = 140px<br>Box count = 12**</font>|<img src="plots/vf-grid-180.png" height=200px><font size=2px><br>**Box width = 180px<br>Box count = 8**</font>|
|:---:|:---:|:---:|:---:|

Now, the points on the $\ln{N_{boxes}}$ vs ${\ln{1/r}}$ graph would be plotted as:

$(-4.094, 3.584), (-4.605, 3.045), (-4.942, 2.485), (-5.193, 2.079)$

We find the slope $m$ of the best-fit line through these points, using the *least squares regression* method, which comes out to be **1.374**.

On running `getfractaldim.m` for box widths varying from 1px to 200px, with an increment of 7px in box width for every iteration, we obtain the following graph.

<p align="center" width="100%">
<img src="plots/vf-graph-1-200-7.png" height=500px>
</p>
<p align="center" width="100%">
<em>Fig 2. Box counting estimation for fractal dimension</em>
</p>

The solid black points represent our observations and the green line is a best fit line estimation for the observed points. This line is obtained using least squares linear regression. The fractal dimension is roughly approximated as the slope of this best fit line. The slope obtained of this line is 1.440.

Hence, our revised estimate for fractal dimension is **1.440**, which is much closer to the actual value of 1.4649 than the estimate we had obtained by hand calculation.

## Notes

This implementation of box counting employs a **dynamic programming** approach for calculating the number of boxes containing at least one pixel of the image boundary (black pixels).
