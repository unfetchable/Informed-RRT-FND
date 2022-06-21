<h2><i> Description </i></h2>

We present an adaptation of an Informed RRT* FND algorithm for efficient path-finding in convex high-dimensional dynamic environments through the use of parametric search heuristics. 
It's capable of making deviations to previous node iterations to negate the computation time required for extensive use, the effect of which can be regulated through its parameters.

<p align="center"><b> Multidirectional Informed RRT* FND </b></p>
<p align="center">
  <image src="https://github.com/luca-paolo/Informed-RRT-FND/examples/visuals/Demonstration.gif" height="480"></image>
</p>


<h2><i> Plans </i></h2>
- A branch evaluation function that can freeze nodes which can no longer be improved upon such as branches in enclosed areas.
