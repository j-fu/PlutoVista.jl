"""
$(TYPEDEF)

Structure containing plot information for Plotly.js
"""
mutable struct PlutoPlotlyPlot  <: AbstractPlutoVistaBackend

    # command list passed to javascript
    jsdict::Dict{String,Any}
    args
    
    # size in canvas coordinates
    w::Float64
    h::Float64

    update::Bool
    # uuid for identifying html element
    uuid::UUID
    PlutoPlotlyPlot(::Nothing)=new()
end

"""
$(TYPEDSIGNATURES)

Create a plotly plot.


"""
function PlutoPlotlyPlot(;resolution=(300,300), kwargs...)
    p=PlutoPlotlyPlot(nothing)
    p.uuid=uuid1()
    p.jsdict=Dict{String,Any}("cmdcount" => 0)
    p.w=resolution[1]
    p.h=resolution[2]
    default_args=(limits=(1,-1),
                  xlimits=(1,-1),
                  xlabel="",
                  ylabel="",
                  title="",
                  xscale=:linear,
                  yscale=:linear,
                  legend=:none,
                  titlefontsize=12,
                  axisfontsize=10,
                  tickfontsize=10,
                  legendfontsize=10,
                  colorbarticks=:default,
                  clear=false)
    p.args=merge(default_args,kwargs)
    p.update=false
    p
end



const plutoplotlyplot = read(joinpath(@__DIR__, "..", "assets", "plutoplotlyplot.js"), String)

"""
$(TYPEDSIGNATURES)

Show plotly plot.
"""
function Base.show(io::IO, ::Union{MIME"text/html", MIME"juliavscode/html"}, p::PlutoPlotlyPlot)
    result="""
        <script type="text/javascript" src="https://cdn.plot.ly/plotly-2.10.0.min.js"></script>
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
        <div id="$(p.uuid)" style= "width: $(p.w)px; height: $(p.h)px; ; display: inline-block;style="white-space:nowrap;"></div>
        """
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


function axisargs!(p,args)
    xscale= args[:xscale]==:identity ? :linear :  args[:xscale]
    yscale= args[:yscale]==:identity ? :linear :  args[:yscale]


    parameter!(p,"ylimits",collect(Float32,args[:limits]))
    parameter!(p,"xlimits",collect(Float32,args[:xlimits]))
    parameter!(p,"xlabel",args[:xlabel])
    parameter!(p,"ylabel",args[:ylabel])
    parameter!(p,"xaxis",String(xscale))
    parameter!(p,"yaxis",String(yscale))
    parameter!(p,"title",args[:title])
    parameter!(p,"legendfontsize",args[:legendfontsize])
    parameter!(p,"axisfontsize"   ,args[:axisfontsize])  
    parameter!(p,"titlefontsize"  ,args[:titlefontsize]) 
    parameter!(p,"tickfontsize"   ,args[:tickfontsize])   
end

"""
$(SIGNATURES)

1D plotly.js plot
"""
function plot!(p::PlutoPlotlyPlot,x,y; kwargs...)

    default_args=(label="",
                  color=:auto,
                  linewidth=2,
                  linestyle=:solid,
                  markersize=6,
                  markercount=10,
                  markertype=:none)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)


    
    if args[:clear]
        reset!(p)
    end


    
    command!(p,"plot")
    parameter!(p,"x",collect(x))
    parameter!(p,"y",collect(y))
    parameter!(p,"label",args[:label])
    parameter!(p,"linewidth",args[:linewidth])
    parameter!(p,"markercount",args[:markercount])
    parameter!(p,"markertype",mshapes[args[:markertype]])
    parameter!(p,"markersize",args[:markersize])
    parameter!(p,"linestyle",String(args[:linestyle]))

    axisargs!(p,args)
    
    if args[:legend]==:none || args[:legend]==""
        parameter!(p,"showlegend",0)
    else
        parameter!(p,"showlegend",1)
        slegend=String(args[:legend])
        parameter!(p,"legendxpos",slegend[1:1])
        parameter!(p,"legendypos",slegend[2:2])
    end
    
    parameter!(p,"clear",args[:clear] ? 1 : 0)
   
    
    if args[:color] == :auto
        parameter!(p,"color","auto")
    else
        rgb=RGB(args[:color])
        rgb=[rgb.r,rgb.g,rgb.b]
        rgb=UInt8.(floor.(rgb*255))
        parameter!(p,"color",rgb)
    end
    p
end


"""
$(SIGNATURES)

Experimental. Plot piecewise linear function on  triangular grid given as "heatmap" and
with isolines using Plotly's mesh3d.
"""
function tricontour!(p::PlutoPlotlyPlot,pts, tris,f;kwargs...)
    reset!(p)

    default_args=(colormap=:viridis, levels=0, aspect=1)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)
    
    
    
    levels,crange,colorbarticks=makeisolevels(f,
                                              args[:levels],
                                              args[:limits] == :auto ? (1,-1) : args[:limits] ,
                                              args[:colorbarticks]== :default ? nothing : args[:colorbarticks])
    
    zval=0.0
    
    command!(p,"tricontour")
    (fmin,fmax)=extrema(f)
    
    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",fill(zval,length(f)))
    parameter!(p,"f",f)
    parameter!(p,"aspect",[1.0,args[:aspect],1.0])
    
    axisargs!(p,args)
    
    stops=collect(0:0.01:1)
    rgb=reinterpret(Float64,get(colorschemes[args[:colormap]],stops,(0,1)))
    rgb=UInt8.(floor.(rgb*255))

    parameter!(p,"cstops",stops)
    parameter!(p,"colors",rgb)
    parameter!(p,"colorbarticks",colorbarticks)
    
    
    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)


    (fmin,fmax)=extrema(f)
    if levels==0
        parameter!(p,"iso_x","none")
        parameter!(p,"iso_y","none")
        parameter!(p,"iso_z","none")
    else
        iso_pts0=marching_triangles(pts,tris,f,levels)
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
$(SIGNATURES)

Experimental. Plot heatmap and isolines on rectangular grid defined by X and Y
using Plotly's native contour plot.
"""
function contour!(p::PlutoPlotlyPlot,X,Y,f; kwargs...)
    reset!(p)
    default_args=(colormap=:viridis, isolines=11,  aspect=1)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)

    isolines=args[:isolines]
    colormap=args[:colormap]

    limits=args.limits


    command!(p,"contour")
    parameter!(p,"x",collect(X))
    parameter!(p,"y",collect(Y))
    parameter!(p,"z",vec(f))
    stops=collect(0:0.01:1)
    rgb=reinterpret(Float64,get(colorschemes[colormap],stops,(0,1)))
    rgb=UInt8.(floor.(rgb*255))
    parameter!(p,"cstops",stops)
    parameter!(p,"colors",rgb)
    parameter!(p,"aspect",[1.0,args[:aspect],1.0])

    axisargs!(p,args)

    
    if limits[1]>limits[2]
        if isa(isolines,Number)
            (fmin,fmax)=extrema(f)
        else
            (fmin,fmax)=extrema(isolines)
        end
    else
        (fmin,fmax)=limits
    end
    if isa(isolines,Number)
        niso=max(2,isolines)
    else
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
$(SIGNATURES)

Experimental. Plot piecewise linear function on  triangular grid given by points and triangles
as matrices
"""
function triplot!(p::PlutoPlotlyPlot,pts, tris,f; kwargs...)
    reset!(p)
    default_args=(colormap=:viridis, isolines=11,  aspect=1)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)
    axisargs!(p,args)


    command!(p,"triplot")

    parameter!(p,"x",pts[1,:])
    parameter!(p,"y",pts[2,:])
    parameter!(p,"z",f)

    parameter!(p,"i",tris[1,:].-1)
    parameter!(p,"j",tris[2,:].-1)
    parameter!(p,"k",tris[3,:].-1)
end

function triupdate!(p::PlutoPlotlyPlot,pts,tris,f; kwargs...)
    reset!(p)
    default_args=(colormap=:viridis, isolines=11,  aspect=1)
    args=merge(p.args,default_args)
    args=merge(args,kwargs)
    axisargs!(p,args)

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









