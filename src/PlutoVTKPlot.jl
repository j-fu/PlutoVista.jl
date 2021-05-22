module PlutoVTKPlot
using PlutoCanvasPlot
using UUIDs
using Colors
using ColorSchemes

loadvtk()=error("Deprecated: loadvtk() is now called automatically when you render a plot, you can delete this cell.")


"""
Structure containig plot information. 
In particular it contains dict of data sent to javascript.
The semantics of the keys is explaind in PlutoCanvasPlot.jl
"""
mutable struct VTKPlot
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64

    # uuid for identifying html element
    uuid::UUID
    VTKPlot(::Nothing)=new()
end

"""
````
 VTKPlot(;resolution=(300,300))
````

Create a canvas plot with given resolution in the notebook
and given "world coordinate" range.
"""
function VTKPlot(;resolution=(300,300))
    p=VTKPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    p.w=resolution[1]
    p.h=resolution[2]
    p
end


"""
Set up  polygon data for vtk. 
Coding is   [3, i11, i12, i13,   3 , i21, i22 ,i23, ...]
Careful: js indexing counts from zero
"""
function vtkpolys(tris)
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
     triplot!(p::VTKPlot,pts, tris,f)

Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::VTKPlot,pts, tris,f)
    pfx=command!(p,"triplot")
    # make 3D points from 2D points by adding function value as
    # z coordinate
    p.jsdict[pfx*"_points"]=vec(vcat(pts,f'))
    p.jsdict[pfx*"_polys"]=vtkpolys(tris)
    p.jsdict[pfx*"_cam"]="3D"
    p
end

"""
     tricolor!(p::VTKPlot,pts, tris,f; colormap)

Plot piecewise linear function on  triangular grid given as "heatmap" 
"""
function tricolor!(p::VTKPlot,pts, tris,f;cmap=:summer)
    pfx=command!(p,"tricolor")
    cscheme=colorschemes[cmap]
    (fmin,fmax)=extrema(f)
    p.jsdict[pfx*"_points"]=vec(vcat(pts,zeros(length(f))'))
    p.jsdict[pfx*"_polys"]=vtkpolys(tris)

    # save transfer capacity by passing rgb values as UInt8
    colors=Array{UInt8,2}(undef,3,length(f))
    for i=1:length(f)
        rgb=get(cscheme,(f[i]-fmin)/(fmax-fmin))
        colors[1,i]=Int(floor(rgb.r*256))
        colors[2,i]=Int(floor(rgb.g*256))
        colors[3,i]=Int(floor(rgb.b*256))       
    end
    p.jsdict[pfx*"_colors"]=vec(colors)
    p.jsdict[pfx*"_cam"]="2D"

    # It seems a colorbar is best drawn via canvas...
    # https://github.com/Kitware/vtk-js/issues/1621
    
    p
end


"""
Add 3D coordinate system axes to the plot.
Sets camera handling
to 3D mode.
"""
function axis3d!(p::VTKPlot;
                 xtics=0:1,
                 ytics=0:1,
                 ztics=0:1)
    pfx=command!(p,"axis3d")
    p.jsdict[pfx*"_bounds"]=[extrema(xtics)..., extrema(ytics)...,extrema(ztics)...]
    p.jsdict[pfx*"_cam"]= ztics[1]==ztics[end] ? "2D" : "3D"

    p
end

"""
Add 2D coordinate system axes to the plot. Sets camera handling
to 2D mode.
"""
axis2d!(p::VTKPlot;kwargs...)=axis3d!(p;ztics=0.0,kwargs...)

"""
Show plot
"""
function Base.show(io::IO, ::MIME"text/html", p::VTKPlot)
    vtkplot = read(joinpath(@__DIR__, "..", "assets", "vtkplot.js"), String)
    result="""
    <script type="text/javascript" src="https://unpkg.com/vtk.js@18"></script>
    <script>
    $(vtkplot)
    const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
    vtkplot("$(p.uuid)",jsdict,invalidation)        
    </script>
    <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px;"></div>
    """
    write(io,result)
end



export loadvtk, VTKPlot,triplot!,tricolor!, axis3d!, axis2d!
end # module
