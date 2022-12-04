module PlutoVista
using UUIDs
using Colors
using ColorSchemes
using DocStringExtensions
using GridVisualizeTools

abstract type AbstractPlutoVistaBackend end



include("plutovtkplot.jl")
export PlutoVTKPlot
export tricontour!,contour!
export trimesh!
export tetcontour!
export tetmesh!
export quiver2d!


include("plutoplotlyplot.jl")
export plot!,plot
export PlutoPlotlyPlot


# Experimental:
export triupdate!, triplot!
export axis3d!, axis2d!

include("plutocanvasplot.jl")
export polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!
export PlutoCanvasPlot


# API
include("plutovistaplot.jl")
export PlutoVistaPlot
export  tricontour,trimesh,contour,tetcontour,tetmesh,quiver2d

# Tools
include("plutoutil.jl")
export ScreenWidthGrabber, PlutoCellWidener


end # module
