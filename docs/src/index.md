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

When using vtk.js (default), interactive control via mouse includes the following actions:

- Left Mouse + Shift: Pan
- Left Mouse + Ctrl/Alt: Reset camera
- Left Mouse + Shift + Ctrl/Alt: Dolly (Zoom)
- Mouse Wheel: Dolly (Zoom)
- Multi-Touch Pinch: Dolly (Zoom)
- Multi-Touch Pan: Pan
- 3D Events: Camera Pose

Compared to [vtk.js](https://kitware.github.io/vtk-js/api/Interaction_Style_InteractorStyleTrackballCamera.html), 
keyboard interaction and rotation have  been disabled,  "spin" has been replaced by "reset camera".


```@docs
tricontour
tricontour!(p::PlutoVistaPlot,pts,tris,f;backend=:vtk, kwargs...)
quiver2d
quiver2d!(p::PlutoVistaPlot,pts,qvec;backend=:vtk, kwargs...)
trimesh
trimesh!(p::PlutoVistaPlot,pts,tris; backend=:vtk, kwargs...)
```


## 3D plots

When using vtk.js (default), interactive control via mouse includes the following actions:

- Left Mouse: Rotate
- Left Mouse + Shift: Pan
- Left Mouse + Ctrl/Alt: Reset camera
- Left Mouse + Shift + Ctrl/Alt: Dolly (Zoom)
- Mouse Wheel: Dolly (Zoom)
- Multi-Touch Rotate: Rotate
- Multi-Touch Pinch: Dolly (Zoom)
- Multi-Touch Pan: Pan
- 3D Events: Camera Pose

Compared to [vtk.js](https://kitware.github.io/vtk-js/api/Interaction_Style_InteractorStyleTrackballCamera.html), 
keyboard interaction has   been disabled, and  "spin" has been replaced by "reset camera".


```@docs
tetcontour
tetcontour!(p::PlutoVistaPlot,pts,tets,f;backend=:vtk, kwargs...)
tetmesh
tetmesh!(p::PlutoVistaPlot,pts,tets; backend=:vtk, kwargs...)
```

## Pluto utilities

```@docs
ScreenWidthGrabber
PlutoCellWidener
```

