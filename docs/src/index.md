PlutoVista.jl
=============


Plot library for Pluto notebooks based on [plotly.js](https://plotly.com/javascript/) for 1D data
and [vtk.js](https://kitware.github.io/vtk-js/index.html) (thus using WebGL)  for 2/3D data.

It uses the Pluto [💁 API to make objects available inside JS](https://github.com/fonsp/Pluto.jl/pull/1124)
to pass plot data from Julia to HTML5.



Please see:

- [example notebook](plutovista.html).


So far, this package is in an early state.

## PlutoVistaPlot


```@docs
PlutoVistaPlot
PlutoVistaPlot(;resolution=(300,300),kwargs...)
```

## 1D plots
```@docs
plot
plot!(p::PlutoVistaPlot,x,y; kwargs...)
```

## 2D plots

```@docs
tricontour
tricontour!(p::PlutoVistaPlot,pts,tris,f;backend=:vtk, kwargs...)
quiver2d
quiver2d!(p::PlutoVistaPlot,pts,qvec;backend=:vtk, kwargs...)
trimesh
trimesh!(p::PlutoVistaPlot,pts,tris; backend=:vtk, kwargs...)
```


## 3D plots

```@docs
tetcontour
tetcontour!(p::PlutoVistaPlot,pts,tets,f;backend=:vtk, kwargs...)
tetmesh
tetmesh!(p::PlutoVistaPlot,pts,tets; backend=:vtk, kwargs...)
```
