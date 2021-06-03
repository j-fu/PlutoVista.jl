module PlutoVista
using UUIDs
using Colors
using ColorSchemes
using GridVisualize


include("common.jl")

include("canvas.jl")

export polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!
export CanvasColorbar
include("vtk.jl")


export plutovista
export triplot!,tricolor!, axis3d!, axis2d!
export triupdate!


include("plotly.jl")


export plot!,plot,tricontour,tricontour!,contour,contour!


export PlotlyPlot
end # module
