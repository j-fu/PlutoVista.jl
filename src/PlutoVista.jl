module PlutoVista
using UUIDs
using Colors
using ColorSchemes



include("common.jl")

include("canvas.jl")

export polygon!,linecolor!, fillcolor!
export textcolor!,textsize!,text!
export polyline!,linecolor!
export polygon!,fillcolor!
export axis!


include("vtk.jl")


export plutovista
export triplot!,tricolor!, axis3d!, axis2d!
export triupdate!

end # module
