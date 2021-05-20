PlutoVTKPlot.jl
==================


Code design study for a plot library for Pluto notebooks based on [vtk.js](https://kitware.github.io/vtk-js/index.html)
This uses the Pluto [💁 API to make objects available inside JS](https://github.com/fonsp/Pluto.jl/pull/1124)
to pass plot data from Julia to HTML5.

Please see the [example pluto notebook](https://raw.githubusercontent.com/j-fu/PlutoVTKPlot.jl/main/examples/vtktest.jl).


So far, this package is in an early state. The current version of the code
is available via the registry https://github.com/j-fu/PackageNursery.git .

So, in order to try this out, you need to add this registry to you Julia environment.

```
pkg> registry add https://github.com/j-fu/PackageNursery.jl.git
```

This step can be safely undone by removing `.julia/registries/PackageNursery` in your
Julia folder.


