module PlutoVista
using UUIDs
using Colors
using ColorSchemes



include("command.jl")

include("canvas.jl")

export CanvasPlot,  polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!


include("vtk.jl")



export VTKPlot,triplot!,tricolor!, axis3d!, axis2d!
export triupdate!

end # module
