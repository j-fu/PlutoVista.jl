# Plotly API

This API is normally being used via [`PlutoVistaPlot`](@ref).

```@docs
PlutoPlotlyPlot
PlutoPlotlyPlot(;resolution=(300,300),kwargs...)
plot!(p::PlutoPlotlyPlot,x,y; kwargs...)
tricontour!(p::PlutoPlotlyPlot,pts, tris,f;kwargs...)
contour!(p::PlutoPlotlyPlot,X,Y,f; kwargs...)
triplot!(p::PlutoPlotlyPlot,pts, tris,f)
```
