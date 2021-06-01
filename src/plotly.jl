
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

Create a canvas plot with given resolution in the notebook
and given "world coordinate" range.
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
Set up  polygon data for vtk. 
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
    parameter!(p,"points",vec(vcat(pts,f')))
    parameter!(p,"polys",plotlypolys(tris))
    parameter!(p,"cam","3D")
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
    
    # It seems a colorbar is best drawn via canvas...
    # https://github.com/Kitware/vtk-js/issues/1621
end

function triupdate!(p::PlotlyPlot,pts,tris,f)
    command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict["xpoints"]=vec(vcat(pts,f'))
    p.update=true
    p
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



"""
Show plot
"""
function Base.show(io::IO, ::MIME"text/html", p::PlotlyPlot)
    plotlyplot = read(joinpath(@__DIR__, "..", "assets", "plotlyplot.js"), String)
    result=" "
    if p.update
        result="""
        <script type="text/javascript" src="https://unpkg.com/plotly.js"></script>
        <script>
        $(plotlyplot)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
//        vtkupdate("$(p.uuid)",jsdict,invalidation)        
        </script>
        """
    else
        result="""

        <script type="text/javascript" src="https://cdn.plot.ly/plotly-1.58.4.min.js"></script>
        <script>
        alert(Plotly)

        $(plotlyplot)
        const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plotlyplot("$(p.uuid)",jsdict,invalidation)        
        </script>
        <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px;"></div>
        """
    end
    write(io,result)
end



