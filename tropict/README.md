# Tropict: A clearer depiction of the tropics.

Tropict is a set of python and R scripts that adjust the globe to make
land masses in the tropics fill up more visual realestate.  It does
this by exploiting the ways continents "fit into" each other, splicing
out wide areas of empty ocean and nestling the continents closer
together.

All Tropict scripts are designed to show the region between 30&deg; S
and 30&deg; N.  In an equirectangular projection, that looks like this:

![Equirectangular tropics](https://raw.githubusercontent.com/jrising/research-common/master/tropict/examples/subjects/arabica-future.png)

By removing open ocean and applying the Gall-Peters projection, we can
see the land much more clearly:

![Equirectangular tropics](https://raw.githubusercontent.com/jrising/research-common/master/tropict/examples/subjects/arabica-futureb.png)
