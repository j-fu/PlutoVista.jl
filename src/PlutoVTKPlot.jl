module PlutoVTKPlot
using Pluto
using PlutoCanvasPlot
using UUIDs

loadvtk()=HTML("""<script type="text/javascript" src="https://unpkg.com/vtk.js"></script>""")


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
    p.jsdict["points"]=vec(vec(vcat(pts,f')))
    p.jsdict["tris"]= vec(tris)
    p
end

"""
Show plot
"""
function Base.show(io::IO, ::MIME"text/html", p::VTKPlot)
    vtkplot = read(joinpath(@__DIR__, "..", "assets", "vtkplot.js"), String)
    result="""
    <script>
    $(vtkplot)
    const jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
    vtkplot("$(p.uuid)",jsdict)        
    </script>
    <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px;"></div>
    """
    write(io,result)
end



export loadvtk, VTKPlot,triplot!
end # module
