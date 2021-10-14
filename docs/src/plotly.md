# Plotly API
Besides of experimental and development work, using this API directly  should be avoided.

```@docs
PlutoPlotlyPlot
PlutoPlotlyPlot(;resolution=(300,300),kwargs...)
plot!(p::PlutoPlotlyPlot,x,y; kwargs...)
tricontour!(p::PlutoPlotlyPlot,pts, tris,f;kwargs...)
contour!(p::PlutoPlotlyPlot,X,Y,f; kwargs...)
triplot!(p::PlutoPlotlyPlot,pts, tris,f)
```
