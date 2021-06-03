module PlutoVista
using UUIDs
using Colors
using ColorSchemes
using GridVisualize


include("common.jl")


include("vtk.jl")
export tricontour,tricontour!,contour,contour!
export axis3d!, axis2d!
export VTKPlot


include("plotly.jl")
export plot!,plot
export PlotlyPlot


# Experimental:
include("canvas.jl")
export polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!
export CanvasPlot


export triupdate!,  triplot!

end # module
