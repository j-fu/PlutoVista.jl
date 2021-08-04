"""
Structure containig plot information. 
In particular it contains dict of data sent to javascript.
"""
mutable struct PlutoPlotlyPlot  <: AbstractPlutoVistaBackend
    # command list passed to javascript
    jsdict::Dict{String,Any}

    # size in canvas coordinates
    w::Float64
    h::Float64

    update::Bool
    # uuid for identifying html element
    uuid::UUID
    PlutoPlotlyPlot(::Nothing)=new()
end

"""
````
 PlutoPlotlyPlot(;resolution=(300,300))
````

Create a plotly plot with given resolution in the notebook
"""
function PlutoPlotlyPlot(;resolution=(300,300), kwargs...)
    p=PlutoPlotlyPlot(nothing)
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
function Base.show(io::IO, ::MIME"text/html", p::PlutoPlotlyPlot)
    plutoplotlyplot = read(joinpath(@__DIR__, "..", "assets", "plutoplotlyplot.js"), String)
    result="""
        <script type="text/javascript" src="https://cdn.plot.ly/plotly-1.58.4.min.js"></script>
        <script>
        $(plutoplotlyplot)
        var jsdict = $(Main.PlutoRunner.publish_to_js(p.jsdict))
        plutoplotlyplot("$(p.uuid)",jsdict,$(p.w), $(p.h))        
        </script>
        """
    # updating only works when the div remains as output from another cell
    # so we can't create a plot and update it in the cell with the draing commands
    if !p.update
        result=result*"""
        <p>
        <div style="white-space:nowrap;">
        <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px; ; display: inline-block; "></div>
        </div>
        </p>"""
    end
    p.update=true
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


function plot!(p::PlutoPlotlyPlot,x,y;
               label="",
               color=:auto,
               linewidth=2,
               linestyle=:solid,
               markersize=6,
               markercount=10,
               markertype=:none,
               ylimits=(1,-1),
               xlimits=(1,-1),
               xlabel="",
               ylabel="",
               title="",
               legend=:none,
               clear=false)


    if clear
        p.jsdict=Dict{String,Any}("cmdcount" => 0)
    end
    
    command!(p,"plot")
    parameter!(p,"x",collect(x))
    parameter!(p,"y",collect(y))
    parameter!(p,"label",label)
    parameter!(p,"linewidth",linewidth)
    parameter!(p,"markercount",markercount)
    parameter!(p,"markertype",mshapes[markertype])
    parameter!(p,"markersize",markersize)
    parameter!(p,"linestyle",String(linestyle))
    parameter!(p,"ylimits",collect(Float32,ylimits))
    parameter!(p,"xlimits",collect(Float32,xlimits))
    parameter!(p,"xlabel",xlabel)
    parameter!(p,"ylabel",ylabel)
    parameter!(p,"title",title)

    parameter!(p,"showlegend",legend == :none ? 0 : 1)

    slegend=String(legend)
    parameter!(p,"legendxpos",slegend[1:1])
    parameter!(p,"legendypos",slegend[2:2])

    parameter!(p,"clear",clear ? 1 : 0)
   
    
    if color == :auto
        parameter!(p,"color","auto")
    else
        rgb=RGB(color)
        rgb=[rgb.r,rgb.g,rgb.b]
        rgb=UInt8.(floor.(rgb*255))
        parameter!(p,"color",rgb)
    end
end


"""
     tricontour!(p::PlutoPlotlyPlot,pts, tris,f; colormap, isolines)

Plot piecewise linear function on  triangular grid given as "heatmap" and
with isolines using Plotly's mesh3d.
"""
function tricontour!(p::PlutoPlotlyPlot,pts, tris,f;colormap=:viridis, isolines=0, kwargs...)
    zval=0.0
    p.jsdict=Dict{String,Any}("cmdcount" => 0)

    command!(p,"tricontour")
    (fmin,fmax)=extrema(f)

    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",fill(zval,length(f)))
    parameter!(p,"f",f)

    
    stops=collect(0:0.01:1)
    rgb=reinterpret(Float64,get(colorschemes[colormap],stops,(0,1)))
    rgb=UInt8.(floor.(rgb*255))

    parameter!(p,"cstops",stops)
    parameter!(p,"colors",rgb)
    
    
    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)


    (fmin,fmax)=extrema(f)

    if isolines==0
        parameter!(p,"iso_x","none")
        parameter!(p,"iso_y","none")
        parameter!(p,"iso_z","none")
    else
        if isa(isolines,Number)
            xisolines=range(fmin,fmax,length=isolines)
        else
            xisolines=isolines
        end
        iso_pts0=GridVisualize.marching_triangles(pts,tris,f,xisolines)
        niso_pts=length(iso_pts0)
        iso_pts=vcat(reshape(reinterpret(Float32,iso_pts0),(2,niso_pts)))

        iso_x=Float32[]
        iso_y=Float32[]
        iso_z=Float32[]
        ipt=0
        for i=1:niso_pts//2
            push!(iso_x,iso_pts[1,ipt+1])
            push!(iso_x,iso_pts[1,ipt+2])
            push!(iso_x,NaN32)
            push!(iso_y,iso_pts[2,ipt+1])
            push!(iso_y,iso_pts[2,ipt+2])
            push!(iso_y,NaN32)
            push!(iso_z,zval)
            push!(iso_z,zval)
            push!(iso_z,NaN32)
            ipt+=2
        end
        parameter!(p,"iso_x",iso_x)
        parameter!(p,"iso_y",iso_y)
        parameter!(p,"iso_z",iso_z)
    end

end


"""
     contour!(p::PlutoPlotlyPlot, X, Y,f; colormap, isolines)

Plot heatmap and isolines on rectangular grid defined by X and Y
using Plotly's native contour plot.
"""
function contour!(p::PlutoPlotlyPlot,X,Y,f; colormap=:viridis, isolines=0 , kwargs...)
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    command!(p,"contour")
    parameter!(p,"x",collect(X))
    parameter!(p,"y",collect(Y))
    parameter!(p,"z",vec(f))
    stops=collect(0:0.01:1)
    rgb=reinterpret(Float64,get(colorschemes[colormap],stops,(0,1)))
    rgb=UInt8.(floor.(rgb*255))
    parameter!(p,"cstops",stops)
    parameter!(p,"colors",rgb)

    if isa(isolines,Number)
        (fmin,fmax)=extrema(f)
        niso=max(2,isolines)
    else
        (fmin,fmax)=extrema(isolines)
        niso=length(isolines)
    end        
    parameter!(p,"costart",fmin)
    parameter!(p,"coend",fmax)
    parameter!(p,"cosize",(fmax-fmin)/(niso-1))
    p
end


###############################################################
# Experimental part
# It turns out that plotly is significantly slower
# than VTK for 3D data. 

"""
     triplot!(p::PlutoPlotlyPlot,pts, tris,f)

Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::PlutoPlotlyPlot,pts, tris,f)
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    command!(p,"triplot")

    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",f)

    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)
end

function triupdate!(p::PlutoPlotlyPlot,pts,tris,f)
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    command!(p,"triupdate")

    # make 3D points from 2D points by adding function value as
    # z coordinate
    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",f)

    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)
end









