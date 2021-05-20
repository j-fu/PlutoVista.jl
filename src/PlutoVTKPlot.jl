module PlutoVTKPlot
using Pluto
using PlutoCanvasPlot
using UUIDs
using Colors
using ColorSchemes

loadvtk()=error("Deprecated: loadvtk() is now called automatically when you render a plot, you can delete this cell.")

mutable struct VTKPlot
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64
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


function triplot!(p::VTKPlot,pts, tris,f)
    pfx=command!(p,"triplot")
    p.jsdict[pfx*"_points"]=vec(vcat(pts,f'))

    # we need to set up  the triangle data for vtk. 
    # Coding is  [3, i1, i2, i3,   3, i1, i2, i3]
    # Careful: js indexing counts from zero
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
    p.jsdict[pfx*"_polys"]=polys
    p.jsdict[pfx*"_cam"]="3D"
    p
end

function tricolor!(p::VTKPlot,pts, tris,f;cmap=:summer)
    pfx=command!(p,"tricolor")
    (fmin,fmax)=extrema(f)
    p.jsdict[pfx*"_points"]=vec(vcat(pts,zeros(length(f))'))
                                
    # we need to set up  the triangle data for vtk. 
    # Coding is  [3, i1, i2, i3,   3, i1, i2, i3]
    # Careful: js indexing counts from zero
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
    p.jsdict[pfx*"_polys"]=polys
    cscheme=colorschemes[cmap]
    p.jsdict[pfx*"_colors"]=collect(reinterpret(Float64,map(x->get(cscheme,(x-fmin)/(fmax-fmin)),f)))
    p.jsdict[pfx*"_cam"]="2D"
    p
end



function axis3d!(p::VTKPlot;
                 xtics=0:1,
                 ytics=0:1,
                 ztics=0:1)
    pfx=command!(p,"axis3d")
    p.jsdict[pfx*"_bounds"]=[extrema(xtics)..., extrema(ytics)...,extrema(ztics)...]
    p.jsdict[pfx*"_cam"]= ztics[1]==ztics[end] ? "2D" : "3D"

    p
end

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
    vtkplot("$(p.uuid)",jsdict)        
    </script>
    <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px;"></div>
    """
    write(io,result)
end



export loadvtk, VTKPlot,triplot!,tricolor!, axis3d!, axis2d!
end # module
