# vtk.js API
This API is normally being used via [`PlutoVistaPlot`](@ref).

```@docs
PlutoVTKPlot
PlutoVTKPlot(;resolution=(300,300),kwargs...)
tricontour!(p::PlutoVTKPlot,pts,tris,f; kwargs...)
quiver2d!(p::PlutoVTKPlot, pts, qvec; kwargs...)
triplot!(p::PlutoVTKPlot,pts, tris,f)
contour!(p::PlutoVTKPlot,X,Y,f; kwargs...)
trimesh!(p::PlutoVTKPlot,pts, tris; kwargs...)
tetcontour!(p::PlutoVTKPlot,pts, tris, f; kwargs...)
tetmesh!(p::PlutoVTKPlot,pts, tris; kwargs...)
```
