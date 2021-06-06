module PlutoVista
using UUIDs
using Colors
using ColorSchemes
using GridVisualize


include("plutovistaplot.jl")
export PlutoVistaPlot
export  tricontour, contour


include("plutovtkplot.jl")
export PlutoVTKPlot
export tricontour!,contour,contour!


include("plutoplotlyplot.jl")
export plot!,plot
export PlutoPlotlyPlot


# Experimental:
export triupdate!,  triplot!
export axis3d!, axis2d!
include("plutocanvasplot.jl")
export polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!
export PlutoCanvasPlot





end # module
