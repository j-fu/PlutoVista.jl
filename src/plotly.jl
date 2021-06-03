
"""
Structure containig plot information. 
In particular it contains dict of data sent to javascript.
The semantics of the keys is explaind in PlutoCanvasPlot.jl
"""
mutable struct PlotlyPlot  <: AbstractVistaPlot
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64

    update::Bool
    # uuid for identifying html element
    uuid::UUID
    PlotlyPlot(::Nothing)=new()
end

"""
````
 PlotlyPlot(;resolution=(300,300))
````

Create a plotly plot with given resolution in the notebook
"""
function PlotlyPlot(;resolution=(300,300))
    p=PlotlyPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    p.w=resolution[1]
    p.h=resolution[2]
    p.update=false
    p
end

"""
Show plot
"""
function Base.show(io::IO, ::MIME"text/html", p::PlotlyPlot)
    plotlyplot = read(joinpath(@__DIR__, "..", "assets", "plotlyplot.js"), String)
    result="""
        <script type="text/javascript" src="https://cdn.plot.ly/plotly-1.58.4.min.js"></script>
        <script>
        $(plotlyplot)
        var jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plotlyplot("$(p.uuid)",jsdict,$(p.w), $(p.h))        
        </script>
        """

    if !p.update
        result=result*"""<div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px;"></div>"""
    end
    write(io,result)
end




#translate Julia attribute symbols to pyplot-speak
const mshapes=Dict(
    :dtriangle => "triangle-down",
    :utriangle => "triangle-up",
    :rtriangle => "triangle-right",
    :ltriangle => "triangle-left",
    :circle => "circle",
    :square => "square",
    :cross => "cross",
    :+ => "cross",
    :xcross => "x",
    :x => "x",
    :diamond => "diamond",
    :star5 => "star",
    :pentagon => "pentagon",
    :hexagon => "hexagon",
    :none => "none"
)


function plot!(p::PlotlyPlot,x,y;
               label="",
               color=:black,
               linewidth=2,
               linestyle=:solid,
               markersize=6,
               markercount=10,
               markertype=:none)

    p.update=false
    command!(p,"plot")
    parameter!(p,"x",collect(x))
    parameter!(p,"y",collect(y))
    parameter!(p,"label",label)
    parameter!(p,"linewidth",linewidth)
    parameter!(p,"markercount",markercount)
    parameter!(p,"markertype",mshapes[markertype])
    parameter!(p,"markersize",markersize)
    parameter!(p,"linestyle",String(linestyle))

    rgb=RGB(color)
    rgb=[rgb.r,rgb.g,rgb.b]
    rgb=UInt8.(floor.(rgb*255))
    parameter!(p,"color",rgb)
    
end




###############################################################
# Experimental part
# It turns out that plotly is significantly slower
# than VTK for 3D data. 
"""
Coding is   [3, i11, i12, i13,   3 , i21, i22 ,i23, ...]
Careful: js indexing counts from zero
"""
function plotlypolys(tris)
    ipoly=1
    ntri=size(tris,2)
    polys=Vector{Int32}(undef,4*ntri)
    for itri=1:ntri
        polys[ipoly] = 3
        polys[ipoly+1] = tris[1,itri]-1
        polys[ipoly+2] = tris[2,itri]-1
        polys[ipoly+3] = tris[3,itri]-1
        ipoly+=4
    end
    polys
end

"""
     triplot!(p::PlotlyPlot,pts, tris,f)

Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::PlotlyPlot,pts, tris,f)
    command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.update=false
    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",f)

    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)
end

function triupdate!(p::PlotlyPlot,pts,tris,f)
    command!(p,"triupdate")
    p.update=true
    # make 3D points from 2D points by adding function value as
    # z coordinate
    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",f)

    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)
end


"""
     tricolor!(p::PlotlyPlot,pts, tris,f; colormap)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function tricolor!(p::PlotlyPlot,pts, tris,f;cmap=:summer)
    command!(p,"tricolor")
    (fmin,fmax)=extrema(f)
    parameter!(p,"points",vec(vcat(pts,zeros(length(f))')))
    parameter!(p,"polys",plotlypolys(tris))

    rgb=reinterpret(Float64,get(colorschemes[cmap],f,:extrema))
    parameter!(p,"colors",UInt8.(floor.(rgb*256)))
    parameter!(p,"cam","2D")
end



"""
Add 3D coordinate system axes to the plot.
Sets camera handling
to 3D mode.
"""
function axis3d!(p::PlotlyPlot;
                 xtics=0:1,
                 ytics=0:1,
                 ztics=0:1)
    command!(p,"axis3d")
    parameter!(p,"bounds",[extrema(xtics)..., extrema(ytics)...,extrema(ztics)...])
    parameter!(p,"cam",ztics[1]==ztics[end] ? "2D" : "3D")
end

"""
    Add 2D coordinate system axes to the plot. Sets camera handling
to 2D mode.
"""
axis2d!(p::PlotlyPlot;kwargs...)=axis3d!(p;ztics=0.0,kwargs...)






